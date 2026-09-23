# Example 08: Multi-Language Task Running

## Quick Reference

All tasks are targets in the root `Makefile`, addressed as `make:<target>` by gaffer-exec.

### Common Tasks
```bash
gaffer-exec --workspace-root . run make:install-all   # Install all dependencies
gaffer-exec --workspace-root . run make:build-all     # Build everything
gaffer-exec --workspace-root . run make:test-all      # Run all tests
gaffer-exec --workspace-root . run make:lint-all      # Lint all code
gaffer-exec --workspace-root . run make:format-all    # Format all code
gaffer-exec --workspace-root . run make:clean         # Clean artifacts
```

### Development
```bash
gaffer-exec --workspace-root . run make:dev           # Setup dev environment
gaffer-exec --workspace-root . run make:start-api     # Start API server
```

### Individual Components
```bash
# Node.js
gaffer-exec --workspace-root . run make:install-node
gaffer-exec --workspace-root . run make:build-node
gaffer-exec --workspace-root . run make:test-node

# Python
gaffer-exec --workspace-root . run make:install-python
gaffer-exec --workspace-root . run make:build-python
gaffer-exec --workspace-root . run make:test-python

# Go
gaffer-exec --workspace-root . run make:install-go
gaffer-exec --workspace-root . run make:build-go
gaffer-exec --workspace-root . run make:test-go

# Rust
gaffer-exec --workspace-root . run make:install-rust
gaffer-exec --workspace-root . run make:build-rust
gaffer-exec --workspace-root . run make:test-rust
```

## What Makes This Different

This example focuses on **task orchestration** across languages:
- Installing dependencies
- Building artifacts
- Running tests
- Linting code
- Formatting code
- Development workflows

One top-level `Makefile` defines the whole graph; gaffer-exec reads it and adds
dependency-aware parallel scheduling plus content-based caching. Compared to
Example 03 (multi-language-build) which focuses solely on build orchestration.

## Performance Benefits

- **Parallelization**: All tasks run in parallel when possible
- **Caching**: Smart caching across all languages
- **Incremental**: Only rebuild what changed
- **Unified**: One tool for everything

Run `./benchmark.sh` to see performance comparisons.
