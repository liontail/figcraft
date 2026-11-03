#!/usr/bin/env bash
# start-collab-poc.sh: Starts FigCraft Real-time Collaboration Server & Web UI
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_BIN="$DIR/target-poc/debug/figcraft-server"

# Load .env if present
if [[ -f "$DIR/.env" ]]; then
    echo "📋 Loading environment configuration from .env..."
    set -a
    # shellcheck disable=SC1091
    source "$DIR/.env"
    set +a
fi

echo "=========================================================="
echo " 🎨 FigCraft Web Real-time Collaboration (Multi-cursor POC)"
echo "=========================================================="

if [[ ! -f "$SERVER_BIN" ]]; then
    echo "⚙️ Building figcraft-server..."
    (cd "$DIR" && CARGO_TARGET_DIR=target-poc cargo build -p figcraft-server)
fi

echo "🚀 Starting Collab Relay Server on port 47900..."
"$SERVER_BIN" --config "$DIR/figcraft-server.toml" &
SERVER_PID=$!

cleanup() {
    echo ""
    echo "🛑 Shutting down Collab Relay Server (PID: $SERVER_PID)..."
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
    echo "Done."
}
trap cleanup EXIT INT TERM

echo ""
echo "🌐 Starting Web Application on http://localhost:8767/..."
echo "----------------------------------------------------------"
echo "👉 Instructions for Multi-User Real-time Testing:"
echo " 1. Open Browser Window 1:  http://localhost:8767/"
echo " 2. In Window 1: Click 'Share' (top right) -> 'Start sharing'"
echo " 3. Copy the Join Code (e.g. K7M-2QX-9TD) or Invite Link"
echo " 4. Open Browser Window 2:  http://localhost:8767/#join=<JOIN_CODE>"
echo "    (or enter the code under Share -> Join with a code)"
echo " 5. Both windows will see live multi-cursors, selection outlines,"
echo "    shape editing, and cursor chat (press '/' to chat) in real time!"
echo "----------------------------------------------------------"
echo ""

cd "$DIR/apps/figcraft-web"
CARGO_TARGET_DIR="$DIR/target-poc" exec trunk serve --port 8767
