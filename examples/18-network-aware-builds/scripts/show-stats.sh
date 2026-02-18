#!/bin/bash

# show-stats.sh - Display build statistics

cd "$(dirname "$0")/.."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Build Statistics"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Count cache hits/misses
if [ -f .cache/cache-hits.log ]; then
    hits=$(grep -c "Cache hit" .cache/cache-hits.log 2>/dev/null || echo 0)
    misses=$(grep -c "Cache miss" .cache/cache-hits.log 2>/dev/null || echo 0)
    total=$((hits + misses))
    
    if [ $total -gt 0 ]; then
        hit_rate=$(echo "scale=1; $hits * 100 / $total" | bc)
        echo "🎯 Cache Performance:"
        echo "   Hits:     $hits"
        echo "   Misses:   $misses"
        echo "   Hit Rate: ${hit_rate}%"
    fi
fi

echo ""

# Show build artifacts
if [ -d bin ]; then
    echo "📦 Build Artifacts:"
    total_size=0
    for file in bin/*; do
        if [ -f "$file" ]; then
            size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            total_size=$((total_size + size))
            
            name=$(basename "$file")
            printf "   %-12s %10s\n" "$name:" "$(numfmt --to=iec-i --suffix=B $size 2>/dev/null || echo $size bytes)"
        fi
    done
    
    echo "   ────────────────────────"
    printf "   %-12s %10s\n" "Total:" "$(numfmt --to=iec-i --suffix=B $total_size 2>/dev/null || echo $total_size bytes)"
fi

echo ""

# Show region info
if [ -f .cache/region-config.sh ]; then
source .cache/region-config.sh
    echo "🌍 Network Configuration:"
    echo "   Primary Cache:   $PRIMARY_CACHE"
    echo "   Fallback 1:      $FALLBACK_CACHE_1"
    echo "   Fallback 2:      $FALLBACK_CACHE_2"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
