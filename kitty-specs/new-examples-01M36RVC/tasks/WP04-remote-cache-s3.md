---
work_package_id: WP04
title: 22-remote-cache-s3 example
dependencies: []
requirement_refs:
- FR-004
planning_base_branch: new-examples
merge_target_branch: new-examples
branch_strategy: Planning artifacts for this mission were generated on new-examples. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into new-examples unless the human explicitly redirects the landing branch.
base_branch: kitty/mission-new-examples-01M36RVC
base_commit: 011ac2a2f7d6223aeb3ca099a660eff1b0f96456
created_at: '2026-09-23T09:18:58.960044+00:00'
subtasks:
- T010
- T011
- T012
phase: Phase 1 - Examples
history:
- at: '2026-09-23T09:30:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/22-remote-cache-s3/
create_intent:
- examples/22-remote-cache-s3/README.md
- examples/22-remote-cache-s3/Makefile
execution_mode: code_change
model: ''
owned_files:
- examples/22-remote-cache-s3/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP04 – 22-remote-cache-s3 example

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

Demonstrate a real remote cache round-trip using MinIO via `--cache-get-remote`/`--cache-set-remote`.

- `Makefile` task graph, `README.md` (shared skeleton), `test.sh` all present.
- `gaffer-exec --workspace-root . run --dry-run make:<primary>` exits 0.
- No emoji (plain unicode symbols only).

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-004; NFR-001..003; C-001).
- gaffer-exec 0.8.0. Always call `gaffer-exec --workspace-root .`.
- README skeleton: Title → What you'll learn → Prerequisites → Quick start → Task graph → How it works → Expected output → Testing → Troubleshooting → Next example.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `new-examples`; completed changes merge back into it.
- **Planning base branch**: `new-examples`
- **Merge target branch**: `new-examples`

## Subtasks & Detailed Guidance

### Subtask T010 – docker-compose MinIO + scripts
- **Steps**: `docker-compose.yml` for MinIO; `scripts/restore.sh`/`scripts/save.sh` that copy the `GAFFER_CACHE_ARTIFACT` to/from MinIO (use the injected env vars). Degrade to a documented dry-run when Docker/MinIO is absent.
### Subtask T011 – Makefile
- **Steps**: A cached `build` target plus `cache-restore`/`cache-save` graphs wired via `--cache-get-remote`/`--cache-set-remote`.
### Subtask T012 – README + test.sh
- **Steps**: Explain remote cache; test.sh runs the round-trip if Docker is up, else records blocked(environment).

## Test Strategy

- `cd examples/22-remote-cache-s3 && bash test.sh` (bounded); `gaffer-exec --workspace-root . run --dry-run make:<primary>`.

## Review Guidance

- Example is self-contained, documented, dry-runs cleanly, and degrades gracefully when a prerequisite is missing.

## Activity Log

- 2026-09-23T09:30:00Z – system – Prompt generated via /spec-kitty.tasks
