"""Carbon Passport: a signed, shareable one-page carbon summary opened from a QR code.

The backend stays stateless: the summary itself travels inside the link (compressed JSON +
an HMAC signature), so nothing is stored and any edit to the link breaks the signature.
"""

from __future__ import annotations

import base64
import hashlib
import hmac
import json
import zlib
from datetime import date
from html import escape
from typing import Any

from app.schemas import CarbonCalculateResponse, FactoryInfo, SolarEstimateResponse

VERSION = 1
SIG_BYTES = 16
MAX_TOKEN_CHARS = 2000
CO2_KG_PER_TREE_YEAR = 22.0  # same rule of thumb as the app (co2_explainer.dart)


def passport_key(app_token: str | None, fallback: bytes) -> bytes:
    """Signing key derived from the app token, so links stay valid across restarts."""
    if not app_token:
        return fallback
    return hashlib.sha256(b"billtogreen-passport|" + app_token.encode()).digest()


def _r(v: float | None, nd: int = 2) -> float | None:
    return None if v is None else round(v, nd)


def build_summary(
    factory: FactoryInfo,
    carbon: CarbonCalculateResponse,
    solar: SolarEstimateResponse | None,
    *,
    synthetic: bool,
    bill_count: int,
    issued: date,
) -> dict[str, Any]:
    t = carbon.totals
    months = [[m.month, _r(m.total_t, 3)] for m in carbon.months if m.total_t is not None][-12:]
    s: dict[str, Any] = {
        "v": VERSION,
        "n": factory.name,
        "loc": factory.district or factory.location,
        "ps": carbon.period_start,
        "pe": carbon.period_end,
        "t": _r(t.total_t),
        "s1": _r(t.scope1_t),
        "s2": _r(t.scope2_t),
        "mw": t.months_with_data,
        "mp": t.months_in_period,
        "i": _r(t.intensity_t_per_1000_units, 3),
        "u": carbon.production_unit_label,
        "m": months,
        "b": bill_count,
        "dr": bool(carbon.placeholders_in_use),
        "syn": synthetic,
        "at": issued.isoformat(),
    }
    if solar is not None:
        s["kw"] = _r(solar.kwp, 1)
        s["av"] = _r(solar.co2_avoided_t_per_year)
        s["off"] = _r(solar.offset_share, 3)
        if solar.financials is not None:
            s["sv"] = round(solar.financials.year1_net_bdt)
            s["pb"] = _r(solar.financials.simple_payback_years, 1)
    return {k: v for k, v in s.items() if v is not None}


