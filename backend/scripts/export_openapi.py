"""Write the OpenAPI contract to ../docs/openapi.json (run from backend/).

    python -m scripts.export_openapi
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

BACKEND = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND))

from app.main import build_services, create_app  # noqa: E402
from app.settings import Settings  # noqa: E402


def main() -> None:
    settings = Settings(_env_file=None, app_token="export", gemini_api_key=None, gemini_model=None)  # type: ignore[call-arg]
    spec = create_app(build_services(settings)).openapi()
    out = BACKEND.parent / "docs" / "openapi.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(spec, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
