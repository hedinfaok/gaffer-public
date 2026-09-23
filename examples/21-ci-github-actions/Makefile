# CI with GitHub Actions and gaffer-exec
#
# Task graph for the tiny Node project in this directory. gaffer-exec reads this
# standard Makefile, infers the dependency graph from the prerequisites, and can
# cache the build outputs between CI runs:
#
#   gaffer-exec --workspace-root . run --cache sha256 make:build
#   gaffer-exec --workspace-root . run make:test
#   gaffer-exec --workspace-root . run make:ci
#
# The same targets also work with plain make:
#
#   make ci

.PHONY: install build test ci clean

.DEFAULT_GOAL := ci

# Install dependencies from the lockfile (no runtime dependencies today, so this
# is fast, but it keeps the target realistic for a growing project).
install:
	@npm ci --no-audit --no-fund

# Compile the sources into the dist/ artifact that the cache stores.
build: install
	@node scripts/build.js

# Run the unit tests. They import the sources directly, so testing is
# independent of the build artifact and can run on its own in CI.
test: install
	@node --test

# Full pipeline: install, build, test.
ci: install build test
	@echo '✓ CI pipeline complete'

# Remove build output and installed dependencies.
clean:
	@rm -rf dist node_modules
	@echo 'cleaned dist/ and node_modules/'
