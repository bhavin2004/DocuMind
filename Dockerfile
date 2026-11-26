FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:0.8.23 /uv /uvx /bin/
WORKDIR /app

ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

COPY . .
ENV PATH="/app/.venv/bin:$PATH" API_BASE_URL="http://127.0.0.1:8000"
EXPOSE 8000 8501
CMD ["bash", "start.sh"]
