---
work_package_id: WP02
title: Remediate example 08 node-frontend + example 04
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
base_branch: kitty/mission-remediate-dependabot-npm-01M36FMA
base_commit: 80843a47bc34b6cd4b88c9f8a6cf735f0b88370d
created_at: '2026-09-23T06:44:15.809296+00:00'
subtasks:
- T006
- T007
- T008
- T009
- T010
phase: Phase 1 - Remediation
history:
- at: '2026-09-23T06:40:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/
create_intent: []
execution_mode: code_change
model: ''
owned_files:
- examples/08-multi-language-task-running/node-frontend/**
- examples/04-incremental-testing/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP02 – Remediate example 08 node-frontend + example 04

## ↯ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- Reduce Dependabot/npm vulnerabilities in `08-.../node-frontend` (70 alerts)
  and `04-incremental-testing` (16) using non-breaking `npm audit fix`.
- Both examples must still build/test.

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-001..FR-005; C-002).
- Plan: [plan.md](../plan.md).
- Example 08's `node-frontend` is a simulated webpack build (`npm run build` in the Makefile). Example 04 uses Jest.
- Do not commit `node_modules`.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `remediate-dependabot-npm`; completed changes merge back into it.
- **Planning base branch**: `remediate-dependabot-npm`
- **Merge target branch**: `remediate-dependabot-npm`

## Subtasks & Detailed Guidance

### Subtask T006 – Baseline audit (08 node-frontend)

- **Steps**: `cd examples/08-multi-language-task-running/node-frontend && npm audit --json`; record counts.

### Subtask T007 – Fix 08 node-frontend

- **Steps**: `npm ci` (or `npm install`) then `npm audit fix`; re-audit. Verify `npm run build` still works (or the Makefile's `build-node`).

### Subtask T008 – Baseline + fix example 04

- **Steps**: `cd examples/04-incremental-testing && npm audit --json`, then `npm audit fix`, then re-audit.

### Subtask T009 – Regression verify

- **Steps**: 08: `gaffer-exec --workspace-root . run --dry-run make:build-all` plus `npm run build` in node-frontend. 04: `bash test.sh` (bounded).
- **Notes**: 04's cache-invalidation test is known-flaky; rerun once.

### Subtask T010 – Residual note

- **Steps**: List advisories that require breaking upgrades with the package and reason; record for WP03.

## Test Strategy

- `cd examples/04-incremental-testing && timeout 900 bash test.sh`
- `cd examples/08-multi-language-task-running/node-frontend && npm run build`

## Risks & Mitigations

- Major upgrades (webpack-dev-server/react-scripts) may break the simulated build → verify or document.
- 08's build is simulated; prefer `npm run build`/lint checks over full multi-language suite.

## Review Guidance

- Confirm both lockfiles changed, node_modules untouched in git, and builds pass.

## Activity Log

- 2026-09-23T06:40:00Z – system – Prompt generated via /spec-kitty.tasks
- 2026-09-23T06:46:16Z – opencode – Example 08 node-frontend: npm audit fix 26->4; example 04: 11->1. Verified: 08 Makefile build-node works (simulated build, creates dist/bundle.js); 04 test.sh exit 0. Reverted incidental tracked node_modules churn in 04. Note: 08's real 'npm run build' (webpack) has a pre-existing entry/config issue unrelated to this remediation and is not the example's Makefile path. Residual 4 (08) + 1 (04) need breaking upgrades.
