---
work_package_id: WP05
title: Consolidated report + defect disposition
dependencies: []
requirement_refs:
- FR-006
- FR-007
subtasks:
- T022
- T023
- T024
phase: Phase 3 - Report
history:
- at: '2026-09-23T05:05:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: reviewer-renata
authoritative_surface: kitty-specs/verify-examples-01M36AAT/
create_intent:
- kitty-specs/verify-examples-01M36AAT/verification-report.md
execution_mode: planning_artifact
model: ''
owned_files:
- kitty-specs/verify-examples-01M36AAT/verification-report.md
role: reviewer
tags: []
task_type: review
tracker_refs: []
---

# Work Package Prompt: WP05 – Consolidated report + defect disposition

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `reviewer-renata`
- **Role**: `reviewer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- Publish `kitty-specs/verify-examples-01M36AAT/verification-report.md` listing all 10 examples with status, evidence command, and outcome.
- Ensure every `fail` has a disposition (fixed or quarantined with rationale).
- Confirm SC-001..SC-005 from the spec.

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-006, FR-007; SC-003, SC-005).
- Inputs: `results/static-results.json` (WP01), `results/wp02-results.json`, `results/wp03-results.json`, `results/wp04-results.json`.
- Status vocabulary: `pass`, `fail`, `blocked (environment)`.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `verify-examples`; completed changes must merge back into `verify-examples`.
- **Planning base branch**: `verify-examples`
- **Merge target branch**: `verify-examples`

## Subtasks & Detailed Guidance

### Subtask T022 – Aggregate results

- **Purpose**: Single source of truth.
- **Steps**: Merge the four result files into a per-example table with status + evidence command + short outcome. Flag any example missing a result.

### Subtask T023 – Defect disposition

- **Purpose**: No unexplained failures.
- **Steps**: For every `fail`, record the defect, the fix applied (with file), or a quarantine rationale. Cross-check against the spec success criteria.

### Subtask T024 – Success-criteria verification

- **Purpose**: Close the mission against its criteria.
- **Steps**: State pass/fail for SC-001..SC-005 with the evidence that proves each.

## Test Strategy

- Verify the report covers exactly the 10 examples and every `fail` has a disposition.

## Risks & Mitigations

- Result files may be absent if execution WPs were blocked → mark `not verified` rather than silently passing.

## Review Guidance

- Confirm no `fail` is left without a disposition and that environment-blocked items are not counted as failures.

## Activity Log

- 2026-09-23T05:05:00Z – system – Prompt generated via /spec-kitty.tasks
