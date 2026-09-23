# Watch Mode Workflows
#
# Task graph for the fswatch + gaffer-exec watch workflow. gaffer-exec reads
# this Makefile and runs the targets with dependency-aware parallelism and
# caching:
#
#   gaffer-exec --workspace-root . run make:build-all
#
# The same targets also work with plain make:
#
#   make build-all

.PHONY: clean install-deps build-shared-lib build-api build-frontend build-all rebuild-shared-lib rebuild-api rebuild-frontend start-api start-frontend dev test

.DEFAULT_GOAL := build-all

# Remove all build artifacts
clean:
	@rm -rf shared-lib/dist api-service/dist frontend/build

# Install dependencies for every service
install-deps:
	@cd shared-lib && npm install && cd ../api-service && npm install && cd ../frontend && npm install

# Shared library (required by both services)
build-shared-lib: install-deps
	@cd shared-lib && npm run build

# API service (depends on shared-lib)
build-api: build-shared-lib
	@cd api-service && npm run build

# Frontend app (depends on shared-lib, builds in parallel with the API)
build-frontend: build-shared-lib
	@cd frontend && npm run build

# Build everything
build-all: build-api build-frontend
	@echo '✅ All services built'

# Rebuild shared-lib without reinstalling dependencies (used by watch mode)
rebuild-shared-lib:
	@cd shared-lib && npm run build

# Rebuild the API (used by watch mode)
rebuild-api: rebuild-shared-lib
	@cd api-service && npm run build

# Rebuild the frontend (used by watch mode)
rebuild-frontend: rebuild-shared-lib
	@cd frontend && npm run build

# Start the API service
start-api: build-api
	@cd api-service && node dist/server.js

# Start the frontend dev server
start-frontend: build-frontend
	@cd frontend && npx serve -s build -p 3000

# Start all services
dev: start-api start-frontend
	@echo '🚀 All services started. Run ./scripts/watch-all.sh in another terminal to enable watch mode.'

# Run the validation tests
test:
	@./test.sh
