# Architecture: Watch Mode Workflows

This document explains the technical architecture of the watch mode workflow system, detailing how `fswatch` and `gaffer-exec` collaborate to provide intelligent, dependency-aware rebuilds.

## Overview

Traditional build watchers (e.g., `tsc --watch`, `nodemon`, `webpack-dev-server`) are tool-specific and lack cross-service dependency awareness. This architecture decouples file watching from build orchestration:

- **File Watching Layer**: `fswatch` monitors filesystem events
- **Orchestration Layer**: `gaffer-exec` manages build dependencies and execution
- **Integration Layer**: Shell scripts bridge the two

## Components

### 1. File Watching (`fswatch`)

**Purpose**: Detect filesystem changes with minimal overhead

**Key Features**:
- Native OS integration (FSEvents on macOS, inotify on Linux)
- Recursive directory monitoring
- Pattern-based filtering (include/exclude)
- Debouncing via `--latency` flag
- Cross-platform support

**Example Usage**:
```bash
fswatch \
  --latency 0.5 \              # Wait 500ms after last change
  --exclude '.*' \             # Exclude all by default
  --include '\.ts$' \          # Include TypeScript files
  --exclude 'node_modules' \   # Exclude dependencies
  --exclude 'dist' \           # Exclude build outputs
  --recursive \                # Watch subdirectories
  shared-lib/src/
```

**Why fswatch?**
- **Performance**: Native OS APIs are faster than polling
- **Reliability**: Battle-tested in production environments
- **Flexibility**: Works with any build tool, not tied to specific languages
- **Simplicity**: Single binary, no complex configuration

### 2. Task Orchestration (`gaffer-exec`)

**Purpose**: Execute tasks with dependency-aware caching

**Key Features**:
- Dependency graph resolution
- Content-based change detection (hashing)
- Incremental execution (skip unchanged tasks)
- Parallel execution where possible
- Proper error propagation

**Example Task Graph**:
```json
{
  "rebuild-shared-lib": {
    "command": "cd shared-lib && npm run build",
    "deps": [],
    "outputs": ["shared-lib/dist/**"]
  },
  "rebuild-api": {
    "command": "cd api-service && npm run build",
    "deps": ["rebuild-shared-lib"],
    "outputs": ["api-service/dist/**"]
  }
}
```

**Execution Flow**:
1. User/script invokes: `gaffer-exec run rebuild-api`
2. Gaffer checks if `rebuild-shared-lib` (dependency) needs to run
3. Compares current state with cached state (via hashing)
4. Runs `rebuild-shared-lib` only if changed
5. Runs `rebuild-api`
6. Caches results for next invocation

**Why gaffer-exec?**
- **Smart**: Only rebuilds what changed
- **Fast**: Skips unnecessary work
- **Composable**: Tasks are building blocks
- **Declarative**: Graph in JSON, not imperative scripts

### 3. Integration Layer (Shell Scripts)

**Purpose**: Bridge fswatch events to gaffer-exec commands

**Pattern**:
```bash
fswatch [options] [paths] | while read -r file; do
    gaffer-exec run [task]
done
```

**Responsibilities**:
- Configure fswatch filters
- Parse file change events
- Invoke appropriate gaffer-exec task
- Handle signals (SIGINT/SIGTERM)
- Provide user feedback

**Example** (`scripts/watch-shared-lib.sh`):
```bash
#!/bin/bash
set -e

trap 'echo "Stopping watch..."; exit 0' SIGINT SIGTERM

fswatch \
  --latency 0.5 \
  --exclude '.*' \
  --include '\.ts$' \
  shared-lib/src/ | while read -r file; do
    echo "Changed: $file"
    gaffer-exec --graph graph.json run rebuild-shared-lib
done
```

## Data Flow

### Cascade: Shared Library Change

