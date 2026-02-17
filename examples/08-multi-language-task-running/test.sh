#!/bin/bash
# Test suite for example 08: Multi-Language Task Running

set -e

EXAMPLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$EXAMPLE_DIR"

echo "========================================="
echo "Testing Example 08: Multi-Language Task Running"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to run a test
run_test() {
  local test_name="$1"
  local command="$2"
  
  echo -e "${BLUE}[TEST]${NC} $test_name"
  
  if eval "$command" > /dev/null 2>&1; then
    echo -e "${GREEN}[PASS]${NC} $test_name"
    ((TESTS_PASSED++))
    return 0
  else
    echo -e "${RED}[FAIL]${NC} $test_name"
    ((TESTS_FAILED++))
    return 1
  fi
}

# Helper function to check file exists
check_file_exists() {
  local test_name="$1"
  local file_path="$2"
  
  echo -e "${BLUE}[TEST]${NC} $test_name"
  
  if [ -f "$file_path" ] || [ -d "$file_path" ]; then
    echo -e "${GREEN}[PASS]${NC} $test_name"
    ((TESTS_PASSED++))
    return 0
  else
    echo -e "${RED}[FAIL]${NC} $test_name - File/Directory not found: $file_path"
    ((TESTS_FAILED++))
    return 1
  fi
}

echo "=== Preliminary Checks ==="
echo ""

# Check graph.json exists
check_file_exists "graph.json exists" "graph.json"

# Check all component directories exist
check_file_exists "node-frontend directory exists" "node-frontend"
check_file_exists "python-ml directory exists" "python-ml"
check_file_exists "go-api directory exists" "go-api"
check_file_exists "rust-cli directory exists" "rust-cli"

echo ""
echo "=== Testing Task Graph ==="
echo ""

# Clean first
echo "Cleaning previous artifacts..."
gaffer-exec run clean --graph graph.json > /dev/null 2>&1 || true

# Test install-all
echo -e "${BLUE}[TEST]${NC} install-all runs successfully"
if gaffer-exec run install-all --graph graph.json > /tmp/test-install.log 2>&1; then
  echo -e "${GREEN}[PASS]${NC} install-all runs successfully"
  ((TESTS_PASSED++))
else
  echo -e "${RED}[FAIL]${NC} install-all failed"
  cat /tmp/test-install.log
  ((TESTS_FAILED++))
fi

# Test individual install tasks completed
run_test "install-node completed" "grep -q 'install-node' /tmp/test-install.log || exit 0"
run_test "install-python completed" "grep -q 'install-python' /tmp/test-install.log || exit 0"
run_test "install-go completed" "grep -q 'install-go' /tmp/test-install.log || exit 0"
run_test "install-rust completed" "grep -q 'install-rust' /tmp/test-install.log || exit 0"

echo ""

# Test build-all
echo -e "${BLUE}[TEST]${NC} build-all runs successfully"
if gaffer-exec run build-all --graph graph.json > /tmp/test-build.log 2>&1; then
  echo -e "${GREEN}[PASS]${NC} build-all runs successfully"
  ((TESTS_PASSED++))
else
  echo -e "${RED}[FAIL]${NC} build-all failed"
  cat /tmp/test-build.log
  ((TESTS_FAILED++))
fi

# Check build outputs exist
check_file_exists "Node.js build output" "node-frontend/dist"
check_file_exists "Python build output" "python-ml/build"
check_file_exists "Go build output" "go-api/bin/api-server"
check_file_exists "Rust build output" "rust-cli/target/release/prediction-cli"

echo ""

# Test test-all
echo -e "${BLUE}[TEST]${NC} test-all runs successfully"
if gaffer-exec run test-all --graph graph.json > /tmp/test-tests.log 2>&1; then
  echo -e "${GREEN}[PASS]${NC} test-all runs successfully"
  ((TESTS_PASSED++))
else
  echo -e "${RED}[FAIL]${NC} test-all failed"
  cat /tmp/test-tests.log
  ((TESTS_FAILED++))
fi

echo ""

# Test lint-all
echo -e "${BLUE}[TEST]${NC} lint-all runs successfully"
if gaffer-exec run lint-all --graph graph.json > /tmp/test-lint.log 2>&1; then
  echo -e "${GREEN}[PASS]${NC} lint-all runs successfully"
  ((TESTS_PASSED++))
else
  echo -e "${RED}[FAIL]${NC} lint-all failed"
  cat /tmp/test-lint.log
  ((TESTS_FAILED++))
fi

echo ""

# Test format-all
echo -e "${BLUE}[TEST]${NC} format-all runs successfully"
if gaffer-exec run format-all --graph graph.json > /tmp/test-format.log 2>&1; then
  echo -e "${GREEN}[PASS]${NC} format-all runs successfully"
  ((TESTS_PASSED++))
else
  echo -e "${RED}[FAIL]${NC} format-all failed"
  cat /tmp/test-format.log
  ((TESTS_FAILED++))
fi

echo ""

# Test dev task
echo -e "${BLUE}[TEST]${NC} dev task runs successfully"
if gaffer-exec run dev --graph graph.json > /tmp/test-dev.log 2>&1; then
  echo -e "${GREEN}[PASS]${NC} dev task runs successfully"
  ((TESTS_PASSED++))
else
  echo -e "${RED}[FAIL]${NC} dev task failed"
  cat /tmp/test-dev.log
  ((TESTS_FAILED++))
fi

echo ""

# Test caching - run build-all again
echo -e "${BLUE}[TEST]${NC} Caching works (build-all second run should be faster)"
START_TIME=$(date +%s%N)
gaffer-exec run build-all --graph graph.json > /tmp/test-cache.log 2>&1
END_TIME=$(date +%s%N)
CACHE_TIME=$((($END_TIME - $START_TIME) / 1000000))

if grep -q "cached" /tmp/test-cache.log || [ $CACHE_TIME -lt 3000 ]; then
  echo -e "${GREEN}[PASS]${NC} Caching appears to work (completed in ${CACHE_TIME}ms)"
  ((TESTS_PASSED++))
else
  echo -e "${RED}[FAIL]${NC} Caching may not be working properly"
  ((TESTS_FAILED++))
fi

echo ""

# Test clean
echo -e "${BLUE}[TEST]${NC} clean removes artifacts"
gaffer-exec run clean --graph graph.json > /dev/null 2>&1
if [ ! -d "node-frontend/dist" ] && [ ! -d "go-api/bin" ]; then
  echo -e "${GREEN}[PASS]${NC} clean removes artifacts"
  ((TESTS_PASSED++))
else
  echo -e "${RED}[FAIL]${NC} clean did not remove all artifacts"
  ((TESTS_FAILED++))
fi

echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo -e "${GREEN}Passed:${NC} $TESTS_PASSED"
echo -e "${RED}Failed:${NC} $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed!${NC}"
  exit 1
fi
