# Research Decision Log: Example quality audit

**Mission**: `example-quality-audit-01M36QA0`
**Date**: 2026-09-23
**CLI**: gaffer-exec 0.8.0

## Summary

Ten examples exist. They are **runnable** (after the migration/fixes in
`verify-examples-01M36AAT`) and several are genuinely good, but the collection
has three systemic weaknesses: **simulation presented as capability** (worst in
08), **overlapping examples** (03 vs 08, 02 vs 18), and **inconsistent, sometimes
overclaiming docs**. The biggest *opportunity* is not fixing what exists but
filling the gaps: gaffer-exec's headline features (`--affected`/`--since`,
`export` for CI, remote cache, alternate manifests) are barely or not
demonstrated.

## Scorecard (1–5)

| Example | Accuracy | Runnable | Teaching | Docs | Notes |
|---|:--:|:--:|:--:|:--:|---|
| 01-monorepo-build | 4 | 5 | 4 | 3 | Real TS monorepo; perf numbers are illustrative; README has a duplicated tail |
| 02-distributed-build | 4 | 3 | 4 | 4 | Real Go services + mocked clouds (disclosed); needs Docker + `az`/`gsutil` |
| 03-multi-language-build | 3 | 5 | 3 | 3 | Real builds, but `integration-test` is fake (`echo … sleep`); overlaps 08 |
| 04-incremental-testing | 4 | 4 | 4 | 4 | Real Jest suite; simulated flaky demo (disclosed); flaky timing |
| 05-ml-workflows | 4 | 5 | 3 | 2 | Real sklearn datasets; tiny scale; README only ~106 lines |
| 06-local-dev-environment | 4 | 5 | 4 | 4 | Real DB/API/frontend; strong after Vite migration |
| 07-watch-workflows | 4 | 5 | 4 | 4 | Real build/watch; good after fixes |
| 08-multi-language-task-running | 2 | 4 | 2 | 3 | Simulated build/test (`echo`, canned PASS); overlaps 03; weakest example |
| 18-network-aware-builds | 4 | 4 | 4 | 4 | Real Go services; delta transfer simulated but clearly disclosed |
| 19-cross-platform-builds | 4 | 5 | 4 | 4 | Real C/Go/Rust/Node + cross-compile; solid |

**Average**: Accuracy 3.5 · Runnability 4.5 · Teaching 3.6 · Docs 3.5.

## Findings (evidence-cited)

### F1 — Simulation is presented as capability (high impact)
- `08` Makefile `build-node` = `echo 'Simulating webpack build…'`; `test-node` = canned `echo 'PASS src/App.test.js'` (`examples/08-…/Makefile:41,57`). The README's premise ("unifies task orchestration") oversells what is largely simulated.
- `03` `integration-test` = `echo … sleep 1 … echo '✓ Integration tests passed'` (`examples/03-…/Makefile:41`).
- Disclosed simulations are fine (`02` mocks, `18` delta, `04` flaky) — the problem is simulation *without* disclosure or real substance.

### F2 — Redundant examples (medium impact)
- `03` (multi-language build) and `08` (multi-language task running) cover nearly the same ground; `08` adds little beyond `03` except more simulated steps.
- `02` (distributed/remote cache) and `18` (network-aware multi-region cache) overlap; `18` is the stronger, more honest one.

### F3 — Unmeasured performance claims (medium impact)
- Specific ms figures in `01` (e.g. `~250ms`, `6.2x`) and `18` (bandwidth tables) are illustrative; the root README admits claims "may be based on projections". Good enough if labelled inline, risky if not.

### F4 — Docs structure is inconsistent (medium impact)
- No shared README skeleton: openings range from "Why gaffer-exec?" (01) to "The Problem" (07) to "Real-World Use Cases" (18).
- Repeated boilerplate: "Real Open Source Project Pattern" appears across 01/02/03/04/05 (some near-duplicated).
- `01` README (~488 lines) has a duplicated tail (two "Next Steps"/value sections).
- Root README leads with a long LLM-disclaimer block *before* the examples list.

