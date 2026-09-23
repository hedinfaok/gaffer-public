# Research Specification: Are the gaffer-exec examples good examples?

**Mission Branch**: `example-quality-audit`
**Created**: 2026-09-23
**Status**: Draft
**Research Type**: Case Study + Content Analysis

## Research Question & Scope

**Primary Research Question**: Are the gaffer-exec examples *good* examples — accurate, realistic, runnable, well-documented, and pedagogically useful — and what improvements plus new examples would make the collection substantially stronger?

**Sub-Questions**:

1. **Accuracy** — Does each example's documentation match what the code actually does (no overclaims, no simulated features presented as real)?
2. **Runnability** — Does each example build/test end-to-end against `gaffer-exec` 0.8.0, and are prerequisites clearly stated?
3. **Coverage & differentiation** — Do the examples collectively cover gaffer-exec's feature surface (parallelism, caching, incremental, watch, remote/multi-region cache, cross-platform, multi-language) without redundancy and without gaps?
4. **Teaching value** — Does each example teach a real workflow a developer would recognize, or is it a toy/simulated shell?
5. **Docs experience** — Is the writing clear, consistent, and appropriately toned (communicator review)?
6. **Portfolio** — Which new examples would add the most value for target audiences (CI, polyglot monorepos, AI/ML, platform teams)?

**Scope**:

- **In Scope**: the 10 examples (`01, 02, 03, 04, 05, 06, 07, 08, 18, 19`), root `README.md`, per-example `README.md`, and supporting docs.
- **Out of Scope**: gaffer-exec CLI changes; the private tool source; published binaries.
- **Boundaries**: gaffer-exec 0.8.0; current repo state on `main`.

**Expected Outcomes**:

- A per-example scorecard (accuracy, runnability, teaching value, docs quality).
- A prioritized improvement backlog (docs, correctness, realism).
- A shortlist of new example proposals with audience, scope, and gaffer features shown.
- A communicator-persona docs review with concrete rewrite recommendations.

## Research Methodology Outline

### Research Approach

- **Method**: Structured case study across all examples + empirical runnability checks (already partly executed in mission `verify-examples-01M36AAT`).
- **Data Sources**: repository files (Makefiles, test.sh, READMEs, source), CLI behavior, and prior verification results.
- **Analysis Approach**: score each example on a rubric; cluster findings into themes; rank by impact/effort.

### Success Criteria

- Every example has a rubric score with cited evidence.
- At least 5 concrete, high-impact improvements identified.
- At least 4 new example proposals with audience and feature coverage.
- A communicator review of the docs with specific, actionable edits.

## Research Requirements

### Data Collection Requirements

- **DR-001**: Inspect every example's `README.md`, `Makefile`, `test.sh`, and source layout.
- **DR-002**: Record findings in `research/evidence-log.csv` with confidence.
- **DR-003**: Reuse the `verify-examples-01M36AAT` results as runnability evidence.

### Analysis Requirements

- **AR-001**: Produce a per-example scorecard and a thematic synthesis in `research.md`.
- **AR-002**: Document the rubric and method so the audit is reproducible.
- **AR-003**: State limitations and confidence explicitly.

### Quality Requirements

- **QR-001**: Every claim cites a file/behavior, not an impression.
- **QR-002**: Distinguish *simulated/claimed* vs *implemented and verified*.
- **QR-003**: Include a docs review by the communicator profile (`comms-cleo`).

## Key Concepts & Terminology

- **Example**: a directory under `examples/` with a `Makefile` task graph, `README.md`, and usually `test.sh`.
- **Overclaim**: documentation asserting a capability the code does not implement (vs simulated/projected).
- **Feature surface**: the capabilities gaffer-exec demonstrates (parallel scheduling, content-based caching, incremental/affected, watch, remote/multi-region cache, cross-platform, multi-language orchestration).
- **Scorecard**: per-example assessment across accuracy, runnability, teaching value, docs.

## Evidence Tracking Guidance

- Log each artifact reviewed in `research/source-register.csv`.
- Capture each finding with confidence in `research/evidence-log.csv`.
- Reference the prior mission's verification report (`docs/verify-examples-report.md`) for runnability facts.
