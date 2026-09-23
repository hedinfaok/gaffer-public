---
work_package_id: WP01
title: Root README + feature-to-example index
dependencies: []
requirement_refs:
- FR-001
- FR-008
planning_base_branch: improve-examples
merge_target_branch: improve-examples
branch_strategy: Planning artifacts for this mission were generated on improve-examples. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into improve-examples unless the human explicitly redirects the landing branch.
base_branch: kitty/mission-improve-examples-01M36QTK
base_commit: a5f47cd83f0c3ff319739406b21e32a1e9c40703
created_at: '2026-09-23T09:01:40.554211+00:00'
subtasks:
- T001
- T002
- T003
phase: Phase 1 - Docs
history:
- at: '2026-09-23T09:10:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: comms-cleo
authoritative_surface: docs/
create_intent:
- docs/example-index.md
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

# Work Package Prompt: WP01 – Root README + feature-to-example index

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `comms-cleo`
- **Role**: `communicator`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- Root `README.md` leads with what the examples demonstrate, not caveats.
- Add a feature→example index (`docs/example-index.md`) and link it from the root README.
- Move the LLM provenance/limitations block to a clearly headed section near the end (keep it honest).

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-001, FR-008; NFR-002, NFR-003).
- Keep the emoji-free plain-symbol style. Second person, sentence-case headings.
- Do not change example content.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `improve-examples`; completed changes merge back into it.
- **Planning base branch**: `improve-examples`
- **Merge target branch**: `improve-examples`

## Subtasks & Detailed Guidance

### Subtask T001 – Root README rework
- **Steps**: Rewrite `README.md`: intro (what this repo is + who it's for), "What these examples show" (3–5 bullets), feature→example table, then "Getting started", then "Provenance & limitations" (the existing honest disclosure, condensed), then links.
- **Files**: `README.md`

### Subtask T002 – Feature→example index
- **Steps**: Create `docs/example-index.md` mapping each gaffer-exec feature (parallel scheduling, content-based caching, incremental/affected, watch, remote/multi-region cache, cross-platform, multi-language orchestration, alternate manifests) to the example(s) that demonstrate it, plus a per-example one-liner.
- **Files**: `docs/example-index.md`

### Subtask T003 – Communicator pass
- **Steps**: Apply `comms-cleo` tone/structure; ensure no superlatives, no ALL-CAPS, consistent voice; verify links resolve.

## Review Guidance
- Root README opens with value; index exists and is accurate; disclosure retained.

## Activity Log
- 2026-09-23T09:10:00Z – system – Prompt generated via /spec-kitty.tasks
- 2026-09-23T09:15:00Z – opencode – Root README rewritten value-first with feature->example table; docs/example-index.md added; provenance moved near end. Commit 59c6686.