def _b64(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def _unb64(text: str) -> bytes:
    return base64.urlsafe_b64decode(text + "=" * (-len(text) % 4))


def encode(summary: dict[str, Any], key: bytes) -> str:
    body = _b64(zlib.compress(json.dumps(summary, separators=(",", ":"), ensure_ascii=False).encode(), 9))
    sig = _b64(hmac.new(key, body.encode(), hashlib.sha256).digest()[:SIG_BYTES])
    return f"{body}.{sig}"


def decode(token: str, key: bytes) -> dict[str, Any] | None:
    """The summary if the link is intact and was signed by this server, else None."""
    if len(token) > MAX_TOKEN_CHARS or token.count(".") != 1:
        return None
    body, sig = token.split(".")
    expected = _b64(hmac.new(key, body.encode(), hashlib.sha256).digest()[:SIG_BYTES])
    if not hmac.compare_digest(sig, expected):
        return None
    try:
        data = json.loads(zlib.decompress(_unb64(body), bufsize=64 * 1024))
    except (ValueError, zlib.error):
        return None
    return data if isinstance(data, dict) and data.get("v") == VERSION else None


# ---------------------------------------------------------------- HTML page

_MONTHS = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")


def _month(m: str | None) -> str:
    if not m or len(m) != 7:
        return "–"
    return f"{_MONTHS[int(m[5:7]) - 1]} {m[:4]}"


def _num(v: float | None, nd: int = 0) -> str:
    return "–" if v is None else f"{v:,.{nd}f}"


def _tonnes(v: float | None) -> str:
    return _num(v, 2 if v is not None and abs(v) < 10 else 1)


def _chart(months: list[list[Any]]) -> str:
    vals = [float(v) for _, v in months if v is not None]
    if len(vals) < 2:
        return ""
    top = max(vals) or 1.0
    w, h, gap = 320, 120, 4
    bw = (w - gap * (len(months) - 1)) / len(months)
    bars, labels = [], []
    for i, (m, v) in enumerate(months):
        bh = max(2.0, float(v) / top * (h - 4))
        x = i * (bw + gap)
        bars.append(f'<rect x="{x:.1f}" y="{h - bh:.1f}" width="{bw:.1f}" height="{bh:.1f}" rx="3"><title>{escape(_month(m))}: {_tonnes(v)} t</title></rect>')
        if i in (0, len(months) - 1):
            anchor = "start" if i == 0 else "end"
            labels.append(f'<text x="{x + (0 if i == 0 else bw):.1f}" y="{h + 14}" text-anchor="{anchor}">{escape(_month(m))}</text>')
    return (
        f'<svg class="chart" viewBox="0 -2 {w} {h + 20}" role="img" aria-label="Monthly emissions, last {len(months)} months">'
        f'<g class="bars">{"".join(bars)}</g><g class="axis">{"".join(labels)}</g></svg>'
    )


def render_html(s: dict[str, Any], url: str) -> str:
    name = escape(str(s.get("n", "Factory")))
    loc = escape(str(s["loc"])) if s.get("loc") else ""
    total = s.get("t")
    s1, s2 = s.get("s1") or 0.0, s.get("s2") or 0.0
    split = s1 + s2
    s2pct = round(s2 / split * 100) if split > 0 else 0
    trees = round(total * 1000 / CO2_KG_PER_TREE_YEAR) if total else None
    period = f"{_month(s.get('ps'))} – {_month(s.get('pe'))}"
    coverage = f"{s.get('mw', 0)} of {s.get('mp', 0)} months with data" if s.get("mw") != s.get("mp") else f"{s.get('mw', 0)} months of data"
    intensity = ""
    if s.get("i") is not None:
        unit = escape(str(s.get("u") or "units"))
        intensity = f'<div class="stat"><b>{_num(s["i"], 3)}</b><span>t CO₂e per 1,000 {unit}</span></div>'

    notes = []
    if s.get("syn"):
        notes.append('<div class="flag warn">Includes synthetic demo data — for demonstration only.</div>')
    if s.get("dr"):
        notes.append('<div class="flag warn">Draft: some emission factors are placeholders.</div>')

    solar = ""
    if s.get("kw") is not None:
        rows = [f'<div class="stat"><b>{_num(s["kw"], 1)} kWp</b><span>rooftop solar that fits</span></div>']
        if s.get("av") is not None:
            rows.append(f'<div class="stat"><b>−{_tonnes(s["av"])} t</b><span>CO₂e avoided per year</span></div>')
        if s.get("sv") is not None:
            rows.append(f'<div class="stat"><b>৳{_num(s["sv"])}</b><span>net savings in year 1</span></div>')
        if s.get("pb") is not None:
            rows.append(f'<div class="stat"><b>{_num(s["pb"], 1)} yrs</b><span>simple payback</span></div>')
        solar = f'<section class="card"><h2>☀️ Reduction plan</h2><div class="grid">{"".join(rows)}</div></section>'

    issued = s.get("at", "")
    try:
        issued_text = date.fromisoformat(issued).strftime("%d %b %Y")
    except ValueError:
        issued_text = escape(str(issued))

    return f"""<!doctype html>
<html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{name} · Carbon Passport</title>
<meta name="description" content="Verified carbon summary for {name}, generated by BillToGreen from utility bills.">
<meta property="og:title" content="{name} · Carbon Passport">
<meta property="og:description" content="{_tonnes(total)} t CO₂e · {escape(period)}">
<meta name="robots" content="noindex">
<style>
:root{{--bg:#f3f7f6;--card:#fff;--ink:#0f172a;--mute:#5b6b6a;--line:#dfe8e6;--brand:#0f766e;--s2:#38bdf8;--s1:#f59e0b;--ok:#15803d;--warn:#b45309}}
@media (prefers-color-scheme:dark){{:root{{--bg:#0b1513;--card:#111f1c;--ink:#e6f0ee;--mute:#93a7a3;--line:#21332f;--brand:#2dd4bf;--ok:#4ade80;--warn:#fbbf24}}}}
*{{box-sizing:border-box}}body{{margin:0;background:var(--bg);color:var(--ink);font:15px/1.45 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}}
main{{max-width:520px;margin:0 auto;padding:16px 16px 40px}}
.hero{{background:linear-gradient(135deg,#064e3b,#0f766e 55%,#14b8a6);color:#fff;border-radius:24px;padding:22px 20px;box-shadow:0 10px 30px rgba(6,78,59,.25)}}
.brand{{display:flex;align-items:center;gap:8px;font-weight:700;font-size:13px;letter-spacing:.06em;text-transform:uppercase;opacity:.9}}
.brand i{{width:26px;height:26px;border-radius:8px;background:#fff;display:grid;place-items:center;font-style:normal}}
h1{{margin:14px 0 2px;font-size:24px;line-height:1.2}}.loc{{opacity:.85;font-size:14px}}
.big{{margin-top:18px;font-size:44px;font-weight:900;letter-spacing:-.02em;line-height:1}}.big small{{font-size:20px;font-weight:700}}
.sub{{opacity:.85;font-size:13px;margin-top:6px}}
.split{{display:flex;height:9px;border-radius:9px;overflow:hidden;background:rgba(255,255,255,.25);margin-top:16px}}
.split .a{{background:#bae6fd}}.split .b{{background:#fde68a;flex:1}}
.legend{{display:flex;flex-wrap:wrap;gap:6px 16px;font-size:12.5px;margin-top:8px}}.legend span::before{{content:"";display:inline-block;width:8px;height:8px;border-radius:50%;margin-right:6px;background:var(--c)}}
.badge{{display:flex;gap:10px;align-items:center;margin-top:14px;background:var(--card);border:1px solid var(--line);border-radius:16px;padding:12px 14px}}
.badge b{{color:var(--ok)}}.badge .dot{{width:30px;height:30px;border-radius:50%;background:var(--ok);color:#fff;display:grid;place-items:center;font-weight:900;flex:none}}
.card{{background:var(--card);border:1px solid var(--line);border-radius:20px;padding:16px;margin-top:14px}}
h2{{font-size:16px;margin:0 0 12px}}
.grid{{display:grid;grid-template-columns:1fr 1fr;gap:10px}}
.stat{{border:1px solid var(--line);border-radius:14px;padding:10px 12px}}.stat b{{display:block;font-size:19px}}.stat span{{color:var(--mute);font-size:12.5px}}
.chart{{width:100%;height:auto;display:block}}.chart .bars rect{{fill:var(--brand)}}.chart .axis text{{fill:var(--mute);font-size:11px}}
.flag{{border-radius:12px;padding:10px 12px;margin-top:10px;font-size:13px}}.flag.warn{{background:rgba(245,158,11,.12);color:var(--warn);border:1px solid rgba(245,158,11,.35)}}
footer{{color:var(--mute);font-size:12px;margin-top:18px;text-align:center}}footer a{{color:var(--brand)}}
</style></head>
<body><main>
<section class="hero">
  <div class="brand"><i>🌿</i>BillToGreen · Carbon Passport</div>
  <h1>{name}</h1>{f'<div class="loc">📍 {loc}</div>' if loc else ""}
  <div class="big">{_tonnes(total)} <small>t CO₂e</small></div>
  <div class="sub">{escape(period)} · {escape(coverage)}{f" · ≈ {trees:,} trees for a year to absorb" if trees else ""}</div>
  {f'<div class="split"><div class="a" style="width:{s2pct}%"></div><div class="b"></div></div>' if split > 0 else ""}
  <div class="legend"><span style="--c:#bae6fd">Scope 2 · grid electricity {_tonnes(s.get("s2"))} t</span><span style="--c:#fde68a">Scope 1 · fuels on site {_tonnes(s.get("s1"))} t</span></div>
</section>
<div class="badge"><div class="dot">✓</div><div><b>Signature verified</b><br><span style="color:var(--mute);font-size:13px">Issued {issued_text} · calculated from {s.get("b", 0)} utility bills. Any change to this link breaks the signature.</span></div></div>
{"".join(notes)}
<section class="card"><h2>Monthly emissions</h2>{_chart(s.get("m", [])) or '<p style="color:var(--mute);margin:0">Not enough months yet.</p>'}
  <div class="grid" style="margin-top:12px"><div class="stat"><b>{_tonnes(s.get("s2"))} t</b><span>Scope 2 (electricity)</span></div><div class="stat"><b>{_tonnes(s.get("s1"))} t</b><span>Scope 1 (diesel, gas, LPG, oil)</span></div>{intensity}</div>
</section>
{solar}
<section class="card"><h2>How this was calculated</h2><p style="margin:0;color:var(--mute);font-size:13.5px">GHG Protocol Scope 1 and Scope 2 (location-based). Energy use is read from the factory's utility bills and confirmed by the factory, then multiplied by published emission factors. Self-reported data; not a third-party audit.</p></section>
<footer>Made with BillToGreen — turning utility bills into carbon proof.<br><a href="{escape(url)}">Permanent link</a></footer>
</main></body></html>"""


INVALID_HTML = """<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Carbon Passport · not valid</title><style>body{margin:0;font:16px/1.5 system-ui,sans-serif;background:#f3f7f6;color:#0f172a;display:grid;place-items:center;min-height:100vh;padding:16px}
@media (prefers-color-scheme:dark){body{background:#0b1513;color:#e6f0ee}}div{max-width:420px;text-align:center}</style></head>
<body><div><h1>⚠️ Not a valid Carbon Passport</h1><p>This link is incomplete or was changed after it was issued, so its signature does not match. Ask the factory for a fresh QR code.</p></div></body></html>"""
