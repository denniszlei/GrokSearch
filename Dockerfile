# syntax=docker/dockerfile:1

FROM ghcr.io/astral-sh/uv:python3.13-alpine AS builder

WORKDIR /app
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

COPY pyproject.toml README.md LICENSE ./
COPY src ./src

RUN uv venv /opt/venv \
    && uv pip install --python /opt/venv/bin/python --no-cache-dir .

FROM python:3.13-alpine

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    HOME=/data \
    MCP_TRANSPORT=streamable-http \
    MCP_HOST=0.0.0.0 \
    MCP_PORT=8000 \
    MCP_PATH=/mcp

RUN adduser -D -u 10001 appuser \
    && mkdir -p /data \
    && chown appuser:appuser /data
COPY --from=builder /opt/venv /opt/venv

USER appuser
VOLUME ["/data"]
EXPOSE 8000

CMD ["grok-search"]
