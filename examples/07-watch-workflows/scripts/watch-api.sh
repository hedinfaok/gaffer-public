#!/bin/bash
# Watch api-service for changes and trigger rebuilds
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "👀 Watching api-service for changes..."
echo "   Source: api-service/src/"
echo "   Trigger: gaffer-exec run rebuild-api"
echo "   Note: Changes to shared-lib will trigger this automatically"
echo ""

# Cleanup on exit
trap 'echo ""; echo "🛑 Stopping api-service watch..."; exit 0' SIGINT SIGTERM

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo "❌ Error: fswatch is not installed"
    echo "   Install with: brew install fswatch (macOS) or apt-get install fswatch (Linux)"
    exit 1
fi

# Watch TypeScript files in api-service with debouncing
fswatch \
  --latency 0.5 \
  --exclude '.*' \
  --include '\.ts$' \
  --include '\.json$' \
  --exclude 'node_modules' \
  --exclude 'dist' \
  --recursive \
  "$WORKSPACE_ROOT/api-service/src" \
  "$WORKSPACE_ROOT/api-service/package.json" \
  "$WORKSPACE_ROOT/api-service/tsconfig.json" | while read -r file; do
    RELATIVE_FILE="${file#$WORKSPACE_ROOT/}"
    echo ""
    echo "🔄 Changed: $RELATIVE_FILE"
    echo "   Running: gaffer-exec run rebuild-api"
    
    cd "$WORKSPACE_ROOT"
    if gaffer-exec --graph graph.json run rebuild-api; then
        echo "✅ Rebuild complete"
    else
        echo "❌ Rebuild failed"
    fi
done
