# Implementation Plan: Remediate Dependabot npm vulnerabilities

**Branch**: `remediate-dependabot-npm` | **Date**: 2026-09-23 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `kitty-specs/remediate-dependabot-npm-01M36FMA/spec.md`

## Summary

Reduce the 235 open npm Dependabot alerts (4 critical, 121 high, 97 moderate,
13 low) that live entirely in five example `package-lock.json` files. Apply
non-breaking `npm audit fix` per manifest, regenerate lockfiles, verify each
example still builds/tests, assess residual advisories that need major upgrades,
and publish a before/after report.

## Technical Context

**Language/Version**: npm (Node 24, npm 11).
**Primary Dependencies**: example projects use webpack/react-scripts/axios/etc.
**Storage**: N/A.
**Testing**: `npm audit --json` (before/after), each example's `test.sh` / build target.
**Target Platform**: Developer machine (macOS) + CI.
**Project Type**: Dependency remediation across example manifests.
**Constraints**: Non-breaking fixes preferred; breaking upgrades require verification (C-002).
**Scale/Scope**: 5 manifests, 235 alerts.

## Charter Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Charter not synthesized; fallback `software-dev-default` + built-in directives.
- Applicable: DIRECTIVE_010 (spec fidelity), DIRECTIVE_028 (efficient tooling),
  DIRECTIVE_043 (close defect classes structurally — remediate the whole alert
  class, not one manifest).
- No blocking gates. PASS.

## Project Structure

### Documentation (this mission)

```
kitty-specs/remediate-dependabot-npm-01M36FMA/
├── spec.md
├── plan.md
├── tasks.md
└── remediation-report.md   # before/after per manifest (SC-004)
```

### Affected manifests (repository root)

```
examples/06-local-dev-environment/frontend/package-lock.json   # 121 alerts
examples/08-multi-language-task-running/node-frontend/package-lock.json  # 70
examples/06-local-dev-environment/api/package-lock.json        # 18
examples/04-incremental-testing/package-lock.json              # 16
examples/06-local-dev-environment/package-lock.json            # 10
```

**Structure Decision**: No application code. Only the five example manifests and
their `package-lock.json` change, plus a mission report.

## Complexity Tracking

No charter violations.

## Implementation Concern Map

### IC-01 — Baseline and non-breaking remediation

- **Purpose**: Capture per-manifest audit totals, then apply `npm audit fix`.
- **Relevant requirements**: FR-001, FR-002, FR-003, FR-007
- **Affected surfaces**: the five `package-lock.json` (+ `package.json` if ranges change)
- **Sequencing/depends-on**: none
- **Risks**: `npm audit fix` may bump semver ranges; lockfile churn is expected.

### IC-02 — Regression verification

- **Purpose**: Prove each remediated example still builds/tests.
- **Relevant requirements**: FR-004, NFR-001
- **Affected surfaces**: `examples/*/test.sh`, example build targets
- **Sequencing/depends-on**: IC-01
- **Risks**: examples 06/08 need Docker/toolchains; degrade to build/static checks.

### IC-03 — Residual assessment

- **Purpose**: Identify advisories needing breaking upgrades and fix or document.
- **Relevant requirements**: FR-005, C-002
- **Affected surfaces**: manifests with residual advisories
- **Sequencing/depends-on**: IC-01
- **Risks**: major upgrades can break examples → revert and document.

### IC-04 — Remediation report

- **Purpose**: Publish before/after totals, commands, and residual notes.
- **Relevant requirements**: FR-006, SC-004
- **Affected surfaces**: `kitty-specs/remediate-dependabot-npm-01M36FMA/remediation-report.md`
- **Sequencing/depends-on**: IC-01, IC-02, IC-03
- **Risks**: report must reflect the committed lockfile state.
