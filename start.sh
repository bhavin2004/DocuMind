#!/usr/bin/env bash
set -e

uvicorn main:app --host 0.0.0.0 --port 8000 &
backend_pid=$!
streamlit run app.py --server.address 0.0.0.0 --server.port "${PORT:-8501}" --server.headless true &
frontend_pid=$!

trap 'kill "$backend_pid" "$frontend_pid" 2>/dev/null || true' EXIT
trap 'exit 143' TERM INT
wait -n "$backend_pid" "$frontend_pid"
