---
work_package_id: WP02
title: Standardize 8 example READMEs
dependencies: []
requirement_refs:
- FR-002
- FR-003
- FR-004
- FR-007
- FR-008
planning_base_branch: improve-examples
merge_target_branch: improve-examples
branch_strategy: Planning artifacts for this mission were generated on improve-examples. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into improve-examples unless the human explicitly redirects the landing branch.
base_branch: kitty/mission-improve-examples-01M36QTK
base_commit: a5f47cd83f0c3ff319739406b21e32a1e9c40703
created_at: '2026-09-23T09:01:45.789038+00:00'
subtasks:
- T004
- T005
- T006
- T007
- T008
- T009
phase: Phase 1 - Docs
history:
- at: '2026-09-23T09:10:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: comms-cleo
authoritative_surface: examples/01-monorepo-build/README.md
create_intent: []
execution_mode: code_change
model: ''
owned_files:
- examples/01-monorepo-build/README.md
- examples/02-distributed-build/README.md
- examples/04-incremental-testing/README.md
- examples/05-ml-workflows/README.md
- examples/06-local-dev-environment/README.md
- examples/07-watch-workflows/README.md
- examples/18-network-aware-builds/README.md
- examples/19-cross-platform-builds/README.md
role: communicator
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP02 – Standardize 8 example READMEs

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `comms-cleo`
- **Role**: `communicator`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- Every owned README follows the shared skeleton:
  **Title → What you'll learn (gaffer features) → Prerequisites → Quick start → Task graph (targets table) → How it works → Expected output → Testing → Troubleshooting → Next example**.
- Remove duplicated "Real Open Source Project Pattern" boilerplate.
- Label illustrative performance numbers inline (e.g. "(illustrative, not a benchmark)").
- Grow example 05's README; trim example 01's duplicated tail.
- Note the 02↔18 overlap and cross-link.

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-002..FR-004, FR-007, FR-008; NFR-002, NFR-003).
- Preserve all commands exactly (`gaffer-exec --workspace-root . run make:<t>`).
- No emoji; plain symbols only. Sentence-case headings; second person.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `improve-examples`; completed changes merge back into it.
- **Planning base branch**: `improve-examples`
- **Merge target branch**: `improve-examples`

## Subtasks & Detailed Guidance

### Subtask T004 – Lock the skeleton
- **Steps**: Write the canonical skeleton as a short template block at the top of a scratch note; apply consistently.

### Subtask T005 – 01 monorepo-build
- **Steps**: Restructure to skeleton; remove the duplicated "Next Steps"/value tail; label perf numbers illustrative.

### Subtask T006 – 02 distributed-build
- **Steps**: Skeleton; add a one-line "vs 18-network-aware-builds" distinction + link.

### Subtask T007 – 04 incremental-testing
- **Steps**: Skeleton; keep the retry/cache feature notes; label any illustrative timing.

### Subtask T008 – 05, 06, 07, 19
- **Steps**: Skeleton for each. Grow 05 substantially (pipeline stages, data, commands, expected output). Trim/retitle as needed.

### Subtask T009 – 18 network-aware-builds + communicator pass
- **Steps**: Skeleton for 18; keep the honest "simulated delta transfer" notes; note "vs 02"; apply consistent voice across all eight.

## Test Strategy
- No code changed; sanity-check commands still match each `Makefile` (target names).

## Review Guidance
- All eight READMEs share the section order; no duplicated boilerplate; numbers labelled.

## Activity Log
- 2026-09-23T09:10:00Z – system – Prompt generated via /spec-kitty.tasks
