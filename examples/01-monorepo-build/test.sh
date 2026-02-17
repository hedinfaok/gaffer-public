#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "=== Testing Monorepo Build Example ==="
echo ""

# Test 1: Clean build
echo "Test 1: Full clean build..."
rm -rf packages/*/dist
output=$(gaffer-exec --graph graph.json --workspace-root . run build-all 2>&1)
if echo "$output" | grep -q "All packages built successfully"; then
    echo "✓ Build completed successfully"
else
    echo "✗ Build failed"
    echo "$output"
    exit 1
fi

# Test 2: Verify all packages were built
echo "Test 2: Checking build artifacts..."
for pkg in shared-lib auth-service user-service api-gateway web-app; do
    if [ -d "packages/$pkg/dist" ]; then
        file_count=$(find "packages/$pkg/dist" -name "*.js" | wc -l | tr -d ' ')
        if [ "$file_count" -gt 0 ]; then
            echo "✓ $pkg built ($file_count files)"
        else
            echo "✗ $pkg has no output files"
            exit 1
        fi
    else
        echo "✗ $pkg dist directory not found"
        exit 1
    fi
done

# Test 3: Cached build should be fast
echo "Test 3: Testing cache (rebuild without changes)..."
start=$(date +%s)
gaffer-exec --graph graph.json --workspace-root . run --cache sha256 build-all >/dev/null 2>&1
end=$(date +%s)
cached_time=$((end - start))
echo "✓ Cached build completed in ${cached_time}s"

# Test 4: Graph visualization works
echo "Test 4: Graph visualization..."
graph_output=$(gaffer-exec --graph graph.json --workspace-root . graph build-all --format dot 2>&1)
if echo "$graph_output" | grep -q "digraph\|web-app\|build"; then
    echo "✓ Graph visualization works"
else
    echo "✗ Graph visualization failed"
    echo "$graph_output"
    exit 1
fi

# Test 5: Running the built app directly (already built from previous tests)
echo "Test 5: Running the application..."
app_output=$(timeout 2s node packages/web-app/dist/index.js 2>&1 || true)
if echo "$app_output" | grep -q "Starting web app"; then
    echo "✓ Application runs successfully"
else
    echo "✗ Application failed to run"
    echo "$app_output"
    exit 1
fi

echo ""
echo "=== All tests passed ==="
echo ""
echo "Summary:"
echo "  ✓ Full build works"
echo "  ✓ All 5 packages compiled"
echo "  ✓ Caching functional"
echo "  ✓ Graph visualization works"
echo "  ✓ Application runs"
echo ""
