---
work_package_id: WP01
title: Build the all-manifests dev stack example
dependencies: []
requirement_refs:
- FR-001
- FR-002
- FR-003
- FR-004
- FR-005
planning_base_branch: all-manifests-devstack
merge_target_branch: all-manifests-devstack
branch_strategy: Planning artifacts for this mission were generated on all-manifests-devstack. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into all-manifests-devstack unless the human explicitly redirects the landing branch.
base_branch: kitty/mission-all-manifests-devstack-01M37QY5
base_commit: 2e569c7194cd0b8e94d68b83ec52b83669acdf0a
created_at: '2026-09-23T18:21:27.161763+00:00'
subtasks:
- T001
- T002
- T003
- T004
- T005
- T006
phase: Phase 1 - Example
history:
- at: '2026-09-23T11:00:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/25-all-manifests-devstack/
create_intent:
- examples/25-all-manifests-devstack/README.md
- examples/25-all-manifests-devstack/Makefile
- examples/25-all-manifests-devstack/Procfile
- examples/25-all-manifests-devstack/test.sh
execution_mode: code_change
model: ''
owned_files:
- examples/25-all-manifests-devstack/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP01 – Build the all-manifests dev stack example

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- `examples/25-all-manifests-devstack/` is a runnable local-dev web stack where every gaffer-exec manifest type participates.
- `gaffer-exec --workspace-root . list -t <type>` yields a graph for: makefile, npm, turborepo, cargo, python, procfile, taskfile, justfile, script, bazel.
- `--auto-port`/`--port-patterns` assign ports to the Procfile processes; a `dev` target wires the flags.
- `test.sh` asserts per-type discovery and a clean dry-run.

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-001..FR-005; NFR-001..003; C-001).
- gaffer-exec 0.8.0. Verified facts:
  - Procfile → `procfile:start` composite with `procfile:start:web` etc.; processes see `$PORT`.
  - `--auto-port 3000 --port-patterns 'procfile:*'` injects PORT.
  - Turborepo needs `package.json` `workspaces` + `turbo.json`.
  - Types: `make:`, `npm:`, `turbo:`, `cargo:`, `python:`, `procfile:`, `taskfile:`, `just:`, `script:`, `bazel:`.
- No emoji; plain unicode symbols only. Keep processes long-running out of tests.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `all-manifests-devstack`; completed changes merge back into it.
- **Planning base branch**: `all-manifests-devstack`
- **Merge target branch**: `all-manifests-devstack`

## Subtasks & Detailed Guidance

### Subtask T001 – Skeleton + Makefile (orchestration)
- **Steps**: Create the directory; `Makefile` with `build-all` (deps on the per-manifest build graphs), `dev` (starts the stack with auto-port), `test-all`, `clean`, `ports`. `.PHONY`, `.DEFAULT_GOAL := dev`. `dev` should call: `gaffer-exec --workspace-root . run --auto-port 3000 --port-patterns 'procfile:*' procfile:start`.

### Subtask T002 – Procfile + processes
- **Steps**: `Procfile` with `web:`, `api:`, `worker:` using `$PORT`. Provide real, tiny implementations: `web/` npm frontend (serves HTML on PORT), `api/` Python HTTP service (PORT), `worker/` Rust binary (reads PORT, loops/logs). Also a `scripts/db-init.sh` (script type) and `scripts/health.sh`.

### Subtask T003 – npm + turborepo
- **Steps**: Root `package.json` with `workspaces: ["web"]` and scripts; `turbo.json` pipeline (`build`, `test`); `web/package.json` with a real `build`.

### Subtask T004 – cargo + python + taskfile + justfile + bazel
- **Steps**: `worker/Cargo.toml` (+ minimal `src/main.rs`); `api/pyproject.toml` (or `setup.py`) with a `build`/`test`; `Taskfile.yml` (`build`/`test`); `justfile` (`build`/`test`/`migrate`); `WORKSPACE.bazel` + `BUILD.bazel` (a genrule producing an artifact). Each must be discoverable by gaffer-exec.

### Subtask T005 – README (shared skeleton)
- **Steps**: Title → What this shows → What you'll learn → Prerequisites → Quick start → Task graph (a table mapping EACH manifest type to its role) → How it works (incl. the port assignment) → Expected output → Testing → Troubleshooting → Next example (link 06-local-dev-environment). Include the exact `dev` command and the `list -t` discovery commands.

### Subtask T006 – test.sh
- **Steps**: For each type, assert `gaffer-exec --workspace-root . list -t <type>` finds a graph; assert `run --dry-run procfile:start` and `--auto-port` dry-run succeed; assert `run --dry-run make:build-all`. Degrade cleanly (skip a type with a warning only if truly unsupported). Exit non-zero on failure.

## Test Strategy
- `cd examples/25-all-manifests-devstack && bash test.sh`
- `gaffer-exec --workspace-root . list -t procfile` etc.; `run --dry-run make:build-all`.

## Risks & Mitigations
- Bazel/turbo discovery quirks → verify each with `list -t` and adjust files.
- Long-running Procfile processes → never start them unbounded in tests; dry-run only.
- Missing toolchains → tests assert discovery/dry-run, not compilation.

## Review Guidance
- All 10 types discoverable; ports wired; test.sh passes; README maps manifests to roles.

## Activity Log
- 2026-09-23T11:00:00Z – system – Prompt generated via /spec-kitty.tasks
- 2026-09-23T18:30:52Z – opencode – Done and verified.
