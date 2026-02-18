#!/bin/bash

# fetch-cache.sh - Fetch build cache from specified region

region=${1:-us-east}

cd "$(dirname "$0")/.."

echo "📥 Fetching cache from region: $region"

# Set endpoint based on region
case $region in
    us-east)
        endpoint="http://localhost:4566"
        bucket="gaffer-cache-us-east"
        ;;
    us-west)
        endpoint="http://localhost:4567"
        bucket="gaffer-cache-us-west"
        ;;
    eu-central)
        endpoint="http://localhost:4568"
        bucket="gaffer-cache-eu-central"
        ;;
    *)
        echo "❌ Unknown region: $region"
        exit 1
        ;;
esac

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Check if bucket exists and has content
echo "🔍 Checking cache availability..."
if aws --endpoint-url=$endpoint s3 ls s3://$bucket/ 2>/dev/null | grep -q .; then
    echo "✅ Cache found in $region"
    
    # Download cache artifacts
    mkdir -p .cache/artifacts
    
    echo "📦 Downloading artifacts..."
    aws --endpoint-url=$endpoint s3 sync s3://$bucket/ .cache/artifacts/ --quiet 2>/dev/null || true
    
    # Count downloaded files
    count=$(find .cache/artifacts -type f | wc -l | tr -d ' ')
    
    if [ "$count" -gt 0 ]; then
        echo "✅ Downloaded $count cached artifacts from $region"
        
        # Log cache hit
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Cache hit from $region - $count artifacts" >> .cache/cache-hits.log
    else
        echo "ℹ️  No artifacts in cache yet"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Cache miss from $region" >> .cache/cache-hits.log
    fi
else
    echo "ℹ️  No cache available in $region (cold start)"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Cache miss from $region - bucket empty" >> .cache/cache-hits.log
fi

echo ""
