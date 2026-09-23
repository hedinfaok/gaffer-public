# Research: Remediate Dependabot npm vulnerabilities

**Mission**: remediate-dependabot-npm-01M36FMA

## Findings

- 235 open Dependabot alerts, all npm, confined to 5 example lockfiles:
  - `examples/06-local-dev-environment/frontend/package-lock.json` (121)
  - `examples/08-multi-language-task-running/node-frontend/package-lock.json` (70)
  - `examples/06-local-dev-environment/api/package-lock.json` (18)
  - `examples/04-incremental-testing/package-lock.json` (16)
  - `examples/06-local-dev-environment/package-lock.json` (10)
- `npm audit` (deduplicated) totals: 56 / 26 / 12 / 11 / 7.
- `npm audit fix` (non-breaking) is available in all; `--force` needed for a
  subset (e.g. react-scripts/webpack-dev-server majors).

## Decisions

- D-001: Prefer `npm audit fix` (non-breaking); never `--force` without a verified example build/test.
- D-002: Remediate the whole alert class across all five manifests (DIRECTIVE_043), not a sample.
- D-003: Commit only `package.json`/`package-lock.json`; never `node_modules`.
- D-004: Residual breaking-only advisories are documented, not silently ignored.

## Risks

- Major upgrades may break example builds; revert + document if so.
- `npm audit fix` may widen semver ranges in `package.json`.
