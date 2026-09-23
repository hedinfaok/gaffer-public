#!/bin/bash
# Watch frontend for changes and trigger rebuilds
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Watching frontend for changes..."
echo "   Source: frontend/src/"
echo "   Trigger: gaffer-exec --workspace-root . run make:rebuild-frontend"
echo "   Note: Changes to shared-lib will trigger this automatically"
echo ""

# Cleanup on exit
trap 'echo ""; echo "Stopping frontend watch..."; exit 0' SIGINT SIGTERM

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo "✗ Error: fswatch is not installed"
    echo "   Install with: brew install fswatch (macOS) or apt-get install fswatch (Linux)"
    exit 1
fi

# Watch TypeScript/React files in frontend with debouncing
fswatch \
  --latency 0.5 \
  --exclude '.*' \
  --include '\.tsx?$' \
  --include '\.html$' \
  --include '\.json$' \
  --exclude 'node_modules' \
  --exclude 'build' \
  --recursive \
  "$WORKSPACE_ROOT/frontend/src" \
  "$WORKSPACE_ROOT/frontend/package.json" \
  "$WORKSPACE_ROOT/frontend/tsconfig.json" \
  "$WORKSPACE_ROOT/frontend/webpack.config.js" | while read -r file; do
    RELATIVE_FILE="${file#$WORKSPACE_ROOT/}"
    echo ""
    echo "Changed: $RELATIVE_FILE"
    echo "   Running: gaffer-exec --workspace-root . run make:rebuild-frontend"
    
    cd "$WORKSPACE_ROOT"
    if gaffer-exec --workspace-root . run make:rebuild-frontend; then
        echo "✓ Rebuild complete"
    else
        echo "✗ Rebuild failed"
    fi
done
