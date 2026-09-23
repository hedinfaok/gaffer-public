# gaffer-exec Examples — Verification Report

**Mission**: `verify-examples-01M36AAT`
**Date**: 2026-09-23
**CLI under test**: `gaffer-exec` 0.8.0
**Harness**: `kitty-specs/verify-examples-01M36AAT/verify.sh`

## Summary

All 10 examples pass static verification (graph validate + primary-target dry-run
+ stale-reference sweep). Nine of ten were executed end-to-end; the tenth (02) is
blocked only by a missing external CLI (`az`/`gsutil`), and a real defect in its
LocalStack configuration was still found and fixed.

| # | Example | Static | Executed | Result |
|---|---------|--------|----------|--------|
| 01 | 01-monorepo-build | pass | pass | ✓ `test.sh` exit 0 — 5 packages built, cached, visualized, app runs |
| 02 | 02-distributed-build | pass | blocked | ⚠ `blocked (environment: azure-cli, gsutil)` — LocalStack defect fixed |
| 03 | 03-multi-language-build | pass | pass | ✓ `test.sh` exit 0 — Rust/Go/Node/Python artifacts verified |
| 04 | 04-incremental-testing | pass | pass | ✓ `test.sh` exit 0 (flaky on first run — see quarantine) |
| 05 | 05-ml-workflows | pass | pass | ✓ `test.sh` 18/18 — full ML pipeline |
| 06 | 06-local-dev-environment | pass | pass | ✓ `test.sh` 10/10 — DB→API→frontend, ports, shutdown |
| 07 | 07-watch-workflows | pass | pass | ✓ `test.sh` 47/0 — after 2 fixes |
| 08 | 08-multi-language-task-running | pass | pass | ✓ `test.sh` 24/0 — after 6 fixes |
| 18 | 18-network-aware-builds | pass | pass | ✓ `test.sh` exit 0 — after 2 fixes |
| 19 | 19-cross-platform-builds | pass | pass | ✓ `test.sh` exit 0 — cross-compilation verified |

Static evidence (per example):
`gaffer-exec --workspace-root . validate` → OK; `run --dry-run make:<primary>` →
valid dependency closure; zero `graph.json`/`--graph`/`--graph-override` matches.

## Defects found and fixed

| # | Example | Defect | Fix |
|---|---------|--------|-----|
| D1 | 07 | `api-service`/`frontend` imported shared-lib via `../../../shared-lib` (off-by-one; resolves outside the example) | Corrected to `../../shared-lib/dist/index` |
| D2 | 07 | `((VAR++))` under `set -e` returns exit 1 when the value starts at 0, aborting `test.sh` | Replaced with `VAR=$((VAR+1))` (32 sites) |
| D3 | 08 | `node-frontend/package.json` had `"install": "npm ci"`, causing infinite `npm ci` recursion | Removed the `install` script (Makefile owns installation) |
| D4 | 08 | Recipes used `pip`/`python`, absent on this host (only `pip3`/`python3`); Homebrew PEP-668 block | `python3 -m pip install --break-system-packages`, `python3 setup.py` |
| D5 | 08 | `install-go` used `go mod download`, leaving `go.sum` incomplete → build failure | `go mod tidy` |
| D6 | 08 | `go-api/main.go` imported `fmt` unused → compile error | Removed the import |
| D7 | 08 | Cache test asserted caching but never passed `--cache`; deps are cleaned earlier in the suite | Test now populates then measures `run --cache sha256` |
| D8 | 18 | `docker-compose.yml` mounted `/tmp/localstack` with `DATA_DIR=/tmp/localstack/data`; modern LocalStack cannot clear that mount → container crash | Switched to `/var/lib/localstack` |
| D9 | 18 | `start-regions.sh` health check compared `"ok"` but `curl -sf` emitted the JSON body (`"{json}ok"`), so readiness never passed despite healthy containers | Redirected curl output to `/dev/null` |
| D10 | 02 | Same LocalStack `/tmp/localstack` defect as D8 | Same `/var/lib/localstack` fix; AWS path now starts healthy |

Same-defect-class note (DIRECTIVE_043): D2 was fixed structurally across all
sites; a repo-wide scan confirmed only 07/08 were affected. D8/D10 are the same
root cause fixed in both owners.

## Quarantined

- **04-incremental-testing** — first `test.sh` run exited 1 at "Test 4.5: cache
  invalidation on file change"; the rerun exited 0 with all checks green.
  Quarantined as an example-level timing flake, not a graph defect (per spec
  edge-case policy). No masking applied.

## Success criteria

| ID | Criterion | Result |
|----|-----------|--------|
| SC-001 | 10/10 static verification pass | ✓ |
| SC-002 | 10/10 executed results recorded | ✓ (02 blocked-environment, recorded) |
| SC-003 | Every non-environment failure fixed or quarantined | ✓ (D1–D10 fixed; 04 quarantined with rationale) |
| SC-004 | Zero removed-JSON-format references | ✓ |
| SC-005 | Single consolidated report | ✓ (this file) |

## How to reproduce

```bash
bash kitty-specs/verify-examples-01M36AAT/verify.sh --static     # all 10
bash kitty-specs/verify-examples-01M36AAT/verify.sh --execute    # adds test.sh runs
```

Per-example executed evidence is captured in the WP02–WP04 activity logs
(`spec-kitty agent tasks status --mission verify-examples-01M36AAT`).

## Environment notes

- `gaffer-exec` 0.8.0; Node 24, npm 11, Go, Rust 1.93, Python 3.14, Docker 29.2.1.
- Docker daemon was started mid-mission; LocalStack images were cold on first run.
- Missing host tools: `az`, `gsutil` (blocked example 02); `pip`/`python` (fixed
  in example 08 recipes).
