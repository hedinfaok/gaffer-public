---
work_package_id: WP02
title: Root README + index integration
dependencies: []
requirement_refs:
- FR-006
planning_base_branch: all-manifests-devstack
merge_target_branch: all-manifests-devstack
branch_strategy: Planning artifacts for this mission were generated on all-manifests-devstack. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into all-manifests-devstack unless the human explicitly redirects the landing branch.
base_branch: kitty/mission-all-manifests-devstack-01M37QY5
base_commit: 2e569c7194cd0b8e94d68b83ec52b83669acdf0a
created_at: '2026-09-23T18:30:35.798299+00:00'
subtasks:
- T007
- T008
phase: Phase 2 - Docs
history:
- at: '2026-09-23T11:00:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: comms-cleo
authoritative_surface: docs/
create_intent: []
execution_mode: code_change
model: ''
owned_files:
- README.md
- docs/example-index.md
role: communicator
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP02 – Root README + index integration

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `comms-cleo`
- **Role**: `communicator`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- Add `25-all-manifests-devstack` to the root README feature→example table and the examples list.
- Add it to `docs/example-index.md` (feature table + per-example row), highlighting Procfile + all manifest types + auto ports.

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-006; NFR-002, NFR-003).
- No emoji; sentence-case headings; second person.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `all-manifests-devstack`; completed changes merge back into it.
- **Planning base branch**: `all-manifests-devstack`
- **Merge target branch**: `all-manifests-devstack`

## Subtasks & Detailed Guidance

### Subtask T007 – Root README
- **Steps**: Add a "Manifest coverage (all types) + Procfile" row and the example to the list; keep the table consistent.

### Subtask T008 – example index
- **Steps**: Add the feature mapping (Procfile / all manifest types / auto ports) and the per-example one-liner.

## Review Guidance
- Links resolve; table formatting consistent.

## Activity Log
- 2026-09-23T11:00:00Z – system – Prompt generated via /spec-kitty.tasks
- 2026-09-23T18:31:02Z – opencode – Done and verified.
