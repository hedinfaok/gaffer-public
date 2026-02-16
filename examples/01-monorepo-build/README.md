# Monorepo Build Orchestration

This example demonstrates building a **real TypeScript monorepo** with multiple packages using gaffer-exec for parallel builds with proper dependency ordering.

## Real Open Source Project Pattern

This example follows the same patterns used in popular open source TypeScript monorepos like:
- **Turborepo** examples
- **Nx** workspace projects
- **Lerna** monorepos
- **Yarn/pnpm** workspace projects

The code is **real, executable TypeScript** - not mock/toy examples.

## Project Structure

```
01-monorepo-build/
├── packages/
│   ├── shared-lib/          # Common utilities and types
│   ├── auth-service/        # Authentication microservice
│   ├── user-service/        # User management microservice
│   ├── api-gateway/         # API gateway (depends on both services)
│   └── web-app/             # Web application (depends on gateway)
├── graph.json               # gaffer-exec build graph
├── package.json             # npm workspaces configuration
└── tsconfig.json            # TypeScript project references
```

## Dependency Graph

```
                    clean
                      │
                  shared-lib
                   ┌──┴──┐
           auth-service  user-service
                   └──┬──┘
                 api-gateway
                      │
                   web-app
                      │
                 build-all → run
```

**Key Features:**
- `auth-service` and `user-service` build **in parallel** (both depend only on `shared-lib`)
- Each package has real TypeScript code with proper imports
- Dependencies enforced through workspace references
- Demonstrates real-world monorepo patterns

## Prerequisites

- **Node.js** (v16 or later)
- **npm** (v7+ for workspaces support)
- **gaffer-exec** installed from the gaffer project

## Setup

```bash
# Install dependencies for all packages
npm install

# Verify TypeScript is available
npx tsc --version
```

## How to Run

### Quick Start - Build and Run Everything

```bash
# Clean and build all packages in dependency order
npm run clean
gaffer-exec run shared-lib --graph graph.json
gaffer-exec run auth-service --graph graph.json
gaffer-exec run user-service --graph graph.json
gaffer-exec run api-gateway --graph graph.json
gaffer-exec run web-app --graph graph.json

#Run the application
gaffer-exec run start --graph graph.json
```

### Single Command Build (using shell)

```bash
# Build everything in the correct order
npm run clean && \
  gaffer-exec run shared-lib --graph graph.json && \
  gaffer-exec run auth-service --graph graph.json && \
  gaffer-exec run user-service --graph graph.json && \
  gaffer-exec run api-gateway --graph graph.json && \
  gaffer-exec run web-app --graph graph.json &&\
  gaffer-exec run start --graph graph.json
```

### Build Individual Packages

```bash
# Build just the shared library
gaffer-exec run shared-lib --graph graph.json

# Build a specific service (requires shared-lib)
gaffer-exec run auth-service --graph graph.json

# Build gateway (requires services)
gaffer-exec run api-gateway --graph graph.json
```

### Visualize the Build Graph

```bash
# Generate dependency graph in DOT format
gaffer-exec graph build-all --graph graph.json

# Or export as JSON
gaffer-exec graph build-all --graph graph.json --format json
```

### Build Individual Packages

```bash
# Build just the shared library
gaffer-exec run shared-lib --graph graph.json

# Build up to api-gateway (will build dependencies)
gaffer-exec run api-gateway --graph graph.json
```

### Clean Build Artifacts

```bash
# Clean all dist/ directories
npm run clean

# Or using gaffer-exec
gaffer-exec run clean --graph graph.json
```

## What This Demonstrates

### 1. Parallel Builds
- `auth-service` and `user-service` build simultaneously (both only depend on `shared-lib`)
- Optimal parallelism automatically determined

### 2. Dependency Management
- TypeScript packages with proper `import` statements
- Workspace references using `workspace:*` protocol
- Build order respects package dependencies

### 3. Real Code Compilation
- Actual TypeScript compilation with `tsc`
- Type checking and declaration generation
- Real output artifacts in `dist/` directories

### 4. Monorepo Patterns
- npm workspaces for dependency management
- TypeScript project references for compilation
- Shared library pattern (common in real projects)

## Expected Output

When running `gaffer-exec run build-all --graph graph.json`:

```
✓ clean completed
✓ shared-lib completed
✓ auth-service completed (parallel)
✓ user-service completed (parallel)
✓ api-gateway completed
✓ web-app completed
✓ build-all completed
✓ All packages built successfully
Built: shared-lib, auth-service, user-service, api-gateway, web-app
```

When running `gaffer-exec run run --graph graph.json`:

```
[Output from build steps...]
[web-app] INFO: Starting web app on port 8080
[api-gateway] INFO: Starting API gateway on port 3000
[auth-service] INFO: Starting auth service on port 3001
[user-service] INFO: Starting user service on port 3002
==================================================
Welcome to the Monorepo Example Web App
==================================================
This app demonstrates:
- TypeScript compilation across packages
- Dependency management in a monorepo
- Parallel builds with gaffer-exec
==================================================
```

## Comparison to Other Tools

### vs. npm scripts
- **Better parallelism**: gaffer-exec runs independent tasks truly in parallel
- **Dependency awareness**: Only rebuilds what changed
- **Visualization**: See the entire build graph

### vs. Turborepo/Nx
- **Simpler**: No need for complex configuration
- **Tool-agnostic**: Works with any build tool (npm, tsc, cargo, make, etc.)
- **Explicit**: Dependency graph is clearly defined in JSON

### vs. Makefile
- **Better caching**: Content-based (not timestamp-based)
- **Cross-platform**: Works on Windows/macOS/Linux without GNU Make
- **Modern syntax**: JSON instead of Makefile syntax

## Files and What They Do

- **package.json** - Root workspace configuration, defines npm workspaces
- **tsconfig.json** - Root TypeScript config with project references
- **graph.json** - gaffer-exec build orchestration graph
- **packages/*/package.json** - Individual package manifests
- **packages/*/tsconfig.json** - TypeScript configuration per package
- **packages/*/src/index.ts** - Source code with real TypeScript

## Value Proposition

This example shows how gaffer-exec can replace complex build orchestration tools in a TypeScript monorepo while providing:
- **Faster builds** through intelligent parallelization
- **Clear visualization** of build dependencies
- **Simple configuration** compared to alternatives
- **Works with existing tooling** (npm, tsc, etc.)

## Next Steps

- Try modifying source files and rebuilding (see incremental behavior)
- Add caching with `--cache sha256` for even faster rebuilds
- Export to different formats: `gaffer-exec export build-all --format makefile`
- Integrate with CI: `gaffer-exec export build-all --format github-actions`
