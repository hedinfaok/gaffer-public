---
work_package_id: WP03
title: 21-ci-github-actions example
dependencies: []
requirement_refs:
- FR-003
planning_base_branch: new-examples
merge_target_branch: new-examples
branch_strategy: Planning artifacts for this mission were generated on new-examples. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into new-examples unless the human explicitly redirects the landing branch.
subtasks:
- T007
- T008
- T009
phase: Phase 1 - Examples
history:
- at: '2026-09-23T09:30:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/21-ci-github-actions/
create_intent:
- examples/21-ci-github-actions/README.md
- examples/21-ci-github-actions/Makefile
execution_mode: code_change
model: ''
owned_files:
- examples/21-ci-github-actions/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP03 – 21-ci-github-actions example

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

Provide a CI example using `export --format github-actions` and cache restore/save.

- `Makefile` task graph, `README.md` (shared skeleton), `test.sh` all present.
- `gaffer-exec --workspace-root . run --dry-run make:<primary>` exits 0.
- No emoji (plain unicode symbols only).

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-003; NFR-001..003; C-001).
- gaffer-exec 0.8.0. Always call `gaffer-exec --workspace-root .`.
- README skeleton: Title → What you'll learn → Prerequisites → Quick start → Task graph → How it works → Expected output → Testing → Troubleshooting → Next example.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `new-examples`; completed changes merge back into it.
- **Planning base branch**: `new-examples`
- **Merge target branch**: `new-examples`

## Subtasks & Detailed Guidance

### Subtask T007 – Example project + Makefile
- **Steps**: Small Node project with `build`/`test` targets.
### Subtask T008 – Workflow
- **Steps**: Add `.github/workflows/ci.yml` that runs `gaffer-exec export --format github-actions` (verify the exact flag/output on 0.8.0) and uses `--cache` with restore/save.
### Subtask T009 – README + test.sh
- **Steps**: Document the workflow; test.sh validates the export command and a dry-run.

## Test Strategy

- `cd examples/21-ci-github-actions && bash test.sh` (bounded); `gaffer-exec --workspace-root . run --dry-run make:<primary>`.

## Review Guidance

- Example is self-contained, documented, dry-runs cleanly, and degrades gracefully when a prerequisite is missing.

## Activity Log

- 2026-09-23T09:30:00Z – system – Prompt generated via /spec-kitty.tasks
