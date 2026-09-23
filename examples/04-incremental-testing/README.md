# Incremental Testing

What this shows: orchestrating a unit to integration to end-to-end test suite with gaffer-exec, adding dependency-aware ordering, retries, parallelism, and cross-run caching on top of a standard test setup.

## What you'll learn

- Dependency-aware test ordering: unit suites feed integration, which feeds end-to-end.
- Retry logic with `--retry N` and exponential backoff for flaky tests.
- Merkle-tree caching with `--cache merkle` to skip unchanged suites across runs.
- Resource-aware parallelism with `-j auto` or a fixed `-j N`.
- Graceful shutdown with `--signal-mode graceful`.

## Prerequisites

- Node.js 18 or later
- npm
- gaffer-exec on your PATH

## Quick start

```bash
# Install test dependencies
npm install

# Run the full suite with dependency-aware orchestration
gaffer-exec --workspace-root . run make:test-all

# Full-featured run with retries, caching, and parallelism
gaffer-exec --workspace-root . run --retry 3 --cache merkle -j auto make:test-all
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `clean` | - | Removes coverage and cache output |
| `install` | `clean` | Runs `npm install` |
| `lint` | `install` | Runs linting checks |
| `unit-tests-lib` | `install` | Library unit tests (`npm run test:lib`) |
| `unit-tests-api` | `install` | API unit tests (`npm run test:api`) |
| `unit-tests-ui` | `install` | UI unit tests (`npm run test:ui`) |
| `unit-tests-flaky` | `install` | Flaky suite used to demonstrate retries |
| `integration-tests` | `unit-tests-lib`, `unit-tests-api` | Integration tests |
| `e2e-tests` | `integration-tests`, `unit-tests-ui` | End-to-end tests |
| `coverage-report` | `unit-tests-lib`, `unit-tests-api`, `unit-tests-ui` | Aggregated coverage |
| `performance-benchmark` | `install` | Benchmarks against alternatives |
| `test-all` | `e2e-tests`, `coverage-report`, `lint` | Full suite plus metrics (default goal) |
| `test-all-with-flaky` | `test-all`, `unit-tests-flaky` | Full suite plus the flaky demo |
| `test-ci` | `test-all`, `performance-benchmark` | CI pipeline |
| `test-watch` | `install` | Watch mode demo |
| `test-debug` | `install` | Verbose debug run |
| `test-signal-handling` | `install` | Graceful interrupt demo |

## How it works

```
unit-tests-lib ┐
unit-tests-api ┤─> integration-tests ─> e2e-tests ┐
unit-tests-ui  ┘                                  ├─> test-all
coverage-report <──────────────────────────────────┘
lint <─────────────────────────────────────────────┘
```

Pattern: this is the standard unit, integration, e2e pyramid, expressed as Make prerequisites. Independent unit suites run concurrently; `test-all` waits for the tiers below it.

Feature flags are passed at run time rather than baked into the Makefile:

```bash
gaffer-exec --workspace-root . run --retry 3 make:test-all
gaffer-exec --workspace-root . run --cache merkle make:test-all
gaffer-exec --workspace-root . run -j auto make:test-all
```

`--retry N` retries failures with exponential backoff; `--cache merkle` hashes each target's inputs and restores cached outputs when they are unchanged; `-j auto` picks a concurrency level from the available CPU cores.

## Expected output

Cold run:

```text
Running library unit tests...
Running API unit tests...
Running UI unit tests...
⏱  Total time: 5000ms
```

Warm run (no changes):

```text
✓ unit-tests-lib (cached, skipped)
✓ unit-tests-api (cached, skipped)
✓ unit-tests-ui (cached, skipped)
↯ Total time: 100ms
```

Flaky retry demonstration:

```text
Attempt 1: ✗ Failed (retrying in 1000ms...)
Attempt 2: ✗ Failed (retrying in 2000ms...)
Attempt 3: ✗ Failed (retrying in 4000ms...)
Attempt 4: ✓ Passed

Retry Statistics:
  Total attempts: 4
  Backoff strategy: Exponential (2.0x multiplier)
```

The millisecond figures above are from a local run (illustrative, not a benchmark); actual cache benefit depends on which suites changed.

## Testing

```bash
./test.sh
```

The suite verifies target wiring and runs the pipeline. `./demo.sh` walks through the retry, cache, and parallelism flags individually. To compare against other runners:

```bash
gaffer-exec --workspace-root . run make:performance-benchmark
```

The benchmark table it prints uses local timings (illustrative, not a benchmark):

| Tool | Cold run | Warm run | Retry logic |
|------|----------|----------|-------------|
| gaffer-exec | ~5000ms | varies with cache hits | Exponential backoff |
| Jest | ~4500ms | ~4500ms | Basic |
| Cypress | ~8000ms | ~8000ms | Manual configuration |
| Playwright | ~6000ms | ~6000ms | Manual configuration |

## Troubleshooting

- **Tests fail on the first run**: run `npm install` first; the `install` target does this automatically as a prerequisite.
- **Flaky suite keeps failing**: raise the retry count, for example `gaffer-exec --workspace-root . run --retry 5 make:unit-tests-flaky`.
- **Cache never hits**: confirm you pass `--cache merkle`, and remember that editing a test file invalidates its cached result.
- **Too much parallelism**: replace `-j auto` with a fixed `-j 2` or `-j 4`.

## Next example

[05-ml-workflows](../05-ml-workflows/README.md) applies the same staged-orchestration idea to a machine learning pipeline.
