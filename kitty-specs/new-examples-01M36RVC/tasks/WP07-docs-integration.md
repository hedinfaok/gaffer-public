---
work_package_id: WP07
title: Root README + index integration
dependencies: []
requirement_refs:
- FR-007
subtasks:
- T019
- T020
phase: Phase 1 - Examples
history:
- at: '2026-09-23T09:30:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: docs/
create_intent:
- docs/example-index.md
execution_mode: code_change
model: ''
owned_files:
- README.md
- docs/example-index.md
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP07 – Root README + index integration

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

Add the six new examples to the root README feature table and `docs/example-index.md`, with cross-links.

- `Makefile` task graph, `README.md` (shared skeleton), `test.sh` all present.
- `gaffer-exec --workspace-root . run --dry-run make:<primary>` exits 0.
- No emoji (plain unicode symbols only).

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-007; NFR-001..003; C-001).
- gaffer-exec 0.8.0. Always call `gaffer-exec --workspace-root .`.
- README skeleton: Title → What you'll learn → Prerequisites → Quick start → Task graph → How it works → Expected output → Testing → Troubleshooting → Next example.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `new-examples`; completed changes merge back into it.
- **Planning base branch**: `new-examples`
- **Merge target branch**: `new-examples`

## Subtasks & Detailed Guidance

### Subtask T019 – Root README
- **Steps**: Add the new examples to the feature→example table and the examples list.
### Subtask T020 – example index
- **Steps**: Add per-example one-liners and feature mappings for the new examples.

## Test Strategy

- `cd examples/None && bash test.sh` (bounded); `gaffer-exec --workspace-root . run --dry-run make:<primary>`.

## Review Guidance

- Example is self-contained, documented, dry-runs cleanly, and degrades gracefully when a prerequisite is missing.

## Activity Log

- 2026-09-23T09:30:00Z – system – Prompt generated via /spec-kitty.tasks
