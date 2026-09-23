# Incremental Testing Orchestration
#
# Test task graph (unit -> integration -> e2e) with dependency-aware ordering,
# resource-aware parallel scheduling, retries and content-based caching.
# gaffer-exec reads this Makefile and runs the targets:
#
#   gaffer-exec --workspace-root . run make:test-all
#
# The same targets also work with plain make:
#
#   make test-all

.PHONY: clean install lint unit-tests-lib unit-tests-api unit-tests-ui unit-tests-flaky integration-tests e2e-tests coverage-report performance-benchmark test-all test-all-with-flaky test-ci test-watch test-debug test-signal-handling

.DEFAULT_GOAL := test-all

# Remove previous test artifacts and caches
clean:
	@rm -rf coverage/ node_modules/.cache/ .nyc_output/ test-metrics.json

# Install test dependencies
install: clean
	@npm install

# Linting checks
lint: install
	@echo '📝 Running linting checks...' && echo '✅ Linting passed (would run eslint in real project)'

# Library unit tests
unit-tests-lib: install
	@echo '🧪 Running library unit tests...' && npm run test:lib

# API unit tests
unit-tests-api: install
	@echo '🧪 Running API unit tests...' && npm run test:api

# UI unit tests
unit-tests-ui: install
	@echo '🧪 Running UI unit tests...' && npm run test:ui

# Flaky test suite (demonstrates retry with exponential backoff)
unit-tests-flaky: install
	@echo '🎲 Running flaky test suite...' && node tests/flaky/run-flaky-tests.js

# Integration tests (wait for unit tests)
integration-tests: unit-tests-lib unit-tests-api
	@echo '🔗 Running integration tests...' && npm run test:integration

# End-to-end tests (wait for integration and UI unit tests)
e2e-tests: integration-tests unit-tests-ui
	@echo '🌐 Running e2e tests...' && npm run test:e2e

# Coverage report (aggregates all unit test suites)
coverage-report: unit-tests-lib unit-tests-api unit-tests-ui
	@echo '📊 Generating coverage report...' && npm run test:coverage

# Performance benchmarks
performance-benchmark: install
	@echo '⚡ Running performance benchmarks...' && node scripts/benchmark-tests.js

# Run the full test suite and aggregate metrics
test-all: e2e-tests coverage-report lint
	@echo '✅ All tests completed successfully!' && echo '📊 Test Summary: Unit, Integration, E2E tests passed' && node scripts/aggregate-metrics.js

# Full suite including the flaky test demonstration
test-all-with-flaky: test-all unit-tests-flaky
	@echo '✅ All tests including flaky test demonstration completed!'

# CI pipeline (full suite plus benchmarks)
test-ci: test-all performance-benchmark
	@echo '🚀 CI test suite complete' && echo 'Ready for deployment'

# Test watch mode for development
test-watch: install
	@echo '👀 Starting test watch mode...' && timeout 3 npm test -- --watch --watchAll=false || echo '⚡ Watch mode started (timeout for demo)'

# Run tests in debug mode
test-debug: install
	@echo '🐛 Running tests in debug mode...' && npm test -- --verbose --detectOpenHandles

# Demonstrate graceful signal handling
test-signal-handling: install
	@node scripts/test-signal-handling.js
