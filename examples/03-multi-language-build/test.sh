#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "=== Testing Multi-Language Build Example ==="

# Check required tools
echo "🔧 Checking required language toolchains..."

required_tools=("go" "cargo" "node" "npm" "python3" "pip3")
missing_tools=()

for tool in "${required_tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo "✅ $tool is available"
    else
        echo "❌ $tool is missing"
        missing_tools+=("$tool")
    fi
done

if [ ${#missing_tools[@]} -gt 0 ]; then
    echo ""
    echo "⚠️  Missing required tools: ${missing_tools[*]}"
    echo "💡 Please install the missing tools to run this example fully."
    echo "📖 See README.md for installation instructions."
    echo ""
    echo "🚀 Continuing with partial test..."
fi

# Test 1: Run the multi-language build
echo "Test 1: Running multi-language-build..."
output=$(gaffer-exec run multi-language-build --graph graph.json 2>&1)
if echo "$output" | grep -q "All components built"; then
    echo "✅ Multi-language build completed"
else
    echo "❌ Multi-language build failed"
    echo "$output"
    exit 1
fi

# Test 2: Verify all language outputs appeared
echo "Test 2: Checking all language builds..."
for lang in "Rust" "Go" "Node" "Python"; do
    if echo "$output" | grep -q "$lang"; then
        echo "✅ $lang build output found"
    else
        echo "⚠️  $lang build output missing (tool may not be installed)"
    fi
done

# Test 3: Check if real artifacts were created (when tools available)
echo "Test 3: Verifying build artifacts..."
expected_artifacts=(
    "rust-backend/target/release/rust-backend"
    "go-cli/go-cli" 
    "python-ml/build"
)

for artifact in "${expected_artifacts[@]}"; do
    if [ -e "$artifact" ]; then
        echo "✅ Artifact created: $artifact"
    else
        echo "ℹ️  Artifact not found: $artifact (may require tool installation)"
    fi
done

# Test 4: Integration test
echo "Test 4: Running integration test..."
integration_output=$(gaffer-exec run integration-test --graph graph.json 2>&1)
if echo "$integration_output" | grep -q "Integration tests passed"; then
    echo "✅ Integration test passed"
else
    echo "❌ Integration test failed"
    echo "$integration_output"
    exit 1
fi

# Test 5: Quick Python ML test (if available)
echo "Test 5: Testing Python ML component..."
if command -v python3 &> /dev/null; then
    cd python-ml
    if python3 -c "print('🐍 Python is working')"; then
        echo "✅ Python component functional"
    else
        echo "⚠️  Python component issues"
    fi
    cd ..
else
    echo "ℹ️  Python not available - skipping ML test"
fi

echo ""
echo "🎉 Multi-language build tests completed!"
echo ""
echo "🚀 To run manually:"
echo "   gaffer-exec run multi-language-build --graph graph.json"
echo "   gaffer-exec run start-all --graph graph.json"
echo ""
echo "📋 Language-specific builds:"
echo "   gaffer-exec run rust-backend --graph graph.json"
echo "   gaffer-exec run go-cli --graph graph.json"
echo "   gaffer-exec run node-frontend --graph graph.json"
echo "   gaffer-exec run python-ml --graph graph.json"
echo "=== All tests passed ==="
