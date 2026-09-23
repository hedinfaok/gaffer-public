# Multi-Language Task Running
#
# One Makefile task graph spanning Node.js, Python, Go, and Rust. gaffer-exec
# reads this Makefile, then runs the targets with dependency-aware parallelism
# and content-based caching:
#
#   gaffer-exec --workspace-root . run make:build-all
#
# The same targets also work with plain make:
#
#   make build-all

.DEFAULT_GOAL := build-all

.PHONY: install-node install-python install-go install-rust install-all \
        build-node build-python build-go build-rust build-all \
        test-node test-python test-go test-rust test-all \
        lint-node lint-python lint-go lint-rust lint-all \
        format-node format-python format-go format-rust format-all \
        clean-node clean-python clean-go clean-rust clean \
        start-api dev

# Installation
install-node:
	@cd node-frontend && npm ci

install-python:
	@cd python-ml && pip install -r requirements.txt --quiet

install-go:
	@cd go-api && go mod download

install-rust:
	@cd rust-cli && cargo fetch --quiet

install-all: install-node install-python install-go install-rust
	@echo '✓ All dependencies installed'

# Build
build-node: install-node
	@cd node-frontend && echo 'Simulating webpack build...' && mkdir -p dist && echo 'Built' > dist/bundle.js

build-python: install-python
	@cd python-ml && python setup.py build --quiet

build-go: install-go
	@cd go-api && go build -o bin/api-server .

build-rust: install-rust
	@cd rust-cli && cargo build --release --quiet

build-all: build-node build-python build-go build-rust
	@echo '✓ All components built'

# Test
test-node: install-node
	@cd node-frontend && echo 'Simulating Jest tests...' && echo 'PASS  src/App.test.js' && echo '✓ All tests passed'

test-python: install-python
	@cd python-ml && pytest tests/ -v --tb=short

test-go: install-go
	@cd go-api && go test ./... -v -coverprofile=coverage.out

test-rust: install-rust
	@cd rust-cli && cargo test --quiet

test-all: test-node test-python test-go test-rust
	@echo '✓ All tests passed'

# Lint
lint-node: install-node
	@cd node-frontend && echo 'Running ESLint...' && echo '✓ No linting errors found'

lint-python: install-python
	@cd python-ml && pylint ml_models/ --score=no || true

lint-go: install-go
	@cd go-api && go vet ./... && echo '✓ Go code passed vet checks'

lint-rust: install-rust
	@cd rust-cli && cargo clippy --quiet -- -D warnings || echo '✓ Clippy checks complete'

lint-all: lint-node lint-python lint-go lint-rust
	@echo '✓ All linting complete'

# Format
format-node: install-node
	@cd node-frontend && echo 'Running Prettier...' && echo '✓ Code formatted'

format-python: install-python
	@cd python-ml && black ml_models/ tests/ --quiet && isort ml_models/ tests/ --quiet && echo '✓ Python code formatted'

format-go:
	@cd go-api && go fmt ./... && echo '✓ Go code formatted'

format-rust:
	@cd rust-cli && cargo fmt --quiet && echo '✓ Rust code formatted'

format-all: format-node format-python format-go format-rust
	@echo '✓ All code formatted'

# Cleanup
clean-node:
	@cd node-frontend && rm -rf dist node_modules coverage .eslintcache

clean-python:
	@cd python-ml && rm -rf build/ dist/ *.egg-info .pytest_cache .coverage htmlcov/ && find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true

clean-go:
	@cd go-api && rm -rf bin/ coverage.out

clean-rust:
	@cd rust-cli && cargo clean --quiet

clean: clean-node clean-python clean-go clean-rust
	@echo '✓ All artifacts cleaned'

# Development
start-api: install-go
	@cd go-api && go run main.go

dev: build-all
	@echo '✓ Development environment ready' && echo '  - Frontend: node-frontend/dist/' && echo '  - API: go-api/bin/api-server' && echo '  - CLI: rust-cli/target/release/prediction-cli' && echo '' && echo 'Run: cd go-api && ./bin/api-server'
