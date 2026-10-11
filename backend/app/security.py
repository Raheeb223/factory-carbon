"""Abuse controls: shared app token, per-IP rate limiting, daily Gemini call cap.

All state is in-process memory. With several container instances each instance has
its own counters, so deploy with max-instances=1 (see README) for the cap to hold.
"""

from __future__ import annotations

import hmac
import threading
import time
from collections import deque
from collections.abc import Callable
from datetime import UTC, date, datetime

from fastapi import Request

from app.settings import Settings


class ApiError(Exception):
    """An error returned to the client as `{"error": {"code", "message"}}`."""

    def __init__(self, status_code: int, code: str, message: str, headers: dict[str, str] | None = None) -> None:
        super().__init__(message)
        self.status_code = status_code
        self.code = code
        self.message = message
        self.headers = headers


def check_app_token(settings: Settings, provided: str | None) -> None:
    expected = settings.app_token.get_secret_value() if settings.app_token else ""
    if not expected:
        raise ApiError(503, "server_misconfigured", "The server has no APP_TOKEN configured.")
    if not provided or not hmac.compare_digest(provided.encode(), expected.encode()):
        raise ApiError(401, "invalid_app_token", "Missing or invalid X-App-Token header.")


def client_ip(request: Request, trust_proxy_headers: bool) -> str:
    if trust_proxy_headers:
        forwarded = request.headers.get("x-forwarded-for")
        if forwarded:
            return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


class RateLimiter:
    """Sliding-window limiter: at most `limit` hits per `window_s` per key."""

    def __init__(self, limit: int, window_s: float = 60.0, clock: Callable[[], float] = time.monotonic) -> None:
        self.limit = limit
        self.window_s = window_s
        self._clock = clock
        self._hits: dict[str, deque[float]] = {}
        self._lock = threading.Lock()

    def hit(self, key: str) -> float | None:
        """Record a hit. Returns None if allowed, else seconds until a slot frees up."""
        now = self._clock()
        with self._lock:
            q = self._hits.setdefault(key, deque())
            while q and now - q[0] >= self.window_s:
                q.popleft()
            if len(q) >= self.limit:
                return max(0.0, self.window_s - (now - q[0]))
            q.append(now)
            if len(self._hits) > 10_000:
                self._evict(now)
            return None

    def _evict(self, now: float) -> None:
        stale = [k for k, q in self._hits.items() if not q or now - q[-1] >= self.window_s]
        for k in stale:
            del self._hits[k]


class DailyCap:
    """Counts calls per UTC day and refuses once `cap` is reached."""

    def __init__(self, cap: int, today: Callable[[], date] = lambda: datetime.now(UTC).date()) -> None:
        self.cap = cap
        self._today = today
        self._day = today()
        self._count = 0
        self._lock = threading.Lock()

    def try_acquire(self) -> bool:
        with self._lock:
            day = self._today()
            if day != self._day:
                self._day, self._count = day, 0
            if self._count >= self.cap:
                return False
            self._count += 1
            return True

    @property
    def used_today(self) -> int:
        with self._lock:
            return self._count if self._today() == self._day else 0
