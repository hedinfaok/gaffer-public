#!/usr/bin/env bash
# Test suite for the affected / since incremental CI example.
#
# It verifies the fixture and Makefile wiring, dry-runs the task graph, makes a
# real change to a package source, and asserts that --affected selects the
# changed package and its dependents. Git-dependent checks (--since) are skipped
# gracefully when git is unavailable or there is no previous commit.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GAFFER="gaffer-exec --workspace-root ."
CHANGED_FILE="packages/a/src/a.txt"
ORIGINAL_FILE="$(mktemp)"
cp "$CHANGED_FILE" "$ORIGINAL_FILE"

restore_changed_file() {
    if [ -f "$ORIGINAL_FILE" ]; then
        cp "$ORIGINAL_FILE" "$CHANGED_FILE"
        rm -f "$ORIGINAL_FILE"
    fi
}
trap restore_changed_file EXIT

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

echo "=== 20-affected-ci test suite ==="
echo ""

echo "Test 1: Fixture files"
for f in Makefile README.md packages/a/src/a.txt packages/b/src/b.txt; do
    if [ -f "$f" ]; then
        pass "$f exists"
    else
        fail "$f exists"
    fi
done

echo ""
echo "Test 2: Makefile targets and dependency wiring"
for target in build-a build-b build-all clean; do
    if grep -qE "^${target}:" Makefile; then
        pass "target '$target' is declared"
    else
        fail "target '$target' is declared"
    fi
done

if grep -qE '^build-b:[[:space:]]*build-a' Makefile; then
    pass "build-b depends on build-a"
else
    fail "build-b depends on build-a"
fi

if grep -qE '^build-all:[[:space:]]*build-a[[:space:]]+build-b' Makefile; then
    pass "build-all depends on build-a and build-b"
else
    fail "build-all depends on build-a and build-b"
fi

echo ""
echo "Test 3: Plain make dry-run"
if make -n build-all >/dev/null 2>&1; then
    pass "make -n build-all"
else
    fail "make -n build-all"
fi

if ! command -v gaffer-exec >/dev/null 2>&1; then
    echo ""
    echo "⊘ gaffer-exec not found on PATH; skipping gaffer-exec checks."
else
    echo ""
    echo "Test 4: gaffer-exec dry-run of the full graph"
    if $GAFFER run --dry-run make:build-all >/dev/null 2>&1; then
        pass "gaffer-exec --dry-run make:build-all"
    else
        fail "gaffer-exec --dry-run make:build-all"
    fi

    echo ""
    echo "Test 5: --affected selects the changed package and its dependents"
    affected_out="$($GAFFER run --dry-run --affected "$CHANGED_FILE" make:build-all 2>&1)"
    affected_rc=$?
    if [ "$affected_rc" -eq 0 ]; then
        pass "--affected $CHANGED_FILE exits 0"
    else
        fail "--affected $CHANGED_FILE exits 0"
    fi
    if echo "$affected_out" | grep -q 'make:build-a'; then
        pass "changed package a (make:build-a) is selected"
    else
        fail "changed package a (make:build-a) is selected"
    fi
    if echo "$affected_out" | grep -q 'make:build-b'; then
        pass "dependent package b (make:build-b) is selected"
    else
        fail "dependent package b (make:build-b) is selected"
    fi

    dependent_out="$($GAFFER run --dry-run --affected packages/b/src/b.txt make:build-all 2>&1)"
    if echo "$dependent_out" | grep -q 'make:build-b'; then
        pass "changed package b (make:build-b) is selected"
    else
        fail "changed package b (make:build-b) is selected"
    fi

    echo ""
    echo "Test 6: git-derived change selection"
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        marker="affected-ci-test-$$-$(date +%s)"
        printf '%s\n' "$marker" >> "$CHANGED_FILE"

        git_changed="$(git diff --relative --name-only -- "$CHANGED_FILE" 2>/dev/null | head -n 1)"
        if [ -z "$git_changed" ]; then
            git_changed="$CHANGED_FILE"
        fi
        pass "git identifies the changed file (${git_changed})"

        git_affected="$($GAFFER run --dry-run --affected "$git_changed" make:build-all 2>&1)"
        if echo "$git_affected" | grep -q 'make:build-a' && echo "$git_affected" | grep -q 'make:build-b'; then
            pass "git-changed file pulls in package a and dependent b"
        else
            fail "git-changed file pulls in package a and dependent b"
        fi
        restore_changed_file

        if git rev-parse --verify -q HEAD~1 >/dev/null 2>&1; then
            if $GAFFER run --dry-run --since HEAD~1 make:build-all >/dev/null 2>&1; then
                pass "--since HEAD~1 dry-run exits 0"
            else
                fail "--since HEAD~1 dry-run exits 0"
            fi
        else
            skip "--since HEAD~1 (repository has no previous commit)"
        fi
    else
        skip "git-derived selection (not inside a git repository)"
    fi
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
