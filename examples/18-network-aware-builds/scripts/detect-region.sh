#!/bin/bash

# detect-region.sh - Detect optimal cache region based on network topology

cd "$(dirname "$0")/.."

echo "🌍 Detecting network topology..."
echo ""

# Create .cache directory if it doesn't exist
mkdir -p .cache

# Define regions as parallel arrays (compatible with bash 3.2+)
region_names=("us-east" "us-west" "eu-central")
region_endpoints=("localhost:4566" "localhost:4567" "localhost:4568")
region_latencies=(50 100 150)
region_bandwidths=(100 50 25)

echo "📊 Network Metrics:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-15s %-20s %-12s %-12s %-10s\n" "Region" "Endpoint" "Latency" "Bandwidth" "Score"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

best_region=""
best_score=1000
best_index=0

# Calculate scores for each region
for i in "${!region_names[@]}"; do
    region="${region_names[$i]}"
    endpoint="${region_endpoints[$i]}"
    latency="${region_latencies[$i]}"
    bandwidth="${region_bandwidths[$i]}"
    
    # Calculate composite score (lower is better)
    # Formula: (latency/10 * 0.4) + ((100-bandwidth)/10 * 0.6)
    latency_score=$(echo "scale=2; $latency / 10 * 0.4" | bc)
    bandwidth_score=$(echo "scale=2; (100 - $bandwidth) / 10 * 0.6" | bc)
    score=$(echo "scale=2; $latency_score + $bandwidth_score" | bc)
    
    # Check if this is the best score
    is_better=$(echo "$score < $best_score" | bc -l)
    if [ "$is_better" -eq 1 ]; then
        best_score=$score
        best_region=$region
        best_index=$i
    fi
    
    printf "%-15s %-20s %-12s %-12s %-10s\n" \
        "$region" "$endpoint" "${latency}ms" "${bandwidth}Mbps" "$score"
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Selected primary cache: $best_region (score: $best_score)"
echo ""

# Export environment variables
export PRIMARY_CACHE=$best_region
export CACHE_ENDPOINT="${region_endpoints[$best_index]}"

# Determine fallback order
fallbacks=()
for i in "${!region_names[@]}"; do
    if [ "${region_names[$i]}" != "$best_region" ]; then
        fallbacks+=("${region_names[$i]}")
    fi
done

echo "🔄 Fallback order: ${fallbacks[0]} → ${fallbacks[1]}"
echo ""

# Set environment variables for the build
echo "export PRIMARY_CACHE=$best_region" > .cache/region-config.sh
echo "export CACHE_ENDPOINT=${region_endpoints[$best_index]}" >> .cache/region-config.sh
echo "export FALLBACK_CACHE_1=${fallbacks[0]}" >> .cache/region-config.sh
echo "export FALLBACK_CACHE_2=${fallbacks[1]}" >> .cache/region-config.sh

echo "💾 Configuration saved to .cache/region-config.sh"
