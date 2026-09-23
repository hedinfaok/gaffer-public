# Bug Report: gaffer-exec CLI (0.8.0)

**Reporter**: example verification work in `hedinfaok/gaffer-public`
**Date**: 2026-09-23
**Version under test**: `gaffer-exec 0.8.0`
**Environment**: macOS (darwin), Docker 29.2.1, Node 24, Go, Rust 1.93, Python 3.14
**Scope**: CLI behavior observed while building and verifying examples 00–25. One report, all findings.

## Summary

| ID | Title | Component | Severity |
|----|-------|-----------|----------|
| GAF-001 | `--port-patterns` matches the working-dir path, not the graph name/id — silently matches nothing | run / port assignment | High |
| GAF-002 | Default port registry template collides for sibling processes in one directory | run / port assignment | High |
| GAF-003 | `--cache-get-remote` / `--cache-set-remote` silently do not execute for composite (`make:`) graphs | run / cache | High |
| GAF-004 | `GAFFER_CACHE_ARTIFACT` is not materialized for Makefile tasks | run / cache | High |
| GAF-005 | Turborepo discovery requires a `workspaces` glob; explicit-only workspaces yield no `turbo:` graphs | discovery / turborepo | Medium |
| GAF-006 | `--manifest-file <Makefile>` runs `make -C <workspace-root>` instead of the manifest's directory | run / manifest | Medium |
| GAF-007 | Workspace discovery scans virtualenvs/site-packages → duplicate sub-graph IDs and validation failures | discovery | Medium |
| GAF-008 | Discovery cache is not invalidated by Taskfile/justfile edits | discovery | Medium |
| GAF-009 | `export --format github-actions` emits a cache key over a file it never writes | export | Low |
| GAF-010 | Manifest naming is inconsistent (filter `justfile` vs prefix `just:`; filter `turborepo` vs prefix `turbo:`) | discovery / UX | Low |
| GAF-011 | `list -t make` is rejected although `make` is the natural type name | list / UX | Low |

---

## GAF-001 — `--port-patterns` matches the working-dir path, not the graph name/id

**Severity**: High · **Component**: `run` (port assignment)

**Steps to reproduce**
```bash
mkdir -p /tmp/pt && cd /tmp/pt
printf 'web: sh -c "echo WEB_PORT=$PORT"\napi: sh -c "echo API_PORT=$PORT"\n' > Procfile
gaffer-exec --workspace-root . run --auto-port 3000 --port-patterns 'procfile:*' procfile:start
```

**Expected**: `WEB_PORT` / `API_PORT` are set (the pattern names the Procfile graphs).

**Actual**: the processes run with an empty port (`WEB_PORT=`), i.e. the pattern matched nothing, with no warning. Using `--port-patterns '*'` (or omitting the pattern) is required.

**Impact**: the documented, intuitive pattern (`<prefix>:*`) is a silent no-op; users get processes with no port and no diagnostic.

**Evidence**: reproduced in `examples/25-all-manifests-devstack`; `'procfile:*'` → empty, `'*'` → ports assigned.

**Workaround**: use `--port-patterns '*'`.

---

## GAF-002 — Default port registry template collides for sibling processes in one directory

**Severity**: High · **Component**: `run` (port registry)

**Steps to reproduce**
```bash
cd /tmp/pt
gaffer-exec --workspace-root . run --auto-port 3000 --port-patterns '*' procfile:start
```

**Expected**: each Procfile process gets a distinct port.

**Actual**:
```
Error: Port registry collision: two graphs produced the same env-var key 'SVC__TMP_PORTTEST_PORT'
```

**Impact**: the default (`SVC_{working_dir}_PORT`) keys on the working directory, so any two processes sharing a directory (the common case for a Procfile) cannot both receive ports. The example only works with an explicit `--port-registry-template '{name}_PORT'`.

**Workaround**: `--port-registry-template '{name}_PORT'` (and processes must then read the per-process var, not `PORT`).

