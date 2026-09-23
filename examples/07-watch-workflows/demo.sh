#!/bin/bash
# Demo script showing watch mode workflows in action
set -e

EXAMPLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$EXAMPLE_DIR"

echo "═══════════════════════════════════════════════════════"
echo "  Example 07: Watch Mode Workflows Demo"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "This demo shows how fswatch + gaffer-exec provide"
echo "intelligent, dependency-aware watch mode for multi-service"
echo "applications."
echo ""

# Check prerequisites
echo "Step 1: Checking prerequisites..."
echo "--------------------------------"

if ! command -v fswatch &> /dev/null; then
    echo "✗ fswatch is not installed"
    echo ""
    echo "Install it with:"
    echo "  macOS:   brew install fswatch"
    echo "  Linux:   apt-get install fswatch"
    exit 1
fi
echo "✓ fswatch: $(fswatch --version | head -n1)"

if ! command -v gaffer-exec &> /dev/null; then
    echo "✗ gaffer-exec is not installed"
    echo ""
    echo "Please install gaffer-exec first"
    exit 1
fi
echo "✓ gaffer-exec: installed"

echo ""

# Show the project structure
echo "Step 2: Project Structure"
echo "-------------------------"
echo ""
echo "This example has three services with dependencies:"
echo ""
echo "shared-lib/     ← TypeScript utilities"
echo "    ↓"
echo "    ├─→ api-service/    ← Express API"
echo "    └─→ frontend/       ← React app"
echo ""
echo "When shared-lib changes, both dependents rebuild automatically!"
echo ""

# Show the watch scripts
echo "Step 3: Watch Scripts"
echo "---------------------"
echo ""
echo "We have four watch scripts:"
ls -1 scripts/watch-*.sh | while read -r script; do
    echo "  • $(basename "$script")"
done
echo ""
echo "Each uses fswatch to monitor files and trigger gaffer-exec rebuilds."
echo ""

# Show example watch pattern
echo "Step 4: Watch Pattern Example"
echo "------------------------------"
echo ""
echo "Here's how watch-shared-lib.sh works:"
echo ""
echo "┌─────────────────────────────────────────────────────┐"
echo "│  fswatch \\                                          │"
echo "│    --latency 0.5 \\        # Debounce 500ms        │"
echo "│    --include '\\.ts\$' \\    # Watch TypeScript      │"
echo "│    shared-lib/src/ |                               │"
echo "│  while read -r file; do                            │"
echo "│    gaffer-exec --workspace-root . \\                │"
echo "│      run make:rebuild-shared-lib                    │"
echo "│  done                                               │"
echo "└─────────────────────────────────────────────────────┘"
echo ""

# Show dependency cascade
echo "Step 5: Dependency Cascade in the Makefile"
echo "-------------------------------------------"
echo ""
echo "The magic happens in the Makefile targets:"
echo ""
echo "rebuild-shared-lib:"
grep -A 1 '^rebuild-shared-lib:' Makefile
echo ""
echo "rebuild-api (depends on shared-lib):"
grep -A 1 '^rebuild-api:' Makefile
echo ""
echo "rebuild-frontend (depends on shared-lib):"
grep -A 1 '^rebuild-frontend:' Makefile
echo ""

# Show how to use it
echo "Step 6: Usage"
echo "-------------"
echo ""
echo "To start watch mode, run:"
echo ""
echo "  ./scripts/watch-all.sh"
echo ""
echo "Then in another terminal, make changes:"
echo ""
echo "  # Change shared-lib → rebuilds shared + api + frontend"
echo "  echo '// change' >> shared-lib/src/index.ts"
echo ""
echo "  # Change api → rebuilds only api"
echo "  echo '// change' >> api-service/src/server.ts"
echo ""
echo "  # Change frontend → rebuilds only frontend"
echo "  echo '// change' >> frontend/src/App.tsx"
echo ""

# Offer to run test
echo "═══════════════════════════════════════════════════════"
echo ""
read -p "Run test.sh to verify everything works? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    ./test.sh
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "Demo complete!"
echo ""
echo "Next steps:"
echo "  1. Read QUICKSTART.md for hands-on tutorial"
echo "  2. Read README.md for detailed explanation"
echo "  3. Read ARCHITECTURE.md for technical deep dive"
echo "  4. Run: ./scripts/watch-all.sh to start watching"
echo "═══════════════════════════════════════════════════════"
