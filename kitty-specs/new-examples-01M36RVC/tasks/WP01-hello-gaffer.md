---
work_package_id: WP01
title: 00-hello-gaffer onboarding example
dependencies: []
requirement_refs:
- FR-001
subtasks:
- T001
- T002
- T003
phase: Phase 1 - Examples
history:
- at: '2026-09-23T09:30:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/00-hello-gaffer/
create_intent:
- examples/00-hello-gaffer/README.md
- examples/00-hello-gaffer/Makefile
execution_mode: code_change
model: ''
owned_files:
- examples/00-hello-gaffer/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP01 – 00-hello-gaffer onboarding example

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

Create the smallest working example: two independent tasks plus an aggregate, showing parallelism and a cache hit.

- `Makefile` task graph, `README.md` (shared skeleton), `test.sh` all present.
- `gaffer-exec --workspace-root . run --dry-run make:<primary>` exits 0.
- No emoji (plain unicode symbols only).

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-001; NFR-001..003; C-001).
- gaffer-exec 0.8.0. Always call `gaffer-exec --workspace-root .`.
- README skeleton: Title → What you'll learn → Prerequisites → Quick start → Task graph → How it works → Expected output → Testing → Troubleshooting → Next example.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `new-examples`; completed changes merge back into it.
- **Planning base branch**: `new-examples`
- **Merge target branch**: `new-examples`

## Subtasks & Detailed Guidance

### Subtask T001 – Makefile
- **Steps**: `hello-a`, `hello-b` (independent), `hello` aggregate depending on both; a `cached` task that writes a file so `--cache sha256` produces a hit. `.PHONY`, `.DEFAULT_GOAL := hello`.
### Subtask T002 – README (skeleton)
- **Steps**: Explain the core loop; show `gaffer-exec --workspace-root . run make:hello` and a `--cache sha256` re-run.
### Subtask T003 – test.sh
- **Steps**: Run `make:hello`, assert both tasks ran; run cached target twice and assert a cache hit.

## Test Strategy

- `cd examples/00-hello-gaffer && bash test.sh` (bounded); `gaffer-exec --workspace-root . run --dry-run make:<primary>`.

## Review Guidance

- Example is self-contained, documented, dry-runs cleanly, and degrades gracefully when a prerequisite is missing.

## Activity Log

- 2026-09-23T09:30:00Z – system – Prompt generated via /spec-kitty.tasks
