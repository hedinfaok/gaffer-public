# Remote Cache with MinIO
#
# A real (not simulated) remote cache round-trip. gaffer-exec runs the cached
# build and, when --cache is active, injects GAFFER_CACHE_KEY (hex sha256 of the
# task inputs) and GAFFER_CACHE_ARTIFACT (path to the local cache tarball, empty
# on a miss) into the hook graphs.
#
#   gaffer-exec --workspace-root . run --cache sha256 \
#     --cache-get-remote script:scripts:restore \
#     --cache-set-remote script:scripts:save \
#     make:build
#
# `cache-restore` and `cache-save` are the Makefile-native names for those hook
# graphs. gaffer-exec 0.8.0 discovers Makefile targets as composite graphs and
# only executes atomic hook graphs, so this example also ships the hooks as
# executable scripts under scripts/, which gaffer-exec discovers atomically as
# `script:scripts:restore` and `script:scripts:save`. The Makefile targets call
# the same scripts, so both entry points stay in sync.

.PHONY: build cache-restore cache-save clean

.DEFAULT_GOAL := build

# Produce a small deterministic artifact in dist/. The recipe is a no-op when
# dist/ has already been restored from the remote cache.
build:
	@if [ -f dist/output.txt ]; then echo 'build: dist/ already present (restored)'; exit 0; fi; \
	 mkdir -p dist; \
	 if command -v sha256sum >/dev/null 2>&1; then H="sha256sum"; else H="shasum -a 256"; fi; \
	 $$H src/input.txt | awk '{print $$1}' > dist/input.sha256; \
	 tr '[:lower:]' '[:upper:]' < src/input.txt > dist/output.txt; \
	 printf '{"sha256":"%s","source":"src/input.txt"}\n' "$$(cat dist/input.sha256)" > dist/build-info.json; \
	 echo "build: wrote $$(ls dist | tr '\n' ' ')"

# Makefile-native hook targets (equivalent to the script graphs).
cache-restore:
	@bash scripts/restore.sh

cache-save:
	@bash scripts/save.sh

clean:
	@rm -rf dist
	@echo 'clean: removed dist/'
