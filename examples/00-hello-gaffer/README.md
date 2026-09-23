# Hello gaffer-exec

What this shows: the smallest useful gaffer-exec example, a task graph with two independent tasks that run in parallel, an aggregate target that waits for both, and a target whose output is restored from cache.

## What you'll learn

- How gaffer-exec reads an ordinary Makefile and turns targets into a task graph.
- How independent targets (`hello-a` and `hello-b`) run in parallel.
- How an aggregate target (`hello`) depends on both and runs only once they finish.
- How `--cache sha256` stores a target's output and restores it on a later run.

## Prerequisites

- gaffer-exec 0.8.0 or later on your PATH
- GNU Make, only to inspect the graph with `make -n` (gaffer-exec does not shell out to make for orchestration)

## Quick start

```bash
# Run the core graph: two independent tasks in parallel, then the aggregate
gaffer-exec --workspace-root . run make:hello

# First cached run computes the result and stores it
gaffer-exec --workspace-root . run --cache sha256 make:cached

# Delete the output, then run again: gaffer-exec restores it from cache
rm -rf out
gaffer-exec --workspace-root . run --cache sha256 make:cached
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `hello-a` | - | Prints `hello from task A` |
| `hello-b` | - | Prints `hello from task B` |
| `hello` | `hello-a`, `hello-b` | Aggregate; prints `→ hello graph complete` (default goal) |
| `cached` | - | Writes `out/stamp.txt` so the result can be cached |

## How it works

gaffer-exec discovers the Makefile at the workspace root and builds a graph from the target dependencies:

```
        hello
       /     \
  hello-a   hello-b     <- run in parallel (no shared dependency)
       \     /
        hello
```

`hello-a` and `hello-b` have no dependencies, so gaffer-exec runs them at the same time. The aggregate `hello` depends on both, so it runs last and prints its summary.

The `cached` target writes `out/stamp.txt`. With `--cache sha256`, gaffer-exec computes a key from the target's command and the source files in the working directory, stores the result, and replays it when the same key appears again. Because the freshly written `out/stamp.txt` is itself a source file, delete `out/` before the second run so the key matches and the hit is visible; the hit then restores `out/stamp.txt` from the cache.

## Expected output

Core graph (`make:hello`):

```text
→ make:hello-a
→ make:hello-b
[make:hello-b] hello from task B
[make:hello-a] hello from task A
→ make:hello
[make:hello] → hello graph complete

✓ make:hello-a
✓ make:hello-b
✓ make:hello
```

The `task A` and `task B` lines can appear in either order, because those two targets run concurrently.

Cached target (`make:cached`, second run after deleting `out/`):

```text
→ make:cached
[make:cached] Cache hit: 83c431c9fd467ad5 (artifacts restored)
✓ make:cached
```

## Testing

Run the validation suite from this directory:

```bash
bash test.sh
```

The script runs `make:hello` and asserts both tasks plus the aggregate executed, then runs `make:cached` twice and asserts the second run is a cache hit that restores `out/stamp.txt`.

## Troubleshooting

- **`gaffer-exec: command not found`**: install gaffer-exec and ensure it is on your PATH.
- **No cache hit on the second run**: any new or changed file in the directory changes the key. Delete `out/` before re-running `make:cached` so the inputs match the first run.
- **Targets look sequential**: `make -n hello` shows what plain make would run; with `-j2`, make also parallelizes `hello-a` and `hello-b`.
- **Targets do not rebuild**: all targets are `.PHONY`, so plain make would always run them; gaffer-exec's `--cache` is what skips work.

## Next example

[01-monorepo-build](../01-monorepo-build/README.md) scales this same loop to a real five-package TypeScript monorepo with incremental rebuilds.
