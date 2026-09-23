# Mission Specification: Add new gaffer-exec examples

**Mission Branch**: `new-examples`
**Created**: 2026-09-23
**Status**: Draft
**Input**: Audit `example-quality-audit-01M36QA0` new-example proposals N1–N6.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A gentle first example (Priority: P1)

A new user wants the smallest possible working example to understand the core
loop (task graph, parallelism, caching) before the large examples.

**Independent Test**: `examples/00-hello-gaffer` runs two independent tasks in
parallel and shows a cache hit on re-run.

### User Story 2 - Incremental CI and caching examples (Priority: P1)

A platform engineer wants examples of building only what changed and caching in
CI, because those are gaffer-exec's headline CI features.

**Independent Test**: `20-affected-ci` runs only affected targets via
`--since`; `21-ci-github-actions` ships a workflow using
`export --format github-actions` and cache restore/save.

### User Story 3 - Real remote cache and alternate manifests (Priority: P2)

A maintainer wants a real (not simulated) remote cache example and one showing
non-Make manifests.

**Independent Test**: `22-remote-cache-s3` performs cache get/set against MinIO;
`23-alternate-manifests` runs a `Taskfile.yml` and a `justfile`.

### User Story 4 - Docker build graph (Priority: P2)

A DevOps user wants to build/publish container images as a dependency graph.

**Independent Test**: `24-docker-build-graph` builds multiple images in parallel
with a dependency edge.

### Edge Cases

- Examples requiring services (MinIO, Docker) must degrade to static/dry-run when unavailable.
- `export --format github-actions` output must be validated against gaffer 0.8.0.
- Keep the plain-symbol style (no emoji).

## Requirements *(mandatory)*

### Functional Requirements

| ID | Title | User Story | Priority | Status |
|----|-------|------------|----------|--------|
| FR-001 | 00-hello-gaffer | As a new user, I want a minimal onboarding example. | High | Open |
| FR-002 | 20-affected-ci | As a platform engineer, I want an affected/since example. | High | Open |
| FR-003 | 21-ci-github-actions | As a CI maintainer, I want a GitHub Actions + cache example. | High | Open |
| FR-004 | 22-remote-cache-s3 | As a distributed team, I want a real remote cache example. | Medium | Open |
| FR-005 | 23-alternate-manifests | As a polyglot repo owner, I want Taskfile/justfile examples. | Medium | Open |
| FR-006 | 24-docker-build-graph | As a DevOps user, I want a container build graph example. | Medium | Open |
| FR-007 | Docs integration | As a reader, I want the new examples in the root README + index. | High | Open |

### Non-Functional Requirements

| ID | Title | Requirement | Category | Priority | Status |
|----|-------|-------------|----------|----------|--------|
| NFR-001 | Runnable | Every new example builds/tests on gaffer-exec 0.8.0 or degrades to dry-run. | Reliability | High | Open |
| NFR-002 | Consistent docs | Every new example README follows the shared skeleton. | Consistency | High | Open |
| NFR-003 | Plain style | No emoji; plain unicode symbols. | Consistency | Medium | Open |

### Constraints

| ID | Title | Constraint | Category | Priority | Status |
|----|-------|------------|----------|----------|--------|
| C-001 | Shipped CLI | Use gaffer-exec 0.8.0 features only. | Technical | High | Open |
| C-002 | Mission branch | Work lands on `new-examples`. | Process | High | Open |

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 6 new examples exist, each with `Makefile`, `README.md` (shared skeleton), and `test.sh`.
- **SC-002**: Each new example's primary target dry-runs cleanly (`gaffer-exec --dry-run`).
- **SC-003**: Root README + `docs/example-index.md` include the new examples.
- **SC-004**: No regression in existing examples.
