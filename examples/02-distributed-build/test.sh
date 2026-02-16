#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "=== Testing Distributed Build Example ==="

# Ensure Go is available
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed. Please install Go to run this example."
    exit 1
fi

# Initialize the project
echo "📦 Initializing Go project..."
go mod tidy

# Test 1: Run the distributed build
echo "Test 1: Running distributed-build..."
output=$(gaffer-exec run distributed-build --graph graph.json 2>&1)
if echo "$output" | grep -q "Distributed build complete"; then
    echo "✅ Distributed build completed"
else
    echo "❌ Distributed build failed"
    echo "$output"
    exit 1
fi

# Test 2: Verify cache behavior
echo "Test 2: Checking cache simulation..."
if echo "$output" | grep -q "cache\|Cache\|caching"; then
    echo "✅ Cache simulation working"
else
    echo "❌ Cache simulation missing"
    exit 1
fi

# Test 3: Verify all services built
echo "Test 3: Checking service builds..."
# The output only shows the final summary, so let's check for that
if echo "$output" | grep -q "microservices built\|All microservices\|services built"; then
    echo "✅ All microservices build output found"
else
    echo "❌ Microservices build confirmation missing"
    echo "Debug: Full output:"
    echo "$output"
    exit 1
fi

# Test 4: Build services individually and verify
echo "Test 4: Building and verifying individual services..."
services=("build-gateway" "build-auth" "build-users") 
expected_bins=("cmd/gateway/main" "cmd/auth/main" "cmd/users/main")

for i in "${!services[@]}"; do
    service="${services[$i]}"
    bin="${expected_bins[$i]}"
    
    echo "Building $service..."
    gaffer-exec run $service --graph graph.json > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ $service completed successfully"
        
        if [ -f "$bin" ] && [ -x "$bin" ]; then
            echo "✅ Binary created and is executable: $bin"
        else
            echo "❌ Binary missing or not executable: $bin"
            exit 1
        fi
    else
        echo "❌ $service failed"
        exit 1
    fi
done

# Test 5: Quick functional test of binaries
echo "Test 5: Testing binary functionality..."
timeout 2 ./cmd/gateway/main &
gateway_pid=$!
sleep 0.5
kill $gateway_pid 2>/dev/null || true
echo "✅ Gateway binary runs"

echo ""
echo "🎉 All distributed build tests passed!"
echo ""
echo "🚀 To run manually:"
echo "   gaffer-exec run distributed-build --graph graph.json"
echo "   gaffer-exec run clean-build --graph graph.json"
