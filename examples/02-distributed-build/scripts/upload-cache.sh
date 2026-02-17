#!/bin/bash
set -e

# Upload artifacts to cloud storage (S3/Azure/GCS)
CACHE_DIR=".cache"
STORAGE_BACKEND="${STORAGE_BACKEND:-s3}"  # s3, azure, or gcs
BUCKET_NAME="gaffer-build-cache"

echo "⬆️  Uploading new artifacts to remote cache (backend: $STORAGE_BACKEND)..."

# Storage backend configuration
AWS_ENDPOINT_URL="${AWS_ENDPOINT_URL:-http://localhost:4566}"
AZURE_STORAGE_CONNECTION_STRING="${AZURE_STORAGE_CONNECTION_STRING:-DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;}"
GCS_ENDPOINT="${GCS_ENDPOINT:-http://localhost:4443}"

# Find newly built artifacts
new_binaries=$(find cmd/ -name "main" -o -name "*.exe" -type f 2>/dev/null || true)

uploaded=0
failed=0

# Function to upload to S3
upload_to_s3() {
    local file="$1"
    local key="$2"
    
    if aws --endpoint-url="$AWS_ENDPOINT_URL" --cli-read-timeout 30 --cli-connect-timeout 10 s3 cp "$file" "s3://$BUCKET_NAME/$key" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to upload to Azure
upload_to_azure() {
    local file="$1"
    local key="$2"
    
    if az storage blob upload \
        --container-name "$BUCKET_NAME" \
        --name "$key" \
        --file "$file" \
        --connection-string "$AZURE_STORAGE_CONNECTION_STRING" \
        --overwrite \
        --timeout 30 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to upload to GCS
upload_to_gcs() {
    local file="$1"
    local key="$2"
    
    # Use curl to upload to fake-gcs-server
    if curl -sf --max-time 30 --connect-timeout 10 -X POST "$GCS_ENDPOINT/upload/storage/v1/b/$BUCKET_NAME/o?uploadType=media&name=$(echo "$key" | sed 's/\//%2F/g')" \
        --data-binary "@$file" \
        -H "Content-Type: application/octet-stream" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Upload artifacts based on backend
for file in $new_binaries; do
    if [ -f "$file" ]; then
        # Copy to local cache
        cache_path="$CACHE_DIR/$file"
        mkdir -p "$(dirname "$cache_path")"
        cp "$file" "$cache_path" 2>/dev/null || true
        
        # Upload to remote storage
        case $STORAGE_BACKEND in
            s3)
                if upload_to_s3 "$file" "$file"; then
                    echo "✓ Uploaded to S3: $file"
                    uploaded=$((uploaded + 1))
                else
                    echo "✗ Failed to upload to S3: $file"
                    failed=$((failed + 1))
                fi
                ;;
            azure)
                if upload_to_azure "$file" "$file"; then
                    echo "✓ Uploaded to Azure: $file"
                    uploaded=$((uploaded + 1))
                else
                    echo "✗ Failed to upload to Azure: $file"
                    failed=$((failed + 1))
                fi
                ;;
            gcs)
                if upload_to_gcs "$file" "$file"; then
                    echo "✓ Uploaded to GCS: $file"
                    uploaded=$((uploaded + 1))
                else
                    echo "✗ Failed to upload to GCS: $file"
                    failed=$((failed + 1))
                fi
                ;;
            *)
                echo "❌ Unknown storage backend: $STORAGE_BACKEND"
                exit 1
                ;;
        esac
    fi
done

echo ""
echo "📤 Upload Summary: $uploaded artifacts uploaded, $failed failed"

# Display cache stats
size=$(du -sh $CACHE_DIR 2>/dev/null | cut -f1 || echo "0B")
echo "💾 Local cache size: $size"

case $STORAGE_BACKEND in
    s3)
        echo "🌐 Remote cache: s3://$BUCKET_NAME/ (endpoint: $AWS_ENDPOINT_URL)"
        ;;
    azure)
        echo "🌐 Remote cache: Azure Blob Storage container: $BUCKET_NAME"
        ;;
    gcs)
        echo "🌐 Remote cache: gs://$BUCKET_NAME/ (endpoint: $GCS_ENDPOINT)"
        ;;
esac

if [ $uploaded -gt 0 ]; then
    echo "🎉 Cache updated successfully!"
else
    echo "ℹ️  No new artifacts to upload"
fi