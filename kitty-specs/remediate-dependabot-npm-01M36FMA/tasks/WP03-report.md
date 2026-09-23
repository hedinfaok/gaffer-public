---
work_package_id: WP03
title: Remediation report + alert-reduction summary
dependencies:
- WP01
- WP02
requirement_refs:
- FR-006
- FR-007
planning_base_branch: remediate-dependabot-npm
merge_target_branch: remediate-dependabot-npm
branch_strategy: Planning artifacts for this mission were generated on remediate-dependabot-npm. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into remediate-dependabot-npm unless the human explicitly redirects the landing branch.
base_branch: kitty/mission-remediate-dependabot-npm-01M36FMA
base_commit: 80843a47bc34b6cd4b88c9f8a6cf735f0b88370d
created_at: '2026-09-23T06:46:37.851358+00:00'
subtasks:
- T011
- T012
- T013
phase: Phase 2 - Report
history:
- at: '2026-09-23T06:40:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: reviewer-renata
authoritative_surface: docs/
create_intent:
- docs/dependabot-remediation-report.md
execution_mode: code_change
model: ''
owned_files:
- docs/dependabot-remediation-report.md
role: reviewer
tags: []
task_type: review
tracker_refs: []
---

# Work Package Prompt: WP03 – Remediation report

## ↯ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `reviewer-renata`
- **Role**: `reviewer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- Publish `docs/dependabot-remediation-report.md` with before/after `npm audit`
  totals for all five manifests, the exact commands used, and residual advisories.
- Confirm alert reduction against SC-002.

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-006, FR-007; SC-002, SC-004).
- Inputs: WP01/WP02 results (activity logs + committed lockfiles).

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `remediate-dependabot-npm`; completed changes merge back into it.
- **Planning base branch**: `remediate-dependabot-npm`
- **Merge target branch**: `remediate-dependabot-npm`

## Subtasks & Detailed Guidance

### Subtask T011 – Aggregate before/after

- **Steps**: For each manifest, re-run `npm audit --json` on the committed
  lockfile and tabulate total + severity vs the WP01/WP02 baseline.

### Subtask T012 – Residual advisories

- **Steps**: List remaining advisories needing breaking upgrades with package,
  severity, and disposition (documented/accepted).

### Subtask T013 – Success-criteria check

- **Steps**: State pass/fail for SC-001..SC-004 with evidence.

## Review Guidance

- Confirm every manifest has before/after rows and residuals are explained.

## Activity Log

- 2026-09-23T06:40:00Z – system – Prompt generated via /spec-kitty.tasks
- 2026-09-23T06:47:19Z – opencode – Authored docs/dependabot-remediation-report.md: 112->36 npm audit (all non-breaking-fixable resolved); residuals are react-scripts (CRA) breaking-only; regression checks pass (06 10/10, 04 exit 0, 08 build-node). SC-001..004 met.
