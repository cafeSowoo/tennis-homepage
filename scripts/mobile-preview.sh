#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${PORT:-8000}"
HOST="${HOST:-0.0.0.0}"

cd "$ROOT_DIR"

echo "Starting tennis homepage preview"
echo "Project: $ROOT_DIR"
echo "Local:   http://127.0.0.1:$PORT"

if command -v tailscale >/dev/null 2>&1; then
  TAILSCALE_IP="$(tailscale ip -4 2>/dev/null | head -n 1 || true)"
  if [ -n "$TAILSCALE_IP" ]; then
    echo "Android: http://$TAILSCALE_IP:$PORT"
  else
    echo "Android: sign in to Tailscale on this Mac, then run: tailscale ip -4"
  fi
else
  echo "Android: install and sign in to Tailscale, then use the MacBook Tailscale IP."
fi

echo
exec python3 -m http.server "$PORT" --bind "$HOST"
