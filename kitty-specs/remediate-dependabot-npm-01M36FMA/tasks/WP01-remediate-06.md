---
work_package_id: WP01
title: Remediate example 06 manifests (frontend/api/root)
dependencies: []
requirement_refs:
- FR-001
- FR-002
- FR-003
- FR-004
- FR-005
planning_base_branch: remediate-dependabot-npm
merge_target_branch: remediate-dependabot-npm
branch_strategy: Planning artifacts for this mission were generated on remediate-dependabot-npm. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into remediate-dependabot-npm unless the human explicitly redirects the landing branch.
subtasks:
- T001
- T002
- T003
- T004
- T005
phase: Phase 1 - Remediation
history:
- at: '2026-09-23T06:40:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/06-local-dev-environment/
create_intent: []
execution_mode: code_change
model: ''
owned_files:
- examples/06-local-dev-environment/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP01 – Remediate example 06 manifests

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- Reduce Dependabot/npm vulnerabilities in the three example-06 manifests
  (`frontend`, `api`, repo-root `06-local-dev-environment`) using non-breaking
  `npm audit fix`.
- Example 06 must still build/start (run its `test.sh` or the build target).

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-001..FR-005; NFR-001..004; C-002).
- Plan: [plan.md](../plan.md) (IC-01, IC-02, IC-03).
- Prefer `npm audit fix` (non-breaking). Do NOT use `--force` without verifying
  the example afterward.
- Do not commit `node_modules`. Only `package.json`/`package-lock.json` change.
- Docker (Postgres) is required for the full 06 test; degrade to build/static
  checks if unavailable.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `remediate-dependabot-npm`; completed changes merge back into it.
- **Planning base branch**: `remediate-dependabot-npm`
- **Merge target branch**: `remediate-dependabot-npm`

## Subtasks & Detailed Guidance

### Subtask T001 – Baseline audit

- **Purpose**: Record before counts.
- **Steps**: In `examples/06-local-dev-environment/{frontend,api,.}`, run `npm audit --json` and record total/critical/high/moderate/low.

### Subtask T002 – Apply non-breaking fix (frontend)

- **Purpose**: Largest alert set (121).
- **Steps**: `cd frontend && npm audit fix`, then `npm audit --json`.

### Subtask T003 – Apply non-breaking fix (api)

- **Steps**: `cd api && npm audit fix`, then re-audit.

### Subtask T004 – Apply non-breaking fix (root)

- **Steps**: `npm audit fix` in `examples/06-local-dev-environment/`, then re-audit.

### Subtask T005 – Regression verify + residual note

- **Purpose**: Prove no functional regression; record residuals.
- **Steps**: Run `bash test.sh` (or `gaffer-exec --workspace-root . run make:dev` bounded) and the frontend/api builds. List remaining advisories and whether they need breaking upgrades.

## Test Strategy

- `cd examples/06-local-dev-environment && timeout 600 bash test.sh` → expect pass (or environment-blocked documented).

## Risks & Mitigations

- `react-scripts`/`webpack-dev-server` majors may need `--force` → only after verifying; otherwise document as residual.
- `npm audit fix` may modify `package.json` ranges → re-run build to confirm.

## Review Guidance

- Confirm lockfiles changed, node_modules not committed, and 06 still passes.

## Activity Log

- 2026-09-23T06:40:00Z – system – Prompt generated via /spec-kitty.tasks
