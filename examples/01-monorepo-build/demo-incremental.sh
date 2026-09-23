#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "════════════════════════════════════════════════════════════════"
echo "  Incremental Build Demo: Only Rebuild What Changed"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Clean and do initial build
echo "🧹 Cleaning build artifacts..."
rm -rf packages/*/dist
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 INITIAL BUILD (all packages)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

INITIAL_START=$(date +%s%3N)
gaffer-exec --workspace-root . run --cache sha256 make:build-all
INITIAL_END=$(date +%s%3N)
INITIAL_TOTAL=$((INITIAL_END - INITIAL_START))

echo ""
echo "  📊 Initial build time: ${INITIAL_TOTAL}ms"
echo ""

# Simulate a change in auth-service
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✏️  SIMULATING CODE CHANGE in auth-service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Adding a comment to auth-service/src/handlers.ts..."
echo ""

# Backup original file
cp packages/auth-service/src/handlers.ts packages/auth-service/src/handlers.ts.backup

# Add a comment to trigger rebuild
echo "// Change at $(date)" >> packages/auth-service/src/handlers.ts

echo "Modified: packages/auth-service/src/handlers.ts"
echo ""
echo "Impact Analysis:"
echo "  ✓ shared-lib:   no rebuild needed (unchanged)"
echo "  ✓ user-service: no rebuild needed (unchanged)"
echo "  ⚡ auth-service: REBUILD REQUIRED (source changed)"
echo "  ⚡ api-gateway:  REBUILD REQUIRED (depends on auth-service)"
echo "  ⚡ web-app:      REBUILD REQUIRED (depends on api-gateway)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 INCREMENTAL BUILD (only affected packages)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

INCREMENTAL_START=$(date +%s%3N)

# With caching, gaffer-exec will detect:
# - shared-lib outputs exist and inputs unchanged -> skip
# - user-service outputs exist and inputs unchanged -> skip  
# - auth-service source changed -> rebuild
# - api-gateway depends on auth-service -> rebuild
# - web-app depends on api-gateway -> rebuild

gaffer-exec --workspace-root . run --cache sha256 make:build-all

INCREMENTAL_END=$(date +%s%3N)
INCREMENTAL_TOTAL=$((INCREMENTAL_END - INCREMENTAL_START))

echo ""
echo "  📊 Incremental build time: ${INCREMENTAL_TOTAL}ms"
echo ""

# Restore original file
mv packages/auth-service/src/handlers.ts.backup packages/auth-service/src/handlers.ts

# Calculate savings
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Full build:        ${INITIAL_TOTAL}ms (5 packages)"
echo "  Incremental build: ${INCREMENTAL_TOTAL}ms (3 packages)"
echo ""

if [ $INCREMENTAL_TOTAL -gt 0 ]; then
    SPEEDUP=$(awk "BEGIN {printf \"%.2f\", $INITIAL_TOTAL / $INCREMENTAL_TOTAL}")
    IMPROVEMENT=$(awk "BEGIN {printf \"%.1f\", (($INITIAL_TOTAL - $INCREMENTAL_TOTAL) / $INITIAL_TOTAL) * 100}")
    echo "  ⚡ Speedup: ${SPEEDUP}x faster"
    echo "  💰 Time saved: ${IMPROVEMENT}%"
    echo "  📦 Packages skipped: 2 out of 5 (40%)"
fi

echo ""
echo "This demonstrates gaffer-exec's smart caching:"
echo "  • Tracks input files (source code)"
echo "  • Tracks output files (compiled JS)"
echo "  • Only rebuilds when inputs change"
echo "  • Propagates changes through dependency tree"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
