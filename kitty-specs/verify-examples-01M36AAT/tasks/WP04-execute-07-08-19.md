---
work_package_id: WP04
title: Execute examples 07, 08, 19
dependencies:
- WP01
requirement_refs:
- FR-003
- FR-005
planning_base_branch: verify-examples
merge_target_branch: verify-examples
branch_strategy: Planning artifacts for this mission were generated on verify-examples. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into verify-examples unless the human explicitly redirects the landing branch.
base_branch: kitty/mission-verify-examples-01M36AAT
base_commit: a9dc23c88fee30944196b9a563c688eb9e647506
created_at: '2026-09-23T05:28:09.127501+00:00'
subtasks:
- T017
- T018
- T019
- T020
- T021
phase: Phase 2 - Execution
history:
- at: '2026-09-23T05:05:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/
create_intent: []
execution_mode: code_change
model: ''
owned_files:
- examples/07-watch-workflows/**
- examples/08-multi-language-task-running/**
- examples/19-cross-platform-builds/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP04 – Execute examples 07, 08, 19

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- Verify the mixed-toolchain examples pass static checks and their build stages execute (or degrade to `blocked (environment)`).
- Audit documented `gaffer-exec` commands in the owned examples.
- Fix non-environment defects inside the owning example only.

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-003, FR-005; NFR-002, NFR-003).
- Plan: [plan.md](../plan.md) (IC-02, IC-03).
- 07 starts dev servers → verify build stage only, bounded by timeout.
- 08 spans Node/Python/Go/Rust; 19 spans C/Go/Rust/Node + cross-compilation.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `verify-examples`; completed changes must merge back into `verify-examples`.
- **Planning base branch**: `verify-examples`
- **Merge target branch**: `verify-examples`

## Subtasks & Detailed Guidance

### Subtask T017 – Example 07 (watch-workflows)

- **Purpose**: Build + watch/rebuild workflows.
- **Steps**: Run the build target(s) bounded by timeout; do not start long-lived watchers unbounded. Run `bash test.sh` if it does not require servers.

### Subtask T018 – Example 08 (multi-language-task-running)

- **Purpose**: Cross-language task orchestration.
- **Steps**: Run `bash test.sh`; record which of Node/Python/Go/Rust are present; `blocked (environment)` if a required toolchain is missing.

### Subtask T019 – Example 19 (cross-platform-builds)

- **Purpose**: Cross-compilation targets.
- **Steps**: Run `make -n` for the primary target plus the toolchain-present build targets; record cross-compile results; `blocked (environment)` for missing cross toolchains.

### Subtask T020 – Documentation command audit (owned examples)

- **Purpose**: Docs must match the CLI.
- **Steps**: Extract `gaffer-exec ...` lines from owned example files; confirm flags exist in `gaffer-exec --help`.

### Subtask T021 – Fix defects in place

- **Purpose**: Leave examples green or cleanly blocked.
- **Steps**: Fix non-environment failures within the owning example; re-run; record any unfixable defect + rationale for WP05.

## Test Strategy

- Static checks pass for all three; executed results recorded with evidence commands.

## Risks & Mitigations

- Watchers/dev servers may hang → never run them unbounded; use `timeout` and target the build stage.
- Cross-compilation needs extra Rust targets → treat missing targets as `blocked (environment)`.

## Review Guidance

- Confirm no unbounded process was left running; confirm results cite raw outcomes.

## Activity Log

- 2026-09-23T05:05:00Z – system – Prompt generated via /spec-kitty.tasks
