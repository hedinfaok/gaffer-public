# Tasks: Add new gaffer-exec examples

**Mission**: `new-examples-01M36RVC` · **Spec**: [spec.md](./spec.md)

| WP | Title | Depends on | Requirement refs |
|----|-------|------------|------------------|
| WP01 | 00-hello-gaffer onboarding example | — | FR-001 |
| WP02 | 20-affected-ci example | — | FR-002 |
| WP03 | 21-ci-github-actions example | — | FR-003 |
| WP04 | 22-remote-cache-s3 example | — | FR-004 |
| WP05 | 23-alternate-manifests example | — | FR-005 |
| WP06 | 24-docker-build-graph example | — | FR-006 |
| WP07 | Root README + index integration | WP01, WP02, WP03, WP04, WP05, WP06 | FR-007 |

---

## WP01 – 00-hello-gaffer onboarding example

Smallest working example: two independent tasks plus an aggregate, showing
parallelism and a cache hit. Owns `examples/00-hello-gaffer/**`.
**Subtasks**: T001, T002, T003. **Depends on**: none.

## WP02 – 20-affected-ci example

Build only what changed using `--since`/`--affected` on a small monorepo
fixture. Owns `examples/20-affected-ci/**`. **Subtasks**: T004, T005, T006.
**Depends on**: none.

## WP03 – 21-ci-github-actions example

CI example using `export --format github-actions` plus cache restore/save. Owns
`examples/21-ci-github-actions/**`. **Subtasks**: T007, T008, T009.
**Depends on**: none.

## WP04 – 22-remote-cache-s3 example

Real remote cache round-trip via MinIO using
`--cache-get-remote`/`--cache-set-remote`. Owns `examples/22-remote-cache-s3/**`.
**Subtasks**: T010, T011, T012. **Depends on**: none.

## WP05 – 23-alternate-manifests example

gaffer-exec consuming a `Taskfile.yml` and a `justfile`. Owns
`examples/23-alternate-manifests/**`. **Subtasks**: T013, T014, T015.
**Depends on**: none.

## WP06 – 24-docker-build-graph example

Build multiple container images as a parallel graph with a dependency edge. Owns
`examples/24-docker-build-graph/**`. **Subtasks**: T016, T017, T018.
**Depends on**: none.

## WP07 – Root README + index integration

Add the six new examples to the root README and `docs/example-index.md`. Owns
`README.md`, `docs/example-index.md`. **Subtasks**: T019, T020.
**Depends on**: WP01, WP02, WP03, WP04, WP05, WP06.
