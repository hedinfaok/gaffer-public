# Implementation Plan: Verify all gaffer-exec examples

**Branch**: `verify-examples` | **Date**: 2026-09-23 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `kitty-specs/verify-examples-01M36AAT/spec.md`

## Summary

Build a reproducible verification harness that, for every example under
`examples/`, (1) validates the Makefile task graph against the installed
`gaffer-exec` CLI, (2) dry-runs the primary target to prove dependency order,
(3) executes the example's own `test.sh` or documented primary target under a
timeout, (4) audits documented `gaffer-exec` invocations against the CLI surface,
and (5) emits a single per-example report. Missing external prerequisites
(Docker/LocalStack/Redis, language toolchains) degrade to `blocked
(environment)`, never a false failure. Defects found are fixed in-place within
the owning example or explicitly quarantined with rationale.

## Technical Context

**Language/Version**: Bash (harness), `gaffer-exec` 0.8.0; examples span Node/TypeScript, Go, Rust, Python, C.
**Primary Dependencies**: `gaffer-exec`, `make` (GNU Make), `git`; per-example toolchains (node/npm, go, cargo, python3/pip, gcc/clang) and Docker for examples 02/06/18.
**Storage**: Filesystem only; transient `.gaffer/` cache/history (gitignored).
**Testing**: Per-example `test.sh` plus `gaffer-exec --workspace-root . validate` and `run --dry-run make:<primary>`.
**Target Platform**: Developer machine (macOS/darwin) with Linux/macOS CI parity; examples themselves are cross-platform.
**Project Type**: Verification harness over a multi-example repository (no application code produced).
**Performance Goals**: Static verification of all examples < 5 minutes warm (NFR-001).
**Constraints**: <= 10 min per executed example (NFR-002); external-service absence must not fail verification (NFR-003); never print/commit secrets (NFR-004).
**Scale/Scope**: 10 examples (01, 02, 03, 04, 05, 06, 07, 08, 18, 19).

## Charter Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Charter is not synthesized for this project; governance falls back to
  `software-dev-default` and the built-in directive catalog.
- Applicable directives: DIRECTIVE_010 (spec fidelity), DIRECTIVE_028 (efficient
  local tooling), DIRECTIVE_043 (close defect classes structurally).
- No charter-specific gates block verification. PASS.

## Project Structure

### Documentation (this mission)

```
kitty-specs/verify-examples-01M36AAT/
├── spec.md                  # Mission specification
├── plan.md                  # This file
├── tasks.md                 # Work packages (/spec-kitty.tasks)
├── verify.sh                # Repeatable verification harness (FR-008)
├── results/                 # Per-example raw evidence (gitignored or committed summaries)
└── verification-report.md   # Consolidated report (SC-005)
```

### Source Code (repository root)

```
examples/
├── 01-monorepo-build/       # TypeScript monorepo (node, npm, tsc)
├── 02-distributed-build/    # Go microservices + LocalStack/Redis (Docker)
├── 03-multi-language-build/ # Rust + Go + Node + Python
├── 04-incremental-testing/  # Node/Jest test orchestration
├── 05-ml-workflows/         # Python venv ML pipeline
├── 06-local-dev-environment/# Node + Postgres (Docker) dev stack
├── 07-watch-workflows/      # Node watch/rebuild workflows
├── 08-multi-language-task-running/ # Node + Python + Go + Rust
├── 18-network-aware-builds/ # Go + multi-region LocalStack/Redis (Docker)
└── 19-cross-platform-builds/# C + Go + Rust + Node cross-compilation
```

**Structure Decision**: No new application code. The mission adds a harness and
report under the mission directory and, where defects are found, edits files
inside the owning example directory only (C-004).

## Complexity Tracking

No charter violations. Harness stays a single Bash entry point to keep the
verification reproducible and dependency-free.

## Implementation Concern Map

### IC-01 — Static graph verification

- **Purpose**: Prove every example's Makefile task graph is valid, discoverable, and correctly ordered without external services.
- **Relevant requirements**: FR-001, FR-002, FR-004, NFR-001
- **Affected surfaces**: `examples/*/Makefile`, `kitty-specs/verify-examples-01M36AAT/verify.sh`
- **Sequencing/depends-on**: none
- **Risks**: gaffer-exec workspace discovery picks the git root, so every call must pass `--workspace-root .`; nested manifests (e.g. `08/python-ml/Makefile`) can inflate discovered graph counts.

### IC-02 — Executed verification

- **Purpose**: Run each example's `test.sh` or primary target under a timeout and classify results, degrading cleanly when prerequisites are missing.
- **Relevant requirements**: FR-003, NFR-002, NFR-003, NFR-004
- **Affected surfaces**: `examples/*/test.sh`, `examples/*/Makefile`, harness `results/`
- **Sequencing/depends-on**: IC-01
- **Risks**: Long-running servers (`dev`, `start`, watch) must be bounded; Docker/cloud examples may be unavailable; `.env` values must not be echoed.

### IC-03 — Documentation and CLI-command audit

- **Purpose**: Confirm every documented `gaffer-exec` invocation uses only flags/subcommands the installed CLI supports.
- **Relevant requirements**: FR-005
- **Affected surfaces**: `examples/**/*.md`, `examples/**/*.sh`, `examples/**/package.json`
- **Sequencing/depends-on**: IC-01
- **Risks**: False positives on prose; restrict checks to `gaffer-exec ...` command lines and cross-check against `gaffer-exec --help`.

### IC-04 — Report and defect disposition

- **Purpose**: Consolidate results into one report and ensure every defect is fixed or quarantined with rationale.
- **Relevant requirements**: FR-006, FR-007, FR-008, SC-003, SC-005
- **Affected surfaces**: `kitty-specs/verify-examples-01M36AAT/verification-report.md`, defect fixes inside `examples/`
- **Sequencing/depends-on**: IC-01, IC-02, IC-03
- **Risks**: Environment-only failures must be labelled `blocked (environment)`, not `fail`; report must cite the exact evidence command per example.
