# Implementation Plan: Improve the gaffer-exec examples

**Branch**: `improve-examples` | **Spec**: [spec.md](./spec.md)

## Summary

Execute the audit's improvement backlog: rework the root README (value-first +
feature→example index), standardize every example README to one skeleton (with
de-duplicated boilerplate, illustrative-number labels, and overlap notes), and
fix the two realism defects (example 08 simulation, example 03 fake integration
test). Docs changes get a communicator (`comms-cleo`) pass; code changes stay
minimal and keep examples runnable on gaffer-exec 0.8.0.

## Technical Context

**Language/Version**: Markdown docs; Bash/Make for the realism fixes.
**Testing**: existing `test.sh` per example; `make -n` / `gaffer-exec --dry-run`.
**Constraints**: no emoji; plain unicode symbols; keep examples runnable (C-001).

## Charter Check

Charter not synthesized; fallback `software-dev-default`. Applicable directives:
DIRECTIVE_010 (spec fidelity), DIRECTIVE_028 (efficient tooling), DIRECTIVE_043
(close defect classes). PASS.

## Project Structure

```
README.md                          # root (WP01)
docs/example-index.md              # feature->example index (WP01, new)
examples/*/README.md               # per-example docs (WP02)
examples/03-multi-language-build/**# real integration test (WP03)
examples/08-multi-language-task-running/** # real-or-relabel (WP03)
```

## Implementation Concern Map

### IC-01 — Root docs and index
- **Requirements**: FR-001, FR-008
- **Surfaces**: `README.md`, `docs/example-index.md`
- **Risks**: keep the honest provenance section, just relocate it lower.

### IC-02 — Example README standardization
- **Requirements**: FR-002, FR-003, FR-004, FR-007, FR-008, NFR-002, NFR-003
- **Surfaces**: `examples/*/README.md`
- **Risks**: don't drop example-specific detail; preserve commands exactly.

### IC-03 — Realism fixes
- **Requirements**: FR-005, FR-006, NFR-001
- **Surfaces**: `examples/03-multi-language-build/**`, `examples/08-multi-language-task-running/**`
- **Risks**: 08's node webpack build has a pre-existing config issue; scope "real" to working paths and label the rest.

### IC-04 — Verification
- **Requirements**: NFR-001, SC-004
- **Surfaces**: example `test.sh`
- **Risks**: re-run affected examples after edits.
