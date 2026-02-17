# Example 08: Multi-Language Task Running

This example demonstrates how `gaffer-exec` unifies task orchestration across multiple programming languages and replaces traditional tools like npm scripts, Makefiles, and shell scripts with a single `graph.json` configuration.

## The Problem

Modern applications often use multiple programming languages, each with their own task running conventions:

- **Node.js**: npm/yarn scripts in `package.json`
- **Python**: `Makefile`, `tox.ini`, or custom shell scripts
- **Go**: `Makefile` or shell scripts
- **Rust**: `cargo` commands with custom scripts

This leads to:
- **Fragmented tooling**: Developers must learn and remember different commands for each language
- **Inconsistent workflows**: Each language has different conventions for testing, linting, building
- **No cross-language orchestration**: Can't easily coordinate tasks across languages
- **Difficult CI/CD**: Complex build pipelines juggling multiple tools
- **Sequential execution**: No automatic parallelization across languages

### Traditional Approach

```bash
# Install dependencies
cd node-frontend && npm ci && cd ..
cd python-ml && pip install -r requirements.txt && cd ..
cd go-api && go mod download && cd ..
cd rust-cli && cargo fetch && cd ..

# Build everything
cd node-frontend && npm run build && cd ..
cd python-ml && make build && cd ..
cd go-api && ./build.sh && cd ..
cd rust-cli && cargo build --release && cd ..

# Run tests
cd node-frontend && npm test && cd ..
cd python-ml && make test && cd ..
cd go-api && ./test.sh && cd ..
cd rust-cli && cargo test && cd ..
```

This is tedious, error-prone, and doesn't leverage parallelism!

## The Solution

With `gaffer-exec`, you define **all tasks** in a single `graph.json` and get:

✅ **Unified interface**: Same commands for all languages  
✅ **Automatic parallelization**: Tasks run in parallel when possible  
✅ **Dependency orchestration**: Define cross-language dependencies  
✅ **Consistent workflows**: Same commands for every task  

### Unified Approach

```bash
# Install all dependencies (runs in parallel)
gaffer-exec run install-all --graph graph.json

**Note**: Use `--graph-override` flag to ensure only graph.json tasks run (prevents auto-discovered package.json interference):

```bash
# Build everything (parallel across languages)
gaffer-exec --graph-override graph.json run build-all

# Run all tests (parallel across languages)
gaffer-exec --graph-override graph.json run test-all

# Lint all code (parallel)
gaffer-exec --graph-override graph.json run lint-all
```

## Project Structure

```
08-multi-language-task-running/
├── graph.json                    # Unified task orchestration
├── node-frontend/                # React dashboard
│   ├── package.json              # Traditional npm scripts (for reference)
│   └── src/
│       ├── App.js
│       └── App.test.js
├── python-ml/                    # ML prediction service
│   ├── Makefile                  # Traditional Makefile (for reference)
│   ├── requirements.txt
│   ├── setup.py
│   ├── ml_models/
│   │   ├── classifier.py
│   │   └── predictor.py
│   └── tests/
├── go-api/                       # REST API server
│   ├── build.sh                  # Traditional build script (for reference)
│   ├── test.sh                   # Traditional test script (for reference)
│   ├── main.go
│   └── handlers/
│       ├── health.go
│       └── predictions.go
└── rust-cli/                     # Command-line tool
    ├── Cargo.toml
    └── src/
        ├── main.rs
        ├── api.rs
        └── output.rs
```

## Available Tasks

### Installation Tasks
- `install-node` - Install Node.js dependencies
- `install-python` - Install Python dependencies
- `install-go` - Download Go dependencies
- `install-rust` - Fetch Rust dependencies
- `install-all` - **Install all dependencies in parallel**

### Build Tasks
- `build-node` - Build React frontend
- `build-python` - Build Python ML package
- `build-go` - Compile Go API server
- `build-rust` - Compile Rust CLI tool
- `build-all` - **Build all components in parallel**

### Test Tasks
- `test-node` - Run Jest tests
- `test-python` - Run pytest tests
- `test-go` - Run Go tests with coverage
- `test-rust` - Run Rust tests
- `test-all` - **Run all tests in parallel**

### Lint Tasks
- `lint-node` - ESLint checks
- `lint-python` - pylint + flake8
- `lint-go` - go vet checks
- `lint-rust` - cargo clippy
- `lint-all` - **Lint all code in parallel**

### Format Tasks
- `format-node` - Prettier formatting
- `format-python` - black + isort
- `format-go` - go fmt
- `format-rust` - cargo fmt
- `format-all` - **Format all code in parallel**

### Cleanup Tasks
- `clean-node` - Remove Node.js artifacts
- `clean-python` - Remove Python artifacts
- `clean-go` - Remove Go artifacts
- `clean-rust` - Remove Rust artifacts
- `clean` - **Clean all artifacts**

### Development Tasks
- `start-api` - Start Go API server
- `dev` - Build all and prepare dev environment

## Quick Start

### 1. Install Dependencies

```bash
cd examples/08-multi-language-task-running
gaffer-exec run install-all --graph graph.json
```

This runs all install tasks **in parallel**, completing much faster than running them sequentially.

### 2. Build Everything

```bash
gaffer-exec run build-all --graph graph.json
```

Builds all components in parallel. Each build task:
- Only runs if dependencies are installed
- Uses caching to skip if nothing changed
- Runs in parallel with other language builds

### 3. Run Tests

```bash
gaffer-exec run test-all --graph graph.json
```

Runs the entire test suite across all languages in parallel.

### 4. Lint Code

```bash
gaffer-exec run lint-all --graph graph.json
```

### 5. Format Code

```bash
gaffer-exec run format-all --graph graph.json
```

### 6. Development Workflow

```bash
# First time setup
gaffer-exec run install-all --graph graph.json
gaffer-exec run build-all --graph graph.json

