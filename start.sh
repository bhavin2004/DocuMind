
#!/usr/bin/env bash
set -Eeuo pipefail

# FastAPI backend
uv run uvicorn main:app --host 0.0.0.0 --port 8000 &
backend_pid=$!

# Streamlit frontend
uv run streamlit run app.py \
    --server.address 0.0.0.0 \
    --server.port 8501 \
    --server.headless true &
frontend_pid=$!

cleanup() {
    kill "$backend_pid" "$frontend_pid" 2>/dev/null || true
    wait 2>/dev/null || true
}

trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

wait -n "$backend_pid" "$frontend_pid"
