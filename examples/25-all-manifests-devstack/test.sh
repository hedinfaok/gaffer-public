#!/usr/bin/env bash
# Verify the all-manifests dev stack.
#
# For every gaffer-exec manifest type used by this example, assert that
# discovery finds at least one graph, then assert that the orchestration and
# Procfile dry-runs succeed. Long-running Procfile processes are never started.
#
# A type is skipped with a warning only when gaffer-exec itself does not
# support it; a genuinely missing graph is a failure.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

FAILURES=0

pass() {
    printf '  ok   %s\n' "$1"
}

fail() {
    printf '  FAIL %s\n' "$1"
    FAILURES=$((FAILURES + 1))
}

warn() {
    printf '  WARN %s\n' "$1"
}

if ! command -v gaffer-exec >/dev/null 2>&1; then
    printf 'FAIL gaffer-exec is not on PATH\n'
    exit 1
fi

# Drop the discovery cache so edits to the manifests are always re-read.
rm -f .gaffer/discovery-cache.json

# check_type <filter> <expected-graph-id>
check_type() {
    local filter="$1"
    local expected="$2"
    local graphs

    if ! graphs="$(gaffer-exec --workspace-root . list -t "$filter" 2>/dev/null)"; then
        fail "$filter: discovery command failed"
        return
    fi

    if printf '%s\n' "$graphs" | grep -qF -- "$expected"; then
        pass "$filter -> $expected"
    elif printf '%s\n' "$graphs" | grep -qiE 'unknown|not a valid|unsupported'; then
        warn "$filter: gaffer-exec does not support this type in this build"
    else
        fail "$filter: expected graph '$expected' not found"
    fi
}

printf 'manifest discovery\n'
check_type makefile   "make:build-all"
check_type npm        "npm:build"
check_type turborepo  "turbo:build"
check_type cargo      "cargo:build"
check_type python     "python:test"
check_type procfile   "procfile:start"
check_type taskfile   "taskfile:build"
check_type justfile   "just:build"
check_type script     "script:scripts:db-init"
check_type bazel      "bazel:build"

printf 'dry runs\n'
if gaffer-exec --workspace-root . run --dry-run make:build-all >/dev/null 2>&1; then
    pass "make:build-all dry-runs cleanly"
else
    fail "make:build-all dry-runs cleanly"
fi

if gaffer-exec --workspace-root . run --dry-run procfile:start >/dev/null 2>&1; then
    pass "procfile:start dry-runs cleanly"
else
    fail "procfile:start dry-runs cleanly"
fi

if gaffer-exec --workspace-root . run --dry-run \
    --auto-port 3000 --port-patterns 'procfile:*' procfile:start >/dev/null 2>&1; then
    pass "procfile:start dry-runs cleanly with --auto-port"
else
    fail "procfile:start dry-runs cleanly with --auto-port"
fi

if [ "$FAILURES" -ne 0 ]; then
    printf '\n%d check(s) failed\n' "$FAILURES"
    exit 1
fi

printf '\nall checks passed\n'
