---
work_package_id: WP06
title: 24-docker-build-graph example
dependencies: []
requirement_refs:
- FR-006
planning_base_branch: new-examples
merge_target_branch: new-examples
branch_strategy: Planning artifacts for this mission were generated on new-examples. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into new-examples unless the human explicitly redirects the landing branch.
base_branch: kitty/mission-new-examples-01M36RVC
base_commit: 011ac2a2f7d6223aeb3ca099a660eff1b0f96456
created_at: '2026-09-23T09:19:09.047836+00:00'
subtasks:
- T016
- T017
- T018
phase: Phase 1 - Examples
history:
- at: '2026-09-23T09:30:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/24-docker-build-graph/
create_intent:
- examples/24-docker-build-graph/README.md
- examples/24-docker-build-graph/Makefile
execution_mode: code_change
model: ''
owned_files:
- examples/24-docker-build-graph/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP06 – 24-docker-build-graph example

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

Build multiple container images as a parallel graph with a dependency edge.

- `Makefile` task graph, `README.md` (shared skeleton), `test.sh` all present.
- `gaffer-exec --workspace-root . run --dry-run make:<primary>` exits 0.
- No emoji (plain unicode symbols only).

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-006; NFR-001..003; C-001).
- gaffer-exec 0.8.0. Always call `gaffer-exec --workspace-root .`.
- README skeleton: Title → What you'll learn → Prerequisites → Quick start → Task graph → How it works → Expected output → Testing → Troubleshooting → Next example.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `new-examples`; completed changes merge back into it.
- **Planning base branch**: `new-examples`
- **Merge target branch**: `new-examples`

## Subtasks & Detailed Guidance

### Subtask T016 – Dockerfiles + Makefile
- **Steps**: Two small images (`base`, `app` depends on `base`); targets `build-base`, `build-app`, `build-all`; use `docker build`.
### Subtask T017 – README
- **Steps**: Explain the graph and parallel scheduling; note Docker requirement.
### Subtask T018 – test.sh
- **Steps**: If Docker is up, build; else record blocked(environment: docker) and run a dry-run.

## Test Strategy

- `cd examples/24-docker-build-graph && bash test.sh` (bounded); `gaffer-exec --workspace-root . run --dry-run make:<primary>`.

## Review Guidance

- Example is self-contained, documented, dry-runs cleanly, and degrades gracefully when a prerequisite is missing.

## Activity Log

- 2026-09-23T09:30:00Z – system – Prompt generated via /spec-kitty.tasks
- 2026-09-23T09:42:41Z – opencode – Built and verified.
