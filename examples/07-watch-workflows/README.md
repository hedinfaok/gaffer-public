# Example 07: Watch Mode Workflows

This example demonstrates **intelligent watch mode workflows** using `fswatch` and `gaffer-exec`. It shows how to build a dependency-aware file watching system that triggers cascading rebuilds across multiple services.

## The Problem

Modern development workflows often involve multiple services with dependencies:
- Changes to a shared library should rebuild all dependent services
- Each service needs its own file watcher
- Rebuilds should be intelligent (only rebuild what changed)
- Watch mode should handle graceful shutdown

Traditional solutions like `nodemon`, `tsc --watch`, or `webpack-dev-server` are service-specific and don't understand cross-service dependencies.

## The Solution

This example combines:
- **`fswatch`**: Fast, cross-platform file system monitoring
- **`gaffer-exec`**: Dependency-aware task orchestration
- **Shell wrapper scripts**: Glue `fswatch` events to `gaffer-exec` commands

The key insight: **gaffer-exec doesn't watch files** — it orchestrates rebuilds when `fswatch` detects changes.

## Architecture

```
┌──────────────┐
│ shared-lib   │  TypeScript library with utilities
│ (TypeScript) │  Used by both api-service and frontend
└──────┬───────┘
       │
       ├─────────────┐
       │             │
       ▼             ▼
┌──────────┐   ┌──────────┐
│   api    │   │ frontend │
│ (Node.js)│   │ (React)  │
└──────────┘   └──────────┘
```

**Dependency cascade:**
- Change `shared-lib/src/index.ts` → Rebuild shared-lib → Rebuild api + frontend
- Change `api-service/src/server.ts` → Rebuild api only
- Change `frontend/src/App.tsx` → Rebuild frontend only

## How It Works

### 1. File Watching (`fswatch`)

Each service has a watch script (`scripts/watch-*.sh`) that:
```bash
fswatch \
  --latency 0.5 \           # Debounce: wait 500ms after last change
  --exclude '.*' \          # Exclude hidden files
  --include '\.ts$' \       # Include .ts files
  --exclude 'node_modules' \ # Exclude dependencies
  shared-lib/src/ | while read -r file; do
    gaffer-exec run rebuild-shared-lib
done
```

### 2. Task Orchestration (`gaffer-exec`)

The `graph.json` defines rebuild tasks with dependencies:
```json
{
  "rebuild-shared-lib": {
    "command": "cd shared-lib && npm run build",
    "deps": []
  },
  "rebuild-api": {
    "command": "cd api-service && npm run build",
    "deps": ["rebuild-shared-lib"]  // ← Depends on shared-lib
  },
  "rebuild-frontend": {
    "command": "cd frontend && npm run build",
    "deps": ["rebuild-shared-lib"]  // ← Depends on shared-lib
  }
}
```

When `rebuild-api` is triggered:
1. `gaffer-exec` checks if `shared-lib` changed (via hashing/timestamps)
2. If yes, rebuilds `shared-lib` first
3. Then rebuilds `api-service`
4. Skips unnecessary work if `shared-lib` is up-to-date

### 3. Graceful Shutdown

Watch scripts handle `SIGINT`/`SIGTERM`:
```bash
trap 'echo "Stopping watch..."; exit 0' SIGINT SIGTERM
```

The `watch-all.sh` script manages multiple watchers and cleans up on exit.

## Usage

### Initial Setup

Install dependencies and build all services:
```bash
gaffer-exec --graph graph.json run build-all
```

### Development Workflow

**Option 1: Run all watchers**
```bash
./scripts/watch-all.sh
```

This starts three parallel watchers:
- `watch-shared-lib.sh` → Watches TypeScript files in `shared-lib/src/`
- `watch-api.sh` → Watches TypeScript files in `api-service/src/`
- `watch-frontend.sh` → Watches React files in `frontend/src/`

**Option 2: Run individual watchers**
```bash
# In terminal 1
./scripts/watch-shared-lib.sh

# In terminal 2
./scripts/watch-api.sh

# In terminal 3
./scripts/watch-frontend.sh
```

