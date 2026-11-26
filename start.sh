
#!/usr/bin/env bash
set -Eeuo pipefail

# Start FastAPI backend
uv run uvicorn main:app --host 0.0.0.0 --port 8000 &
backend_pid=$!

# Start Streamlit frontend
uv run streamlit run app.py \
    --server.address 0.0.0.0 \
    --server.port "${PORT:-8501}" \
    --server.headless true &
frontend_pid=$!

cleanup() {
    kill "$backend_pid" "$frontend_pid" 2>/dev/null || true
    wait 2>/dev/null || true
}

trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

# Exit when either process exits
wait -n "$backend_pid" "$frontend_pid"
