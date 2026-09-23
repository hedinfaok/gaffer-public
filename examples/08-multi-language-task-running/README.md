# Example 08: Multi-Language Task Running

Run one unified task graph across Node.js, Python, Go, and Rust with
`gaffer-exec`. A single top-level `Makefile` defines install, build, test, lint,
format, and clean targets for every language; `gaffer-exec` reads that Makefile,
then adds dependency-aware parallel scheduling and content-based caching on top.

## What you'll learn

- How one `Makefile` can be the single task graph for four language toolchains.
- How gaffer-exec schedules independent targets in parallel and caches unchanged
  work.
- How cross-language dependencies (`build-all` waits on all four builds) are
  expressed with plain Make targets.
- Which targets do real work and which are explicitly labelled simulations.

## Prerequisites

Install the toolchains you want to run:

- **Node.js** (with npm) — https://nodejs.org/
- **Python 3** (with pip3)
- **Go** — https://go.dev/dl/
- **Rust** — https://rustup.rs/

`install-all` installs the per-language dependencies (`npm ci`, pip
requirements, `go mod tidy`, `cargo fetch`).

## Quick start

```bash
cd examples/08-multi-language-task-running

# Install everything (parallel)
gaffer-exec --workspace-root . run make:install-all

# Build everything (parallel; real webpack/setuptools/go/cargo builds)
gaffer-exec --workspace-root . run make:build-all

# Run every test suite (real Jest/pytest/go test/cargo test)
gaffer-exec --workspace-root . run make:test-all
```

The same targets work with plain `make`, e.g. `make build-all`.

## Task graph

Each row is a target in the root `Makefile`, addressed as `make:<target>`.

| Group | Targets | Depends on |
|-------|---------|------------|
| Install | `install-node`, `install-python`, `install-go`, `install-rust` | — |
| | `install-all` | all four installs |
| Build | `build-node`, `build-python`, `build-go`, `build-rust` | matching install |
| | `build-all` | all four builds |
| Test | `test-node`, `test-python`, `test-go`, `test-rust` | matching install |
| | `test-all` | all four tests |
| Lint | `lint-node`, `lint-python`, `lint-go`, `lint-rust` | matching install |
| | `lint-all` | all four lints |
| Format | `format-node`, `format-python`, `format-go`, `format-rust` | matching install |
| | `format-all` | all four formats |
| Clean | `clean-node`, `clean-python`, `clean-go`, `clean-rust`, `clean` | — |
| Dev | `start-api`, `dev` | `install-go` / `build-all` |

## How it works

The root `Makefile` is the orchestration layer. Each language keeps its own
traditional config (`node-frontend/package.json`, `python-ml/Makefile`,
`go-api/build.sh`, `go-api/test.sh`) for a package-level view, but gaffer-exec
runs everything through the unified `make:<target>` interface.

Targets that only need their own language run in parallel; targets that depend
on several others wait for them. Wrap a run with `--cache sha256` to have
gaffer-exec skip targets whose inputs are unchanged.

### What is real vs simulated

| Target | Status |
|--------|--------|
| `build-node` | **Real** — runs webpack (`npm run build`) and emits `node-frontend/dist/bundle.js` |
| `build-python` | **Real** — `python3 setup.py build` |
| `build-go` | **Real** — `go build -o bin/api-server .` |
| `build-rust` | **Real** — `cargo build --release` |
| `test-node` | **Real** — runs Jest (`npm test`) against `src/App.test.js` |
| `test-python` | **Real** — runs pytest |
| `test-go` | **Real** — `go test ./...` with coverage |
| `test-rust` | **Real** — `cargo test` |
| `lint-node` | **Simulated** — prints `(simulated)` and a canned result |
| `format-node` | **Simulated** — prints `(simulated)` and a canned result |
| `lint-python`, `lint-rust` | Real tools invoked, but failures are tolerated (`|| true`) |
| `lint-go`, `format-python`, `format-go`, `format-rust` | Real tools |

The Node.js targets run real tools because the package lock was repaired to
install the missing `scheduler` dependency that `react-dom` needs; without it
webpack cannot bundle. The two Node.js lint/format targets remain simulated and
say so in their output.

## Expected output

`make:build-all` ends with `✓ All components built` and creates:

- `node-frontend/dist/bundle.js` (webpack)
- `python-ml/build/` (setuptools)
- `go-api/bin/api-server` (Go)
- `rust-cli/target/release/prediction-cli` (Rust)

`make:test-all` ends with `✓ All tests passed` after running the four real test
suites.

## Testing

```bash
bash test.sh
```

The script cleans, runs `install-all`, `build-all`, `test-all`, `lint-all`,
`format-all`, and `dev`, checks the build outputs exist, and verifies that
caching skips a re-run.

## Troubleshooting

- **`npm ci` fails** — Node.js/npm must be installed; the lockfile is
  self-contained and installs webpack, babel, and Jest.
- **webpack build fails** — run `make:install-node` first so `node_modules` is
  populated; the build needs babel and its React preset.
- **Python targets fail on import** — run `make:install-python`.
- **Rust/Go build is slow the first time** — dependencies are fetched by the
  install targets; later runs are cached.
- **A lint/format target reports a missing tool** — install that ecosystem's
  tooling; `lint-python`/`lint-rust` tolerate failures by design.

## Next example

Example 08 is about one unified task graph across the whole lifecycle.
[Example 03](../03-multi-language-build/) uses a smaller, build-focused graph
and then wires the compiled Rust, Go, Python, and Node artifacts together in a
real cross-language integration test. Choose 03 to see components
interoperating at runtime; choose 08 to see lifecycle task orchestration with
caching and parallelism.
