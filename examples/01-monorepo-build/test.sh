#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "=== Testing Monorepo Build Example ==="

# Test 1: Run the full build
echo "Test 1: Running build-all..."
output=$(gaffer-exec run build-all --graph graph.json --workspace-root . 2>&1)
if echo "$output" | grep -q "All packages built successfully"; then
    echo "✓ Build completed successfully"
else
    echo "✗ Build failed"
    echo "$output"
    exit 1
fi

# Test 2: Verify graph visualization works
echo "Test 2: Graph visualization..."
graph_output=$(gaffer-exec graph build-all --graph graph.json --workspace-root . --format dot 2>&1)
if echo "$graph_output" | grep -q "web-app\|build"; then
    echo "✓ Graph visualization works"
else
    echo "✗ Graph visualization failed"
    echo "$graph_output"
    exit 1
fi

echo ""
echo "=== All tests passed ==="
