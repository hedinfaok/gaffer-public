# Tasks: All-manifests local dev web stack

**Mission**: `all-manifests-devstack-01M37QY5` · **Spec**: [spec.md](./spec.md)

| WP | Title | Depends on | Requirement refs |
|----|-------|------------|------------------|
| WP01 | Build the all-manifests dev stack example | — | FR-001, FR-002, FR-003, FR-004, FR-005 |
| WP02 | Root README + index integration | WP01 | FR-006 |

---

## WP01 – Build the all-manifests dev stack example

Create `examples/25-all-manifests-devstack/` covering all manifest types with a
web stack and auto-assigned ports. Owns `examples/25-all-manifests-devstack/**`.
**Subtasks**: T001, T002, T003, T004, T005, T006. **Depends on**: none.

## WP02 – Root README + index integration

Add the example to the root README and `docs/example-index.md`. Owns `README.md`,
`docs/example-index.md`. **Subtasks**: T007, T008. **Depends on**: WP01.
