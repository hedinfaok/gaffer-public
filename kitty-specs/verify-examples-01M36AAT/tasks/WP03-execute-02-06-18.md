---
work_package_id: WP03
title: Execute examples 02, 06, 18 (service-dependent)
dependencies:
- WP01
requirement_refs:
- FR-003
- FR-005
planning_base_branch: verify-examples
merge_target_branch: verify-examples
branch_strategy: Planning artifacts for this mission were generated on verify-examples. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into verify-examples unless the human explicitly redirects the landing branch.
base_branch: kitty/mission-verify-examples-01M36AAT
base_commit: a9dc23c88fee30944196b9a563c688eb9e647506
created_at: '2026-09-23T05:27:33.140547+00:00'
subtasks:
- T012
- T013
- T014
- T015
- T016
phase: Phase 2 - Execution
history:
- at: '2026-09-23T05:05:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/
create_intent: []
execution_mode: code_change
model: ''
owned_files:
- examples/02-distributed-build/**
- examples/06-local-dev-environment/**
- examples/18-network-aware-builds/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP03 – Execute examples 02, 06, 18 (service-dependent)

## ↯ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- Verify the service-dependent examples pass all static checks and either execute successfully or degrade to `blocked (environment)` naming the missing service.
- Audit documented `gaffer-exec` commands in the owned examples.
- Fix non-environment defects inside the owning example only.

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-003, FR-005; NFR-002, NFR-003, NFR-004).
- Plan: [plan.md](../plan.md) (IC-02, IC-03).
- Docker/LocalStack/Redis/Postgres may be unavailable; that is `blocked (environment)`, not `fail`.
- Never echo `.env` values (the root `.env` holds DB/API ports).

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `verify-examples`; completed changes must merge back into `verify-examples`.
- **Planning base branch**: `verify-examples`
- **Merge target branch**: `verify-examples`

## Subtasks & Detailed Guidance

### Subtask T012 – Example 02 (distributed-build)

- **Purpose**: Go microservices + cloud cache.
- **Steps**: Check Docker; if available run `bash test.sh`, else run harness static checks and record `blocked (environment: docker)`. Record Go toolchain presence.

### Subtask T013 – Example 06 (local-dev-environment)

- **Purpose**: Postgres + API + frontend dev stack.
- **Steps**: Check Docker for Postgres; run `bash test.sh` if available, else static + `blocked (environment: docker)`. Verify `package.json` scripts invoke `make:` targets.

### Subtask T014 – Example 18 (network-aware-builds)

- **Purpose**: Multi-region cache build.
- **Steps**: Docker required for regions; run static checks always. If Docker present, run `bash test.sh` with a timeout.

### Subtask T015 – Documentation command audit (owned examples)

- **Purpose**: Docs must match the CLI.
- **Steps**: Extract `gaffer-exec ...` lines; confirm flags exist in `gaffer-exec --help`.

### Subtask T016 – Fix defects in place

- **Purpose**: Leave examples green or cleanly blocked.
- **Steps**: Fix non-environment failures within the owning example; re-run; record any unfixable defect + rationale for WP05.

## Test Strategy

- Static checks must pass for all three; executed results recorded.

## Risks & Mitigations

- `docker compose up` may hang → bound with timeout and always run `stop`/cleanup.
- Ports may collide with local services → detect and record as environment-blocked.

## Review Guidance

- Confirm each result names the exact missing prerequisite when blocked, and that no `.env` content leaked into logs.

## Activity Log

- 2026-09-23T05:05:00Z – system – Prompt generated via /spec-kitty.tasks
- 2026-09-23T06:21:36Z – opencode – Executed examples 02/06/18 (Docker up). 06 pass (10/10) after a transient first-run DB-start failure; rerun green. 18 pass (test.sh exit 0) after fixing two defects: (a) docker-compose mounted /tmp/localstack with DATA_DIR, which modern LocalStack cannot clear -> switched to /var/lib/localstack; (b) start-regions.sh health check compared 'ok' but curl -sf emitted the JSON body ('{json}ok') so readiness never passed -> redirected curl output. 02 blocked (environment: azure-cli 'az' and gsutil missing) but a real LocalStack defect was fixed (same /tmp/localstack -> /var/lib/localstack change); AWS path now starts healthy.
