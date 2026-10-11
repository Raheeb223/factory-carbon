"""Upload checks: size limit and MIME validation by file signature (magic bytes)."""

from __future__ import annotations

from fastapi import UploadFile

from app.security import ApiError

_SIGNATURES: tuple[tuple[bytes, str], ...] = (
    (b"\x89PNG\r\n\x1a\n", "image/png"),
    (b"\xff\xd8\xff", "image/jpeg"),
    (b"%PDF-", "application/pdf"),
)
ALLOWED_DECLARED = {"image/png", "image/jpeg", "image/jpg", "application/pdf", "application/octet-stream"}
_CHUNK = 64 * 1024


def sniff_mime(data: bytes) -> str | None:
    for sig, mime in _SIGNATURES:
        if data.startswith(sig):
            return mime
    return None


async def read_limited(upload: UploadFile, max_bytes: int) -> bytes:
    """Read the upload into memory, failing fast once it exceeds `max_bytes`."""
    buf = bytearray()
    while chunk := await upload.read(_CHUNK):
        buf.extend(chunk)
        if len(buf) > max_bytes:
            raise ApiError(413, "file_too_large", f"File is larger than {max_bytes // (1024 * 1024)} MB.")
    return bytes(buf)


def validate_image(data: bytes, declared_type: str | None) -> str:
    """Return the detected MIME type or raise ApiError."""
    if not data:
        raise ApiError(400, "empty_file", "The uploaded file is empty.")
    if declared_type and declared_type.split(";")[0].strip().lower() not in ALLOWED_DECLARED:
        raise ApiError(415, "unsupported_media_type", "Upload a PNG, JPEG or PDF file.")
    mime = sniff_mime(data)
    if mime is None:
        raise ApiError(415, "unsupported_media_type", "File content is not a PNG, JPEG or PDF.")
    return mime
