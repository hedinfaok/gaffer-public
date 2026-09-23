# Affected / Since Incremental CI
#
# A two-package monorepo where package b depends on package a. gaffer-exec reads
# this standard Makefile, infers the dependency graph from the prerequisites,
# and can run only the tasks affected by a set of changed files:
#
#   gaffer-exec --workspace-root . run --affected packages/a/src/a.txt make:build-all
#   gaffer-exec --workspace-root . run --since HEAD~1 make:build-all
#
# The same targets also work with plain make:
#
#   make build-all

.PHONY: build-a build-b build-all clean

# Package a -> out/a/a.txt
build-a:
	@mkdir -p out/a
	@cp packages/a/src/a.txt out/a/a.txt
	@echo 'built packages/a -> out/a/a.txt'

# Package b depends on a: it consumes out/a/a.txt plus its own source
build-b: build-a
	@mkdir -p out/b
	@cat out/a/a.txt packages/b/src/b.txt > out/b/b.txt
	@echo 'built packages/b -> out/b/b.txt (depends on a)'

# Top of the graph: builds both packages
build-all: build-a build-b
	@echo 'built all packages: a, b'

# Remove every build artifact
clean:
	@rm -rf out
	@echo 'cleaned out/'
