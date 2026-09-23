# All-manifests dev stack: one Makefile orchestrates every other manifest type.
#
#   gaffer-exec --workspace-root . run make:build-all
#   gaffer-exec --workspace-root . run make:dev
#   gaffer-exec --workspace-root . run make:test-all
#   gaffer-exec --workspace-root . run make:ports
#
# build-all fans out to one helper target per manifest. Each helper runs that
# manifest's own gaffer-exec graph, so the orchestration stays visible as a
# dependency graph instead of a wall of inline commands.

.PHONY: build-all dev test-all clean ports
.PHONY: build-npm build-turbo build-cargo build-python
.PHONY: build-taskfile build-just build-bazel build-db
.PHONY: test-npm test-cargo test-python test-taskfile test-just

.DEFAULT_GOAL := dev

build-all: build-npm build-turbo build-cargo build-python build-taskfile build-just build-bazel build-db
	@echo "build-all: every manifest build graph completed"

build-npm:
	gaffer-exec --workspace-root . run npm:build

build-turbo:
	gaffer-exec --workspace-root . run turbo:build

build-cargo:
	gaffer-exec --workspace-root . run cargo:build

build-python:
	gaffer-exec --workspace-root . run python:install

build-taskfile:
	gaffer-exec --workspace-root . run taskfile:build

build-just:
	gaffer-exec --workspace-root . run just:build

build-bazel:
	gaffer-exec --workspace-root . run bazel:build

build-db:
	gaffer-exec --workspace-root . run script:scripts:db-init

# Start the stack. Procfile processes receive PORT automatically from the
# free ports found at or above 3000 for graphs matching 'procfile:*'.
dev:
	gaffer-exec --workspace-root . run --auto-port 3000 --port-patterns 'procfile:*' procfile:start

test-all: test-npm test-cargo test-python test-taskfile test-just
	@echo "test-all: every manifest test graph completed"

test-npm:
	gaffer-exec --workspace-root . run npm:test

test-cargo:
	gaffer-exec --workspace-root . run cargo:test

test-python:
	gaffer-exec --workspace-root . run python:test

test-taskfile:
	gaffer-exec --workspace-root . run taskfile:test

test-just:
	gaffer-exec --workspace-root . run just:test

clean:
	rm -rf build dist web/dist api/dist worker/target
	rm -rf bazel-out bazel-bin bazel-testlogs .gaffer/cache
	@echo "clean: removed build outputs"

ports:
	@echo "Ports are assigned automatically by 'make dev' (base 3000, pattern procfile:*)."
	@echo "Each Procfile process receives the next free PORT at runtime."
