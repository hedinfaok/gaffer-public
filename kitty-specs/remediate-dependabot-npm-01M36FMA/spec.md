# Mission Specification: Remediate Dependabot npm vulnerabilities

**Mission Branch**: `remediate-dependabot-npm`
**Created**: 2026-09-23
**Status**: Draft
**Input**: User description: "If the debt is valid, use spec-kitty to address it."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Safe, non-breaking dependency remediation (Priority: P1)

A maintainer wants the npm Dependabot alerts in the example lockfiles reduced
using only non-breaking upgrades, so the public repo stops advertising hundreds
of known vulnerabilities without changing example behavior.

**Why this priority**: The debt is real (235 open alerts) and `npm audit fix`
resolves most of it without breaking changes.

**Independent Test**: For each affected manifest, run `npm audit fix` and confirm
the `npm audit` total drops, then confirm the example still builds/tests.

**Acceptance Scenarios**:

1. **Given** an affected example manifest, **When** `npm audit fix` runs, **Then** the lockfile is updated and the audit total decreases.
2. **Given** a remediated example, **When** its build/test flow runs, **Then** it still succeeds (no new failures).

---

### User Story 2 - Residual risk assessment (Priority: P2)

A maintainer wants the vulnerabilities that remain (those requiring breaking
upgrades) identified and either fixed with a verified targeted upgrade or
documented as accepted risk.

**Why this priority**: Some advisories only resolve via major-version bumps
(e.g. `react-scripts`/`webpack-dev-server`), which need explicit judgement.

**Independent Test**: List residual advisories per manifest with their severity
and the reason they were not auto-fixed.

**Acceptance Scenarios**:

1. **Given** residual advisories after `npm audit fix`, **When** reviewed, **Then** each is either fixed via a verified upgrade or recorded with rationale.

---

### User Story 3 - Remediation report (Priority: P3)

A maintainer wants a before/after report of alert counts and the exact commands
used.

**Why this priority**: It makes the remediation auditable and reproducible.

**Independent Test**: Read the report and confirm before/after totals per manifest.

**Acceptance Scenarios**:

1. **Given** completed remediation, **When** the report is read, **Then** each manifest has before/after `npm audit` totals and residual notes.

---

### Edge Cases

- Major-version upgrades that break the example build → revert, record as accepted risk.
- `npm audit fix` that changes `package.json` semver ranges → verify build still passes.
- Examples whose tests require Docker/network → verify build/static only.
- Dev-only tooling advisories (webpack-dev-server, eslint) → still remediate where non-breaking.

## Requirements *(mandatory)*

### Functional Requirements

| ID | Title | User Story | Priority | Status |
|----|-------|------------|----------|--------|
| FR-001 | Baseline capture | As a maintainer, I want per-manifest vulnerability baselines so progress is measurable. | High | Open |
| FR-002 | Non-breaking fix | As a maintainer, I want `npm audit fix` applied to each affected manifest. | High | Open |
| FR-003 | Lockfile integrity | As a maintainer, I want lockfiles regenerated and committed, not node_modules. | High | Open |
| FR-004 | Regression check | As a maintainer, I want each remediated example to still build/test. | High | Open |
| FR-005 | Residual assessment | As a maintainer, I want residual advisories fixed or documented. | Medium | Open |
| FR-006 | Remediation report | As a maintainer, I want a before/after report with commands. | Medium | Open |
| FR-007 | Alert reduction check | As a maintainer, I want the post-fix audit totals recorded per manifest. | High | Open |

### Non-Functional Requirements

| ID | Title | Requirement | Category | Priority | Status |
|----|-----------|-------------|----------|----------|--------|
| NFR-001 | No functional regression | Examples that passed before still pass (or regression documented). | Reliability | High | Open |
| NFR-002 | Clean tree | No `node_modules` committed; only manifests/lockfiles change. | Maintainability | High | Open |
| NFR-003 | Bounded work | <= 15 min per manifest for install/audit/verify. | Performance | Medium | Open |
| NFR-004 | No secrets | No `.env` values or tokens printed or committed. | Security | High | Open |

### Constraints

| ID | Title | Constraint | Category | Priority | Status |
|----|-------|------------|----------|----------|--------|
| C-001 | Scope | Only example npm manifests/lockfiles; no gaffer-exec CLI changes. | Technical | High | Open |
| C-002 | Prefer safe fixes | Breaking upgrades require a verified example build/test before acceptance. | Technical | High | Open |
| C-003 | Mission branch | Work lands on `remediate-dependabot-npm`. | Process | High | Open |

### Key Entities

- **Affected Manifest**: one of the five `package-lock.json` files with open alerts.
- **Advisory**: a Dependabot/npm vulnerability with severity and package.
- **Residual**: an advisory not resolved by non-breaking fixes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Non-breaking `npm audit fix` applied to all five affected manifests.
- **SC-002**: Aggregate `npm audit` total reduced by >= 80% of the non-breaking-fixable count.
- **SC-003**: Every remediated example that passed before still passes (or the regression is documented with rationale).
- **SC-004**: A report records before/after totals per manifest plus residual advisories.
