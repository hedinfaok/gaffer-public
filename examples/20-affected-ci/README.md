# Affected / Since Incremental CI

What this shows: a tiny two-package monorepo (package `b` depends on package `a`) where gaffer-exec runs only the tasks affected by a set of changed files, so CI can skip work that cannot have changed.

## What you'll learn

- `--affected <path>`: run tasks whose inputs match one or more changed file paths (repeatable).
- `--since <git-ref>`: derive the changed file list from git (`git diff <ref>`) and run the affected tasks.
- Dependency closure: a change to package `a` is also a change to package `b`, because `b` depends on `a`.
- `--dry-run` previews the selected task set before a real CI run.

## Prerequisites

- gaffer-exec on your PATH
- GNU make
- git (only needed for `--since`)

## Quick start

```bash
# Build everything
gaffer-exec --workspace-root . run make:build-all

# Preview what a change to package a would rebuild
gaffer-exec --workspace-root . run --dry-run --affected packages/a/src/a.txt make:build-all

# Preview what changed since the previous commit
gaffer-exec --workspace-root . run --dry-run --since HEAD~1 make:build-all
```

Drop `--dry-run` to actually run the selected tasks.

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `build-a` | - | Copies `packages/a/src/a.txt` to `out/a/a.txt` |
| `build-b` | `build-a` | Writes `out/b/b.txt` from `out/a/a.txt` and `packages/b/src/b.txt` |
| `build-all` | `build-a`, `build-b` | Builds both packages |
| `clean` | - | Removes `out/` |

## How it works

```
packages/a/src/a.txt ──► build-a ──► out/a/a.txt
                                        │
packages/b/src/b.txt ───────────────► build-b ──► out/b/b.txt
                                        │
                            build-all ◄─┴─ (build-a, build-b)
```

`build-b` lists `build-a` as a prerequisite, so gaffer-exec infers the same edge plain make would: package `b` cannot build without package `a`. `--affected` and `--since` then select the tasks touched by the changed files and everything downstream of them.

```bash
# Changed file paths (repeatable)
gaffer-exec --workspace-root . run --affected packages/a/src/a.txt make:build-all

# Changed files computed from git
gaffer-exec --workspace-root . run --since HEAD~1 make:build-all
```

`--affected` matches each path against a task's inputs; `--since` computes that path list with `git diff <ref> --name-only` first. Both are run-time flags, so they are not baked into the Makefile and can be combined with `--dry-run` for a safe preview.

Note: a Makefile does not declare per-task input globs, so gaffer-exec treats the workspace as the input set for these Make tasks. In this small fixture the affected set is therefore the whole graph, and the point is the dependency closure: gaffer-exec never runs `build-b` without `build-a`, and a change to package `a` pulls package `b` in. Manifests that declare inputs (a Taskfile `sources:` glob or a turbo `inputs:` list) let the same two flags narrow the run to exactly the changed packages and their dependents.

## Expected output

```text
$ gaffer-exec --workspace-root . run --dry-run --affected packages/a/src/a.txt make:build-all
Affected tasks (4):
  make:build-a
  make:build-all
  make:build-b
  make:clean
Dry run - would execute 3 graphs:
  - make:build-all: ... build-all
    Dependencies: make:build-a, make:build-b
  - make:build-a: ... build-a
  - make:build-b: ... build-b
    Dependencies: make:build-a
```

`build-a` (the changed package) and `build-b` (its dependent) are both in the selected set. Running without `--dry-run` produces the recipes' own output:

```text
built packages/a -> out/a/a.txt
built packages/b -> out/b/b.txt (depends on a)
built all packages: a, b
```

## Testing

```bash
cd examples/20-affected-ci
bash test.sh
```

The suite verifies the fixture and Makefile wiring, dry-runs the graph, changes a package source with git, and asserts that the changed package and its dependents are selected by `--affected`. It degrades gracefully when gaffer-exec or git is unavailable, or when there is no previous commit for `--since`.

## Troubleshooting

- **`gaffer-exec: command not found`**: install gaffer-exec and ensure it is on your PATH.
- **`--since` reports nothing / errors**: `--since HEAD~1` needs at least two commits. In a fresh repository, make an initial commit and then a change, or use `--affected <path>` instead.
- **Not a git repository**: `--affected` still works with explicit paths; only `--since` requires git.
- **A build looks like it did nothing**: run `make clean` or `gaffer-exec --workspace-root . run make:clean` and rebuild to see the outputs in `out/`.

## Next example

[01-monorepo-build](../01-monorepo-build/README.md) scales this up to a full TypeScript monorepo with dependency-aware parallelism, content-based caching, and incremental rebuilds.
