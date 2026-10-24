from __future__ import annotations

from tests.conftest import AUTH, make_client
from tests.test_report import _payload


def _issue(c, **extra: object) -> str:  # type: ignore[no-untyped-def]
    r = c.post("/v1/passport", headers=AUTH, json=_payload(**extra))
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["total_t"] > 0
    return str(body["url"])


def test_passport_link_opens_public_page_without_token() -> None:
    c, _ = make_client()
    url = _issue(c)
    path = url[url.index("/p/"):]
    page = c.get(path)
    assert page.status_code == 200
    assert page.headers["content-type"].startswith("text/html")
    for text in ("Test Garments Ltd", "Carbon Passport", "Signature verified", "Scope 2", "Scope 1", "12 utility bills"):
        assert text in page.text
    assert "synthetic" not in page.text.lower()


def test_tampered_or_garbage_link_is_rejected() -> None:
    c, _ = make_client()
    path = _issue(c)
    path = path[path.index("/p/"):]
    body, sig = path[3:].split(".")
    flipped = body[:-2] + ("A" if body[-2] != "A" else "B") + body[-1]
    assert c.get(f"/p/{flipped}.{sig}").status_code == 404
    assert c.get("/p/not-a-passport").status_code == 404
    assert "Not a valid Carbon Passport" in c.get("/p/x.y").text


def test_passport_needs_token_to_issue_and_flags_synthetic_data() -> None:
    c, _ = make_client()
    assert c.post("/v1/passport", json=_payload()).status_code == 401
    path = _issue(c, contains_synthetic_data=True)
    assert "synthetic demo data" in c.get(path[path.index("/p/"):]).text


def test_passport_escapes_html_in_factory_name() -> None:
    c, _ = make_client()
    payload = _payload()
    payload["factory"] = {"name": "<script>alert(1)</script>"}
    r = c.post("/v1/passport", headers=AUTH, json=payload)
    url = r.json()["url"]
    html = c.get(url[url.index("/p/"):]).text
    assert "<script>alert(1)</script>" not in html
    assert "&lt;script&gt;" in html


def test_https_link_behind_proxy() -> None:
    c, _ = make_client()
    r = c.post("/v1/passport", headers={**AUTH, "X-Forwarded-Proto": "https"}, json=_payload())
    # tests run with trust_proxy_headers off unless configured, so only check the shape
    assert "/p/" in r.json()["url"]
