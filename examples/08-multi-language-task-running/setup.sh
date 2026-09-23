#!/bin/bash
# Quick setup script for example 08

set -e

EXAMPLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$EXAMPLE_DIR"

echo "========================================="
echo "Setting up Example 08"
echo "========================================="
echo ""

# Check if gaffer-exec is available
if ! command -v gaffer-exec &> /dev/null; then
  echo "Error: gaffer-exec not found in PATH"
  echo "Please install gaffer first: npm install -g @gaffer/cli"
  exit 1
fi

echo "Installing all dependencies..."
gaffer-exec --workspace-root . run make:install-all

echo ""
echo "Building all components..."
gaffer-exec --workspace-root . run make:build-all

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Try these commands:"
echo "  gaffer-exec --workspace-root . run make:test-all"
echo "  gaffer-exec --workspace-root . run make:lint-all"
echo "  gaffer-exec --workspace-root . run make:dev"
echo ""
echo "Or run the tests:"
echo "  ./test.sh"
echo ""
echo "Or run benchmarks:"
echo "  ./benchmark.sh"
echo ""