### F5 — Feature coverage gaps (high opportunity)
gaffer-exec's marquee capabilities are under-demonstrated:
- **`--affected` / `--since`** (build only what changed) — barely used; no dedicated example.
- **`export --format github-actions` / CI caching** — no CI example.
- **Remote cache get/set** (`--cache-get-remote`/`--cache-set-remote`) — only simulated.
- **Alternate manifests** (Taskfile.yml, justfile) — supported but never shown.
- **Onboarding** — no minimal "hello world"; 01 is a large first step.

### F6 — Missing assets (medium opportunity)
- No feature→example index (which example teaches caching? affected? watch?).
- Examples don't link to CLI docs or to each other ("if you liked X, see Y").

## Communicator review (`comms-cleo`) — docs recommendations

1. **Lead with value, not caveats.** Root README: open with "What these examples show" + the feature→example table; move the LLM provenance/limitations to a clearly headed section near the bottom (keep it, don't hide it).
2. **Adopt one README skeleton** for every example: *Title → What you'll learn (gaffer features) → Prerequisites → Quick start → Task graph (targets table) → How it works → Expected output → Testing → Troubleshooting → Next example*.
3. **Delete duplicated boilerplate** ("Real Open Source Project Pattern" blocks); replace with a one-line "pattern" note where relevant.
4. **Label illustrative numbers inline** ("illustrative, not a benchmark") and link to any real measurement.
5. **Trim `01`'s duplicated tail** and de-duplicate its two "Next Steps" sections.
6. **Voice/tone**: consistent second person, sentence-case headings, no ALL-CAPS emphasis, keep the now-emoji-free plain-symbol style.
7. **Add a one-line "What this shows" tagline** under each title for scannability.

## Improvement backlog (ranked)

| # | Item | Impact | Effort |
|---|---|---|---|
| I1 | Rewrite `08` to do real work OR relabel it honestly as a simulation tour | High | M |
| I2 | Make `03`'s integration test real (build+run cross-language smoke test) | High | S |
| I3 | Standardize all READMEs to the shared skeleton | High | M |
| I4 | Rework root README (value-first + feature→example table) | High | S |
| I5 | Differentiate 03 vs 08 and 02 vs 18 (or merge) | Medium | M |
| I6 | Label illustrative perf numbers inline | Medium | S |
| I7 | Trim/de-duplicate `01` README; grow `05` README | Medium | S |
| I8 | Add a "which example teaches what" index + cross-links | Medium | S |

## New example proposals (ranked for value)

| # | Proposed example | Audience | gaffer features shown | Value |
|---|---|---|---|---|
| N1 | `00-hello-gaffer` — minimal onboarding | New users | run, parallel, cache | Removes the steep first step |
| N2 | `20-affected-ci` — build only what changed vs `main` | Platform/CI | `--affected`, `--since`, cache | Flagship "incremental CI" story, currently unshown |
| N3 | `21-ci-github-actions` — CI with cache restore/save | CI maintainers | `export --format github-actions`, remote cache | High relevance |
| N4 | `22-remote-cache-s3` — real remote cache (MinIO) | Distributed teams | `--cache-get-remote`/`--cache-set-remote` | Turns simulated caching real |
| N5 | `23-alternate-manifests` — Taskfile.yml + justfile | Polyglot/legacy repos | manifest discovery beyond Make | Broadens adoption story |
| N6 | `24-docker-build-graph` — build/publish images as a graph | DevOps | parallel graph over docker builds | Common workflow |

**Recommended shortlist**: N1, N2, N3, N4 (onboarding + incremental CI + CI cache + real remote cache). These cover the highest-value, currently-missing features for the most likely audiences.

## Next actions

1. Approve the backlog (I1–I8) and the N1–N4 shortlist.
2. Run a software-dev mission to execute I1–I8 (docs + realism fixes).
3. Run a separate software-dev mission to build N1–N4 as new examples.
4. Fold the communicator recommendations into the docs work.
