#!/usr/bin/env bash
# Verify that gaffer-exec discovers the Taskfile.yml and justfile in this
# workspace, using the per-manifest filters and the workspace-root flag.

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

# assert_contains <description> <needle> <haystack>
assert_contains() {
    if printf '%s\n' "$3" | grep -qF -- "$2"; then
        pass "$1"
    else
        fail "$1 (missing '$2')"
    fi
}

# assert_absent <description> <needle> <haystack>
assert_absent() {
    if printf '%s\n' "$3" | grep -qF -- "$2"; then
        fail "$1 (unexpected '$2')"
    else
        pass "$1"
    fi
}

if ! command -v gaffer-exec >/dev/null 2>&1; then
    printf 'FAIL gaffer-exec is not on PATH\n'
    exit 1
fi

# Drop the discovery cache so edits to the manifests are always re-read.
rm -f .gaffer/discovery-cache.json

printf 'taskfile manifest\n'
taskfile_graphs="$(gaffer-exec --workspace-root . list -t taskfile 2>/dev/null)"
assert_contains "taskfile filter finds taskfile:setup" "taskfile:setup" "$taskfile_graphs"
assert_contains "taskfile filter finds taskfile:build" "taskfile:build" "$taskfile_graphs"
assert_contains "taskfile filter finds taskfile:test" "taskfile:test" "$taskfile_graphs"
assert_absent "taskfile filter excludes just graphs" "just:build" "$taskfile_graphs"

printf 'justfile manifest\n'
justfile_graphs="$(gaffer-exec --workspace-root . list -t justfile 2>/dev/null)"
assert_contains "justfile filter finds just:setup" "just:setup" "$justfile_graphs"
assert_contains "justfile filter finds just:build" "just:build" "$justfile_graphs"
assert_contains "justfile filter finds just:test" "just:test" "$justfile_graphs"
assert_contains "justfile filter finds just:clean" "just:clean" "$justfile_graphs"

# Discovered just recipes are namespaced with "just:", not "justfile:".
assert_absent "justfile graph ids do not use the justfile: prefix" "justfile:build" "$justfile_graphs"

printf 'run preflight\n'
if gaffer-exec --workspace-root . run --dry-run taskfile:build >/dev/null 2>&1; then
    pass "taskfile:build dry-runs cleanly"
else
    fail "taskfile:build dry-runs cleanly"
fi

if gaffer-exec --workspace-root . run --dry-run just:build >/dev/null 2>&1; then
    pass "just:build dry-runs cleanly"
else
    fail "just:build dry-runs cleanly"
fi

if [ "$FAILURES" -ne 0 ]; then
    printf '\n%d check(s) failed\n' "$FAILURES"
    exit 1
fi

printf '\nall checks passed\n'
