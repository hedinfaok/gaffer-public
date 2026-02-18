#!/bin/bash

# sync-caches.sh - Synchronize caches across all regions

cd "$(dirname "$0")/.."

echo "🔄 Synchronizing caches across regions..."
echo ""

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Define region data as parallel arrays (bash 3.2 compatible)
region_names=("us-east" "us-west" "eu-central")
region_endpoints=("http://localhost:4566" "http://localhost:4567" "http://localhost:4568")
region_buckets=("gaffer-cache-us-east" "gaffer-cache-us-west" "gaffer-cache-eu-central")

# Primary is always first (us-east)
primary="us-east"
primary_endpoint="${region_endpoints[0]}"
primary_bucket="${region_buckets[0]}"

echo "📍 Primary region: $primary"
echo ""

# Download from primary to temp
temp_dir=".cache/sync-temp"
mkdir -p "$temp_dir"

echo "📥 Downloading from primary ($primary)..."
aws --endpoint-url=$primary_endpoint s3 sync s3://$primary_bucket/ $temp_dir/ --quiet 2>/dev/null

primary_count=$(find $temp_dir -type f 2>/dev/null | wc -l | tr -d ' ')
echo "   Found $primary_count artifacts"
echo ""

# Sync to each secondary region
for i in "${!region_names[@]}"; do
    region="${region_names[$i]}"
    
    if [ "$region" != "$primary" ]; then
        endpoint="${region_endpoints[$i]}"
        bucket="${region_buckets[$i]}"
        
        echo "📤 Syncing to $region..."
        
        # Get current count in target
        before_count=$(aws --endpoint-url=$endpoint s3 ls s3://$bucket/ 2>/dev/null | wc -l | tr -d ' ')
        
        # Upload to target
        aws --endpoint-url=$endpoint s3 sync $temp_dir/ s3://$bucket/ --quiet 2>/dev/null
        
        # Get new count
        after_count=$(aws --endpoint-url=$endpoint s3 ls s3://$bucket/ 2>/dev/null | wc -l | tr -d ' ')
        new_items=$((after_count - before_count))
        
        if [ $new_items -gt 0 ]; then
            echo "   ✅ Synced $new_items new artifacts to $region"
        else
            echo "   ✅ $region is up to date"
        fi
        
        # Log sync operation
        mkdir -p .cache
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Sync: $primary → $region - $new_items new items" >> .cache/sync.log
    fi
done

# Cleanup temp directory
rm -rf "$temp_dir"

echo ""
echo "✅ Cache synchronization complete!"
echo ""

# Show summary
echo "📊 Cache Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for i in "${!region_names[@]}"; do
    region="${region_names[$i]}"
    endpoint="${region_endpoints[$i]}"
    bucket="${region_buckets[$i]}"
    count=$(aws --endpoint-url=$endpoint s3 ls s3://$bucket/ 2>/dev/null | wc -l | tr -d ' ')
    
    printf "%-15s %5s artifacts\n" "$region:" "$count"
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
