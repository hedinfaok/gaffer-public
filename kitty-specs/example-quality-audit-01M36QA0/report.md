# Example Quality Audit — Report

**Mission**: `example-quality-audit-01M36QA0`
**Type**: Research (case study + content analysis)
**Date**: 2026-09-23
**Subject**: the gaffer-exec example collection (`examples/01…19`, root README)

## Executive summary

The examples are **runnable and several are genuinely good**, but the collection
is uneven. Three systemic issues stand out: **simulated work presented as
capability** (worst: example 08), **overlapping examples** (03↔08, 02↔18), and
**inconsistent docs with unmeasured performance claims**. The larger opportunity
is *coverage*: gaffer-exec's headline features — `--affected`/`--since`, CI
`export`, remote cache get/set, alternate manifests — are barely or never shown.

**Verdict**: worth keeping and improving, not rewriting. Fix the accuracy and
docs issues, retire or differentiate the redundant examples, and add a small set
of high-value new examples led by an onboarding example and an incremental-CI
example.

## Scorecard (1–5)

| Example | Accuracy | Runnable | Teaching | Docs |
|---|:--:|:--:|:--:|:--:|
| 01-monorepo-build | 4 | 5 | 4 | 3 |
| 02-distributed-build | 4 | 3 | 4 | 4 |
| 03-multi-language-build | 3 | 5 | 3 | 3 |
| 04-incremental-testing | 4 | 4 | 4 | 4 |
| 05-ml-workflows | 4 | 5 | 3 | 2 |
| 06-local-dev-environment | 4 | 5 | 4 | 4 |
| 07-watch-workflows | 4 | 5 | 4 | 4 |
| 08-multi-language-task-running | 2 | 4 | 2 | 3 |
| 18-network-aware-builds | 4 | 4 | 4 | 4 |
| 19-cross-platform-builds | 4 | 5 | 4 | 4 |

**Averages**: Accuracy 3.5 · Runnability 4.5 · Teaching 3.6 · Docs 3.5.

## Key findings

1. **Simulation as capability.** `08` builds/tests with `echo` and a canned PASS
   (`Makefile:41,57`); `03`'s `integration-test` is `echo … sleep` (`Makefile:41`).
   Disclosed simulations (02 mocks, 18 delta, 04 flaky) are fine; undisclosed
   ones undermine trust.
2. **Redundancy.** `03` vs `08` (multi-language) and `02` vs `18` (remote cache).
   `18` and `03` are the stronger of each pair.
3. **Unmeasured claims.** Specific ms/bandwidth figures (01, 18) are illustrative;
   label them inline.
4. **Docs drift.** No shared README skeleton; repeated "Real Open Source Project
   Pattern" boilerplate; `01` has a duplicated tail; `05`'s README is thin; root
   README leads with a long LLM disclaimer before any value.
5. **Coverage gaps.** No example for `--affected`/`--since`, CI (`export
   --format github-actions` + cache), real remote cache (`--cache-get-remote`/
   `--cache-set-remote`), or alternate manifests (Taskfile/justfile). No minimal
   onboarding example.

## Communicator review (`comms-cleo`)

- Lead root README with value + a feature→example table; move provenance/limits
  to a labelled section near the end.
- Adopt one README skeleton: *What you'll learn → Prerequisites → Quick start →
  Task graph → How it works → Expected output → Testing → Troubleshooting → Next*.
- Remove duplicated boilerplate; label illustrative numbers inline; trim `01`.
- Consistent voice, sentence-case headings, plain-symbol style (emoji now removed).

## Improvement backlog (ranked)

| # | Item | Impact | Effort |
|---|---|---|---|
| I1 | Make `08` do real work or relabel it honestly as a simulation tour | High | M |
| I2 | Make `03`'s integration test real (cross-language smoke test) | High | S |
| I3 | Standardize all READMEs to the shared skeleton | High | M |
| I4 | Rework root README (value-first + feature→example table) | High | S |
| I5 | Differentiate 03↔08 and 02↔18 (or merge) | Medium | M |
| I6 | Label illustrative perf numbers inline | Medium | S |
| I7 | Trim `01` README; grow `05` README | Medium | S |
| I8 | Add feature→example index + cross-links | Medium | S |

## New example proposals (ranked)

| # | Example | Audience | Features shown |
|---|---|---|---|
| N1 | `00-hello-gaffer` — minimal onboarding | New users | run, parallel, cache |
| N2 | `20-affected-ci` — build only what changed | Platform/CI | `--affected`, `--since`, cache |
| N3 | `21-ci-github-actions` — CI with cache | CI maintainers | `export github-actions`, remote cache |
| N4 | `22-remote-cache-s3` — real remote cache (MinIO) | Distributed teams | `--cache-get-remote`/`--cache-set-remote` |
| N5 | `23-alternate-manifests` — Taskfile.yml + justfile | Polyglot/legacy | manifest discovery |
| N6 | `24-docker-build-graph` — image build graph | DevOps | parallel docker builds |

**Recommended shortlist**: N1, N2, N3, N4.

## Recommended next steps

1. Approve backlog I1–I8 and shortlist N1–N4.
2. Software-dev mission A: execute I1–I8 (realism + docs).
3. Software-dev mission B: build N1–N4.
4. Fold communicator recommendations into mission A.

## Method & limitations

Rubric-based case study over all examples and repo docs; runnability facts from
mission `verify-examples-01M36AAT` (gaffer-exec 0.8.0). Scores reflect one
machine/CLI version; "teaching value" is a reasoned judgement, not user testing.