---

## GAF-003 — `--cache-get-remote` / `--cache-set-remote` silently do not execute for composite graphs

**Severity**: High · **Component**: `run` (remote cache)

**Steps to reproduce**
```bash
# With a Makefile providing cache-restore / cache-save targets:
gaffer-exec --workspace-root . run --cache sha256 \
  --cache-get-remote make:cache-restore \
  --cache-set-remote make:cache-save \
  make:build
```

**Expected**: the named restore/save graphs run before/after each cached task.

**Actual**: the flags parse and validate the graph names, but the hook graphs **never execute** (nothing appears in history/logs) when they are `make:` composite graphs. The same hooks work when provided as `script:` graphs (`script:scripts:restore` / `script:scripts:save`).

**Impact**: remote-cache restore/save silently no-ops for the most common manifest type (Makefile). A user following the documented flags believes remote caching is active when it is not.

**Evidence**: observed independently in examples 21 and 22; 22 ships the hooks as `script:` graphs as a workaround.

**Workaround**: express the hooks as shell scripts (`script:...`), not Make targets.

---

## GAF-004 — `GAFFER_CACHE_ARTIFACT` is not materialized for Makefile tasks

**Severity**: High · **Component**: `run` (cache contract)

**Steps to reproduce**
- Run a cached `make:` target with `--cache sha256` and have the task echo `$GAFFER_CACHE_ARTIFACT`.

**Expected**: per `run --help`, `GAFFER_CACHE_ARTIFACT` is the absolute path to `.gaffer/cache/<key>.tar.gz` on a hit, empty on a miss.

**Actual**: for Makefile tasks the variable is not set/materialized, so a save/restore script cannot use it to archive or restore outputs for `make:` targets.

**Impact**: the documented remote-cache contract cannot be implemented for Makefile graphs.

**Workaround**: the example archives `dist/` itself instead of using `GAFFER_CACHE_ARTIFACT`.

---

## GAF-005 — Turborepo discovery requires a `workspaces` glob

**Severity**: Medium · **Component**: discovery (turborepo)

**Steps to reproduce**
```bash
# root package.json with explicit workspaces only:
{"name":"app","private":true,"workspaces":["web"],"scripts":{"build":"echo b"}}
# plus turbo.json
gaffer-exec --workspace-root . list -t turborepo
```

**Expected**: `turbo:` graphs for the workspace.

**Actual**: `No graphs found for type(s): ["turborepo"]`. Discovery only expands workspace patterns ending in `/*` (e.g. `["web","./*"]`).

**Impact**: a valid, common Turborepo layout silently produces no graphs.

**Workaround**: include a `./*` glob in `workspaces`.

---

## GAF-006 — `--manifest-file <Makefile>` uses the workspace root as make's working directory

**Severity**: Medium · **Component**: `run` / `--manifest-file`

**Steps to reproduce**
```bash
cd examples/01-monorepo-build
gaffer-exec --manifest-file Makefile --dry-run run make:build-all
```

**Expected**: `make -C <dir of Makefile> ...` so relative paths in recipes resolve.

**Actual**: `make -C <workspace-root> -f <abs path to Makefile>` — the `-C` is the git/workspace root, not the manifest's directory, so recipes with relative paths run in the wrong directory when the manifest is nested.

**Impact**: `--manifest-file` is misleading/broken for nested manifests.

**Workaround**: use `--workspace-root .` and rely on discovery (`make:<target>`).

---

## GAF-007 — Workspace discovery scans virtualenvs and reports duplicate sub-graph IDs

**Severity**: Medium · **Component**: discovery

**Steps to reproduce**
- In a workspace containing a Python `venv/` with bundled `package.json` files, run `gaffer-exec --workspace-root . validate`.

**Expected**: common vendor dirs (`venv/`, `.venv/`, `site-packages/`) are skipped, or duplicates are deduplicated.

