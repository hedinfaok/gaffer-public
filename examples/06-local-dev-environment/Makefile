# Local Development Environment Orchestration
#
# Task graph for a full-stack dev environment (PostgreSQL + Express + React).
# gaffer-exec reads this Makefile and runs the targets with dependency-aware
# parallelism and caching:
#
#   gaffer-exec --workspace-root . run make:dev
#
# The same targets also work with plain make:
#
#   make dev

.DEFAULT_GOAL := dev

.PHONY: setup install-deps db-start api-start frontend-start dev test stop clean

# One-time environment setup (directories + auto port assignment)
setup:
	@scripts/setup.sh

# Install dependencies for every service
install-deps: setup
	@scripts/install-deps.sh

# Start PostgreSQL in Docker
db-start: install-deps
	@scripts/start-db.sh

# Start the Express API server
api-start: db-start
	@scripts/start-api.sh

# Start the React development server
frontend-start: install-deps
	@scripts/start-frontend.sh

# Bring up the full stack and wait for readiness
dev: db-start api-start frontend-start
	@scripts/wait-for-services.sh

# Run integration tests (requires services running)
test: dev
	@scripts/run-tests.sh

# Stop all services gracefully
stop:
	@scripts/stop-services.sh

# Clean up generated files and Docker resources
clean: stop
	@scripts/clean.sh
