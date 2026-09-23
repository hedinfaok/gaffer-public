# Implementation Plan: All-manifests local dev web stack

**Branch**: `all-manifests-devstack` | **Spec**: [spec.md](./spec.md)

## Summary

Build `examples/25-all-manifests-devstack`: a local-dev web stack where each
layer uses a different gaffer-exec manifest type — Makefile (orchestration),
Procfile (web/api/worker processes), npm + turborepo (frontend workspace),
Cargo (Rust worker), Python (api), Taskfile.yml, justfile, shell scripts
(db-init/health), and Bazel (a generated artifact). Ports are assigned with
`--auto-port`/`--port-patterns` for the Procfile processes; a `dev` target wires
the flags. A `test.sh` asserts discovery per type and a clean dry-run. Docs are
added to the root README and index.

## Verified CLI facts (0.8.0)

- Procfile → `procfile:start` composite with `procfile:start:<name>` children; `$PORT` is available to processes.
- `--auto-port <base>` + `--port-patterns '<glob>'` inject `PORT` (checks availability; `--port-interface` optional).
- Types/prefixes: `make:` , `npm:`, `turbo:`, `cargo:`, `python:`, `procfile:`, `taskfile:`, `just:`, `script:`, `bazel:`.
- Turborepo needs a `package.json` with `workspaces` + `turbo.json`.

## Technical Context
**Testing**: per-type `gaffer-exec list -t <type>`; `run --dry-run`; `test.sh`.
**Constraints**: gaffer-exec 0.8.0; no emoji; degrade cleanly (NFR-001).

## Charter Check
Charter not synthesized; fallback `software-dev-default`. PASS.

## Project Structure

```
examples/25-all-manifests-devstack/
├── Makefile                # orchestration (makefile)
├── Procfile                # web/api/worker processes (procfile)
├── package.json            # npm workspace root (npm)
├── turbo.json              # build pipeline (turborepo)
├── web/                    # frontend workspace (npm)
├── api/                    # Python api service (python)
├── worker/                 # Rust worker (cargo)
├── Taskfile.yml            # taskfile
├── justfile                # just
├── scripts/                # db-init.sh, health.sh (script)
├── WORKSPACE.bazel, BUILD.bazel # bazel
├── README.md               # shared skeleton
└── test.sh
README.md, docs/example-index.md   # WP02
```

## Implementation Concern Map

### IC-01 — The stack (FR-001..FR-005)
- All manifests present and discoverable; `dev` wires `--auto-port`; `test.sh` asserts discovery + dry-run; README maps each manifest to its role.

### IC-02 — Docs integration (FR-006)
- Root README + index entries; cross-links.
