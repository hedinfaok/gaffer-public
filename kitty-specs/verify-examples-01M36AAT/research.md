# Research: Verify all gaffer-exec examples

**Mission**: `verify-examples-01M36AAT`
**Date**: 2026-09-23
**Target CLI**: `gaffer-exec` 0.8.0 (`/Users/rob/.cargo/bin/gaffer-exec`)

## Decisions

### D-001 — Verification target is the installed CLI 0.8.0

`gaffer-exec --version` → `0.8.0`. `--help` confirms the removed JSON-graph
flags (`--graph`, `--graph-override`) are absent; manifest support is via
`--manifest-file` (Makefile, Taskfile.yml, justfile) plus auto-discovery of
`make:`, `npm:`, `cargo:`, `python:`, `script:`, etc.

### D-002 — Always pass `--workspace-root .`

Workspace discovery roots at the git root, so nested examples must be run with
`--workspace-root .` from inside their directory; graph IDs then resolve as
`make:<target>`.

### D-003 — Static verification primitives

- `gaffer-exec --workspace-root . validate` → `Validated N graph(s): OK`
- `gaffer-exec --workspace-root . list -t makefile` → Make targets discovered
- `gaffer-exec --workspace-root . run --dry-run make:<primary>` → `would execute N graphs`
- `gaffer-exec --workspace-root . show make:<primary> --format dot` → dependency graph

### D-004 — Status vocabulary

`pass`, `fail`, `blocked (environment)`. Missing external prerequisites
(Docker daemon, cross-compile targets) are `blocked (environment)` and must not
be reported as failures (NFR-003).

### D-005 — Primary target per example

| Example | Primary target | Prerequisites |
|---------|----------------|---------------|
| 01-monorepo-build | `make:build-all` | node, npm, tsc |
| 02-distributed-build | `make:distributed-build` | go, docker (LocalStack + Redis) |
| 03-multi-language-build | `make:multi-language-build` | cargo, go, node, python3 |
| 04-incremental-testing | `make:test-all` | node, npm (jest) |
| 05-ml-workflows | `make:pipeline` | python3, pip, venv |
| 06-local-dev-environment | `make:dev` | node, docker (Postgres) |
| 07-watch-workflows | `make:build-all` | node, npm |
| 08-multi-language-task-running | `make:build-all` | node, python3, go, cargo |
| 18-network-aware-builds | `make:network-build` | go, docker (multi-region LocalStack + Redis) |
| 19-cross-platform-builds | `make:build-all` | gcc/clang, go, cargo, node |

### D-006 — Local toolchain availability (this machine)

Present: node v24.12.0, npm 11.6.2, go (installed), cargo/rustc 1.93.1,
python3 3.14.6, pip 26.1.2, docker 29.2.1 (daemon status checked at runtime),
Apple clang 21, GNU Make 3.81, jq 1.8.2. `timeout` may be absent on macOS →
detect `timeout`/`gtimeout`; fall back to a background-PID kill wrapper.

### D-007 — Known non-service vs service examples

Service-dependent: 02, 06, 18 (Docker/LocalStack/Redis/Postgres).
Non-service: 01, 03, 04, 05, 07, 08, 19.

## Alternatives considered

- **Taskfile.yml instead of Makefile** — rejected for this mission: the examples
  were just migrated to Makefiles; re-migrating is out of scope (C-004).
- **package.json scripts** — cannot express the dependency DAG (verified: npm
  composite graphs have no edges), so Makefile remains the task graph.

## Evidence sources

- `gaffer-exec --help`, `gaffer-exec --version` (0.8.0)
- `gaffer-exec list -f json`, `show -f json`, `validate`, `run --dry-run`
- Repository: `examples/*/Makefile`, `examples/*/README.md`, `examples/*/test.sh`

## Open questions

- Does the Docker daemon run in this environment? Resolved at execution time
  (WP03); absence ⇒ `blocked (environment: docker)`.
- Are extra Rust cross targets installed for 19? Resolved at execution time
  (WP04); absence ⇒ `blocked (environment)` for those specific targets.