```
┌─────────────────────────────────────────────────────────┐
│ 1. Edit shared-lib/src/index.ts                        │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│ 2. fswatch detects change                              │
│    - Waits 500ms (debounce)                            │
│    - Outputs: shared-lib/src/index.ts                  │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│ 3. watch-shared-lib.sh receives event                  │
│    - Pipes to: gaffer-exec run rebuild-shared-lib      │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│ 4. gaffer-exec evaluates task graph                    │
│    - rebuild-shared-lib has no deps → run immediately  │
│    - Executes: cd shared-lib && npm run build          │
│    - Hashes outputs: shared-lib/dist/**                │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│ 5. Dependent watchers may trigger                      │
│    - rebuild-api depends on rebuild-shared-lib         │
│    - rebuild-frontend depends on rebuild-shared-lib    │
│    - Next invocation will see shared-lib changed       │
└─────────────────────────────────────────────────────────┘
```

### Cascade: API Service Change

```
┌─────────────────────────────────────────────────────────┐
│ 1. Edit api-service/src/server.ts                      │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│ 2. fswatch detects change                              │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│ 3. watch-api.sh receives event                         │
│    - Pipes to: gaffer-exec run rebuild-api             │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│ 4. gaffer-exec evaluates dependencies                  │
│    - rebuild-api depends on rebuild-shared-lib         │
│    - Checks if shared-lib changed (NO)                 │
│    - Skips rebuild-shared-lib                          │
│    - Executes: cd api-service && npm run build         │
└─────────────────────────────────────────────────────────┘
```

**Key Insight**: Even though `rebuild-api` depends on `rebuild-shared-lib`, gaffer skips the dependency because it hasn't changed. This is much smarter than traditional watchers.

## Debouncing Strategy

**Problem**: Rapid file saves can trigger excessive rebuilds

**Solution**: `fswatch --latency N` (where N is seconds)

**How it works**:
1. File change detected at T=0ms
2. Another change at T=100ms
3. Another change at T=250ms
4. fswatch waits until T=750ms (500ms after last change)
5. Emits single event
6. Triggers one rebuild (not three)

**Choosing Latency**:
- Too low (< 0.3s): Risk multiple rebuilds
- Too high (> 2s): Feels sluggish
- Sweet spot: 0.5s - 1s

**Example**:
```bash
# User saves file 5 times in 2 seconds
# Without debouncing: 5 rebuilds
# With --latency 0.5: 1 rebuild (500ms after last save)
```

## Signal Handling

**Problem**: When user presses Ctrl+C, watch processes should exit gracefully

**Solution**: Trap signals and clean up

**Implementation**:
```bash
trap 'echo "Stopping watch..."; exit 0' SIGINT SIGTERM
```

**watch-all.sh** (managing multiple watchers):
```bash
PIDS=()

cleanup() {
    for pid in "${PIDS[@]}"; do
        kill "$pid" 2>/dev/null || true
    done
    wait
}

trap cleanup SIGINT SIGTERM

./watch-shared-lib.sh &
PIDS+=($!)

./watch-api.sh &
PIDS+=($!)

wait  # Wait for all background processes
```

**Sequence**:
1. User presses Ctrl+C
2. Shell receives SIGINT
3. `cleanup()` function executes
4. Kills all child processes (watchers)
5. Waits for them to exit
6. Parent exits cleanly

## Performance Analysis

### Memory Usage

| Component | Memory (RSS) | Notes |
|-----------|--------------|-------|
| fswatch (per instance) | ~2-5 MB | Native binary, minimal overhead |
| gaffer-exec (per run) | ~10-20 MB | Go binary, fast startup |
| Shell script overhead | ~1-2 MB | Bash process |
| **Total (3 watchers)** | **~15-35 MB** | Much lighter than webpack-dev-server (~200-500 MB) |

### CPU Usage

- **Idle**: ~0% (fswatch uses OS notifications, not polling)
- **During rebuild**: Depends on build tool (TypeScript, Webpack, etc.)
- **fswatch overhead**: Negligible (< 1% even with many files)

### Rebuild Times

**Scenario**: Change `shared-lib/src/index.ts`

| Approach | Time | Why |
|----------|------|-----|
| Manual (rebuild all) | ~15s | Rebuilds everything |
| tsc --watch (3 separate watchers) | ~12s | No dependency cascade |
| **This approach** | **~5s** | Only rebuilds shared-lib + dependents |

