# Docker Build Graph
#
# Container images as a dependency graph. gaffer-exec consumes this standard
# Makefile and adds content-based caching and dependency-aware scheduling:
#
#   gaffer-exec --workspace-root . run make:build-all
#   make build-all
#
# The app image builds FROM the base image tag, so build-app depends on
# build-base.

BASE_IMAGE ?= gaffer-docker-build-graph-base:latest
APP_IMAGE  ?= gaffer-docker-build-graph-app:latest

.DEFAULT_GOAL := build-all

.PHONY: build-base build-app build-all clean

build-base:
	@docker build -t $(BASE_IMAGE) base
	@echo '✓ Built base image $(BASE_IMAGE)'

build-app: build-base
	@docker build -t $(APP_IMAGE) --build-arg BASE_IMAGE=$(BASE_IMAGE) app
	@echo '✓ Built app image $(APP_IMAGE)'

build-all: build-base build-app
	@echo '✓ All images built: $(BASE_IMAGE), $(APP_IMAGE)'

clean:
	@docker image rm -f $(APP_IMAGE) $(BASE_IMAGE) 2>/dev/null || true
	@echo '✓ Removed example images'
