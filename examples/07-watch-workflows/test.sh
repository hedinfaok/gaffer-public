#!/bin/bash
# Test script for Example 07: Watch Mode Workflows
set -e

EXAMPLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$EXAMPLE_DIR"

echo "🧪 Testing Example 07: Watch Mode Workflows"
echo "==========================================="
echo ""

# Track test results
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function for test assertions
assert_success() {
    if [ $? -eq 0 ]; then
        echo "  ✅ $1"
        ((TESTS_PASSED++))
    else
        echo "  ❌ $1"
        ((TESTS_FAILED++))
    fi
}

assert_file_exists() {
    if [ -f "$1" ]; then
        echo "  ✅ File exists: $1"
        ((TESTS_PASSED++))
    else
        echo "  ❌ File missing: $1"
        ((TESTS_FAILED++))
    fi
}

assert_dir_exists() {
    if [ -d "$1" ]; then
        echo "  ✅ Directory exists: $1"
        ((TESTS_PASSED++))
    else
        echo "  ❌ Directory missing: $1"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Verify directory structure
echo "Test 1: Directory Structure"
echo "----------------------------"
assert_dir_exists "shared-lib/src"
assert_dir_exists "api-service/src"
assert_dir_exists "frontend/src"
assert_dir_exists "scripts"
echo ""

# Test 2: Verify essential files exist
echo "Test 2: Essential Files"
echo "-----------------------"
assert_file_exists "Makefile"
assert_file_exists "shared-lib/package.json"
assert_file_exists "shared-lib/tsconfig.json"
assert_file_exists "api-service/package.json"
assert_file_exists "api-service/tsconfig.json"
assert_file_exists "frontend/package.json"
assert_file_exists "frontend/webpack.config.js"
echo ""

# Test 3: Verify watch scripts exist and are executable
echo "Test 3: Watch Scripts"
echo "---------------------"
for script in watch-shared-lib.sh watch-api.sh watch-frontend.sh watch-all.sh; do
    if [ -f "scripts/$script" ]; then
        echo "  ✅ Script exists: scripts/$script"
        ((TESTS_PASSED++))
        
        if [ -x "scripts/$script" ]; then
            echo "  ✅ Script is executable: scripts/$script"
            ((TESTS_PASSED++))
        else
            echo "  ❌ Script not executable: scripts/$script"
            ((TESTS_FAILED++))
        fi
    else
        echo "  ❌ Script missing: scripts/$script"
        ((TESTS_FAILED++))
    fi
done
echo ""

# Test 4: Verify Makefile task targets
echo "Test 4: Task Graph Structure"
echo "-----------------------------"
if [ -f Makefile ]; then
    echo "  ✅ Makefile exists"
    ((TESTS_PASSED++))

    # Check for required targets
    for task in clean build-shared-lib build-api build-frontend rebuild-shared-lib rebuild-api rebuild-frontend; do
        if grep -qE "^$task:" Makefile; then
            echo "  ✅ Target defined: $task"
            ((TESTS_PASSED++))
        else
            echo "  ❌ Target missing: $task"
            ((TESTS_FAILED++))
        fi
    done
else
    echo "  ❌ Makefile missing"
    ((TESTS_FAILED++))
fi
echo ""

# Test 5: Validate gaffer-exec Makefile discovery
echo "Test 5: Gaffer-exec Schema Validation"
echo "--------------------------------------"
if command -v gaffer-exec &> /dev/null; then
    echo "  ✅ gaffer-exec is installed"
    ((TESTS_PASSED++))
    
    # Test that gaffer-exec discovers the Makefile graph
    if gaffer-exec --workspace-root . list -t makefile > /dev/null 2>&1; then
        echo "  ✅ Makefile graph is valid (gaffer-exec list -t makefile)"
        ((TESTS_PASSED++))
    else
        echo "  ❌ Makefile graph validation failed"
        ((TESTS_FAILED++))
    fi
    
    # Test that clean target can be executed
    if gaffer-exec --workspace-root . run make:clean > /dev/null 2>&1; then
        echo "  ✅ Clean target executes successfully"
        ((TESTS_PASSED++))
    else
        echo "  ❌ Clean target execution failed"
        ((TESTS_FAILED++))
    fi
else
    echo "  ❌ gaffer-exec not installed"
    ((TESTS_FAILED++))
fi
echo ""

# Test 6: Check for fswatch dependency
echo "Test 6: Watch Mode Dependencies"
echo "--------------------------------"
if command -v fswatch &> /dev/null; then
    echo "  ✅ fswatch is installed"
    ((TESTS_PASSED++))
else
    echo "  ⚠️  fswatch not installed (required for watch mode)"
    echo "     Install with: brew install fswatch (macOS)"
fi
echo ""

# Test 7: Verify source files exist
echo "Test 7: Source Files"
echo "--------------------"
assert_file_exists "shared-lib/src/index.ts"
assert_file_exists "api-service/src/server.ts"
assert_file_exists "frontend/src/App.tsx"
assert_file_exists "frontend/src/index.tsx"
echo ""

# Test 8: Install dependencies (if not already installed)
echo "Test 8: Dependency Installation"
echo "--------------------------------"
if [ ! -d "shared-lib/node_modules" ]; then
    echo "  📦 Installing shared-lib dependencies..."
    cd shared-lib && npm install --silent > /dev/null 2>&1
    assert_success "shared-lib dependencies installed"
    cd ..
else
    echo "  ✅ shared-lib dependencies already installed"
    ((TESTS_PASSED++))
fi

if [ ! -d "api-service/node_modules" ]; then
    echo "  📦 Installing api-service dependencies..."
    cd api-service && npm install --silent > /dev/null 2>&1
    assert_success "api-service dependencies installed"
    cd ..
else
    echo "  ✅ api-service dependencies already installed"
    ((TESTS_PASSED++))
fi

if [ ! -d "frontend/node_modules" ]; then
    echo "  📦 Installing frontend dependencies..."
    cd frontend && npm install --silent > /dev/null 2>&1
    assert_success "frontend dependencies installed"
    cd ..
else
    echo "  ✅ frontend dependencies already installed"
    ((TESTS_PASSED++))
fi
echo ""

# Test 8: Build all services
echo "Test 8: Build Verification"
echo "---------------------------"
if command -v gaffer-exec &> /dev/null; then
    echo "  🔨 Building shared-lib..."
    cd shared-lib && npm run build > /dev/null 2>&1
    assert_success "shared-lib builds successfully"
    cd ..

    echo "  🔨 Building api-service..."
    cd api-service && npm run build > /dev/null 2>&1
    assert_success "api-service builds successfully"
    cd ..

    echo "  🔨 Building frontend..."
    cd frontend && npm run build > /dev/null 2>&1
    assert_success "frontend builds successfully"
    cd ..

    # Verify build outputs exist
    assert_dir_exists "shared-lib/dist"
    assert_dir_exists "api-service/dist"
    assert_dir_exists "frontend/build"
else
    echo "  ⚠️  Skipping build tests (gaffer-exec not installed)"
fi
echo ""

# Test 10: Verify watch script patterns
echo "Test 10: Watch Script Patterns"
echo "-------------------------------"
if grep -q "fswatch" scripts/watch-shared-lib.sh; then
    echo "  ✅ watch-shared-lib.sh uses fswatch"
    ((TESTS_PASSED++))
else
    echo "  ❌ watch-shared-lib.sh doesn't use fswatch"
    ((TESTS_FAILED++))
fi

if grep -q "gaffer-exec" scripts/watch-shared-lib.sh; then
    echo "  ✅ watch-shared-lib.sh calls gaffer-exec"
    ((TESTS_PASSED++))
else
    echo "  ❌ watch-shared-lib.sh doesn't call gaffer-exec"
    ((TESTS_FAILED++))
fi

if grep -q -- "--latency" scripts/watch-shared-lib.sh; then
    echo "  ✅ watch-shared-lib.sh uses debouncing (--latency)"
    ((TESTS_PASSED++))
else
    echo "  ❌ watch-shared-lib.sh missing debouncing"
    ((TESTS_FAILED++))
fi

if grep -q "SIGINT SIGTERM" scripts/watch-shared-lib.sh; then
    echo "  ✅ watch-shared-lib.sh handles graceful shutdown"
    ((TESTS_PASSED++))
else
    echo "  ❌ watch-shared-lib.sh missing signal handlers"
    ((TESTS_FAILED++))
fi
echo ""

# Summary
echo "========================================="
echo "Test Summary"
echo "========================================="
echo "  ✅ Passed: $TESTS_PASSED"
echo "  ❌ Failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "🎉 All tests passed!"
    echo ""
    echo "Next steps:"
    echo "  1. Run: ./scripts/watch-all.sh"
    echo "  2. In another terminal, start services:"
    echo "     cd api-service && node dist/server.js"
    echo "  3. Make changes to files and watch rebuilds cascade"
    exit 0
else
    echo "❌ Some tests failed"
    exit 1
fi
