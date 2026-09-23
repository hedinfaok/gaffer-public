# Network-Aware Build Orchestration
#
# Task graph for the multi-region network-aware build. gaffer-exec reads this
# Makefile and runs the targets with dependency-aware parallelism and caching:
#
#   gaffer-exec --workspace-root . run make:network-build
#
# The same targets also work with plain make:
#
#   make network-build

.PHONY: clean init detect-network fetch-cache-us-east fetch-cache-us-west fetch-cache-eu build-api build-worker build-frontend verify-builds upload-cache sync-regions network-build benchmark monitor test-failure

.DEFAULT_GOAL := network-build

# Remove all build artifacts and caches
clean:
	@rm -rf cmd/*/main cmd/*/*.exe pkg/*/*.a .cache/ bin/

# Initialize Go modules and working directories
init: clean
	@go mod tidy && mkdir -p bin .cache

# Detect the optimal cache region from network topology
detect-network: init
	@chmod +x scripts/detect-region.sh && ./scripts/detect-region.sh

# Fetch artifacts from the US-East cache
fetch-cache-us-east: detect-network
	@chmod +x scripts/fetch-cache.sh && ./scripts/fetch-cache.sh us-east

# Fetch artifacts from the US-West cache
fetch-cache-us-west: detect-network
	@chmod +x scripts/fetch-cache.sh && ./scripts/fetch-cache.sh us-west

# Fetch artifacts from the EU-Central cache
fetch-cache-eu: detect-network
	@chmod +x scripts/fetch-cache.sh && ./scripts/fetch-cache.sh eu-central

# Build the API service
build-api: fetch-cache-us-east
	@echo 'Building API service...' && go build -o bin/api ./cmd/api

# Build the worker service
build-worker: fetch-cache-us-east
	@echo 'Building worker service...' && go build -o bin/worker ./cmd/worker

# Build the frontend service
build-frontend: fetch-cache-us-east
	@echo 'Building frontend service...' && go build -o bin/frontend ./cmd/frontend

# Verify all service binaries
verify-builds: build-api build-worker build-frontend
	@chmod +x scripts/verify-builds.sh && ./scripts/verify-builds.sh

# Upload artifacts to the primary regional cache
upload-cache: verify-builds
	@chmod +x scripts/upload-cache.sh && ./scripts/upload-cache.sh

# Synchronize caches across regions
sync-regions: upload-cache
	@chmod +x scripts/sync-caches.sh && ./scripts/sync-caches.sh

# Full network-aware build
network-build: sync-regions
	@echo '✓ Network-aware build complete!' && echo 'Build statistics:' && ./scripts/show-stats.sh

# Run performance benchmarks
benchmark:
	@chmod +x scripts/benchmark.sh && ./scripts/benchmark.sh

# Monitor network performance
monitor:
	@chmod +x scripts/monitor-network.sh && ./scripts/monitor-network.sh

# Exercise failure recovery
test-failure:
	@chmod +x scripts/test-failure.sh && ./scripts/test-failure.sh
