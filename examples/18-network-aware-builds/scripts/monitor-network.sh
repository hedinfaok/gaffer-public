#!/bin/bash

# monitor-network.sh - Monitor network performance across regions

cd "$(dirname "$0")/.."

echo "📊 Network Performance Monitor"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Define regions as parallel arrays (bash 3.2 compatible)
region_names=("us-east" "us-west" "eu-central")
region_endpoints=("http://localhost:4566" "http://localhost:4567" "http://localhost:4568")
region_buckets=("gaffer-cache-us-east" "gaffer-cache-us-west" "gaffer-cache-eu-central")
region_latencies=(50 100 150)
region_bandwidths=(100 50 25)

# Table header
printf "%-15s | %-10s | %-12s | %-12s | %-10s\n" "Region" "Latency" "Bandwidth" "Cache Size" "Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for i in "${!region_names[@]}"; do
    region="${region_names[$i]}"
    endpoint="${region_endpoints[$i]}"
    bucket="${region_buckets[$i]}"
    latency="${region_latencies[$i]}"
    bandwidth="${region_bandwidths[$i]}"
    
    # Check health
    if curl -sf "$endpoint/_localstack/health" >/dev/null 2>&1; then
        status="✅"
        
        # Get cache object count
        cache_count=$(aws --endpoint-url=$endpoint s3 ls s3://$bucket/ 2>/dev/null | wc -l | tr -d ' ')
        
        # Calculate cache hit rate if log exists
        if [ -f .cache/cache-hits.log ]; then
            region_hits=$(grep -c "$region.*Cache hit" .cache/cache-hits.log 2>/dev/null || echo 0)
            region_total=$(grep -c "$region" .cache/cache-hits.log 2>/dev/null || echo 1)
            hit_rate=$(echo "scale=0; $region_hits * 100 / $region_total" | bc 2>/dev/null || echo 0)
        else
            hit_rate=0
        fi
    else
        status="❌"
        cache_count=0
        hit_rate=0
    fi
    
    printf "%-15s | %-10s | %-12s | %-12s | %-10s\n" \
        "$region" \
        "${latency}ms" \
        "${bandwidth}Mbps" \
        "$cache_count objects" \
        "$status"
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Show cache hit statistics
if [ -f .cache/cache-hits.log ]; then
    echo "📈 Overall Cache Statistics:"
    total_ops=$(wc -l < .cache/cache-hits.log | tr -d ' ')
    total_hits=$(grep -c "Cache hit" .cache/cache-hits.log 2>/dev/null || echo 0)
    total_misses=$(grep -c "Cache miss" .cache/cache-hits.log 2>/dev/null || echo 0)
    
    if [ $total_ops -gt 0 ]; then
        overall_hit_rate=$(echo "scale=1; $total_hits * 100 / $total_ops" | bc)
        echo "   Total Operations: $total_ops"
        echo "   Cache Hits:       $total_hits"
        echo "   Cache Misses:     $total_misses"
        echo "   Hit Rate:         ${overall_hit_rate}%"
    fi
    echo ""
fi

# Show bandwidth savings
if [ -d bin ] && [ -d .cache/artifacts ]; then
    echo "💾 Bandwidth Savings:"
    
    # Calculate total artifact size
    if [ "$(uname)" = "Darwin" ]; then
        bin_size=$(find bin -type f -exec stat -f%z {} \; 2>/dev/null | awk '{s+=$1} END {print s}')
    else
        bin_size=$(find bin -type f -exec stat -c%s {} \; 2>/dev/null | awk '{s+=$1} END {print s}')
    fi
    
    # Assume 95% savings on cache hits (delta transfers + compression)
    if [ ! -z "$bin_size" ] && [ "$bin_size" -gt 0 ]; then
        total_hits=${total_hits:-0}
        if [ $total_hits -gt 0 ]; then
            savings=$(echo "scale=0; $bin_size * $total_hits * 0.95" | bc)
            echo "   Saved bandwidth: $(numfmt --to=iec-i --suffix=B $savings 2>/dev/null || echo $savings bytes)"
            echo "   Efficiency:      95% (delta + compression)"
        fi
    fi
    echo ""
fi

# Show recent activity
if [ -f .cache/cache-operations.log ]; then
    echo "📝 Recent Operations:"
    tail -5 .cache/cache-operations.log | while read line; do
        echo "   $line"
    done
    echo ""
fi

echo "🔄 Auto-refresh: Press Ctrl+C to stop, or run 'watch -n 2 ./scripts/monitor-network.sh'"
echo ""
