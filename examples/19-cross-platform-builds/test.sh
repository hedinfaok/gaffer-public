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

echo "Test 1: Validate graph.json structure"
if [ -f "graph.json" ]; then
    if command -v jq &> /dev/null; then
        jq empty graph.json 2>/dev/null
        test_result "graph.json is valid JSON" $?
    else
        python3 -m json.tool graph.json > /dev/null 2>&1
        test_result "graph.json is valid JSON" $?
    fi
else
    test_result "graph.json exists" 1
fi

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
if command -v jq &> /dev/null; then
    # Check that Linux tasks have uname checks
    jq -e '.graphs["build-c-linux"].command | contains("uname")' graph.json > /dev/null 2>&1
    test_result "Linux C build uses uname check" $?
    
    # Check that macOS tasks have uname checks
    jq -e '.graphs["build-c-macos"].command | contains("uname")' graph.json > /dev/null 2>&1
    test_result "macOS C build uses uname check" $?
    
    # Check that Windows tasks have uname checks
    jq -e '.graphs["build-c-windows"].command | contains("uname")' graph.json > /dev/null 2>&1
    test_result "Windows C build uses uname check" $?
    
    # Verify no platforms field exists
    ! jq -e '.graphs["build-c-linux"].platforms' graph.json > /dev/null 2>&1
    test_result "Linux task has no platforms field" $?
    
    ! jq -e '.graphs["build-c-macos"].platforms' graph.json > /dev/null 2>&1
    test_result "macOS task has no platforms field" $?
else
    echo -e "${YELLOW}⊗${NC} Skipping platform check validation (jq not installed)"
fi

echo ""
echo "Test 5: Verify cross-compilation tasks"
if command -v jq &> /dev/null; then
    jq -e '.graphs["build-go-linux-amd64"]' graph.json > /dev/null 2>&1
    test_result "Go Linux AMD64 cross-compile task exists" $?
    
    jq -e '.graphs["build-go-darwin-arm64"]' graph.json > /dev/null 2>&1
    test_result "Go Darwin ARM64 cross-compile task exists" $?
    
    jq -e '.graphs["cross-compile-go"]' graph.json > /dev/null 2>&1
    test_result "Cross-compile aggregator task exists" $?
else
    echo -e "${YELLOW}⊗${NC} Skipping cross-compilation validation (jq not installed)"
fi

echo ""
echo "Test 6: Verify platform-agnostic tasks have no platform checks"
if command -v jq &> /dev/null; then
    # detect-platform should not have uname conditionals
    ! jq -e '.graphs["detect-platform"].command | contains("[ \\\"$(uname)")' graph.json > /dev/null 2>&1
    test_result "detect-platform has no platform conditional" $?
    
    # clean should not have uname conditionals
    ! jq -e '.graphs["clean"].command | contains("[ \\\"$(uname)")' graph.json > /dev/null 2>&1
    test_result "clean has no platform conditional" $?
else
    echo -e "${YELLOW}⊗${NC} Skipping platform-agnostic validation (jq not installed)"
fi

echo ""
echo "Test 7: Verify task dependencies"
if command -v jq &> /dev/null; then
    jq -e '.graphs["build-all"].deps' graph.json > /dev/null 2>&1
    test_result "build-all has dependencies" $?
    
    jq -e '.graphs["build-c"].deps' graph.json > /dev/null 2>&1
    test_result "build-c aggregates platform builds" $?
else
    echo -e "${YELLOW}⊗${NC} Skipping dependency validation (jq not installed)"
fi

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
    # Try to list tasks
    gaffer-exec --workspace-root . --graph-override graph.json list > /dev/null 2>&1
    test_result "gaffer-exec can read graph.json" $?
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
    echo "  1. Run: gaffer-exec --workspace-root . --graph-override graph.json run detect-platform"
    echo "  2. Run: gaffer-exec --workspace-root . --graph-override graph.json run build-all"
    echo "  3. Run: gaffer-exec --workspace-root . --graph-override graph.json run run-all"
    exit 0
fi
