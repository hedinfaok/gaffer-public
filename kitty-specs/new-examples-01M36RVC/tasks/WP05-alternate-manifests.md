---
work_package_id: WP05
title: 23-alternate-manifests example
dependencies: []
requirement_refs:
- FR-005
subtasks:
- T013
- T014
- T015
phase: Phase 1 - Examples
history:
- at: '2026-09-23T09:30:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/23-alternate-manifests/
create_intent:
- examples/23-alternate-manifests/README.md
- examples/23-alternate-manifests/Makefile
execution_mode: code_change
model: ''
owned_files:
- examples/23-alternate-manifests/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP05 – 23-alternate-manifests example

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

Show gaffer-exec consuming non-Make manifests: a `Taskfile.yml` and a `justfile`.

- `Makefile` task graph, `README.md` (shared skeleton), `test.sh` all present.
- `gaffer-exec --workspace-root . run --dry-run make:<primary>` exits 0.
- No emoji (plain unicode symbols only).

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-005; NFR-001..003; C-001).
- gaffer-exec 0.8.0. Always call `gaffer-exec --workspace-root .`.
- README skeleton: Title → What you'll learn → Prerequisites → Quick start → Task graph → How it works → Expected output → Testing → Troubleshooting → Next example.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `new-examples`; completed changes merge back into it.
- **Planning base branch**: `new-examples`
- **Merge target branch**: `new-examples`

## Subtasks & Detailed Guidance

### Subtask T013 – Taskfile.yml
- **Steps**: A small `Taskfile.yml` with `build`/`test` tasks; confirm gaffer discovers `taskfile:` graphs.
### Subtask T014 – justfile
- **Steps**: A `justfile` with recipes; confirm `justfile:` graphs.
### Subtask T015 – README + test.sh
- **Steps**: Compare manifest options; test.sh asserts `gaffer-exec list -t taskfile` and `-t justfile` discover targets.

## Test Strategy

- `cd examples/23-alternate-manifests && bash test.sh` (bounded); `gaffer-exec --workspace-root . run --dry-run make:<primary>`.

## Review Guidance

- Example is self-contained, documented, dry-runs cleanly, and degrades gracefully when a prerequisite is missing.

## Activity Log

- 2026-09-23T09:30:00Z – system – Prompt generated via /spec-kitty.tasks