# Start API server
gaffer-exec run start-api --graph graph.json

# In another terminal, test the CLI
cd rust-cli
./target/release/prediction-cli health
```

## Key Features Demonstrated

### 1. Cross-Language Dependencies

The graph automatically handles dependencies across languages. For example:
- `build-go` depends on `install-go`
- `build-all` waits for all individual builds
- `test-all` requires installations but runs tests in parallel

### 2. Smart Caching

Each task specifies cache keys:

```json
{
  "cache": {
    "enabled": true,
    "keys": ["node-frontend/src/**/*.js", "node-frontend/package.json"]
  }
}
```

If these files haven't changed, the task is skipped!

### 3. Incremental Execution

Change one Python file? Only `build-python` and `test-python` re-run. Everything else uses cached results.

### 4. Parallel Execution

Tasks without dependencies run in parallel automatically:
- All 4 install tasks run simultaneously
- All 4 test tasks run simultaneously
- All 4 lint tasks run simultaneously

### 5. Unified Interface

Instead of remembering:
- `npm run build` for Node.js
- `make build` for Python
- `./build.sh` for Go
- `cargo build --release` for Rust

You use: `gaffer-exec run build-all --graph graph.json` for everything!

## Comparison with Traditional Tools

### Traditional Approach
```bash
# Developer needs to know:
cd node-frontend && npm ci && npm run build && npm test
cd ../python-ml && pip install -r requirements.txt && make build && make test
cd ../go-api && go mod download && ./build.sh && ./test.sh
cd ../rust-cli && cargo fetch && cargo build --release && cargo test

# Run sequentially (slow!)
# Manual coordination of dependencies
# Different commands for each language
```

### Gaffer Approach
```bash
# One command for everything:
gaffer-exec run test-all --graph graph.json

# Automatically:
# - Installs all dependencies in parallel
# - Builds all components in parallel
# - Runs all tests in parallel
# - Handles cross-language dependencies
```

## Performance Benefits

See `benchmark.sh` for performance comparisons. On a multi-core machine:

- **Install-all**: ~60% faster (parallel execution)
- **Build-all**: ~70% faster (parallel execution)
- **Test-all**: ~65% faster (parallel execution)

## Traditional Configuration Files (For Reference)

This example includes the traditional configuration files to show what we're replacing:

- `node-frontend/package.json` - npm scripts
- `python-ml/Makefile` - Python build tasks
- `go-api/build.sh` - Go build script
- `go-api/test.sh` - Go test script

These files are **not used** when running with gaffer-exec. They're included for educational purposes to show the "before" state.

## Real-World Use Cases

This pattern is ideal for:

1. **Microservices**: Different services in different languages
2. **Fullstack apps**: Frontend + Backend + CLI + Infrastructure
3. **ML platforms**: Python models + Go API + React dashboard
4. **Developer tools**: Multi-language CLI toolchains
5. **Monorepos**: Unified task running across all packages

## CI/CD Integration

In CI pipelines, this approach simplifies configuration:

```yaml
# .github/workflows/ci.yml
- name: Install
  run: gaffer-exec run install-all --graph graph.json

- name: Build
  run: gaffer-exec run build-all --graph graph.json

- name: Test
  run: gaffer-exec run test-all --graph graph.json

- name: Lint
  run: gaffer-exec run lint-all --graph graph.json
```

No need for language-specific CI steps!

## Testing

Run the test suite:

```bash
./test.sh
```

This validates:
- All install tasks work
- All build tasks produce expected outputs
- All test tasks pass
- Task dependencies are correct

## Benchmarking

Compare performance against traditional tools:

```bash
./benchmark.sh
```

This runs both traditional and gaffer-based approaches and reports timing differences.

## Learn More

- See `graph.json` for the complete task graph
- Compare with example 03 (multi-language-build) which focuses on build orchestration
- This example focuses on comprehensive **task orchestration** across the development lifecycle

## Summary

This example shows how `gaffer-exec` replaces:
- ❌ npm/yarn scripts
- ❌ Makefiles
- ❌ Shell scripts
- ❌ Manual task coordination

With:
- ✅ Single `graph.json` configuration
- ✅ Unified command interface
- ✅ Automatic parallelization
- ✅ Cross-language orchestration
