# Implementation Plan: Add new gaffer-exec examples

**Branch**: `new-examples` | **Spec**: [spec.md](./spec.md)

## Summary

Add six new examples that cover the audit's highest-value gaps: onboarding
(`00-hello-gaffer`), incremental CI (`20-affected-ci`), GitHub Actions caching
(`21-ci-github-actions`), real remote cache (`22-remote-cache-s3`), alternate
manifests (`23-alternate-manifests`), and Docker build graphs
(`24-docker-build-graph`). Each is a self-contained directory with a `Makefile`
task graph, a shared-skeleton `README.md`, and a `test.sh`. The root README and
`docs/example-index.md` are updated to include them.

## Technical Context

**Language/Version**: Bash/Make; per-example languages (Node, Go, Python, Rust, Docker).
**Testing**: each example's `test.sh`; `gaffer-exec --workspace-root . run --dry-run make:<primary>`.
**Constraints**: gaffer-exec 0.8.0 (C-001); plain-symbol style (NFR-003).

## Charter Check
Charter not synthesized; fallback `software-dev-default`. PASS.

## Project Structure

```
examples/00-hello-gaffer/            # WP01
examples/20-affected-ci/             # WP02
examples/21-ci-github-actions/       # WP03
examples/22-remote-cache-s3/         # WP04
examples/23-alternate-manifests/     # WP05
examples/24-docker-build-graph/      # WP06
README.md, docs/example-index.md     # WP07
```

## Implementation Concern Map

### IC-01 — Onboarding (FR-001)
- Minimal Makefile (two independent tasks + an aggregate), README, test.sh.

### IC-02 — Incremental CI (FR-002)
- Monorepo fixture; demonstrate `--since`/`--affected` selecting only changed targets.

### IC-03 — CI caching (FR-003)
- `.github/workflows` using `gaffer-exec export --format github-actions` + cache restore/save; README.

### IC-04 — Real remote cache (FR-004)
- MinIO (docker) + `--cache-get-remote`/`--cache-set-remote`; degrade to dry-run when unavailable.

### IC-05 — Alternate manifests (FR-005)
- `Taskfile.yml` and `justfile` consumed by gaffer-exec; README.

### IC-06 — Docker build graph (FR-006)
- Two images built in parallel with a dependency edge; degrade when Docker absent.

### IC-07 — Docs integration (FR-007)
- Update root README + index; cross-links.