**Actual**: discovery walks the venv and reports many errors, e.g.
`duplicate sub-graph ID 'npm:@jupyterlab/application-top:build'`, causing `validate` to fail with ~20 errors unrelated to the project's own graphs.

**Impact**: `validate` is unusable in any repo with a checked-out virtualenv; false failures.

**Workaround**: delete the venv (regenerable) before validating.

---

## GAF-008 — Discovery cache is not invalidated by Taskfile/justfile edits

**Severity**: Medium · **Component**: discovery

**Steps to reproduce**
```bash
mkdir -p /tmp/tfcache && cd /tmp/tfcache
printf 'version: "3"\ntasks:\n  build:\n    cmds:\n      - echo build\n' > Taskfile.yml
gaffer-exec --workspace-root . list -t taskfile            # shows taskfile:build
printf 'version: "3"\ntasks:\n  build:\n    cmds:\n      - echo build\n  test:\n    cmds:\n      - echo test\n' > Taskfile.yml
touch Taskfile.yml                                          # update mtime too
gaffer-exec --workspace-root . list -t taskfile            # STILL only taskfile:build
rm -f .gaffer/discovery-cache.json
gaffer-exec --workspace-root . list -t taskfile            # now shows taskfile:test
```

**Expected**: the newly added `test` task is discovered after the edit.

**Actual**: discovery is served from `.gaffer/discovery-cache.json` and the new task does not appear until the cache file is deleted — even after `touch` updates the manifest mtime. (Makefile edits *are* picked up, so invalidation is type-specific.)

**Impact**: confusing stale graphs while iterating on Taskfile/justfile manifests; users must know to delete the cache.

**Workaround**: `rm -f .gaffer/discovery-cache.json` (documented in example 23's troubleshooting).

---

## GAF-009 — `export --format github-actions` emits a cache key over a file it never writes

**Severity**: Low · **Component**: `export`

**Steps to reproduce**
```bash
gaffer-exec --workspace-root . export make:build --format github-actions
# inspect the generated workflow
```

**Expected**: a usable cache key (e.g. hash of lockfiles/inputs).

**Actual**: the generated workflow keys the cache on `hashFiles('.gaffer/graphs/make-build.json')` — a path the tool never writes, so the key is degenerate (constant), defeating cache invalidation.

**Impact**: exported CI cache is effectively always the same key.

**Workaround**: hand-edit the exported workflow to key on real inputs (as example 21 does).

---

## GAF-010 — Manifest naming is inconsistent between filters and graph prefixes

**Severity**: Low · **Component**: discovery / UX

**Details**
- Filter is `justfile`; graph prefix is `just:` (`just:build`), not `justfile:build`.
- Filter is `turborepo`; graph prefix is `turbo:` (`turbo:build`).

**Impact**: users guessing `justfile:build` get `Unknown graph`; the mapping is not discoverable from the error.

**Workaround**: `list -t justfile` shows the actual ids.

---

## GAF-011 — `list -t make` is rejected

**Severity**: Low · **Component**: `list` / UX

**Actual**: `Error: 'make' is not a valid manifest type. Valid types: bazel, cargo, justfile, makefile, npm, procfile, python, script, taskfile, turborepo`.

**Impact**: minor friction; the natural short name `make` is not accepted (must be `makefile`). The error is at least explicit.

**Workaround**: use `-t makefile`.

---

## Notes

- Findings were surfaced while building/verifying examples in `hedinfaok/gaffer-public` (missions `verify-examples`, `remediate-dependabot-npm`, `example-quality-audit`, `improve-examples`, `new-examples`, `all-manifests-devstack`).
- GAF-003/GAF-004 mean the shipped examples 21 and 22 implement remote caching via `script:` hooks and documented workarounds rather than the `make:` flag path; their READMEs state this explicitly.
- No CLI source access; all findings are black-box observations on 0.8.0.
