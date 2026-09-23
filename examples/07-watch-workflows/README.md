# Watch Mode Workflows

What this shows: a dependency-aware file watcher that rebuilds a TypeScript shared library and cascades the rebuild to every dependent service.

## What you'll learn

- Combining `fswatch` with gaffer-exec: the watcher detects changes, gaffer-exec plans the rebuild.
- Dependency cascade: editing the shared library rebuilds the API and frontend too; editing one service rebuilds only that service.
- Debouncing with `fswatch --latency` so rapid saves trigger one rebuild.
- Path filtering to ignore `node_modules` and build output.
- Graceful shutdown of every watcher with `SIGINT`/`SIGTERM` traps.

## Prerequisites

- Node.js 18 or later
- npm
- `fswatch` (macOS: `brew install fswatch`; Debian/Ubuntu: `apt-get install fswatch`; Fedora/RHEL: `dnf install fswatch`)
- gaffer-exec on your PATH

## Quick start

```bash
# Install dependencies and build all services
gaffer-exec --workspace-root . run make:build-all

# Start all three watchers
./scripts/watch-all.sh
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `clean` | - | Removes all build artifacts |
| `install-deps` | - | Installs dependencies for all three services |
| `build-shared-lib` | `install-deps` | Builds the shared TypeScript library |
| `build-api` | `build-shared-lib` | Builds the API service |
| `build-frontend` | `build-shared-lib` | Builds the frontend (parallel with the API) |
| `build-all` | `build-api`, `build-frontend` | Builds everything (default goal) |
| `rebuild-shared-lib` | - | Rebuilds the library without reinstalling dependencies |
| `rebuild-api` | `rebuild-shared-lib` | Rebuilds the API (used by watch mode) |
| `rebuild-frontend` | `rebuild-shared-lib` | Rebuilds the frontend (used by watch mode) |
| `start-api` | `build-api` | Runs the API server |
| `start-frontend` | `build-frontend` | Serves the frontend build on port 3000 |
| `dev` | `start-api`, `start-frontend` | Starts both services |
| `test` | - | Runs the validation suite |

## How it works

```
shared-lib (TypeScript)
    ├── api-service (Node.js)
    └── frontend (React)

change shared-lib/src/index.ts -> rebuild shared-lib -> rebuild api + frontend
change api-service/src/server.ts -> rebuild api only
change frontend/src/App.tsx -> rebuild frontend only
```

Pattern: file watchers stay dumb and gaffer-exec stays the single source of dependency truth. Each `scripts/watch-*.sh` pipes `fswatch` events into one `gaffer-exec run make:rebuild-*` call:

```bash
fswatch \
  --latency 0.5 \
  --exclude '.*' \
  --include '\.ts$' \
  --exclude 'node_modules' \
  shared-lib/src/ | while read -r file; do
    gaffer-exec --workspace-root . run make:rebuild-shared-lib
done
```

When a rebuild target runs, gaffer-exec rebuilds `shared-lib` first if it changed, then the dependent service, and skips work that is already up to date. `watch-all.sh` starts the three watchers together and traps `SIGINT`/`SIGTERM` to clean them up on exit.

`fswatch` is one option; the same pattern works with `watchman`, `inotifywait`, or `chokidar-cli`, as long as the watcher ends up calling `gaffer-exec`.

## Expected output

Initial build:

```text
✓ All services built
```

Watch mode after editing `shared-lib/src/index.ts`:

```text
[watch] shared-lib/src/index.ts changed
[watch] running make:rebuild-shared-lib
Rebuilding shared-lib...
Rebuilding api-service...
Rebuilding frontend...
```

## Testing

```bash
./test.sh
```

The suite verifies that all services build, that the watch scripts are structured correctly, and that dependencies are wired. `./demo.sh` shows the cascade end to end. You can also run individual watchers in separate terminals:

```bash
./scripts/watch-shared-lib.sh
./scripts/watch-api.sh
./scripts/watch-frontend.sh
```

## Troubleshooting

- **`fswatch: command not found`**: install it with the command for your platform listed above.
- **Rebuild loops**: confirm `--exclude 'node_modules'` and `--exclude 'dist'` are present so build output does not retrigger the watcher.
- **Repeated rebuilds while typing**: raise `--latency` (for example `--latency 1.0`) to debounce longer.
- **Services do not start**: build first with `gaffer-exec --workspace-root . run make:build-all`, then use `make:start-api` and `make:start-frontend`.

## Next example

[19-cross-platform-builds](../19-cross-platform-builds/README.md) shows how to keep a single build graph working across Linux, macOS, and Windows.
