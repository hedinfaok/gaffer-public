#!/bin/bash
set -e

# Fetch artifacts from cloud storage (S3/Azure/GCS)
CACHE_DIR=".cache"
STORAGE_BACKEND="${STORAGE_BACKEND:-s3}"  # s3, azure, or gcs
BUCKET_NAME="gaffer-build-cache"

mkdir -p $CACHE_DIR

echo "🔍 Checking remote cache for artifacts (backend: $STORAGE_BACKEND)..."

# Storage backend configuration
AWS_ENDPOINT_URL="${AWS_ENDPOINT_URL:-http://localhost:4566}"
AZURE_STORAGE_CONNECTION_STRING="${AZURE_STORAGE_CONNECTION_STRING:-DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;}"
GCS_ENDPOINT="${GCS_ENDPOINT:-http://localhost:4443}"

# List of artifacts to fetch
artifacts=(
    "cmd/gateway/main"
    "cmd/auth/main"
    "cmd/users/main"
)

found=0
total=${#artifacts[@]}

# Function to fetch from S3
fetch_from_s3() {
    local key="$1"
    local dest="$2"
    
    mkdir -p "$(dirname "$dest")"
    
    if aws --endpoint-url="$AWS_ENDPOINT_URL" --cli-read-timeout 30 --cli-connect-timeout 10 s3 cp "s3://$BUCKET_NAME/$key" "$dest" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to fetch from Azure
fetch_from_azure() {
    local key="$1"
    local dest="$2"
    
    mkdir -p "$(dirname "$dest")"
    
    if az storage blob download \
        --container-name "$BUCKET_NAME" \
        --name "$key" \
        --file "$dest" \
        --connection-string "$AZURE_STORAGE_CONNECTION_STRING" \
        --timeout 30 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to fetch from GCS
fetch_from_gcs() {
    local key="$1"
    local dest="$2"
    
    mkdir -p "$(dirname "$dest")"
    
    # Use curl to fetch from fake-gcs-server
    if curl -sf --max-time 30 --connect-timeout 10 "$GCS_ENDPOINT/storage/v1/b/$BUCKET_NAME/o/$(echo "$key" | sed 's/\//%2F/g')?alt=media" -o "$dest" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Fetch artifacts based on backend
for artifact in "${artifacts[@]}"; do
    cache_file="$CACHE_DIR/$artifact"
    
    case $STORAGE_BACKEND in
        s3)
            if fetch_from_s3 "$artifact" "$cache_file"; then
                echo "✓ Cache hit (S3): $artifact"
                found=$((found + 1))
                # Restore to build location
                mkdir -p "$(dirname "$artifact")"
                cp "$cache_file" "$artifact" 2>/dev/null || true
                chmod +x "$artifact" 2>/dev/null || true
            else
                echo "✗ Cache miss (S3): $artifact"
            fi
            ;;
        azure)
            if fetch_from_azure "$artifact" "$cache_file"; then
                echo "✓ Cache hit (Azure): $artifact"
                found=$((found + 1))
                # Restore to build location
                mkdir -p "$(dirname "$artifact")"
                cp "$cache_file" "$artifact" 2>/dev/null || true
                chmod +x "$artifact" 2>/dev/null || true
            else
                echo "✗ Cache miss (Azure): $artifact"
            fi
            ;;
        gcs)
            if fetch_from_gcs "$artifact" "$cache_file"; then
                echo "✓ Cache hit (GCS): $artifact"
                found=$((found + 1))
                # Restore to build location
                mkdir -p "$(dirname "$artifact")"
                cp "$cache_file" "$artifact" 2>/dev/null || true
                chmod +x "$artifact" 2>/dev/null || true
            else
                echo "✗ Cache miss (GCS): $artifact"
            fi
            ;;
        *)
            echo "❌ Unknown storage backend: $STORAGE_BACKEND"
            exit 1
            ;;
    esac
done

echo ""
echo "📊 Cache Summary: $found/$total artifacts found"

# Calculate cache hit percentage
if [ $total -gt 0 ]; then
    hit_rate=$((found * 100 / total))
else
    hit_rate=0
fi

echo "🎯 Cache hit rate: $hit_rate%"

if [ $hit_rate -gt 60 ]; then
    echo "🚀 Excellent cache performance!"
elif [ $hit_rate -gt 30 ]; then
    echo "⚡ Good cache performance"
else
    echo "🔥 Cache warming needed"
fi