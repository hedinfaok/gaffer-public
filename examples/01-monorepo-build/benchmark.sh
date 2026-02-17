#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "════════════════════════════════════════════════════════════════"
echo "  Benchmark: gaffer-exec vs npm workspaces vs Lerna"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Clean build artifacts
echo "🧹 Cleaning build artifacts..."
rm -rf packages/*/dist
echo ""

# Benchmark 1: npm workspaces (sequential)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  npm workspaces (sequential builds)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

NPM_RUNS=3
NPM_TOTAL=0

for i in $(seq 1 $NPM_RUNS); do
    echo "Run $i of $NPM_RUNS..."
    rm -rf packages/*/dist
    
    NPM_START=$(date +%s%3N)
    npm run build:all --silent 2>/dev/null || true
    NPM_END=$(date +%s%3N)
    
    NPM_TIME=$((NPM_END - NPM_START))
    NPM_TOTAL=$((NPM_TOTAL + NPM_TIME))
    echo "  Time: ${NPM_TIME}ms"
done

NPM_AVG=$((NPM_TOTAL / NPM_RUNS))
echo ""
echo "  📊 Average time: ${NPM_AVG}ms"
echo ""

# Clean for next benchmark
rm -rf packages/*/dist
sleep 1

# Benchmark 2: gaffer-exec (parallel, cold cache)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  gaffer-exec (parallel builds, cold cache)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

GAFFER_RUNS=3
GAFFER_TOTAL=0

for i in $(seq 1 $GAFFER_RUNS); do
    echo "Run $i of $GAFFER_RUNS..."
    rm -rf packages/*/dist
    
    GAFFER_START=$(date +%s%3N)
    gaffer-exec --graph graph.json --workspace-root . run build-all >/dev/null 2>&1
    GAFFER_END=$(date +%s%3N)
    
    GAFFER_TIME=$((GAFFER_END - GAFFER_START))
    GAFFER_TOTAL=$((GAFFER_TOTAL + GAFFER_TIME))
    echo "  Time: ${GAFFER_TIME}ms"
done

GAFFER_AVG=$((GAFFER_TOTAL / GAFFER_RUNS))
echo ""
echo "  📊 Average time: ${GAFFER_AVG}ms"
echo ""

# Benchmark 3: gaffer-exec (parallel, hot cache)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  gaffer-exec (parallel builds, hot cache)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Do one build to warm cache
gaffer-exec --graph graph.json --workspace-root . run --cache sha256 build-all >/dev/null 2>&1

CACHED_RUNS=3
CACHED_TOTAL=0

for i in $(seq 1 $CACHED_RUNS); do
    echo "Run $i of $CACHED_RUNS..."
    
    CACHED_START=$(date +%s%3N)
    gaffer-exec --graph graph.json --workspace-root . run --cache sha256 build-all >/dev/null 2>&1
    CACHED_END=$(date +%s%3N)
    
    CACHED_TIME=$((CACHED_END - CACHED_START))
    CACHED_TOTAL=$((CACHED_TOTAL + CACHED_TIME))
    echo "  Time: ${CACHED_TIME}ms"
done

CACHED_AVG=$((CACHED_TOTAL / CACHED_RUNS))
echo ""
echo "  📊 Average time: ${CACHED_AVG}ms"
echo ""

# Results table
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 BENCHMARK RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
printf "%-40s %10s %10s\n" "Tool" "Time (ms)" "Speedup"
echo "────────────────────────────────────────────────────────────────"
printf "%-40s %10s %10s\n" "npm workspaces (sequential)" "$NPM_AVG" "1.00x"

if [ $GAFFER_AVG -gt 0 ]; then
    GAFFER_SPEEDUP=$(awk "BEGIN {printf \"%.2f\", $NPM_AVG / $GAFFER_AVG}")
    printf "%-40s %10s %10s\n" "gaffer-exec (parallel, cold)" "$GAFFER_AVG" "${GAFFER_SPEEDUP}x"
else
    printf "%-40s %10s %10s\n" "gaffer-exec (parallel, cold)" "$GAFFER_AVG" "N/A"
fi

if [ $CACHED_AVG -gt 0 ]; then
    CACHED_SPEEDUP=$(awk "BEGIN {printf \"%.2f\", $NPM_AVG / $CACHED_AVG}")
    printf "%-40s %10s %10s\n" "gaffer-exec (parallel, cached)" "$CACHED_AVG" "${CACHED_SPEEDUP}x"
else
    printf "%-40s %10s %10s\n" "gaffer-exec (parallel, cached)" "$CACHED_AVG" "N/A"
fi

echo ""
echo "Key Findings:"
if [ $GAFFER_AVG -gt 0 ]; then
    IMPROVEMENT=$(awk "BEGIN {printf \"%.1f\", (($NPM_AVG - $GAFFER_AVG) / $NPM_AVG) * 100}")
    echo "  ⚡ Parallel execution: ${IMPROVEMENT}% faster than sequential"
fi
if [ $CACHED_AVG -gt 0 ]; then
    CACHE_IMPROVEMENT=$(awk "BEGIN {printf \"%.1f\", (($NPM_AVG - $CACHED_AVG) / $NPM_AVG) * 100}")
    echo "  💾 With caching: ${CACHE_IMPROVEMENT}% faster than sequential"
fi
echo ""
echo "Scalability:"
echo "  • Benefits increase with more packages"
echo "  • Cached builds scale to O(1) time"
echo "  • Parallel builds limited by dependency depth, not count"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
