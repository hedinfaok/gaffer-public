# Mission Specification: All-manifests local dev web stack

**Mission Branch**: `all-manifests-devstack`
**Created**: 2026-09-23
**Status**: Draft
**Input**: "a local dev example with all of the manifest types ... I don't see procfile ... using ports for a web stack would be cool."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - One stack, every manifest type (Priority: P1)

A developer evaluating gaffer-exec wants a single local-dev web stack in which
each layer is declared with a *different* supported manifest type, so they can
see how discovery unifies Make, npm/turbo, Cargo, Python, Taskfile, just, shell
scripts, Bazel, and a Procfile.

**Why this priority**: Manifest breadth is the point; no existing example shows
Procfile or most of these types.

**Independent Test**: `gaffer-exec --workspace-root . list -t <type>` returns
graphs for every type, and the stack's `dev` flow runs.

**Acceptance Scenarios**:

1. **Given** the example, **When** `gaffer-exec list -t makefile|npm|turborepo|cargo|python|procfile|taskfile|justfile|script|bazel` runs, **Then** each type yields at least one graph.
2. **Given** the example, **When** `bash test.sh` runs, **Then** it asserts discovery per type and a clean dry-run.

### User Story 2 - Ports for a web stack (Priority: P1)

A developer wants the Procfile processes (`web`, `api`, `worker`) to receive
distinct ports automatically instead of hard-coding them.

**Independent Test**: `gaffer-exec --workspace-root . run --auto-port 3000
--port-patterns 'procfile:*' procfile:start` dry-runs, and the `dev` target wires
those flags.

**Acceptance Scenarios**:

1. **Given** the Procfile, **When** the stack starts with `--auto-port`, **Then** each process is assigned an available PORT from the base.
2. **Given** the stack, **When** a port is occupied, **Then** the next free port is chosen.

### Edge Cases

- Bazel/Turborepo/Cargo/Procfile may be unavailable in some environments; the example must degrade to static discovery + dry-run, never a false failure.
- Procfile processes are long-running; tests must not block on them.
- Keep the plain-symbol style (no emoji).

## Requirements *(mandatory)*

### Functional Requirements

| ID | Title | User Story | Priority | Status |
|----|-------|------------|----------|--------|
| FR-001 | Web stack | As a developer, I want a web stack (web, api, worker, db) to run locally. | High | Open |
| FR-002 | All manifest types | As a developer, I want every supported manifest type represented. | High | Open |
| FR-003 | Auto ports | As a developer, I want Procfile processes to get ports automatically. | High | Open |
| FR-004 | Verification | As a developer, I want a `test.sh` asserting discovery per type and a clean dry-run. | High | Open |
| FR-005 | README | As a developer, I want a README mapping each manifest to its role and the run commands. | High | Open |
| FR-006 | Docs integration | As a reader, I want the example in the root README and index. | Medium | Open |

### Non-Functional Requirements

| ID | Title | Requirement | Category | Priority | Status |
|----|-------|-------------|----------|----------|--------|
| NFR-001 | Degrade cleanly | Missing tools/services yield static/dry-run, not failure. | Reliability | High | Open |
| NFR-002 | Consistent docs | README follows the shared skeleton. | Consistency | High | Open |
| NFR-003 | Plain style | No emoji. | Consistency | Medium | Open |

### Constraints

| ID | Title | Constraint | Category | Priority | Status |
|----|-------|------------|----------|----------|--------|
| C-001 | Shipped CLI | Use gaffer-exec 0.8.0 features only. | Technical | High | Open |
| C-002 | Mission branch | Work lands on `all-manifests-devstack`. | Process | High | Open |

## Success Criteria *(mandatory)*

- **SC-001**: `gaffer-exec list -t` finds a graph for each of the 10 manifest types.
- **SC-002**: `--auto-port`/`--port-patterns` assigns ports to Procfile processes; `dev` wires them.
- **SC-003**: `test.sh` passes; primary targets dry-run cleanly.
- **SC-004**: Root README + index include the example.
