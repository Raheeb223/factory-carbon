# Stateless API image. Needs no persistent disk.
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    MPLCONFIGDIR=/tmp/matplotlib \
    PORT=8080

# Latest system CA store (OpenSSL / urllib), so revoked or distrusted CAs are not trusted.
RUN apt-get update && apt-get install -y --no-install-recommends --only-upgrade ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /srv
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app ./app
COPY config ./config

RUN useradd --create-home --uid 10001 api
USER api

# Cloud Run / Render provide $PORT. Access logs contain method, path and status only (no bodies).
CMD ["sh", "-c", "exec uvicorn --factory app.main:create_default_app --host 0.0.0.0 --port ${PORT} --proxy-headers --forwarded-allow-ips='*' --timeout-keep-alive 5"]
