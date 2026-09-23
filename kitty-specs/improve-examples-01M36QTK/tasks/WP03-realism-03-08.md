---
work_package_id: WP03
title: 'Realism fixes: examples 03 and 08'
dependencies: []
requirement_refs:
- FR-005
- FR-006
- FR-007
planning_base_branch: improve-examples
merge_target_branch: improve-examples
branch_strategy: Planning artifacts for this mission were generated on improve-examples. During /spec-kitty.implement this WP may branch from a dependency-specific base, but completed changes must merge back into improve-examples unless the human explicitly redirects the landing branch.
subtasks:
- T010
- T011
- T012
- T013
- T014
phase: Phase 2 - Realism
history:
- at: '2026-09-23T09:10:00Z'
  actor: system
  action: Prompt generated via /spec-kitty.tasks
agent_profile: implementer-ivan
authoritative_surface: examples/03-multi-language-build/
create_intent: []
execution_mode: code_change
model: ''
owned_files:
- examples/03-multi-language-build/**
- examples/08-multi-language-task-running/**
role: implementer
tags: []
task_type: implement
tracker_refs: []
---

# Work Package Prompt: WP03 – Realism fixes: examples 03 and 08

## ⚡ Do This First: Load Agent Profile

Use the `/ad-hoc-profile-load` skill to load the agent profile specified in the frontmatter, and behave according to its guidance before parsing the rest of this prompt.

- **Profile**: `implementer-ivan`
- **Role**: `implementer`
- **Agent/tool**: `opencode`

## Objectives & Success Criteria

- Example 03: `make:integration-test` performs a real cross-language smoke check that fails (non-zero) when a component is broken — no canned `echo`.
- Example 08: each build/test target does real work where the toolchain supports it; anything still simulated is clearly labelled in code output and README.
- Both examples still pass their `test.sh`.

## Context & Constraints

- Spec: [spec.md](../spec.md) (FR-005, FR-006, FR-007; NFR-001).
- gaffer-exec 0.8.0; keep targets/deps intact.
- 08 node-frontend real webpack build has a pre-existing `index.wasm` config issue — either fix the config so `npm run build` works, or keep node's step labelled as simulated while python/go/rust run real tools. Do not pretend.
- No emoji; plain symbols.

## Branch Strategy

- **Strategy**: Planning artifacts were generated on `improve-examples`; completed changes merge back into it.
- **Planning base branch**: `improve-examples`
- **Merge target branch**: `improve-examples`

## Subtasks & Detailed Guidance

### Subtask T010 – Real integration test for 03
- **Purpose**: Replace the fake `echo … sleep`.
- **Steps**: Add a small script (e.g. `scripts/integration-test.sh`) that runs the built Go CLI / Rust binary / Node test / Python analysis and asserts real output; make `integration-test` call it and exit non-zero on failure.
- **Files**: `examples/03-multi-language-build/Makefile`, `examples/03-multi-language-build/scripts/`

### Subtask T011 – 08 build targets: real or labelled
- **Steps**: For node, either fix `webpack.config.js` so `npm run build` succeeds and call it from `build-node`, or keep the simulated build but print an explicit "(simulated)" marker. python/go/rust already run real tools — confirm.
- **Files**: `examples/08-multi-language-task-running/Makefile`, `node-frontend/webpack.config.js`

### Subtask T012 – 08 test targets: real or labelled
- **Steps**: Make `test-node` run real Jest (add a minimal test if needed) or mark simulated. Confirm python/go/rust run real tests.
- **Files**: `examples/08-multi-language-task-running/Makefile`, `node-frontend/`

### Subtask T013 – Update 03/08 READMEs
- **Steps**: Apply the shared skeleton to `examples/03-.../README.md` and `examples/08-.../README.md`; state plainly what is real vs simulated; add the 03↔08 differentiation note + link.
- **Files**: `examples/03-multi-language-build/README.md`, `examples/08-multi-language-task-running/README.md`

### Subtask T014 – Verify
- **Steps**: Run `bash test.sh` for 03 and 08 (bounded); confirm pass. Run `make -n` for the primary targets.

## Test Strategy
- `cd examples/03-multi-language-build && bash test.sh`
- `cd examples/08-multi-language-task-running && bash test.sh` (or the build/test subset if heavy)

## Risks & Mitigations
- Breaking a build → keep changes minimal and re-run tests.
- Heavy 08 suite → verify the changed targets directly.

## Review Guidance
- 03 integration test can fail; 08 simulation status is explicit; both tests pass.

## Activity Log
- 2026-09-23T09:10:00Z – system – Prompt generated via /spec-kitty.tasks
