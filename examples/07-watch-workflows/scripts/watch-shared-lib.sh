#!/bin/bash
# Watch shared-lib for changes and trigger rebuilds
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "👀 Watching shared-lib for changes..."
echo "   Source: shared-lib/src/"
echo "   Trigger: gaffer-exec run rebuild-shared-lib"
echo "   Cascades: Will also rebuild api-service and frontend"
echo ""

# Cleanup on exit
trap 'echo ""; echo "🛑 Stopping shared-lib watch..."; exit 0' SIGINT SIGTERM

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo "❌ Error: fswatch is not installed"
    echo "   Install with: brew install fswatch (macOS) or apt-get install fswatch (Linux)"
    exit 1
fi

# Watch TypeScript files in shared-lib with debouncing
fswatch \
  --latency 0.5 \
  --exclude '.*' \
  --include '\.ts$' \
  --include '\.json$' \
  --exclude 'node_modules' \
  --exclude 'dist' \
  --recursive \
  "$WORKSPACE_ROOT/shared-lib/src" \
  "$WORKSPACE_ROOT/shared-lib/package.json" \
  "$WORKSPACE_ROOT/shared-lib/tsconfig.json" | while read -r file; do
    RELATIVE_FILE="${file#$WORKSPACE_ROOT/}"
    echo ""
    echo "🔄 Changed: $RELATIVE_FILE"
    echo "   Running: gaffer-exec run rebuild-shared-lib"
    
    cd "$WORKSPACE_ROOT"
    if gaffer-exec --graph graph.json run rebuild-shared-lib; then
        echo "✅ Rebuild complete"
    else
        echo "❌ Rebuild failed"
    fi
done
