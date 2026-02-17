# Example 08: Multi-Language Task Running

## Quick Reference

### Common Tasks
```bash
gaffer-exec run install-all --graph graph.json   # Install all dependencies
gaffer-exec run build-all --graph graph.json     # Build everything
gaffer-exec run test-all --graph graph.json      # Run all tests
gaffer-exec run lint-all --graph graph.json      # Lint all code
gaffer-exec run format-all --graph graph.json    # Format all code
gaffer-exec run clean --graph graph.json         # Clean artifacts
```

### Development
```bash
gaffer-exec run dev --graph graph.json           # Setup dev environment
gaffer-exec run start-api --graph graph.json     # Start API server
```

### Individual Components
```bash
# Node.js
gaffer-exec run install-node --graph graph.json
gaffer-exec run build-node --graph graph.json
gaffer-exec run test-node --graph graph.json

# Python
gaffer-exec run install-python --graph graph.json
gaffer-exec run build-python --graph graph.json
gaffer-exec run test-python --graph graph.json

# Go
gaffer-exec run install-go --graph graph.json
gaffer-exec run build-go --graph graph.json
gaffer-exec run test-go --graph graph.json

# Rust
gaffer-exec run install-rust --graph graph.json
gaffer-exec run build-rust --graph graph.json
gaffer-exec run test-rust --graph graph.json
```

## What Makes This Different

This example focuses on **task orchestration** across languages:
- Installing dependencies
- Building artifacts
- Running tests
- Linting code
- Formatting code
- Development workflows

Compared to Example 03 (multi-language-build) which focuses solely on build orchestration.

## Performance Benefits

- **Parallelization**: All tasks run in parallel when possible
- **Caching**: Smart caching across all languages
- **Incremental**: Only rebuild what changed
- **Unified**: One tool for everything

Run `./benchmark.sh` to see performance comparisons.
