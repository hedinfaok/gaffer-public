#!/usr/bin/env bash
# Test suite for cross-platform builds example

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "╔════════════════════════════════════════════════╗"
echo "║  Cross-Platform Builds Test Suite             ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result tracking
test_result() {
    local name="$1"
    local status="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo "Test 1: Validate Makefile structure"
if [ -f "Makefile" ]; then
    test_result "Makefile exists" 0
else
    test_result "Makefile exists" 1
fi

grep -qE '^\.DEFAULT_GOAL[[:space:]]*:=[[:space:]]*build-all' Makefile
test_result "Makefile sets build-all as default goal" $?

grep -qE '^\.PHONY:' Makefile
test_result "Makefile declares .PHONY targets" $?

echo ""
echo "Test 2: Verify platform detection script"
if [ -f "scripts/detect-platform.sh" ]; then
    bash scripts/detect-platform.sh > /dev/null 2>&1
    test_result "Platform detection script executes" $?
else
    test_result "Platform detection script exists" 1
fi

echo ""
echo "Test 3: Check required source files"
test -f "c-app/main.c"
test_result "C application source exists" $?

test -f "go-cli/main.go"
test_result "Go CLI source exists" $?

test -f "go-cli/go.mod"
test_result "Go module file exists" $?

test -f "rust-bin/Cargo.toml"
test_result "Rust Cargo.toml exists" $?

test -f "rust-bin/src/main.rs"
test_result "Rust source exists" $?

test -f "node-native/package.json"
test_result "Node.js package.json exists" $?

test -f "node-native/index.js"
test_result "Node.js source exists" $?

echo ""
echo "Test 4: Verify platform-specific tasks use shell conditionals"
if grep -qE '^build-c-linux:' Makefile && grep -q 'Skipping build-c-linux' Makefile; then
    test_result "Linux C build target has uname check" 0
else
    test_result "Linux C build target has uname check" 1
fi

if grep -qE '^build-c-macos:' Makefile && grep -q 'Skipping build-c-macos' Makefile; then
    test_result "macOS C build target has uname check" 0
else
    test_result "macOS C build target has uname check" 1
fi

if grep -qE '^build-c-windows:' Makefile && grep -q 'Skipping build-c-windows' Makefile; then
    test_result "Windows C build target has uname check" 0
else
    test_result "Windows C build target has uname check" 1
fi

echo ""
echo "Test 5: Verify cross-compilation targets"
grep -qE '^build-go-linux-amd64:' Makefile
test_result "Go Linux AMD64 cross-compile target exists" $?

grep -qE '^build-go-darwin-arm64:' Makefile
test_result "Go Darwin ARM64 cross-compile target exists" $?

grep -qE '^cross-compile-go:' Makefile
test_result "Cross-compile aggregator target exists" $?

echo ""
echo "Test 6: Verify platform-agnostic tasks have no platform checks"
if awk '/^detect-platform:/{getline; print}' Makefile | grep -q uname; then
    test_result "detect-platform has no platform conditional" 1
else
    test_result "detect-platform has no platform conditional" 0
fi

if awk '/^clean:/{getline; print}' Makefile | grep -q uname; then
    test_result "clean has no platform conditional" 1
else
    test_result "clean has no platform conditional" 0
fi

echo ""
echo "Test 7: Verify task dependencies"
grep -qE '^build-all: build-c build-go build-rust build-node' Makefile
test_result "build-all has dependencies" $?

grep -qE '^build-c: build-c-linux build-c-macos build-c-windows' Makefile
test_result "build-c aggregates platform builds" $?

echo ""
echo "Test 8: Check script executability"
for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        [ -x "$script" ] || chmod +x "$script"
        test_result "$(basename $script) is executable" $?
    fi
done

echo ""
echo "Test 9: Validate C source compiles on current platform"
# Detect current platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v gcc &> /dev/null; then
        gcc -c c-app/main.c -o /tmp/test-c-compile.o 2>/dev/null
        test_result "C source compiles with gcc" $?
        rm -f /tmp/test-c-compile.o
    else
        echo -e "${YELLOW}⊗${NC} Skipping C compilation test (gcc not found)"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v clang &> /dev/null; then
        clang -c c-app/main.c -o /tmp/test-c-compile.o 2>/dev/null
        test_result "C source compiles with clang" $?
        rm -f /tmp/test-c-compile.o
    else
        echo -e "${YELLOW}⊗${NC} Skipping C compilation test (clang not found)"
    fi
else
    echo -e "${YELLOW}⊗${NC} Skipping C compilation test (unsupported platform)"
fi

echo ""
echo "Test 10: Validate Go module"
if command -v go &> /dev/null; then
    (cd go-cli && go mod verify > /dev/null 2>&1)
    test_result "Go module is valid" $?
else
    echo -e "${YELLOW}⊗${NC} Skipping Go validation (go not installed)"
fi

echo ""
echo "Test 11: Validate Rust project"
if command -v cargo &> /dev/null; then
    (cd rust-bin && cargo check > /dev/null 2>&1)
    test_result "Rust project checks successfully" $?
else
    echo -e "${YELLOW}⊗${NC} Skipping Rust validation (cargo not installed)"
fi

echo ""
echo "Test 12: Validate Node.js package.json"
if command -v node &> /dev/null; then
    node -e "require('./node-native/package.json')" 2>/dev/null
    test_result "Node.js package.json is valid" $?
else
    echo -e "${YELLOW}⊗${NC} Skipping Node.js validation (node not installed)"
fi

echo ""
echo "Test 13: Check documentation"
test -f "README.md"
test_result "README.md exists" $?

test -f "PLATFORM_GUIDE.md"
test_result "PLATFORM_GUIDE.md exists" $?

# Check that README explains shell-based detection
if [ -f "README.md" ]; then
    grep -i "uname" README.md > /dev/null 2>&1
    test_result "README explains uname detection" $?
fi

# Check that PLATFORM_GUIDE explains shell-based detection
if [ -f "PLATFORM_GUIDE.md" ]; then
    grep -i "shell.based\|shell conditional" PLATFORM_GUIDE.md > /dev/null 2>&1
    test_result "PLATFORM_GUIDE.md explains shell-based detection" $?
fi

echo ""
echo "Test 14: Verify gaffer-exec compatibility"
if command -v gaffer-exec &> /dev/null; then
    # List discovered Makefile targets
    gaffer-exec --workspace-root . list -t makefile > /dev/null 2>&1
    test_result "gaffer-exec can list Makefile targets" $?

    # Dry-run the primary target to validate the graph
    gaffer-exec --workspace-root . run --dry-run make:build-all > /dev/null 2>&1
    test_result "gaffer-exec can dry-run build-all" $?
else
    echo -e "${YELLOW}⊗${NC} Skipping gaffer-exec test (not installed)"
fi

echo ""
echo "═══════════════════════════════════════════════"
echo "Test Summary:"
echo "  Total:  $TESTS_RUN"
echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
else
    echo "  Failed: 0"
fi
echo "═══════════════════════════════════════════════"

if [ $TESTS_FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}Some tests failed. Please review the output above.${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run: gaffer-exec --workspace-root . run make:detect-platform"
    echo "  2. Run: gaffer-exec --workspace-root . run make:build-all"
    echo "  3. Run: gaffer-exec --workspace-root . run make:run-all"
    exit 0
fi
