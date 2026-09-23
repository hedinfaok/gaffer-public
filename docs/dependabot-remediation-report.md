# Dependabot npm Remediation Report

**Mission**: `remediate-dependabot-npm-01M36FMA`
**Date**: 2026-09-23
**Scope**: the five example `package-lock.json` files carrying all 235 open npm Dependabot alerts.

## Result

All non-breaking, `npm audit fix`-resolvable vulnerabilities were removed.
Remediation used only non-breaking upgrades (no `--force`). Remaining advisories
require breaking major upgrades of `react-scripts` (Create React App), which is
itself deprecated and pins the affected build tooling.

| Manifest | npm audit before | npm audit after | Dependabot (before) | Residual cause |
|----------|-----------------:|----------------:|--------------------:|----------------|
| `examples/06-local-dev-environment/frontend` | 56 | 30 | 121 | `react-scripts@5` transitive build tooling |
| `examples/06-local-dev-environment/api` | 12 | 1 | 18 | 1 moderate (breaking-only) |
| `examples/06-local-dev-environment` (root) | 7 | 0 | 10 | — |
| `examples/08-multi-language-task-running/node-frontend` | 26 | 4 | 70 | `react-scripts`-adjacent dev tooling |
| `examples/04-incremental-testing` | 11 | 1 | 16 | 1 moderate (breaking-only) |
| **Total** | **112** | **36** | **235** | |

`npm audit` counts unique advisories; Dependabot counts advisories per package
path, so the totals differ.

**Measured Dependabot outcome after the rescan (post-merge):**

| | Before | After |
|---|---:|---:|
| Open alerts | 235 | **38** |
| Critical | 4 | **0** |
| High | 121 | 7 |
| Moderate | 97 | 30 |
| Low | 13 | 1 |

Per manifest (after): `06/frontend` 24, `08/node-frontend` 8, `06/api` 3,
`04` 3, `06` root 0. The remaining alerts are cases that only clear via a
breaking `react-scripts`/CRA change.

## Commands used

```bash
# per manifest directory
npm audit fix          # non-breaking only; exit 1 when residuals remain
npm audit --json       # before/after verification
```

A second `npm audit fix` pass produced no further reduction, confirming the
residuals are breaking-only.

## Residual advisories (documented, breaking-only)

The residual set is dominated by `react-scripts@5.0.1` (Create React App):
`@svgr/webpack`, `css-minimizer-webpack-plugin`, `postcss`, `svgo`,
`serialize-javascript`, `sockjs`, `resolve-url-loader`, `rollup-plugin-terser`,
and `react-scripts` itself. `npm audit` marks their fix as
`react-scripts@0.0.0 isSemVerMajor: true` — i.e. only resolvable by a major
change (or migrating the example off CRA). That is a breaking redesign and is
**out of scope** per constraint C-002 (breaking upgrades require a verified
example redesign), so it is recorded as accepted residual risk.

Remaining single moderate advisories in `06/api` and `04` are likewise
breaking-only.

## Regression verification (no functional regression)

| Example | Check | Result |
|---------|-------|--------|
| 06-local-dev-environment | `bash test.sh` (DB→API→frontend, integration, shutdown) | ✓ 10/10 |
| 04-incremental-testing | `bash test.sh` | ✓ exit 0 |
| 08-multi-language-task-running | `gaffer-exec --workspace-root . run make:build-node` (the example's build path) | ✓ `dist/bundle.js` produced |

Note: example 08's *unused* real `npm run build` (webpack) has a pre-existing
entry/config issue (`src/index.wasm`) unrelated to this remediation; the example's
Makefile uses a simulated webpack build, which works.

## Repo hygiene observations

- `examples/04-incremental-testing/node_modules` is **tracked in git** (pre-existing).
  `npm audit fix` churned hundreds of tracked files; these were reverted so only
  `package-lock.json` changed. Recommendation (out of scope here): `git rm -r --cached`
  the tracked `node_modules` and rely on the lockfile.

## Success criteria

| ID | Criterion | Result |
|----|-----------|--------|
| SC-001 | Non-breaking `npm audit fix` applied to all five manifests | ✓ |
| SC-002 | All non-breaking-fixable advisories resolved | ✓ (112 → 36; second pass no-op) |
| SC-003 | No regression in remediated examples | ✓ (06, 04, 08 verified) |
| SC-004 | Before/after report + residuals | ✓ (this file) |
