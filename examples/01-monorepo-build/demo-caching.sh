#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "════════════════════════════════════════════════════════════════"
echo "  Caching Demo: First Build vs Cached Rebuild"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Clean everything
echo "🧹 Cleaning all build artifacts..."
rm -rf packages/*/dist
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 FIRST BUILD (cold cache - nothing cached)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Building all packages from scratch..."
echo ""

FIRST_START=$(date +%s%3N)
gaffer-exec --graph graph.json --workspace-root . run --cache sha256 build-all
FIRST_END=$(date +%s%3N)
FIRST_TOTAL=$((FIRST_END - FIRST_START))

echo ""
echo "  📊 First build time: ${FIRST_TOTAL}ms"
echo "  💾 All outputs cached"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚡ SECOND BUILD (hot cache - everything cached)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Running same build again (no source changes)..."
echo ""

SECOND_START=$(date +%s%3N)
gaffer-exec --graph graph.json --workspace-root . run --cache sha256 build-all
SECOND_END=$(date +%s%3N)
SECOND_TOTAL=$((SECOND_END - SECOND_START))

echo ""
echo "  📊 Cached build time: ${SECOND_TOTAL}ms"
echo "  💾 All tasks skipped (cache hit)"
echo ""

# Clean dist folders but keep gaffer cache
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 THIRD BUILD (outputs deleted, cache intact)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Deleting dist/ folders but keeping gaffer cache..."
rm -rf packages/*/dist
echo ""
echo "This simulates: 'git checkout' or 'npm clean'"
echo "Outputs are gone but gaffer remembers the build results"
echo ""

THIRD_START=$(date +%s%3N)
gaffer-exec --graph graph.json --workspace-root . run --cache sha256 build-all
THIRD_END=$(date +%s%3N)
THIRD_TOTAL=$((THIRD_END - THIRD_START))

echo ""
echo "  📊 Restore from cache: ${THIRD_TOTAL}ms"
echo "  💾 Outputs restored from cache"
echo ""

# Results
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. First build (cold):      ${FIRST_TOTAL}ms"
echo "  2. Second build (hot):      ${SECOND_TOTAL}ms"
echo "  3. Restore from cache:      ${THIRD_TOTAL}ms"
echo ""

if [ $SECOND_TOTAL -gt 0 ]; then
    SPEEDUP=$(awk "BEGIN {printf \"%.2f\", $FIRST_TOTAL / $SECOND_TOTAL}")
    echo "  ⚡ Cache speedup: ${SPEEDUP}x faster"
fi

echo ""
echo "Key Benefits:"
echo "  ✓ First build computes and caches results"
echo "  ✓ Subsequent builds skip unchanged tasks instantly"
echo "  ✓ Can restore outputs even if deleted (CI/CD use case)"
echo "  ✓ Works across git branches and checkouts"
echo ""
echo "This is especially valuable in:"
echo "  • CI/CD pipelines (share cache across builds)"
echo "  • Large monorepos (skip most rebuilds)"
echo "  • Team development (shared remote cache)"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