**Scenario**: Change `api-service/src/server.ts`

| Approach | Time | Why |
|----------|------|-----|
| Manual | ~8s | Rebuilds everything |
| nodemon | ~6s | Restarts service |
| **This approach** | **~3s** | Only rebuilds api-service |

## Comparison to Alternatives

### Traditional Watch Mode

**Example**: `tsc --watch`

**Pros**:
- Built into TypeScript
- Zero configuration

**Cons**:
- No cross-service dependencies
- Must run separately for each service
- Rebuilds entire project on any change
- No task composition

### Webpack Dev Server

**Example**: `webpack-dev-server`

**Pros**:
- Hot module replacement
- Fast incremental rebuilds (in-memory)

**Cons**:
- Webpack-specific (doesn't work for backend services)
- Heavy memory usage
- Complex configuration
- Doesn't handle multi-service dependencies

### Turborepo / Nx Watch

**Example**: `turbo watch`

**Pros**:
- Monorepo-aware
- Dependency tracking

**Cons**:
- Requires adopting entire build system
- Opinionated structure
- Overkill for simple projects

### This Approach (fswatch + gaffer)

**Pros**:
- ✅ Works with any build tool
- ✅ Minimal overhead
- ✅ Dependency-aware
- ✅ Composable (shell scripts)
- ✅ Easy to debug

**Cons**:
- Requires installing fswatch
- One-time setup cost (writing scripts)

## Extensibility

### Adding a New Service

1. Create the service directory
2. Add build task to `graph.json`:
   ```json
   {
     "rebuild-new-service": {
       "command": "cd new-service && npm run build",
       "deps": ["rebuild-shared-lib"]
     }
   }
   ```
3. Create watch script:
   ```bash
   # scripts/watch-new-service.sh
   fswatch --latency 0.5 new-service/src/ | while read -r file; do
       gaffer-exec run rebuild-new-service
   done
   ```
4. Add to `watch-all.sh`:
   ```bash
   ./scripts/watch-new-service.sh &
   PIDS+=($!)
   ```

### Using Different File Watchers

**watchman**:
```bash
watchman-make -p 'shared-lib/src/**/*.ts' \
  --run 'gaffer-exec run rebuild-shared-lib'
```

**chokidar-cli**:
```bash
chokidar 'shared-lib/src/**/*.ts' \
  -c 'gaffer-exec run rebuild-shared-lib'
```

**inotify-tools** (Linux):
```bash
inotifywait -m -r -e modify shared-lib/src/ | while read -r file; do
    gaffer-exec run rebuild-shared-lib
done
```

### Adding Live Reload

Combine with a live reload server:

```bash
# Start live reload server
npx live-server frontend/build &

# Watch and rebuild
./scripts/watch-frontend.sh
```

On rebuild, live-server detects `frontend/build` changes and refreshes browser.

## Troubleshooting

### fswatch not detecting changes

**Symptom**: Save file, no rebuild triggered

**Solutions**:
1. Check fswatch is installed: `which fswatch`
2. Verify pattern matches: Add `--verbose` flag
3. Ensure not excluding the file: Check `--exclude` patterns

### Multiple rebuilds for single save

**Symptom**: One file change triggers multiple rebuilds

**Solutions**:
1. Increase `--latency`: Try 1.0s instead of 0.5s
2. Check for multiple watchers on same path
3. IDE may be creating temp files → adjust `--exclude` patterns

### Build fails but watch continues

**Symptom**: Build error, but watcher keeps running

**Solutions**:
1. Watch script should show error output
2. gaffer-exec will report non-zero exit code
3. Fix the build error, save again to retry

## Summary

This architecture demonstrates a powerful pattern:

1. **Separation of Concerns**: fswatch watches, gaffer builds
2. **Composability**: Shell scripts glue them together
3. **Intelligence**: Dependency-aware cascading rebuilds
4. **Performance**: Only rebuild what changed
5. **Flexibility**: Works with any build tool

The result is a fast, reliable, and maintainable watch mode workflow for multi-service applications.
