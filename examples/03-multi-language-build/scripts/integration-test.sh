#!/usr/bin/env bash
#
# Cross-language integration smoke test for the multi-language build example.
#
# Unlike a canned echo, this script runs the artifacts that multi-language-build
# produced and asserts on their real output. It starts the Rust backend, then
# exercises the Go CLI, Python analysis, and Node.js test harness against it.
# Any broken component makes the script exit non-zero.

set -uo pipefail

cd "$(dirname "$0")/.."
ROOT="$(pwd)"

RUST_BIN="rust-backend/target/release/rust-backend"
GO_BIN="go-cli/go-cli"
BACKEND_LOG="$(mktemp -t rust-backend-XXXXXX.log)"

RUST_PID=""
cleanup() {
    if [ -n "$RUST_PID" ] && kill -0 "$RUST_PID" 2>/dev/null; then
        kill "$RUST_PID" 2>/dev/null || true
        wait "$RUST_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

fail() {
    echo "✗ $1" >&2
    exit 1
}

pass() {
    echo "✓ $1"
}

echo "Running cross-language integration test..."
echo ""

# ---------------------------------------------------------------------------
# 1. Rust backend: start it and probe its real HTTP endpoints.
# ---------------------------------------------------------------------------
[ -x "$ROOT/$RUST_BIN" ] || fail "Rust binary missing: $RUST_BIN (run make:rust-backend)"

"$ROOT/$RUST_BIN" >"$BACKEND_LOG" 2>&1 &
RUST_PID=$!

backend_up=""
for _ in $(seq 1 50); do
    if curl -fsS http://localhost:8080/health >/dev/null 2>&1; then
        backend_up="yes"
        break
    fi
    # Bail out early if the server process died.
    if ! kill -0 "$RUST_PID" 2>/dev/null; then
        break
    fi
    sleep 0.2
done

if [ -z "$backend_up" ]; then
    echo "Rust backend log:" >&2
    cat "$BACKEND_LOG" >&2
    fail "Rust backend did not answer on http://localhost:8080/health"
fi

health_json="$(curl -fsS http://localhost:8080/health)" || fail "curl /health failed"
echo "$health_json" | grep -q '"status":"healthy"' \
    || fail "unexpected /health payload: $health_json"
pass "Rust backend serves /health (status=healthy)"

metrics_json="$(curl -fsS http://localhost:8080/metrics)" || fail "curl /metrics failed"
echo "$metrics_json" | grep -q '"languages_integrated":4' \
    || fail "unexpected /metrics payload: $metrics_json"
pass "Rust backend serves /metrics (languages_integrated=4)"

# ---------------------------------------------------------------------------
# 2. Go CLI: query the running Rust backend.
# ---------------------------------------------------------------------------
[ -x "$ROOT/$GO_BIN" ] || fail "Go CLI binary missing: $GO_BIN (run make:go-cli)"

go_out="$("$ROOT/$GO_BIN" health 2>&1)" || fail "Go CLI exited non-zero: $go_out"
echo "$go_out" | grep -q "Backend Status: healthy" \
    || fail "Go CLI did not report a healthy backend: $go_out"
pass "Go CLI queries Rust backend (Backend Status: healthy)"

# ---------------------------------------------------------------------------
# 3. Python analysis: fetch metrics and produce its results file.
# ---------------------------------------------------------------------------
py_out="$(cd "$ROOT/python-ml" && python3 analyze.py 2>&1)" || fail "Python analysis exited non-zero: $py_out"
echo "$py_out" | grep -q "Successfully fetched metrics from Rust backend" \
    || fail "Python analysis did not reach the backend: $py_out"
[ -f "$ROOT/python-ml/ml_analysis_results.json" ] \
    || fail "Python analysis did not write ml_analysis_results.json"
pass "Python analysis consumes the Rust backend"

# ---------------------------------------------------------------------------
# 4. Node.js test harness: run the frontend package's test script.
# ---------------------------------------------------------------------------
node_out="$(cd "$ROOT/node-frontend" && npm run test 2>&1)" || fail "Node.js test script failed: $node_out"
echo "$node_out" | grep -q "Node.js frontend tests pass" \
    || fail "unexpected Node.js test output: $node_out"
pass "Node.js frontend test harness runs"

echo ""
echo "✓ Integration tests passed"
