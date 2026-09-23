# Alternate Manifests

What this shows: gaffer-exec consumes non-Make manifests directly. A `Taskfile.yml` (go-task) and a `justfile` (just) in the same workspace become ordinary gaffer-exec task graphs, with their `deps` edges and recipe dependencies preserved.

## What you'll learn

- How gaffer-exec discovers `Taskfile.yml` and `justfile` alongside a `Makefile`.
- Filtering discovered graphs by manifest type with `-t taskfile` and `-t justfile`.
- How manifest namespaces become graph id prefixes: `taskfile:<task>` and `just:<recipe>`.
- That `deps`/recipe dependencies are translated into gaffer-exec edges, so the same scheduler, parallelism, and caching apply.
- That gaffer-exec runs the task commands itself; the `task` and `just` binaries are not required.

## Prerequisites

- gaffer-exec 0.8.0 on your PATH.
- No extra toolchain: the commands only use `mkdir`, `cp`, `tr`, and `grep`.
- Optional: `task` (go-task) or `just` if you want to run the manifests outside gaffer-exec.

## Quick start

```bash
# Discover the go-task graphs
gaffer-exec --workspace-root . list -t taskfile

# Discover the just graphs
gaffer-exec --workspace-root . list -t justfile

# Run the primary target from each manifest
gaffer-exec --workspace-root . run taskfile:build
gaffer-exec --workspace-root . run just:build
```

## Task graph

`Taskfile.yml` contributes the `taskfile:` namespace:

| Task | Depends on | What it does |
|------|------------|--------------|
| `setup` | - | Creates `build/taskfile/` and stages `src/message.txt` |
| `build` | `setup` | Uppercases the staged fixture into `build/taskfile/greeting.txt` |
| `test` | `build` | Asserts the greeting contains the expected text |

`justfile` contributes the `just:` namespace:

| Recipe | Depends on | What it does |
|--------|------------|--------------|
| `setup` | - | Creates `build/just/` and stages `src/message.txt` |
| `build` | `setup` | Uppercases the staged fixture into `build/just/greeting.txt` |
| `test` | `build` | Asserts the greeting contains the expected text |
| `clean` | - | Removes `build/` |

Both graphs carry their dependencies into gaffer-exec, so `run taskfile:build` schedules `taskfile:setup` first.

## How it works

gaffer-exec scans the workspace root for supported manifests. A `Taskfile.yml` becomes graphs prefixed `taskfile:` and a `justfile` becomes graphs prefixed `just:`. Each top-level task or recipe is one graph; a task's `deps` list and a recipe's `name: dep` header become graph dependencies.

```text
src/message.txt
      |
      v
taskfile:setup ---> taskfile:build ---> taskfile:test
just:setup     ---> just:build     ---> just:test
```

Use `-t <type>` to limit discovery to one manifest kind. The valid type names are gaffer-exec's, so the just filter is `-t justfile` even though the resulting graph ids use the shorter `just:` prefix:

```bash
gaffer-exec --workspace-root . list -t justfile   # filter name
gaffer-exec --workspace-root . show just:build    # graph id
```

Running `gaffer-exec --workspace-root . show just:build` prints a DOT graph with `just:setup -> just:build`.

## Expected output

```bash
$ gaffer-exec --workspace-root . list -t taskfile
Discovering packages in workspace...

Available graphs:

taskfile:build (atomic):

taskfile:setup (atomic):

taskfile:test (atomic):

$ gaffer-exec --workspace-root . list -t justfile
Discovering packages in workspace...

Available graphs:

just:build (atomic):

just:clean (atomic):

just:setup (atomic):

just:test (atomic):
```

`run taskfile:build` executes the dependency first, then the target (illustrative):

```text
-> taskfile:setup
[taskfile:setup] Completed
-> taskfile:build
[taskfile:build] built build/taskfile/greeting.txt
[taskfile:build] Completed
✓ taskfile:setup
✓ taskfile:build
```

## Testing

```bash
cd examples/23-alternate-manifests
bash test.sh
```

`test.sh` asserts that `list -t taskfile` discovers `taskfile:setup`, `taskfile:build`, and `taskfile:test`, that `list -t justfile` discovers `just:setup`, `just:build`, `just:test`, and `just:clean`, and that both primary targets dry-run cleanly. It exits non-zero on any failure.

To run a single target directly:

```bash
gaffer-exec --workspace-root . run taskfile:test
gaffer-exec --workspace-root . run just:test
```

## Troubleshooting

- **A newly added task or recipe is not listed**: gaffer-exec caches workspace discovery under `.gaffer/`. Delete `.gaffer/discovery-cache.json` and re-run the command.
- **`Unknown graph: justfile:build`**: recipe graphs are prefixed `just:`, not `justfile:`. Use the filter `-t justfile` only for `list`.
- **`task` or `just` is not installed**: that is fine. gaffer-exec parses the manifests and runs the commands itself; the standalone binaries are only needed to run the files outside gaffer-exec.
- **No graphs found**: confirm you are in this directory and pass `--workspace-root .`.

## Next example

[24-docker-build-graph](../24-docker-build-graph/README.md) builds several container images as a dependency graph with gaffer-exec.
