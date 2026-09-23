# All-Manifests Dev Stack

What this shows: a single local-dev web stack in which every gaffer-exec manifest type participates, with the Procfile processes receiving automatically assigned ports.

## What you'll learn

- How gaffer-exec unifies ten manifest types into one task graph: Makefile, npm, Turborepo, Cargo, Python, Procfile, Taskfile, justfile, shell scripts, and Bazel.
- How manifest namespaces become graph id prefixes: `make:`, `npm:`, `turbo:`, `cargo:`, `python:`, `procfile:`, `taskfile:`, `just:`, `script:`, `bazel:`.
- How to filter discovery per manifest type with `list -t <type>`.
- How a Procfile becomes a composite graph (`procfile:start`) whose children (`procfile:start:web`, `procfile:start:api`, `procfile:start:worker`) each see a `PORT` environment variable.
- How `--auto-port` plus `--port-patterns` assigns a free port per process instead of hard-coding one.

## Prerequisites

- gaffer-exec 0.8.0 on your PATH.
- Node.js 18 or later and npm for the frontend (`node --version`).
- Python 3 for the API service (`python3 --version`).
- Optional: Rust and Cargo for the worker, Bazel for the generated artifact, `task` and `just` if you want to run those manifests outside gaffer-exec.

The discovery and dry-run checks in `test.sh` need none of the language toolchains; they only need gaffer-exec.

## Quick start

```bash
# Start the whole stack. Procfile processes get ports at or above 3000.
gaffer-exec --workspace-root . run --auto-port 3000 --port-patterns 'procfile:*' procfile:start

# Or through the Makefile orchestration (same command):
gaffer-exec --workspace-root . run make:dev
```

Build and test everything through the Makefile graph:

```bash
gaffer-exec --workspace-root . run make:build-all
gaffer-exec --workspace-root . run make:test-all
```

Discover the graphs each manifest contributes:

```bash
gaffer-exec --workspace-root . list -t makefile
gaffer-exec --workspace-root . list -t npm
gaffer-exec --workspace-root . list -t turborepo
gaffer-exec --workspace-root . list -t cargo
gaffer-exec --workspace-root . list -t python
gaffer-exec --workspace-root . list -t procfile
gaffer-exec --workspace-root . list -t taskfile
gaffer-exec --workspace-root . list -t justfile
gaffer-exec --workspace-root . list -t script
gaffer-exec --workspace-root . list -t bazel
```

## Task graph

| Manifest type | Filter (`list -t`) | Graph id | Role in the stack |
|---------------|--------------------|----------|-------------------|
| Makefile | `makefile` | `make:build-all`, `make:dev`, `make:test-all`, `make:clean`, `make:ports` | Orchestration: fans out to every other manifest graph and starts the stack |
| Procfile | `procfile` | `procfile:start` | Runs `web`, `api`, and `worker` as long-running processes with `$PORT` |
| npm | `npm` | `npm:build`, `npm:test`, `npm:start`, `npm:install` | Root workspace scripts plus the `web` package |
| Turborepo | `turborepo` | `turbo:build`, `turbo:test` | Pipeline that runs the workspace `build`/`test` tasks |
| Cargo | `cargo` | `cargo:build`, `cargo:test` | Builds and tests the Rust `worker` |
| Python | `python` | `python:install`, `python:test`, `python:lint` | Installs, tests, and lints the `api` service |
| Taskfile | `taskfile` | `taskfile:build`, `taskfile:test` | Alternative task runner for the build artifact |
| justfile | `justfile` | `just:build`, `just:test`, `just:migrate` | Alternative recipes, including a database migration |
| Shell script | `script` | `script:scripts:db-init`, `script:scripts:health` | Database initialization and health probe |
| Bazel | `bazel` | `bazel:build` | Generates an artifact with a `genrule` |

## How it works

`make:build-all` is a composite graph: each prerequisite (`build-npm`, `build-turbo`, and so on) is a real Make target, so gaffer-exec turns the Make dependencies into graph edges and runs the independent builds in parallel. Each helper then invokes that manifest's own graph, so the orchestration stays visible.

Port assignment is the interesting part. The `Procfile` declares three processes:

```text
web: node web/serve.js
api: python3 api/serve.py
worker: cargo run --quiet --manifest-path worker/Cargo.toml
```

gaffer-exec discovers them as the composite `procfile:start` with children `procfile:start:web`, `procfile:start:api`, and `procfile:start:worker`. When you pass `--auto-port 3000 --port-patterns 'procfile:*'`, gaffer-exec walks the matching graphs, checks that each candidate port is free, and injects a distinct `PORT` into each child's environment starting at the base port. The processes read `PORT` themselves; nothing in the Procfile hard-codes a port. Because the three processes are declared in order, they receive consecutive free ports (3000, 3001, 3002 when all are free), and if a port is already taken gaffer-exec moves to the next one.

## Expected output

Discovery lists one graph per type (abridged):

```text
$ gaffer-exec --workspace-root . list -t turborepo

Available graphs:

turbo:build (composite):
└── turbo:web:build

turbo:test (composite):
└── turbo:web:test
```

The orchestration dry-run shows the fan-out without running anything:

```text
$ gaffer-exec --workspace-root . run --dry-run make:build-all

Dry run - would execute 9 graphs:
  - make:build-all: make -C ... -f .../Makefile build-all
    Dependencies: make:build-npm, make:build-turbo, make:build-cargo, ...
```

The Procfile dry-run shows the three long-running processes that `make:dev` would start:

```text
$ gaffer-exec --workspace-root . run --dry-run procfile:start

Dry run - would execute 3 graphs:
  - procfile:start:web: node web/serve.js
  - procfile:start:api: python3 api/serve.py
  - procfile:start:worker: cargo run --quiet --manifest-path worker/Cargo.toml
```

## Testing

```bash
cd examples/25-all-manifests-devstack
bash test.sh
```

`test.sh` asserts that `list -t <type>` finds a graph for each of the ten manifest types, and that `run --dry-run make:build-all`, `run --dry-run procfile:start`, and the `--auto-port` dry-run all succeed. It never starts the long-running Procfile processes, and exits non-zero on any real failure.

## Troubleshooting

- **A newly added target is not listed**: gaffer-exec caches discovery under `.gaffer/`. Delete `.gaffer/discovery-cache.json` and re-run the command.
- **Turborepo finds no graphs**: gaffer-exec's Turborepo discovery expands workspace patterns that end in `/*`, so the root `package.json` uses a glob alongside the explicit `web` entry. Keep `turbo.json` at the workspace root with a `pipeline` object.
- **Bazel finds no graphs**: discovery needs both `WORKSPACE.bazel` and a `BUILD.bazel` at the workspace root.
- **Scripts are not discovered**: shell scripts must live under `scripts/` and end in `.sh`; they become `script:scripts:<name>`.
- **`Unknown graph: justfile:build`**: just graphs are prefixed `just:`, not `justfile:`. Use `-t justfile` only for `list`.
- **Ports look wrong at runtime**: ports are chosen by checking availability, so a busy 3000 shifts the whole range upward. Run `gaffer-exec --workspace-root . run make:ports` for a reminder.

## Next example

[06-local-dev-environment](../06-local-dev-environment/README.md) shows a Docker-backed stack with health checks and graceful shutdown, complementing the multi-manifest discovery shown here.
