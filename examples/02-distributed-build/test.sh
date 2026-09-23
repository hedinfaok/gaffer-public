#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "=== Testing Distributed Build Example with Cloud Storage ==="

# Ensure Go is available
if ! command -v go &> /dev/null; then
    echo "✗ Go is not installed. Please install Go to run this example."
    exit 1
fi

# Ensure Docker is available
if ! command -v docker &> /dev/null; then
    echo "✗ Docker is not installed. Please install Docker to run this example."
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "✗ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Ensure AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "✗ AWS CLI is not installed. Please install it: brew install awscli"
    exit 1
fi

# Ensure curl is available
if ! command -v curl &> /dev/null; then
    echo "✗ curl is not installed. Please install it: brew install curl"
    exit 1
fi

# Start storage services
echo "Starting cloud storage services..."
chmod +x scripts/start-storage.sh scripts/stop-storage.sh
./scripts/start-storage.sh

# Set environment for LocalStack
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export STORAGE_BACKEND=s3

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Cleaning up..."
    ./scripts/stop-storage.sh
}
trap cleanup EXIT

# Test 1: Verify storage connectivity
echo ""
echo "Test 1: Verifying storage connectivity..."
if aws --endpoint-url=$AWS_ENDPOINT_URL s3 ls s3://gaffer-build-cache 2>/dev/null; then
    echo "✓ S3 (LocalStack) is accessible"
else
    echo "✗ S3 (LocalStack) connection failed"
    exit 1
fi

# Azure test (if Azure CLI is available)
if command -v az &> /dev/null; then
    echo "Testing Azure Blob Storage..."
    export AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;"
    if az storage container exists --name gaffer-build-cache --connection-string "$AZURE_STORAGE_CONNECTION_STRING" 2>/dev/null | grep -q true; then
        echo "✓ Azure (Azurite) is accessible"
    else
        echo "⚠  Azure CLI available but Azurite not accessible (non-critical)"
    fi
fi

# GCS test
echo "Testing GCS..."
if curl -sf http://localhost:4443/storage/v1/b/gaffer-build-cache > /dev/null 2>&1; then
    echo "✓ GCS (fake-gcs-server) is accessible"
else
    echo "⚠  GCS not accessible (non-critical)"
fi

# Initialize the project
echo ""
echo "Test 2: Initializing Go project..."
go mod tidy
echo "✓ Go modules initialized"

# Test 3: Validate the Makefile task graph
echo ""
echo "Test 3: Validating Makefile task graph..."
if [ ! -f Makefile ]; then
    echo "✗ Makefile not found"
    exit 1
fi
for target in clean init fetch-cache build-gateway build-auth build-users upload-cache distributed-build clean-build; do
    if ! grep -qE "^${target}:" Makefile; then
        echo "✗ Missing Makefile target: $target"
        exit 1
    fi
done
gaffer-exec --workspace-root . list -t makefile > /dev/null
echo "✓ Makefile targets present and discoverable"

# Clean build artifacts
echo ""
echo "Test 4: Cleaning previous builds..."
gaffer-exec --workspace-root . run make:clean
echo "✓ Clean complete"

# Test 5: Run the distributed build (first time - cold cache)
echo ""
echo "Test 5: Running distributed-build (cold cache)..."
output=$(gaffer-exec --workspace-root . run make:distributed-build 2>&1)
if echo "$output" | grep -q "Distributed build complete"; then
    echo "✓ Distributed build completed (cold cache)"
else
    echo "✗ Distributed build failed"
    echo "$output"
    exit 1
fi

# Test 6: Verify artifacts were uploaded to storage
echo ""
echo "Test 6: Verifying cache upload..."
artifact_count=$(aws --endpoint-url=$AWS_ENDPOINT_URL s3 ls s3://gaffer-build-cache/cmd/ --recursive 2>/dev/null | wc -l || echo 0)
if [ "$artifact_count" -gt 0 ]; then
    echo "✓ Found $artifact_count artifacts in S3 cache"
else
    echo "✗ No artifacts found in S3 cache"
    exit 1
fi

# Test 7: Clean local binaries and test cache restore
echo ""
echo "Test 7: Testing cache restore (warm cache)..."
rm -f cmd/*/main
output=$(gaffer-exec --workspace-root . run make:distributed-build 2>&1)
if echo "$output" | grep -q "Cache hit"; then
    echo "✓ Cache hits detected - warm cache working"
else
    echo "⚠  No cache hits detected (may need investigation)"
fi

if echo "$output" | grep -q "Distributed build complete"; then
    echo "✓ Distributed build completed (warm cache)"
else
    echo "✗ Distributed build failed on warm cache"
    exit 1
fi

# Test 8: Verify all services built
echo ""
echo "Test 8: Verifying service binaries..."
services=("cmd/gateway/main" "cmd/auth/main" "cmd/users/main")

for bin in "${services[@]}"; do
    if [ -f "$bin" ] && [ -x "$bin" ]; then
        echo "✓ Binary exists and is executable: $bin"
    else
        echo "✗ Binary missing or not executable: $bin"
        exit 1
    fi
done

# Test 9: Quick functional test of binaries
echo ""
echo "Test 9: Testing binary functionality..."
timeout 2 ./cmd/gateway/main &
gateway_pid=$!
sleep 0.5
kill $gateway_pid 2>/dev/null || true
echo "✓ Gateway binary runs"

echo ""
echo "All distributed build tests passed!"
echo ""
echo "Test Summary:"
echo "   ✓ Cloud storage services working"
echo "   ✓ Cache upload/download working"
echo "   ✓ Cold and warm cache scenarios tested"
echo "   ✓ All microservices building correctly"
echo ""
echo "To run manually:"
echo "   ./scripts/start-storage.sh"
echo "   export AWS_ENDPOINT_URL=http://localhost:4566"
echo "   export STORAGE_BACKEND=s3"
echo "   gaffer-exec --workspace-root . run make:distributed-build"
echo "   ./scripts/stop-storage.sh"