**Start the services** (in separate terminals):
```bash
# Terminal 1: Start API
cd api-service && node dist/server.js

# Terminal 2: Start frontend
cd frontend && npx serve -s build -p 3000
```

Or use gaffer to start them:
```bash
gaffer-exec --graph graph.json run start-api &
gaffer-exec --graph graph.json run start-frontend &
```

### Making Changes

**Edit shared-lib:**
```bash
# Edit shared-lib/src/index.ts
# → Rebuilds shared-lib
# → Rebuilds api-service (depends on shared-lib)
# → Rebuilds frontend (depends on shared-lib)
```

**Edit api-service:**
```bash
# Edit api-service/src/server.ts
# → Rebuilds api-service only
```

**Edit frontend:**
```bash
# Edit frontend/src/App.tsx
# → Rebuilds frontend only
```

## Performance Comparison

### Traditional Approach
```bash
# Terminal 1
cd shared-lib && tsc --watch

# Terminal 2
cd api-service && nodemon

# Terminal 3
cd frontend && webpack-dev-server
```

**Problems:**
- No dependency awareness (api doesn't rebuild when shared-lib changes)
- Must manually restart dependent services
- Wasteful (rebuilds everything, even if nothing changed)

### This Approach (fswatch + gaffer-exec)
```bash
./scripts/watch-all.sh
```

**Benefits:**
- ✅ Dependency-aware cascading rebuilds
- ✅ Incremental builds (only rebuild what changed)
- ✅ Single command to watch all services
- ✅ Graceful shutdown of all watchers
- ✅ Debouncing via `--latency` flag
- ✅ Works with any build tool (TypeScript, Webpack, Babel, etc.)

## Key Features

### 1. Debouncing
The `--latency 0.5` flag tells `fswatch` to wait 500ms after the last file change before triggering. This prevents:
- Multiple rebuilds for rapid successive saves
- Rebuilds triggered by intermediate IDE autosaves

### 2. Smart Filtering
Each watcher excludes irrelevant files:
```bash
--exclude 'node_modules'  # Don't watch dependencies
--exclude 'dist'          # Don't watch build outputs
--include '\.ts$'         # Only watch TypeScript files
```

### 3. Dependency Cascade
Thanks to `graph.json` dependencies:
- Changing `shared-lib` automatically rebuilds dependents
- Changing a service only rebuilds that service
- No manual intervention required

### 4. Cross-Platform
- `fswatch` works on macOS, Linux, and Windows (via WSL)
- `gaffer-exec` is platform-agnostic
- Scripts use portable shell syntax

## Prerequisites

Install `fswatch`:

**macOS:**
```bash
brew install fswatch
```

**Linux (Ubuntu/Debian):**
```bash
apt-get install fswatch
```

**Linux (Fedora/RHEL):**
```bash
dnf install fswatch
```

## Alternatives to fswatch

This pattern works with other file watchers:

**watchman (Facebook):**
```bash
watchman-make -p 'shared-lib/src/**/*.ts' -t rebuild-shared-lib
```

**inotify-tools (Linux only):**
```bash
inotifywait -m -r shared-lib/src/ | while read -r file; do
    gaffer-exec run rebuild-shared-lib
done
```

**chokidar-cli (Node.js):**
```bash
chokidar 'shared-lib/src/**/*.ts' -c 'gaffer-exec run rebuild-shared-lib'
```

The pattern is the same: file watcher → filter events → trigger `gaffer-exec`.

## Testing

Run the validation script:
```bash
./test.sh
```

This verifies:
- All services build successfully
- Watch scripts are properly structured
- Dependencies are correctly wired

## Cleanup

Remove build artifacts:
```bash
gaffer-exec --graph graph.json run clean
```

## Learn More

- **`fswatch` documentation**: http://emcrisostomo.github.io/fswatch/
- **Example 04**: Incremental Testing (similar watch patterns)
- **Example 06**: Local Dev Environment (orchestrating multiple services)

## Summary

This example shows how to build intelligent watch mode workflows by combining:
1. **`fswatch`** for fast file system monitoring
2. **`gaffer-exec`** for dependency-aware task orchestration
3. **Shell scripts** to connect the two

The result: a development workflow that's faster, smarter, and easier to manage than traditional per-service watchers.
