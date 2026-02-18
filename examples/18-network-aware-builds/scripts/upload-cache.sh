#!/bin/bash

# upload-cache.sh - Upload build cache to primary region

cd "$(dirname "$0")/.."

# Load region configuration
if [ -f .cache/region-config.sh ]; then
    source .cache/region-config.sh
else
    PRIMARY_CACHE="us-east"
fi

region=${1:-$PRIMARY_CACHE}

echo "📤 Uploading cache to region: $region"

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

# Create cache directory if it doesn't exist
mkdir -p .cache/artifacts

# Copy built binaries to cache
echo "📦 Preparing artifacts..."
if [ -d bin ]; then
    cp -r bin/* .cache/artifacts/ 2>/dev/null || true
fi

# Upload to S3
echo "☁️  Uploading to $bucket..."
aws --endpoint-url=$endpoint s3 sync .cache/artifacts/ s3://$bucket/ --quiet

# Verify upload
count=$(aws --endpoint-url=$endpoint s3 ls s3://$bucket/ 2>/dev/null | wc -l | tr -d ' ')

echo "✅ Uploaded to $region ($count objects)"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Cache upload to $region - $count objects" >> .cache/cache-operations.log

echo ""
