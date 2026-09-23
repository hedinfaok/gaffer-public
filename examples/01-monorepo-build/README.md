# Monorepo Build Orchestration

What this shows: building a real TypeScript monorepo of five packages with gaffer-exec, using dependency-aware parallelism, content-based caching, and incremental rebuilds.

## What you'll learn

- Dependency-aware parallel scheduling: `auth-service` and `user-service` build at the same time because neither depends on the other.
- Content-based caching: unchanged targets are skipped and their outputs are restored.
- Incremental rebuilds: only the packages affected by a source change rebuild.
- Graph inspection with `show make:build-all --format dot` and `--format json`.
- Output tracking: each target declares what it produces, so artifacts can be restored after deletion.

## Prerequisites

- Node.js v16 or later
- npm v7 or later (for workspaces)
- gaffer-exec on your PATH
- Basic familiarity with TypeScript and monorepos

## Quick start

```bash
# Install dependencies for all packages
npm install

# Build the whole graph
gaffer-exec --workspace-root . run make:build-all

# Run the compiled web app
gaffer-exec --workspace-root . run make:start
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `clean` | - | Removes `packages/*/dist` |
| `shared-lib` | - | Compiles the shared library with `tsc` |
| `auth-service` | `shared-lib` | Compiles the authentication service |
| `user-service` | `shared-lib` | Compiles the user service |
| `api-gateway` | `auth-service`, `user-service` | Compiles the API gateway |
| `web-app` | `api-gateway` | Compiles the web application |
| `build-all` | `web-app` | Builds the full graph and prints a summary |
| `start` | `build-all` | Runs the compiled web app |

## How it works

The dependency graph leaves one obvious parallel opportunity: `auth-service` and `user-service` share only `shared-lib`, so gaffer-exec schedules them together.

```
                    clean
                      │
                  shared-lib
                   ┌──┴──┐
           auth-service  user-service   <- build in parallel
                   └──┬──┘
                 api-gateway
                      │
                   web-app
                      │
                 build-all -> start
```

Pattern: this is the shape of any npm-workspaces monorepo, a shared package at the bottom, independent services in the middle, and a gateway and app on top. gaffer-exec reads the standard Makefile, so there is no new syntax to learn.

## Expected output

```text
Building shared-lib...
✓ shared-lib complete
Building auth-service...
✓ auth-service complete
Building user-service...
✓ user-service complete
Building api-gateway...
✓ api-gateway complete
Building web-app...
✓ web-app complete

════════════════════════════════════════
✓ All packages built successfully!
════════════════════════════════════════
Built: shared-lib, auth-service, user-service, api-gateway, web-app
```

The `auth-service` and `user-service` lines can interleave, because those two targets run concurrently.

## Testing

Run the validation suite:

```bash
./test.sh
```

The demo scripts each show one behavior and print illustrative timings:

```bash
./demo-parallel.sh     # parallel vs sequential
./demo-incremental.sh  # rebuild only what changed
./demo-caching.sh      # cold vs warm cache
./benchmark.sh         # repeated runs, averages
```

Illustrative results from a modern development machine (illustrative, not a benchmark):

| Scenario | npm workspaces | gaffer-exec (cold) | gaffer-exec (cached) |
|----------|----------------|--------------------|----------------------|
| Full clean build | 280ms | 175ms | - |
| Second build (no changes) | 280ms | 45ms | 45ms |
| Change one file | 280ms | 150ms | 120ms |

## Troubleshooting

- **Build fails with "Cannot find module"**: run `npm install` at the root, then confirm workspaces are linked.
- **`gaffer-exec` command not found**: install it and ensure it is on your PATH; `npx gaffer-exec` also works.
- **Builds seem slow**: the first build compiles TypeScript from cold; later runs reuse the cache.
- **Demo scripts fail**: make them executable with `chmod +x *.sh` and run them from this directory.

## Next example

[02-distributed-build](../02-distributed-build/README.md) moves the cache off the local machine and into remote cloud storage backends.
