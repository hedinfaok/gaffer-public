# Distributed Build with Cloud Caching
#
# gaffer-exec --workspace-root . run make:distributed-build
# make distributed-build
#
# gaffer-exec consumes this standard Makefile and adds content-based caching,
# dependency-aware parallel scheduling, and output caching on top of it.

.PHONY: clean init fetch-cache build-gateway build-auth build-users upload-cache distributed-build clean-build

.DEFAULT_GOAL := distributed-build

clean:
	@rm -rf cmd/*/main cmd/*/*.exe pkg/*/*.a .cache/cmd .cache/pkg

init: clean
	@go mod tidy

fetch-cache: init
	@chmod +x scripts/fetch-cache.sh && ./scripts/fetch-cache.sh

build-gateway: fetch-cache
	@echo '🔨 Building gateway service...' && go build -o cmd/gateway/main ./cmd/gateway

build-auth: fetch-cache
	@echo '🔨 Building auth service...' && go build -o cmd/auth/main ./cmd/auth

build-users: fetch-cache
	@echo '🔨 Building users service...' && go build -o cmd/users/main ./cmd/users

upload-cache: build-gateway build-auth build-users
	@chmod +x scripts/upload-cache.sh && ./scripts/upload-cache.sh

distributed-build: upload-cache
	@echo '✅ Distributed build complete!' && echo '🚀 All microservices built with caching optimization'

clean-build: distributed-build
	@echo '🧹 Clean build (no cache)'
