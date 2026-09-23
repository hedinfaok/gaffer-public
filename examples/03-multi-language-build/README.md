# Multi-Language Project Builds

Orchestrate real builds across Rust, Go, Node.js, and Python in a single
dependency graph, then prove the built artifacts talk to each other with a
cross-language integration test.

## What you'll learn

- How gaffer-exec reads one `Makefile` and schedules targets across four
  language toolchains.
- How per-language dependency targets (`rust-deps`, `go-deps`, ...) feed the
  build targets that depend on them.
- How to wire a real cross-language smoke test (`make:integration-test`) that
  starts the Rust server and drives the Go, Python, and Node artifacts.
- How a shared `Makefile` gives every language the same `gaffer-exec
  --workspace-root . run make:<target>` interface.

## Prerequisites

Install the toolchains you want to exercise:

- **Rust** — https://rustup.rs/
- **Go** — https://go.dev/dl/
- **Node.js** (with npm) — https://nodejs.org/
- **Python 3** (with pip3)

The integration test starts the Rust backend on `localhost:8080`, so that port
must be free. Python analysis uses `requests`, `numpy`, and `pandas`, which
`make:python-deps` installs.

## Quick start

```bash
# Build every language
gaffer-exec --workspace-root . run make:multi-language-build

# Run the real cross-language smoke test (builds first)
gaffer-exec --workspace-root . run make:integration-test
```

Build a single component:

```bash
gaffer-exec --workspace-root . run make:rust-backend
gaffer-exec --workspace-root . run make:go-cli
gaffer-exec --workspace-root . run make:python-ml
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `rust-deps` | — | `cargo fetch` |
| `go-deps` | — | `go mod download` |
| `node-deps` | — | `npm install` |
| `python-deps` | — | install Python requirements |
| `rust-backend` | `rust-deps` | `cargo build --release` |
| `go-cli` | `go-deps` | `go build` the CLI |
| `node-frontend` | `node-deps` | run the Node frontend test script |
| `python-ml` | `python-deps` | `python3 setup.py build` |
| `multi-language-build` | all four builds | build every component |
| `integration-test` | `multi-language-build` | run `scripts/integration-test.sh` |
| `start-all` | the servers/CLIs | start the integrated stack |

## How it works

Each language has a dependency target and a build target. `multi-language-build`
depends on all four build targets, so gaffer-exec can schedule them in parallel
where the graph allows.

`integration-test` depends on the full build and then runs
`scripts/integration-test.sh`. That script does real work and exits non-zero on
failure:

1. Starts the compiled Rust backend (`rust-backend/target/release/rust-backend`).
2. Waits for `http://localhost:8080/health` and asserts `"status":"healthy"`
   and `"languages_integrated":4` from `/metrics`.
3. Runs the Go CLI (`go-cli/go-cli health`) against that server and asserts it
   reports a healthy backend.
4. Runs `python3 analyze.py`, which fetches the Rust metrics and writes
   `python-ml/ml_analysis_results.json`.
5. Runs the Node frontend package test script.

This is a genuine cross-language check: break any component and the target
fails.

## Expected output

A successful `make:integration-test` ends with:

```
✓ Rust backend serves /health (status=healthy)
✓ Rust backend serves /metrics (languages_integrated=4)
✓ Go CLI queries Rust backend (Backend Status: healthy)
✓ Python analysis consumes the Rust backend
✓ Node.js frontend test harness runs

✓ Integration tests passed
```

## Testing

```bash
bash test.sh
```

The test script checks the toolchains, runs `make:multi-language-build`, verifies
artifacts, and runs `make:integration-test`.

## Troubleshooting

- **`Rust binary missing`** — run `make:rust-backend` (or the full build) first;
  the integration test does not build for you when invoked directly.
- **`Rust backend did not answer`** — port 8080 is in use, or the server failed
  to start. The server log is printed on failure.
- **`Go CLI did not report a healthy backend`** — the Go binary could not reach
  `localhost:8080`; confirm the Rust backend is running.
- **Python analysis fails on import** — install dependencies with
  `gaffer-exec --workspace-root . run make:python-deps`.
- **Missing toolchain** — install the language from Prerequisites; `test.sh`
  continues with a partial run when a tool is absent.

## Next example

Example 03 wires compiled artifacts together and tests them at runtime.
[Example 08](../08-multi-language-task-running/) keeps the same multi-language
idea but focuses on one unified task graph across the whole development
lifecycle (install, build, test, lint, format, clean) with caching and
parallelism, rather than connecting components at runtime.
