#!/bin/bash

# verify-builds.sh - Verify that all services built successfully

cd "$(dirname "$0")/.."

echo "🔍 Verifying build artifacts..."
echo ""

success=true

# Check for built binaries
services=("api" "worker" "frontend")

for service in "${services[@]}"; do
    binary="bin/$service"
    
    if [ -f "$binary" ]; then
        size=$(stat -f%z "$binary" 2>/dev/null || stat -c%s "$binary" 2>/dev/null)
        echo "✅ $service: $(numfmt --to=iec-i --suffix=B $size 2>/dev/null || echo $size bytes)"
    else
        echo "❌ $service: NOT FOUND"
        success=false
    fi
done

echo ""

if [ "$success" = true ]; then
    echo "✅ All services built successfully!"
    exit 0
else
    echo "❌ Some services failed to build"
    exit 1
fi
