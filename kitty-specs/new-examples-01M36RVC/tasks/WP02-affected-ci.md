---
work_package_id: WP02
title: 20-affected-ci example
dependencies: []
requirement_refs:
- FR-002
planning_base_branch: new-examples
merge_target_branch: new-examples
branch_strategy: Planning artifacts for this mission were generated on new-examples. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into new-examples unless the human explicitly redirects the landing branch.
base_branch: kitty/mission-new-examples-01M36RVC
base_commit: 011ac2a2f7d6223aeb3ca099a660eff1b0f96456
created_at: '2026-09-23T09:18:48.766817+00:00'
subtasks:
- T004
- T005
- T006
phase: Phase 1 - Examples
history:
- at: '2026-09-23T09:30:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/20-affected-ci/
create_intent:
- examples/20-affected-ci/README.md
- examples/20-affected-ci/Makefile
execution_mode: code_change
model: ''
owned_files:
- examples/20-affected-ci/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP02 – 20-affected-ci example

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

Show building only what changed using `--since`/`--affected` on a small monorepo fixture.

- `Makefile` task graph, `README.md` (shared skeleton), `test.sh` all present.
- `gaffer-exec --workspace-root . run --dry-run make:<primary>` exits 0.
- No emoji (plain unicode symbols only).

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-002; NFR-001..003; C-001).
- gaffer-exec 0.8.0. Always call `gaffer-exec --workspace-root .`.
- README skeleton: Title → What you'll learn → Prerequisites → Quick start → Task graph → How it works → Expected output → Testing → Troubleshooting → Next example.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `new-examples`; completed changes merge back into it.
- **Planning base branch**: `new-examples`
- **Merge target branch**: `new-examples`

## Subtasks & Detailed Guidance

### Subtask T004 – Fixture
- **Steps**: A tiny monorepo (`packages/a`, `packages/b`) with a Makefile where `b` depends on `a`; targets write outputs.
### Subtask T005 – README
- **Steps**: Explain affected/since semantics; commands `gaffer-exec --workspace-root . run --since HEAD~1 make:build-all` and `--affected packages/a/src/x.txt`.
### Subtask T006 – test.sh
- **Steps**: Dry-run affected selection; assert the changed package + dependents are selected. Degrade gracefully without git history.

## Test Strategy

- `cd examples/20-affected-ci && bash test.sh` (bounded); `gaffer-exec --workspace-root . run --dry-run make:<primary>`.

## Review Guidance

- Example is self-contained, documented, dry-runs cleanly, and degrades gracefully when a prerequisite is missing.

## Activity Log

- 2026-09-23T09:30:00Z – system – Prompt generated via /spec-kitty.tasks
