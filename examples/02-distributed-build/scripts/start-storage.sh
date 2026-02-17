#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "🚀 Starting cloud storage services..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Check for port conflicts
echo "🔍 Checking for port conflicts..."
for port in 4566 10000 10001 10002 4443; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "⚠️  Warning: Port $port is already in use. Stopping existing services..."
        docker-compose down 2>/dev/null || true
        break
    fi
done

# Start services
echo "📦 Starting LocalStack (S3), Azurite (Azure), and fake-gcs-server (GCS)..."
docker-compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
timeout=60
elapsed=0
all_healthy=false

while [ $elapsed -lt $timeout ]; do
    if docker-compose ps | grep -q "healthy"; then
        all_healthy=true
        for service in localstack azurite fake-gcs; do
            if ! docker-compose ps $service 2>/dev/null | grep -q "healthy\|Up"; then
                all_healthy=false
                break
            fi
        done
        
        if [ "$all_healthy" = true ]; then
            echo ""
            echo "✅ All services are ready!"
            break
        fi
    fi
    
    sleep 2
    elapsed=$((elapsed + 2))
    echo -n "."
done

echo ""

if [ "$all_healthy" = false ]; then
    echo "❌ Services failed to become healthy within ${timeout}s"
    echo "📋 Service status:"
    docker-compose ps
    echo "📋 Recent logs:"
    docker-compose logs --tail=20
    exit 1
fi

# Initialize S3 bucket in LocalStack
echo "🪣 Creating S3 bucket..."
if ! aws --endpoint-url=http://localhost:4566 s3 mb s3://gaffer-build-cache 2>&1 | grep -q "BucketAlreadyOwnedByYou\|BucketAlreadyExists"; then
    # Check if bucket exists
    if aws --endpoint-url=http://localhost:4566 s3 ls s3://gaffer-build-cache >/dev/null 2>&1; then
        echo "   ✓ Bucket already exists"
    else
        echo "   ✓ Bucket created"
    fi
else
    echo "   ✓ Bucket already exists"
fi

# Initialize Azure container
echo "🗄️  Creating Azure container..."
if output=$(az storage container create \
    --name gaffer-build-cache \
    --connection-string "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;" 2>&1); then
    echo "   ✓ Container created"
elif echo "$output" | grep -q "ContainerAlreadyExists\|already exists"; then
    echo "   ✓ Container already exists"
else
    echo "   ❌ Failed to create container: $output"
    exit 1
fi

# Initialize GCS bucket using curl
echo "☁️  Creating GCS bucket..."
if output=$(curl -s -X POST http://localhost:4443/storage/v1/b -H "Content-Type: application/json" -d '{"name":"gaffer-build-cache"}' 2>&1); then
    if echo "$output" | grep -q "error\|Error"; then
        if echo "$output" | grep -q "409\|already exists\|duplicate"; then
            echo "   ✓ Bucket already exists"
        else
            echo "   ❌ Failed to create bucket: $output"
            exit 1
        fi
    else
        echo "   ✓ Bucket created"
    fi
else
    echo "   ✓ Request completed"
fi

# Export AWS credentials for use in this shell and subprocesses
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566
export AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;"
export GCS_ENDPOINT=http://localhost:4443

echo ""
echo "🎉 Cloud storage services are ready!"
echo ""
echo "📊 Service endpoints:"
echo "   • S3 (LocalStack):  http://localhost:4566"
echo "   • Azure (Azurite):  http://localhost:10000"
echo "   • GCS (fake-gcs):   http://localhost:4443"
echo ""
echo "🔧 Environment variables (copy to set in your shell):"
echo "   export AWS_ACCESS_KEY_ID=test"
echo "   export AWS_SECRET_ACCESS_KEY=test"
echo "   export AWS_DEFAULT_REGION=us-east-1"
echo "   export AWS_ENDPOINT_URL=http://localhost:4566"
echo "   export AZURE_STORAGE_CONNECTION_STRING=\"DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;\""
echo "   export GCS_ENDPOINT=http://localhost:4443"
echo ""
echo "💡 View logs: docker-compose logs -f"
echo "🛑 Stop services: ./scripts/stop-storage.sh"
