# Tasks: Verify all gaffer-exec examples

**Mission**: `verify-examples-01M36AAT`
**Branch**: `verify-examples` → merges back into `verify-examples`
**Target CLI**: `gaffer-exec` 0.8.0
**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Work Package Overview

| WP | Title | Phase | Depends on | Requirement refs |
|----|-------|-------|------------|------------------|
| WP01 | Verification harness + static graph checks | Phase 1 – Foundational | — | FR-001, FR-002, FR-004, FR-008 |
| WP02 | Execute examples 01, 03, 04, 05 | Phase 2 – Execution | WP01 | FR-003, FR-005 |
| WP03 | Execute examples 02, 06, 18 (service-dependent) | Phase 2 – Execution | WP01 | FR-003, FR-005 |
| WP04 | Execute examples 07, 08, 19 | Phase 2 – Execution | WP01 | FR-003, FR-005 |
| WP05 | Consolidated report + defect disposition | Phase 3 – Report | WP02, WP03, WP04 | FR-006, FR-007 |

---

## WP01 – Verification harness + static graph checks

**Goal**: Provide one reproducible entry point that statically verifies every
example's Makefile task graph against `gaffer-exec` 0.8.0.

**Priority**: P1 (MVP). **Independent test**: run
`bash kitty-specs/verify-examples-01M36AAT/verify.sh --static` and confirm every
example reports `pass`.

**Included subtasks**: T001, T002, T003, T004, T005

**Implementation notes**:
- Every `gaffer-exec` call passes `--workspace-root .` because discovery roots at
  the git root.
- Static checks: `validate`, `run --dry-run make:<primary>`, `list -t makefile`.
- Stale-reference sweep: `graph.json`, `--graph`, `--graph-override` in example
  content (exclude `node_modules`, `venv`, `target`).
- Emit machine-readable results to `results/static-results.json`.

**Parallel opportunities**: none (foundational). **Risks**: nested manifests can
inflate discovered graph counts; treat per-example primary-target dry-run as the
source of truth.

**Estimated prompt size**: ~140 lines.

---

## WP02 – Execute examples 01, 03, 04, 05

**Goal**: Execute the non-service examples' `test.sh` (or documented primary
target) under a timeout, audit their documented `gaffer-exec` commands, and fix
defects in place.

**Priority**: P1. **Independent test**: each example's raw result file exists and
records `pass`, `fail`, or `blocked (environment)` with an evidence command.

**Included subtasks**: T006, T007, T008, T009, T010, T011

**Dependencies**: WP01 (uses the harness).

**Implementation notes**:
- Bounded execution: `timeout` per example (<= 10 min).
- `blocked (environment)` when a required toolchain is absent; never `fail`.
- Doc audit: every `gaffer-exec` line must use only flags present in `gaffer-exec --help`.
- Defects fixed only within the owning example.

**Parallel opportunities**: WP02 runs in parallel with WP03 and WP04.
**Estimated prompt size**: ~180 lines.

---

## WP03 – Execute examples 02, 06, 18 (service-dependent)

**Goal**: Verify the Docker/service-dependent examples degrade cleanly and pass
all non-service checks.

**Priority**: P1. **Independent test**: each example records static `pass` plus
either an executed result or `blocked (environment: Docker/LocalStack/Redis)`.

**Included subtasks**: T012, T013, T014, T015, T016

**Dependencies**: WP01.

**Implementation notes**:
- Start services only if Docker is available; otherwise record blocked and still
  run the harness static checks.
- Never echo `.env` values.
- Examples: 02 (LocalStack+Redis), 06 (Postgres), 18 (multi-region LocalStack+Redis).

**Parallel opportunities**: parallel with WP02/WP04.
**Estimated prompt size**: ~160 lines.

---

## WP04 – Execute examples 07, 08, 19

**Goal**: Verify the remaining mixed-toolchain examples (watch workflows,
multi-language task running, cross-platform builds).

**Priority**: P1. **Independent test**: each records `pass`/`fail`/`blocked` with
evidence.

**Included subtasks**: T017, T018, T019, T020, T021

**Dependencies**: WP01.

**Implementation notes**:
- 07 starts dev servers → verify the build stage only, bound with timeout.
- 08 spans Node/Python/Go/Rust → `blocked (environment)` for any missing toolchain.
- 19 cross-compiles → run `make -n` plus the toolchain-present targets.

**Parallel opportunities**: parallel with WP02/WP03.
**Estimated prompt size**: ~160 lines.

---

## WP05 – Consolidated report + defect disposition

**Goal**: Publish one report listing every example's status and evidence, and
ensure every defect is fixed or quarantined with rationale.

**Priority**: P2. **Independent test**: the report lists all 10 examples with a
status and evidence command; every `fail` has a disposition.

**Included subtasks**: T022, T023, T024

**Dependencies**: WP02, WP03, WP04.

**Implementation notes**:
- Report path: `kitty-specs/verify-examples-01M36AAT/verification-report.md`.
- Status vocabulary: `pass`, `fail`, `blocked (environment)`.
- Include the exact evidence command per example.

**Parallel opportunities**: none (terminal).
**Estimated prompt size**: ~120 lines.
