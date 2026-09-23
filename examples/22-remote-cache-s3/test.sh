#!/usr/bin/env bash
# Test suite for the remote cache (MinIO) example.
#
# With Docker available this starts MinIO, clears the bucket, runs the cached
# build twice and asserts that the second run is served from the remote cache.
# Without Docker it records `blocked (environment: docker)` and still validates
# the graph with a dry-run. Exit 0 when the round-trip passes or is blocked;
# exit 1 only on a real failure.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

test_result() {
  local name="$1" status="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ "$status" -eq 0 ]; then
    echo -e "${GREEN}✓${NC} $name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗${NC} $name"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

have_docker() {
  command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1
}

compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  else
    docker-compose "$@"
  fi
}

run_cached() {
  gaffer-exec --workspace-root . run --cache sha256 \
    --cache-get-remote script:scripts:restore \
    --cache-set-remote script:scripts:save \
    make:build 2>&1
}

echo "════════════════════════════════════════════════"
echo "  Remote Cache (MinIO) Test Suite"
echo "════════════════════════════════════════════════"
echo ""

# Test 1: static files and dry-run.
test -f Makefile && test_result "Makefile exists" 0 || test_result "Makefile exists" 1
test -f docker-compose.yml && test_result "docker-compose.yml exists" 0 || test_result "docker-compose.yml exists" 1
test -f scripts/restore.sh && test_result "scripts/restore.sh exists" 0 || test_result "scripts/restore.sh exists" 1
test -f scripts/save.sh && test_result "scripts/save.sh exists" 0 || test_result "scripts/save.sh exists" 1
test -f README.md && test_result "README.md exists" 0 || test_result "README.md exists" 1

if command -v gaffer-exec >/dev/null 2>&1; then
  gaffer-exec --workspace-root . run --dry-run make:build >/dev/null 2>&1
  test_result "gaffer-exec dry-run make:build" $?
else
  test_result "gaffer-exec on PATH" 1
fi

# The static checks and dry-run above are real failures if they failed.
if [ "$TESTS_FAILED" -gt 0 ]; then
  exit 1
fi

echo ""
if ! have_docker; then
  echo -e "${YELLOW}⊘${NC} blocked (environment: docker)"
  echo "  MinIO round-trip skipped; dry-run above still validated the graph."
  echo ""
  exit 0
fi

# shellcheck source=scripts/lib
. "$SCRIPT_DIR/scripts/lib"

cleanup() {
  compose down -v >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Starting MinIO..."
if ! compose up -d >/dev/null 2>&1; then
  echo -e "${YELLOW}⊘${NC} blocked (environment: docker) — could not start MinIO"
  exit 0
fi

# Wait for the S3 API to answer.
minio_up=0
for _ in $(seq 1 60); do
  if curl -fsS "${MINIO_ENDPOINT}/minio/health/live" >/dev/null 2>&1; then
    minio_up=1
    break
  fi
  sleep 1
done

if [ "$minio_up" -ne 1 ]; then
  echo -e "${YELLOW}⊘${NC} blocked (environment: docker) — MinIO did not become ready"
  exit 0
fi

# Ensure the bucket exists (idempotent).
compose run --rm createbucket >/dev/null 2>&1 || true

if ! remote_available; then
  echo -e "${YELLOW}⊘${NC} blocked (environment: docker) — no mc/aws client to talk to MinIO"
  exit 0
fi

echo ""
echo "Test 2: first run stores the artifact in MinIO"
remote_rm_recursive >/dev/null 2>&1 || true
rm -rf .gaffer dist
RUN1_OUTPUT="$(run_cached)"
echo "$RUN1_OUTPUT" | grep -q "save: uploaded"
test_result "first run uploaded the cache artifact" $?

echo ""
echo "Test 3: second run restores from the remote cache"
rm -rf .gaffer dist
RUN2_OUTPUT="$(run_cached)"
echo "$RUN2_OUTPUT" | grep -q "REMOTE HIT"
test_result "second run reported a remote hit" $?
echo "$RUN2_OUTPUT" | grep -q "already present (restored)"
test_result "build was satisfied by the restored artifact" $?

echo ""
echo "Test 4: restored artifact content"
if [ -f dist/output.txt ] && grep -q "REMOTE CACHE ROUND-TRIP" dist/output.txt; then
  test_result "dist/output.txt restored with expected content" 0
else
  test_result "dist/output.txt restored with expected content" 1
fi

echo ""
echo "════════════════════════════════════════════════"
echo "Test Summary:"
echo "  Total:  $TESTS_RUN"
echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
if [ "$TESTS_FAILED" -gt 0 ]; then
  echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
else
  echo "  Failed: 0"
fi
echo "════════════════════════════════════════════════"

if [ "$TESTS_FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
