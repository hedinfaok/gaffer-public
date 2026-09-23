# Mission Specification: Improve the gaffer-exec examples

**Mission Branch**: `improve-examples`
**Created**: 2026-09-23
**Status**: Draft
**Input**: Audit mission `example-quality-audit-01M36QA0` — implement improvements I1–I8.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Accurate, honest examples (Priority: P1)

A maintainer wants no example to present simulated work as real capability, so
readers trust what they see.

**Why this priority**: Trust is the collection's core asset; example 08 and 03's
integration test currently undermine it.

**Independent Test**: 08 either performs real work or is explicitly labelled a
simulation; 03's integration test runs a real cross-language smoke check.

**Acceptance Scenarios**:

1. **Given** example 08, **When** its build/test targets run, **Then** they either do real work or the docs state plainly which steps are simulated.
2. **Given** example 03, **When** `make:integration-test` runs, **Then** it executes a real check (non-zero exit on failure), not a canned `echo`.

---

### User Story 2 - Consistent, clear docs (Priority: P1)

A reader wants every example README to have the same shape and the root README to
lead with value.

**Why this priority**: Docs were the most inconsistent dimension in the audit.

**Independent Test**: every example README follows the shared skeleton; the root
README opens with what the examples show and a feature→example index.

**Acceptance Scenarios**:

1. **Given** any example, **When** its README is opened, **Then** it contains the standard sections in order.
2. **Given** the root README, **When** opened, **Then** value + index appear before any provenance/limitations section.
3. **Given** any README, **When** performance numbers appear, **Then** they are labelled illustrative.

---

### User Story 3 - Differentiated examples (Priority: P2)

A reader wants to know why 03 differs from 08 and 02 from 18.

**Why this priority**: Redundancy confuses selection.

**Independent Test**: each of 03/08 and 02/18 states its distinct purpose and points to the sibling.

**Acceptance Scenarios**:

1. **Given** 03 or 08, **When** read, **Then** it explains its distinct focus vs the sibling and links to it.

---

### Edge Cases

- Example tests must still pass after doc/realism changes.
- 08's node-frontend webpack build has a pre-existing config issue; "real" work must be scoped to what actually runs (e.g. python/go/rust real; node real via a working path or clearly labelled).
- Keep the emoji-free plain-symbol style.

## Requirements *(mandatory)*

### Functional Requirements

| ID | Title | User Story | Priority | Status |
|----|-------|------------|----------|--------|
| FR-001 | Root README rework | As a reader, I want the root README to lead with value and an index. | High | Open |
| FR-002 | README skeleton | As a reader, I want every example README to share one structure. | High | Open |
| FR-003 | De-duplicate boilerplate | As a reader, I want no repeated boilerplate; 01 trimmed, 05 expanded. | Medium | Open |
| FR-004 | Label illustrative numbers | As a reader, I want performance figures marked illustrative. | Medium | Open |
| FR-005 | Example 08 honesty | As a reader, I want 08 to do real work or be clearly labelled. | High | Open |
| FR-006 | Example 03 real test | As a reader, I want 03's integration test to be real. | High | Open |
| FR-007 | Differentiate overlap | As a reader, I want 03/08 and 02/18 to state distinct purposes. | Medium | Open |
| FR-008 | Communicator review | As a reader, I want the docs reviewed and rewritten with a communicator lens. | High | Open |

### Non-Functional Requirements

| ID | Title | Requirement | Category | Priority | Status |
|----|-------|-------------|----------|----------|--------|
| NFR-001 | No regressions | Every example that passed still passes. | Reliability | High | Open |
| NFR-002 | Plain-symbol style | No emoji; keep plain unicode symbols. | Consistency | Medium | Open |
| NFR-003 | Consistent voice | Second person, sentence-case headings, no marketing superlatives. | Consistency | Medium | Open |

### Constraints

| ID | Title | Constraint | Category | Priority | Status |
|----|-------|------------|----------|----------|--------|
| C-001 | Stay runnable | Examples must remain runnable on gaffer-exec 0.8.0. | Technical | High | Open |
| C-002 | Mission branch | Work lands on `improve-examples`. | Process | High | Open |

### Key Entities

- **Shared skeleton**: the canonical README section order.
- **Illustrative label**: inline marker distinguishing projected from measured numbers.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 10/10 example READMEs follow the shared skeleton.
- **SC-002**: Root README leads with value + feature→example index.
- **SC-003**: 03's integration test is real; 08's simulation status is explicit.
- **SC-004**: All example tests still pass after changes.
