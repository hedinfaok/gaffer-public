# Local Development Environment

What this shows: orchestrating a full local stack, PostgreSQL in Docker, an Express API, and a React frontend, with automatic port assignment, health checks, and graceful shutdown.

## What you'll learn

- Dependency-aware startup ordering: database, then API, then frontend.
- Automatic port discovery written to `.env` so services do not collide.
- Readiness gating: `dev` waits for every service to report healthy.
- One-command integration testing against the running stack.
- Graceful teardown of containers and dev servers with `make:stop`.

## Prerequisites

- Node.js 18 or later (`node --version`)
- npm (`npm --version`)
- Docker (`docker --version`)
- gaffer-exec on your PATH

## Quick start

```bash
# One-time setup: directories and automatic port assignment
gaffer-exec --workspace-root . run make:setup

# Start the complete stack and wait for readiness
./scripts/dev-full.sh

# Or start it step by step
gaffer-exec --workspace-root . run make:db-start
gaffer-exec --workspace-root . run make:api-start
gaffer-exec --workspace-root . run make:frontend-start
gaffer-exec --workspace-root . run make:dev
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `setup` | - | Creates directories and assigns free ports into `.env` |
| `install-deps` | `setup` | Installs dependencies for every service |
| `db-start` | `install-deps` | Starts PostgreSQL in Docker |
| `api-start` | `db-start` | Starts the Express API server |
| `frontend-start` | `install-deps` | Starts the React development server |
| `dev` | `db-start`, `api-start`, `frontend-start` | Brings up the stack and waits for readiness (default goal) |
| `test` | `dev` | Runs integration tests against the running stack |
| `stop` | - | Stops all services gracefully |
| `clean` | `stop` | Removes generated files and Docker resources |

## How it works

```
setup -> install-deps -> db-start -> api-start ┐
                   └──> frontend-start ────────┴─> dev -> test
```

Pattern: a service-oriented local stack where startup order matters. gaffer-exec schedules `frontend-start` in parallel with `db-start`/`api-start` because the frontend only needs dependencies installed, while `dev` waits on all three.

1. **Port assignment**: `setup` scans upward from the defaults (PostgreSQL 5432+, API 3001+, frontend 3000+) and writes the chosen ports to `.env`.
2. **Health checks**: the database uses `pg_isready`, the API exposes a `/health` endpoint, and the frontend checks that its assets load.
3. **Readiness**: `dev` runs `scripts/wait-for-services.sh`, which polls until all three services respond.
4. **Shutdown**: `stop` terminates the frontend, the API (with connection cleanup), and the PostgreSQL container in that order.

## Expected output

After `gaffer-exec --workspace-root . run make:dev` completes:

```text
All services are ready!

Development Stack Status:
   Database:  http://localhost:5433 (PostgreSQL)
   API:       http://localhost:3001
   Frontend:  http://localhost:3000

You can now:
   - Open your browser to http://localhost:3000
   - Test API at http://localhost:3001/api/tasks
   - Check API health at http://localhost:3001/health
```

The generated `.env` records the assigned ports:

```bash
DB_PORT=5433
API_PORT=3001
FRONTEND_PORT=3000
DATABASE_URL=postgresql://devuser:devpass@localhost:5433/taskmanager
```

## Testing

```bash
./test.sh
```

The suite runs ten checks across the lifecycle: prerequisites, setup and port assignment, dependency install, database/API/frontend startup, integration tests, graceful shutdown, and cleanup. With the stack already running you can run just the integration tests:

```bash
gaffer-exec --workspace-root . run make:test
```

Those tests cover database connectivity, API endpoints, CRUD operations, frontend accessibility, and service health.

## Troubleshooting

- **Port conflicts**: run `gaffer-exec --workspace-root . run make:clean`, then `make:setup` to pick new ports, then `make:dev`.
- **Database issues**: check `docker ps` for the container and `docker logs taskmanager-db` for errors.
- **API connection issues**: check `curl http://localhost:$API_PORT/health` and `tail -f logs/api.log`.
- **Frontend build issues**: check `tail -f logs/frontend.log`.

## Next example

[07-watch-workflows](../07-watch-workflows/README.md) keeps services rebuilt automatically as you edit, using a file watcher feeding gaffer-exec.
