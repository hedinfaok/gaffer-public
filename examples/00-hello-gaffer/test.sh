#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== Testing 00-hello-gaffer ==="
echo ""

# Test 1: the core graph runs both independent tasks and the aggregate
echo "Test 1: core graph (make:hello)..."
output=$(gaffer-exec --workspace-root . run make:hello 2>&1) || {
    echo "✗ make:hello failed"
    echo "$output"
    exit 1
}

if echo "$output" | grep -q "hello from task A" && echo "$output" | grep -q "hello from task B"; then
    echo "✓ both independent tasks ran"
else
    echo "✗ expected both tasks to run"
    echo "$output"
    exit 1
fi

if echo "$output" | grep -q "hello graph complete"; then
    echo "✓ aggregate target ran after its dependencies"
else
    echo "✗ aggregate target did not run"
    echo "$output"
    exit 1
fi

echo ""

# Test 2: the cached target stores its output, then restores it on a cache hit
echo "Test 2: cached target (make:cached)..."

# Start from a clean slate so the cache and output do not exist yet
rm -rf .gaffer out

first=$(gaffer-exec --workspace-root . run --cache sha256 make:cached 2>&1) || {
    echo "✗ first cached run failed"
    echo "$first"
    exit 1
}

if [ -f out/stamp.txt ]; then
    echo "✓ first run produced out/stamp.txt"
else
    echo "✗ first run did not produce out/stamp.txt"
    echo "$first"
    exit 1
fi

# Delete the output so the next run has to restore it from the cache
rm -rf out

second=$(gaffer-exec --workspace-root . run --cache sha256 make:cached 2>&1) || {
    echo "✗ second cached run failed"
    echo "$second"
    exit 1
}

if echo "$second" | grep -qi "cache hit"; then
    echo "✓ second run was a cache hit"
else
    echo "✗ expected a cache hit on the second run"
    echo "$second"
    exit 1
fi

if [ -f out/stamp.txt ]; then
    echo "✓ cached output restored to out/stamp.txt"
else
    echo "✗ cache hit did not restore out/stamp.txt"
    exit 1
fi

echo ""
echo "=== All tests passed ==="
