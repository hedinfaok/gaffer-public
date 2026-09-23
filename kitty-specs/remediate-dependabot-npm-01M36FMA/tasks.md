# Tasks: Remediate Dependabot npm vulnerabilities

**Mission**: `remediate-dependabot-npm-01M36FMA`
**Branch**: `remediate-dependabot-npm`
**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Work Package Overview

| WP | Title | Depends on | Requirement refs |
|----|-------|------------|------------------|
| WP01 | Remediate example 06 manifests (frontend/api/root) | — | FR-001, FR-002, FR-003, FR-004, FR-005 |
| WP02 | Remediate example 08 node-frontend + example 04 | — | FR-001, FR-002, FR-003, FR-004, FR-005 |
| WP03 | Remediation report + alert-reduction summary | WP01, WP02 | FR-006, FR-007 |

---

## WP01 – Remediate example 06 manifests

**Goal**: Reduce Dependabot alerts in the 06 local-dev-environment manifests
(frontend 121, api 18, root 10) via non-breaking upgrades.

**Priority**: P1. **Independent test**: `npm audit` totals drop in each of the
three manifests and example 06 still builds/starts.

**Included subtasks**: T001–T005.

## WP02 – Remediate example 08 node-frontend + example 04

**Goal**: Reduce Dependabot alerts in 08 node-frontend (70) and 04
incremental-testing (16).

**Priority**: P1. **Independent test**: `npm audit` totals drop in both
manifests and both examples still build/test.

**Included subtasks**: T006–T010.

## WP03 – Remediation report

**Goal**: Publish `docs/dependabot-remediation-report.md` with before/after
totals per manifest, commands, and residual advisories.

**Priority**: P2. **Independent test**: the report lists all five manifests with
before/after totals and residual notes.

**Included subtasks**: T011–T013.
**Dependencies**: WP01, WP02.
