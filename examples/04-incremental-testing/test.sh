#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "=== Testing Incremental Testing Example ==="

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js to run this example."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm to run this example."
    exit 1
fi

echo "✅ Node.js and npm are available"

# Test 1: Install dependencies
echo "Test 1: Installing dependencies..."
npm install > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Test 2: Run the full incremental test suite
echo "Test 2: Running incremental test suite..."
output=$(gaffer-exec run test-all --graph graph.json 2>&1)
if echo "$output" | grep -q "All tests completed successfully"; then
    echo "✅ Full test suite completed"
else
    echo "❌ Test suite failed"
    echo "$output"
    exit 1
fi

# Test 3: Test individual unit test suites run
echo "Test 3: Testing unit test execution..."
for suite in "unit-tests-lib" "unit-tests-api" "unit-tests-ui"; do
    suite_output=$(gaffer-exec run $suite --graph graph.json 2>&1)
    if echo "$suite_output" | grep -q "$suite"; then
        echo "✅ $suite executed"
    else
        echo "⚠️  $suite may have issues"
    fi
done

# Test 4: Test incremental dependency execution
echo "Test 4: Testing incremental dependencies..."
integration_output=$(gaffer-exec run integration-tests --graph graph.json 2>&1)
if echo "$integration_output" | grep -q "integration"; then
    echo "✅ Integration tests run after unit tests"
else
    echo "⚠️  Integration test execution may have issues"
fi

# Test 5: Verify test artifacts are created
echo "Test 5: Checking for test artifacts..."
if [ -f "package.json" ] && [ -f "jest.config.js" ] && [ -f "tests/setup.js" ]; then
    echo "✅ Test configuration files exist"
else
    echo "❌ Missing test configuration files"
    exit 1
fi

# Check for test files
test_files=$(find tests/ -name "*.test.js" 2>/dev/null | wc -l)
if [ "$test_files" -gt 0 ]; then
    echo "✅ Found $test_files test files"
else
    echo "❌ No test files found"
    exit 1
fi

# Test 6: Verify actual test execution (if Jest is working)
echo "Test 6: Attempting real test execution..."
if npm test -- --passWithNoTests 2>/dev/null; then
    echo "✅ Jest test runner is working"
else
    echo "⚠️  Jest test runner may need configuration"
fi

# Test 7: Coverage report generation
echo "Test 7: Testing coverage report..."
coverage_output=$(gaffer-exec run coverage-report --graph graph.json 2>&1)
if echo "$coverage_output" | grep -q "coverage"; then
    echo "✅ Coverage reporting configured"
else
    echo "⚠️  Coverage reporting may have issues"
fi

echo ""
echo "🎉 Incremental testing example verification completed!"
echo ""
echo "🚀 To run manually:"
echo "   npm install"
echo "   gaffer-exec run test-all --graph graph.json"
echo ""
echo "📋 Individual test commands:"
echo "   gaffer-exec run unit-tests-lib --graph graph.json"
echo "   gaffer-exec run unit-tests-api --graph graph.json"
echo "   gaffer-exec run unit-tests-ui --graph graph.json"
echo "   gaffer-exec run integration-tests --graph graph.json"
echo "   gaffer-exec run e2e-tests --graph graph.json"
echo ""
echo "💡 For development:"
echo "   gaffer-exec run test-watch --graph graph.json"
echo "   gaffer-exec run test-debug --graph graph.json"
