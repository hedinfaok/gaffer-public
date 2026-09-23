#!/usr/bin/env bash
# Test suite for the GitHub Actions + gaffer-exec CI example.
#
# It verifies the fixture and Makefile wiring, dry-runs the build and test
# graphs, checks the committed workflow, and confirms that
# `gaffer-exec export --format github-actions` succeeds and produces a workflow.
# gaffer-exec checks are skipped gracefully when the binary is not on PATH.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GAFFER="gaffer-exec --workspace-root ."
EXPORT_FILE=".gaffer/exports/make-build.yml"

TESTS_RUN=0
TESTS_FAILED=0

pass() {
    TESTS_RUN=$((TESTS_RUN + 1))
    echo "  ✓ $1"
}

fail() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  ✗ $1"
}

skip() {
    echo "  ⊘ SKIP: $1"
}

echo "=== 21-ci-github-actions test suite ==="
echo ""

echo "Test 1: Fixture files"
for f in Makefile package.json package-lock.json scripts/build.js src/index.js src/math.js src/math.test.js .github/workflows/gaffer-ci.yml README.md; do
    if [ -f "$f" ]; then
        pass "$f exists"
    else
        fail "$f exists"
    fi
done

echo ""
echo "Test 2: Makefile targets, .PHONY, and default goal"
for target in install build test ci clean; do
    if grep -qE "^${target}:" Makefile; then
        pass "target '$target' is declared"
    else
        fail "target '$target' is declared"
    fi
done

if grep -qE '^\.PHONY:' Makefile; then
    pass ".PHONY is declared"
else
    fail ".PHONY is declared"
fi

if grep -qE '^build:[[:space:]]*install' Makefile; then
    pass "build depends on install"
else
    fail "build depends on install"
fi

if grep -qE '^ci:[[:space:]]*install[[:space:]]+build[[:space:]]+test' Makefile; then
    pass "ci depends on install, build, and test"
else
    fail "ci depends on install, build, and test"
fi

echo ""
echo "Test 3: Plain make dry-run"
if make -n ci >/dev/null 2>&1; then
    pass "make -n ci"
else
    fail "make -n ci"
fi

if ! command -v gaffer-exec >/dev/null 2>&1; then
    echo ""
    echo "⊘ gaffer-exec not found on PATH; skipping gaffer-exec checks."
else
    echo ""
    echo "Test 4: gaffer-exec dry-run of the build and test graphs"
    if $GAFFER run --dry-run make:build >/dev/null 2>&1; then
        pass "gaffer-exec --dry-run make:build"
    else
        fail "gaffer-exec --dry-run make:build"
    fi

    if $GAFFER run --dry-run make:test >/dev/null 2>&1; then
        pass "gaffer-exec --dry-run make:test"
    else
        fail "gaffer-exec --dry-run make:test"
    fi

    if $GAFFER run --dry-run make:ci >/dev/null 2>&1; then
        pass "gaffer-exec --dry-run make:ci"
    else
        fail "gaffer-exec --dry-run make:ci"
    fi

    echo ""
    echo "Test 5: export --format github-actions"
    rm -f "$EXPORT_FILE"
    if $GAFFER export make:build --format github-actions >/dev/null 2>&1; then
        pass "gaffer-exec export make:build --format github-actions exits 0"
    else
        fail "gaffer-exec export make:build --format github-actions exits 0"
    fi

    if [ -f "$EXPORT_FILE" ]; then
        pass "export writes $EXPORT_FILE"
    else
        fail "export writes $EXPORT_FILE"
    fi

    if [ -f "$EXPORT_FILE" ] && grep -q 'gaffer-exec run make:build' "$EXPORT_FILE"; then
        pass "exported workflow runs the make:build graph"
    else
        fail "exported workflow runs the make:build graph"
    fi
fi

echo ""
echo "Test 6: Committed workflow wiring"
WF=".github/workflows/gaffer-ci.yml"
if [ -f "$WF" ]; then
    for needle in "actions/checkout" "actions/setup-node" "cache/restore" "cache/save" "run --cache sha256 make:build" "run make:test"; do
        if grep -qF "$needle" "$WF"; then
            pass "workflow contains '$needle'"
        else
            fail "workflow contains '$needle'"
        fi
    done
else
    fail "$WF exists"
fi

echo ""
echo "───────────────────────────────────────────────"
echo "Tests run:    $TESTS_RUN"
echo "Tests failed: $TESTS_FAILED"
echo "───────────────────────────────────────────────"

if [ "$TESTS_FAILED" -gt 0 ]; then
    echo "✗ Some tests failed."
    exit 1
fi

echo "✓ All tests passed."
exit 0
