# Mission Specification: Verify all gaffer-exec examples

**Mission Branch**: `verify-examples`
**Created**: 2026-09-23
**Status**: Draft
**Input**: User description: "run a spec-kitty mission to verify all of the examples in this repo."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Static verification of every example's task graph (Priority: P1)

A maintainer wants every example's `Makefile` task graph to be discoverable and
valid under the shipped `gaffer-exec` CLI, so that no example ships with a
broken or stale manifest.

**Why this priority**: This is the cheapest, most deterministic check and
catches the failure class that started this work (the removed JSON graph
format). It needs no external services or toolchains.

**Independent Test**: For each example directory run
`gaffer-exec --workspace-root . validate` and
`gaffer-exec --workspace-root . run --dry-run make:<primary-target>`, and confirm
exit 0 plus the expected dependency chain.

**Acceptance Scenarios**:

1. **Given** an example with a `Makefile`, **When** `gaffer-exec --workspace-root . validate` runs in its directory, **Then** it exits 0 with no graph errors.
2. **Given** an example, **When** `gaffer-exec --workspace-root . run --dry-run make:<primary>` runs, **Then** it lists the primary target plus its full dependency closure in a valid order.
3. **Given** the repository, **When** searching for `graph.json`, `--graph`, or `--graph-override` in example content, **Then** zero matches remain.

---

### User Story 2 - Execute each example's build/test flow (Priority: P1)

A maintainer wants each example's primary target and its own `test.sh` executed,
so that documented behavior is proven, not assumed.

**Why this priority**: Static checks do not prove the examples build and test
successfully. This is the core value of "verify".

**Independent Test**: For each example, run its `test.sh` (or documented
primary target) and capture the exit code and output summary.

**Acceptance Scenarios**:

1. **Given** an example whose prerequisites are installed, **When** its `test.sh` runs, **Then** it exits 0 and reports success.
2. **Given** an example whose prerequisites are unavailable (Docker, cloud, or a language toolchain), **When** verification runs, **Then** the result is recorded as `blocked (environment)` with the missing prerequisite named, not as a failure.
3. **Given** a long-running or interactive example, **When** verification runs, **Then** it is bounded by a timeout and does not hang.

---

### User Story 3 - Documentation commands match the CLI (Priority: P2)

A maintainer wants every command shown in example documentation to be
executable against the installed CLI, so readers are not misled.

**Why this priority**: Docs drift is the second-most common defect after the
manifest format itself.

**Independent Test**: Extract `gaffer-exec ...` invocations from example
markdown/scripts and confirm each uses only flags that exist in
`gaffer-exec --help`.

**Acceptance Scenarios**:

1. **Given** example documentation, **When** its `gaffer-exec` invocations are checked, **Then** none reference removed flags or non-existent subcommands.
2. **Given** a documented quick-start command, **When** executed in dry-run form, **Then** it resolves a real graph.

---

### User Story 4 - Consolidated verification report (Priority: P3)

A maintainer wants a single report summarizing per-example status and any
defects, so the result is auditable and actionable.

**Why this priority**: The report is the durable deliverable; it is lower
priority than producing trustworthy results.

**Independent Test**: Read the report and confirm it lists all examples with
status, evidence command, and outcome.

**Acceptance Scenarios**:

1. **Given** completed verification, **When** the report is opened, **Then** every example has a status of `pass`, `fail`, or `blocked (environment)` with evidence.
2. **Given** any `fail`, **When** the report is read, **Then** the defect and its resolution (fixed or quarantined) are recorded.

---

### Edge Cases

- Missing toolchains (Go, Rust, Python, Node, Docker) — record `blocked (environment)`.
- Examples that start long-running servers (`dev`, `start`, watch modes) — bound with a timeout and verify the build stage only.
- Network-dependent examples (02, 18) requiring LocalStack/Redis — degrade to static + dry-run checks when services are absent.
- Flaky or signal-handling tests (04) — allow bounded retries; report variance.
- Examples with large dependency installs (venv/node_modules) — record install time and do not fail on environment-only issues.

## Requirements *(mandatory)*

### Functional Requirements

| ID | Title | User Story | Priority | Status |
|----|-------|------------|----------|--------|
| FR-001 | Graph validation | As a maintainer, I want every example's Makefile graph validated so stale manifests are caught. | High | Open |
| FR-002 | Dry-run dependency check | As a maintainer, I want each primary target dry-run so dependency order is proven. | High | Open |
| FR-003 | Execute example tests | As a maintainer, I want each example's `test.sh` executed so behavior is proven. | High | Open |
| FR-004 | Stale-reference sweep | As a maintainer, I want zero removed-format references in example content. | High | Open |
| FR-005 | Doc command audit | As a maintainer, I want documented `gaffer-exec` commands checked against the CLI. | Medium | Open |
| FR-006 | Verification report | As a maintainer, I want a consolidated per-example report with evidence. | Medium | Open |
| FR-007 | Defect disposition | As a maintainer, I want every discovered defect fixed or explicitly quarantined with rationale. | High | Open |
| FR-008 | Repeatable harness | As a maintainer, I want one scripted entry point that reproduces the whole verification. | Medium | Open |

### Non-Functional Requirements

| ID | Title | Requirement | Category | Priority | Status |
|----|-------|-------------|----------|----------|--------|
| NFR-001 | Deterministic static checks | All static checks complete in under 5 minutes total on a warm checkout. | Performance | High | Open |
| NFR-002 | Bounded execution | Every executed example step is bounded by a timeout (<= 10 min per example). | Reliability | High | Open |
| NFR-003 | Environment degradation | Missing external prerequisites produce `blocked (environment)`, never a false `fail`. | Reliability | High | Open |
| NFR-004 | No secret exposure | Verification never prints or commits `.env` values or credentials. | Security | High | Open |
| NFR-005 | Clean tree preservation | Verification removes transient artifacts (`.gaffer/`, build outputs it creates) or leaves them gitignored. | Maintainability | Medium | Open |

### Constraints

| ID | Title | Constraint | Category | Priority | Status |
|----|-------|------------|----------|----------|--------|
| C-001 | Shipped CLI only | Verification uses installed `gaffer-exec` 0.7.1; no CLI changes. | Technical | High | Open |
| C-002 | No new required services | Examples must not be rewritten to require new external services. | Technical | Medium | Open |
| C-003 | Mission branch | All work lands on `verify-examples` and merges back to it. | Process | High | Open |
| C-004 | Fixes stay in-scope | Defects are fixed within the example that owns them; no cross-example refactors. | Process | Medium | Open |

### Key Entities

- **Example**: one directory under `examples/` with a `Makefile` task graph, a `README.md`, and usually a `test.sh`.
- **Verification Result**: per-example record of status (`pass`/`fail`/`blocked`), the evidence command, output summary, and any defect.
- **Defect**: a reproducible failure or documentation inaccuracy with a disposition (fixed or quarantined).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 10/10 examples pass static verification (`validate` + dry-run of the primary target) with exit 0.
- **SC-002**: 10/10 examples have an executed result recorded (pass, fail, or blocked-environment) from `test.sh` or the documented primary target.
- **SC-003**: Every non-environment `fail` is fixed within the mission, or quarantined with a written rationale; zero unexplained failures remain.
- **SC-004**: Zero references to the removed JSON-graph format remain in example content.
- **SC-005**: A single report at `kitty-specs/verify-examples-01M36AAT/verification-report.md` lists every example with status and evidence.
