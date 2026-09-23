# Tasks: Improve the gaffer-exec examples

**Mission**: `improve-examples-01M36QTK` · **Spec**: [spec.md](./spec.md)

| WP | Title | Depends on | Requirement refs |
|----|-------|------------|------------------|
| WP01 | Root README + feature→example index | — | FR-001, FR-008 |
| WP02 | Standardize 8 example READMEs | — | FR-002, FR-003, FR-004, FR-007, FR-008 |
| WP03 | Realism fixes: examples 03 and 08 | — | FR-005, FR-006, FR-007 |

## WP01 – Root README + feature→example index
Value-first root README (what the examples show), a feature→example table, and a
`docs/example-index.md`; provenance/limitations moved to a labelled section near
the end. Communicator (`comms-cleo`) pass. **Subtasks**: T001–T003.

## WP02 – Standardize 8 example READMEs
Apply one skeleton to examples 01, 02, 04, 05, 06, 07, 18, 19; de-duplicate
boilerplate; label illustrative numbers; note overlap (02 vs 18). Grow 05, trim
01. Communicator pass. **Subtasks**: T004–T009.

## WP03 – Realism fixes: examples 03 and 08
Make 03's integration test real; make 08 real where feasible or relabel it
honestly; update their READMEs accordingly. Verify both still run.
**Subtasks**: T010–T014.
