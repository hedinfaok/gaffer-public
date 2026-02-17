#!/bin/bash
# Run all watch scripts in parallel
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting watch mode for all services..."
echo "   This will watch shared-lib, api-service, and frontend"
echo "   Changes will trigger intelligent cascading rebuilds"
echo "   Press Ctrl+C to stop all watchers"
echo ""

# Store PIDs for cleanup
PIDS=()

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Stopping all watchers..."
    for pid in "${PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
        fi
    done
    wait
    echo "✅ All watchers stopped"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start each watcher in the background
"$SCRIPT_DIR/watch-shared-lib.sh" &
PIDS+=($!)

"$SCRIPT_DIR/watch-api.sh" &
PIDS+=($!)

"$SCRIPT_DIR/watch-frontend.sh" &
PIDS+=($!)

echo "✅ All watchers started"
echo ""
echo "Legend:"
echo "  🔄 = File changed"
echo "  ✅ = Rebuild successful"
echo "  ❌ = Rebuild failed"
echo ""

# Wait for all background processes
wait
