---
work_package_id: WP01
title: Verification harness + static graph checks
dependencies: []
requirement_refs:
- FR-001
- FR-002
- FR-004
- FR-008
planning_base_branch: verify-examples
merge_target_branch: verify-examples
branch_strategy: Planning artifacts for this mission were generated on verify-examples. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into verify-examples unless the human explicitly redirects the landing branch.
subtasks:
- T001
- T002
- T003
- T004
- T005
phase: Phase 1 - Foundational
history:
- at: '2026-09-23T05:05:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: kitty-specs/verify-examples-01M36AAT/
create_intent:
- kitty-specs/verify-examples-01M36AAT/verify.sh
- kitty-specs/verify-examples-01M36AAT/results/static-results.json
execution_mode: planning_artifact
model: ''
owned_files:
- kitty-specs/verify-examples-01M36AAT/verify.sh
- kitty-specs/verify-examples-01M36AAT/results/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP01 – Verification harness + static graph checks

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- Deliver `kitty-specs/verify-examples-01M36AAT/verify.sh`: one entry point that statically verifies every example under `examples/` against `gaffer-exec` 0.8.0.
- Every example reports `pass` for: `validate`, primary-target dry-run, Makefile discovery, and stale-reference sweep.
- Emit `results/static-results.json` with per-example status + evidence command.

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-001, FR-002, FR-004, FR-008; NFR-001).
- Plan: [plan.md](../plan.md) (IC-01).
- `gaffer-exec` roots discovery at the git root; **always** pass `--workspace-root .` from inside the example directory.
- Examples: 01, 02, 03, 04, 05, 06, 07, 08, 18, 19.
- Do not modify anything under `examples/` in this WP (owned by WP02–WP04).

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `verify-examples`; completed changes must merge back into `verify-examples`.
- **Planning base branch**: `verify-examples`
- **Merge target branch**: `verify-examples`

## Subtasks & Detailed Guidance

### Subtask T001 – Design the harness

- **Purpose**: One reproducible, dependency-light Bash entry point.
- **Steps**: Create `verify.sh` with modes `--static`, `--execute`, and `--all`. Default to `--static`. Fail fast on missing `gaffer-exec`/`make`. Create `results/` on demand.
- **Files**: `kitty-specs/verify-examples-01M36AAT/verify.sh`
- **Parallel?**: no (foundational).

### Subtask T002 – Static validate + discovery per example

- **Purpose**: Catch invalid/unparseable task graphs.
- **Steps**: For each example dir, run `gaffer-exec --workspace-root . validate` and `gaffer-exec --workspace-root . list -t makefile`; require exit 0 and at least one `make:` graph.
- **Files**: `verify.sh`

### Subtask T003 – Primary-target dry-run dependency closure

- **Purpose**: Prove dependency ordering is intact.
- **Steps**: Map each example to its primary target (`01→build-all`, `02→distributed-build`, `03→multi-language-build`, `04→test-all`, `05→pipeline`, `06→dev`, `07→build-all`, `08→build-all`, `18→network-build`, `19→build-all`). Run `gaffer-exec --workspace-root . run --dry-run make:<target>`; require exit 0 and a `would execute N graphs` line with N >= 1.
- **Files**: `verify.sh`

### Subtask T004 – Stale-reference sweep

- **Purpose**: Guarantee no removed-format references remain.
- **Steps**: Search example content for `graph.json`, `--graph `, `--graph-override`; exclude `node_modules`, `venv`, `target`. Require zero matches (allow intentional historical notes only if explicitly listed).
- **Files**: `verify.sh`

### Subtask T005 – Machine-readable results

- **Purpose**: Feed WP05's report.
- **Steps**: Write `results/static-results.json` as an array of `{example, status, evidence, detail}`. `status` ∈ `pass|fail|blocked`.
- **Files**: `results/static-results.json`

## Test Strategy

- Self-test: `bash verify.sh --static` exits 0 and `results/static-results.json` contains 10 entries, all `pass`.

## Risks & Mitigations

- Nested manifests inflate `list` counts → rely on the primary-target dry-run, not counts.
- macOS `timeout` may be absent (GNU coreutils) → detect `timeout`/`gtimeout` and fall back.

## Review Guidance

- Confirm `verify.sh` is idempotent, passes `--workspace-root .` everywhere, and does not touch `examples/`.

## Activity Log

- 2026-09-23T05:05:00Z – system – Prompt generated via /spec-kitty.tasks
