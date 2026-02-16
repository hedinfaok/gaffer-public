#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "════════════════════════════════════════════════════════════════"
echo "  Parallel Build Demo: gaffer-exec vs Sequential npm Scripts"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Clean first
echo "🧹 Cleaning build artifacts..."
rm -rf packages/*/dist
echo ""

# Sequential build simulation (npm workspaces style)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏱️  SEQUENTIAL BUILD (like 'npm run build --workspaces')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SEQUENTIAL_START=$(date +%s%3N)

echo "Building shared-lib..."
npx tsc -p packages/shared-lib/tsconfig.json
SEQUENTIAL_SHARED=$(date +%s%3N)

echo "Building auth-service..."
npx tsc -p packages/auth-service/tsconfig.json
SEQUENTIAL_AUTH=$(date +%s%3N)

echo "Building user-service..."
npx tsc -p packages/user-service/tsconfig.json
SEQUENTIAL_USER=$(date +%s%3N)

echo "Building api-gateway..."
npx tsc -p packages/api-gateway/tsconfig.json
SEQUENTIAL_GATEWAY=$(date +%s%3N)

echo "Building web-app..."
npx tsc -p packages/web-app/tsconfig.json
SEQUENTIAL_END=$(date +%s%3N)

SEQUENTIAL_TOTAL=$((SEQUENTIAL_END - SEQUENTIAL_START))

echo ""
echo "✓ Sequential build complete"
echo "  shared-lib:   $((SEQUENTIAL_SHARED - SEQUENTIAL_START))ms"
echo "  auth-service: $((SEQUENTIAL_AUTH - SEQUENTIAL_SHARED))ms"
echo "  user-service: $((SEQUENTIAL_USER - SEQUENTIAL_AUTH))ms"
echo "  api-gateway:  $((SEQUENTIAL_GATEWAY - SEQUENTIAL_USER))ms"
echo "  web-app:      $((SEQUENTIAL_END - SEQUENTIAL_GATEWAY))ms"
echo ""
echo "  📊 TOTAL TIME: ${SEQUENTIAL_TOTAL}ms"
echo ""

# Clean for parallel build
echo "🧹 Cleaning for parallel build..."
rm -rf packages/*/dist
echo ""

# Parallel build with gaffer-exec
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚡ PARALLEL BUILD (gaffer-exec)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Note: auth-service and user-service build IN PARALLEL"
echo "      (both depend only on shared-lib)"
echo ""

PARALLEL_START=$(date +%s%3N)

gaffer-exec --graph graph.json --workspace-root . run build-all

PARALLEL_END=$(date +%s%3N)
PARALLEL_TOTAL=$((PARALLEL_END - PARALLEL_START))

echo ""
echo "  📊 TOTAL TIME: ${PARALLEL_TOTAL}ms"
echo ""

# Calculate speedup
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Sequential (npm):  ${SEQUENTIAL_TOTAL}ms"
echo "  Parallel (gaffer): ${PARALLEL_TOTAL}ms"
echo ""

if [ $PARALLEL_TOTAL -gt 0 ]; then
    SPEEDUP=$(awk "BEGIN {printf \"%.2f\", $SEQUENTIAL_TOTAL / $PARALLEL_TOTAL}")
    IMPROVEMENT=$(awk "BEGIN {printf \"%.1f\", (($SEQUENTIAL_TOTAL - $PARALLEL_TOTAL) / $SEQUENTIAL_TOTAL) * 100}")
    echo "  ⚡ Speedup: ${SPEEDUP}x faster"
    echo "  💰 Time saved: ${IMPROVEMENT}%"
else
    echo "  ⚡ Speedup: N/A (parallel was too fast to measure)"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
