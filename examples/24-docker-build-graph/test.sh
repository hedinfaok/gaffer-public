#!/usr/bin/env bash
# Test suite for the docker-build-graph example.
#
# If Docker is available, build the image graph and assert the images exist.
# Otherwise record blocked (environment: docker) and validate the graph with a
# dry-run. A blocked environment exits 0; only real failures exit non-zero.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BASE_IMAGE="${BASE_IMAGE:-gaffer-docker-build-graph-base:latest}"
APP_IMAGE="${APP_IMAGE:-gaffer-docker-build-graph-app:latest}"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════╗"
echo "║  Docker Build Graph Test Suite                 ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

echo "Test 1: Required files"
for f in Makefile README.md test.sh base/Dockerfile app/Dockerfile; do
    if [ -f "$f" ]; then
        echo -e "${GREEN}✓${NC} $f exists"
    else
        echo -e "${RED}✗${NC} $f missing"
        exit 1
    fi
done

echo ""
echo "Test 2: Makefile declares the image graph"
grep -qE '^build-base:' Makefile || { echo -e "${RED}✗${NC} build-base target missing"; exit 1; }
grep -qE '^build-app: build-base' Makefile || { echo -e "${RED}✗${NC} build-app does not depend on build-base"; exit 1; }
grep -qE '^build-all: build-base build-app' Makefile || { echo -e "${RED}✗${NC} build-all does not aggregate both"; exit 1; }
grep -qE '^clean:' Makefile || { echo -e "${RED}✗${NC} clean target missing"; exit 1; }
echo -e "${GREEN}✓${NC} build-base, build-app, build-all, clean have the expected edges"

echo ""
echo "Test 3: app image builds FROM the base image"
grep -qF 'FROM ${BASE_IMAGE}' app/Dockerfile || { echo -e "${RED}✗${NC} app/Dockerfile is not FROM the base image"; exit 1; }
echo -e "${GREEN}✓${NC} app/Dockerfile is FROM \${BASE_IMAGE}"

echo ""
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    echo "Test 4: Docker detected - building the image graph"
    gaffer-exec --workspace-root . run make:build-all

    echo ""
    echo "Test 5: Assert images exist"
    docker image inspect "$BASE_IMAGE" >/dev/null
    echo -e "${GREEN}✓${NC} $BASE_IMAGE exists"
    docker image inspect "$APP_IMAGE" >/dev/null
    echo -e "${GREEN}✓${NC} $APP_IMAGE exists"

    echo ""
    echo "═══════════════════════════════════════════════"
    echo -e "${GREEN}✓ All tests passed (Docker ran)${NC}"
    exit 0
else
    echo -e "${YELLOW}⊘ blocked (environment: docker)${NC}"
    echo ""
    echo "Test 4: Validate the graph with a dry-run"
    gaffer-exec --workspace-root . run --dry-run make:build-all
    echo -e "${GREEN}✓${NC} dry-run of make:build-all succeeded"

    echo ""
    echo "═══════════════════════════════════════════════"
    echo -e "${YELLOW}⊘ Tests blocked (environment: docker) - dry-run passed${NC}"
    exit 0
fi
