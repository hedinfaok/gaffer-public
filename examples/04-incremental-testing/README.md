# Incremental Testing with Intelligent Test Orchestration

This example demonstrates **gaffer-exec's advanced test orchestration capabilities** that go beyond traditional test runners like Jest, Cypress, and Playwright.

## Key Differentiators vs Alternatives

### gaffer-exec Advantages:
✓ **Advanced Retry Logic** - `--retry N` flag for intelligent retry handling
✓ **Merkle Tree Caching** - `--cache merkle` to skip unchanged test suites across runs
✓ **Auto-Detect Parallelization** - `-j auto` for optimal resource utilization
✓ **Dependency-Aware Test Ordering** - Unit → Integration → E2E sequencing in the Makefile task graph
✓ **Task Orchestration** - Coordinate multiple test tiers in a single Makefile task graph
✓ **Graceful Signal Handling** - `--signal-mode graceful` for proper cleanup
✓ **Test Result Aggregation** - Comprehensive metrics across all test tiers

### Vs Alternatives:
- **Jest**: Basic retry, no cross-run caching, limited parallelism control
- **Cypress**: Manual retry configuration, no intelligent orchestration layer
- **Playwright**: Better parallelism but no dependency graph + caching combined

## Real Open Source Project Pattern

This follows incremental testing patterns used by:
- **React** (Jest unit → integration → e2e with Playwright)
- **Angular** (Jasmine/Karma unit → Protractor e2e)
- **Vue.js** (Jest unit → Cypress e2e)
- **Node.js** (Mocha/Jest unit → supertest integration)

## Project Structure

```
04-incremental-testing/
├── src/
│   ├── lib/                 # Library code
│   ├── api/                 # API services
│   └── ui/                  # UI components
├── tests/
│   ├── unit/                # Unit tests (Jest)
│   ├── integration/         # Integration tests
│   ├── e2e/                 # End-to-end tests
│   └── flaky/               # Flaky test demonstrations
├── scripts/
│   ├── benchmark-tests.js   # Performance benchmarking
│   ├── aggregate-metrics.js # Test metrics aggregation
│   └── test-signal-handling.js # Graceful shutdown demo
├── package.json            # npm test configuration
├── jest.config.js          # Jest configuration
└── Makefile                # Test orchestration task graph (features via CLI flags)
```

## Test Dependency Graph

```
                    ┌──────────────────┐
                    │   unit-tests-lib │ (parallel with -j flag)
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │   unit-tests-api │ (parallel with -j flag)
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │   unit-tests-ui  │ (parallel with -j flag)
                    └────────┬─────────┘
                             │
                    ┌────────▼──────────┐
                    │ integration-tests │ (retry with --retry flag)
                    └────────┬──────────┘
                             │
                    ┌────────▼─────────┐
                    │    e2e-tests     │ (cached with --cache merkle)
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │     test-all     │ + metrics aggregation
                    └──────────────────┘
```

**Advanced Features (via CLI flags):**
- ✓ **Dependency ordering** defined in the Makefile ensures correct sequence
- ✓ **Parallel execution** with `-j auto` or `-j 4` for concurrent independent tests
- ✓ **Retry logic** with `--retry 3` for handling flaky tests
- ✓ **Merkle tree caching** with `--cache merkle` skips unchanged test suites
- ✓ **Graceful shutdown** with `--signal-mode graceful` ensures proper cleanup
- ✓ Flaky test demonstration scripts
- ✓ Performance benchmarking vs Jest/Cypress/Playwright

## How to Run

### Basic Test Execution

```bash
# Install test dependencies
npm install

# Run all tests with intelligent orchestration
gaffer-exec --workspace-root . run make:test-all

# Run with retry, caching, and parallelism
gaffer-exec --workspace-root . run --retry 3 --cache merkle -j auto make:test-all

# Run just unit tests with parallelism
gaffer-exec --workspace-root . run make:unit-tests-lib
gaffer-exec --workspace-root . run make:unit-tests-api
gaffer-exec --workspace-root . run make:unit-tests-ui
```

### Advanced Features via CLI Flags

**Retry Logic:**
```bash
# Retry failed tests up to 3 times (for flaky tests)
gaffer-exec --workspace-root . run --retry 3 make:test-all

# Demonstrate flaky test handling
gaffer-exec --workspace-root . run --retry 5 make:unit-tests-flaky
```

**Merkle Tree Caching:**
```bash
# First run (builds cache)
gaffer-exec --workspace-root . run --cache merkle make:test-all

# Second run (leverages cache - much faster!)
gaffer-exec --workspace-root . run --cache merkle make:test-all

# Modify a test file and see cache invalidation
touch tests/unit/lib.test.js
gaffer-exec --workspace-root . run --cache merkle make:test-all  # Re-runs only affected tests
```

**Parallelism Control:**
```bash
# Auto-detect optimal parallelism
gaffer-exec --workspace-root . run -j auto make:test-all

# Specify exact number of parallel jobs
gaffer-exec --workspace-root . run -j 4 make:test-all

# Check optimal concurrency for your machine
gaffer-exec detect-concurrency
```

**Combined Power:**
```bash
# Full-featured test run (recommended for CI)
gaffer-exec --workspace-root . run --retry 3 --cache merkle -j auto --signal-mode graceful make:test-all

# Performance benchmark vs alternatives
gaffer-exec --workspace-root . run make:performance-benchmark

# Test graceful signal handling (press Ctrl+C)
gaffer-exec --workspace-root . run --signal-mode graceful make:test-signal-handling
```

### Configuration Reference

**Available CLI Flags:**
- `--retry N` - Retry failed tests up to N times
- `--cache merkle` - Enable Merkle tree caching (also: `--cache sha256`)
- `-j N` or `-j auto` - Parallel jobs (auto-detect optimal concurrency)
- `--signal-mode graceful` - Graceful shutdown on interrupt
- `--on-failure continue|stop` - Failure handling mode
- `--cache-dir <path>` - Custom cache directory
- `--cache-backend <backend>` - Storage backend (local, s3, gs, azure)

See `gaffer-exec --help` for complete list.

## Expected Output

### Cache Optimization

**First run (cold cache):**
```
Running library unit tests...
Running API unit tests...
Running UI unit tests...
⏱  Total time: 5000ms
```

**Second run (warm cache - no changes):**
```
✓ unit-tests-lib (cached, skipped)
✓ unit-tests-api (cached, skipped)
✓ unit-tests-ui (cached, skipped)
↯ Total time: 100ms
↯ Cache speedup: Results vary based on cache effectiveness
```

### Retry Logic with Exponential Backoff

**Flaky test execution:**
```
Attempt 1: ✗ Failed (retrying in 1000ms...)
Attempt 2: ✗ Failed (retrying in 2000ms...)
Attempt 3: ✗ Failed (retrying in 4000ms...)
Attempt 4: ✓ Passed

Retry Statistics:
  Total attempts: 4
  Backoff strategy: Exponential (2.0x multiplier)
  Total delay: 7000ms
```

### Performance Metrics

```
TEST EXECUTION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Tests: 45
Passed: 45 (100%)
Failed: 0
Total Execution Time: 3245ms

CACHE PERFORMANCE:
Cache Hit Rate: 70.0%
Cache Hits: 7
Cache Misses: 3

↻  RETRY STATISTICS:
Total Retry Attempts: 3
Retry Strategy: Exponential backoff with 2.0x multiplier

CODE COVERAGE:
Lines: 85.2%
Statements: 84.8%
Functions: 90.1%
Branches: 78.3%
```

## Configuration Details

### Retry Configuration (CLI Flags)

Retry behavior is controlled at run time rather than in the Makefile:

```bash
gaffer-exec --workspace-root . run --retry 3 make:test-all
```

**Retry delays:**
- Attempt 1: Immediate
- Attempt 2: 500ms delay
- Attempt 3: 1000ms delay (500ms × 2.0)
- Attempt 4: 2000ms delay (1000ms × 2.0)
- Attempt 5: 4000ms delay (2000ms × 2.0, capped at max_delay_ms)

### Cache Optimization (Merkle Tree)

gaffer-exec hashes each target's inputs (the recipe and the files it reads) and
caches the outputs:

```bash
gaffer-exec --workspace-root . run --cache merkle make:test-all
```

**Cache behavior:**
- ✓ If inputs unchanged → skip execution, use cached outputs
- ✗ If inputs changed → re-run tests, update cache

### Resource-Aware Parallelization

Parallelism is controlled with the `-j` flag. Independent Makefile targets (for
example the three unit-test suites) run concurrently:

```bash
gaffer-exec --workspace-root . run -j auto make:test-all
```

**Auto-detection:**
- Detects available CPU cores
- Monitors memory usage
- Adjusts parallelism to prevent resource exhaustion

## Real Test Implementation

Each test suite uses industry-standard frameworks:
- **Jest** for unit and integration testing
- **Supertest** for API integration tests  
- **Playwright/Puppeteer** for e2e tests (simulated)
- **Istanbul/nyc** for coverage reporting

## Performance Benchmarks

Run `gaffer-exec --workspace-root . run make:performance-benchmark` to compare:

| Tool | Cold Run | Warm Run | Cache Hit Rate | Retry Logic |
|------|----------|----------|----------------|-------------|
| **gaffer-exec** | ~5000ms | Varies* | Up to 70% | ✓ Exponential backoff |
| Jest | ~4500ms | ~4500ms | 0% | ⚠ Basic (immediate retry) |
| Cypress | ~8000ms | ~8000ms | 0% | ⚠ Manual configuration |
| Playwright | ~6000ms | ~6000ms | 0% | ⚠ Manual configuration |

**Speedup: Cache effectiveness depends on actual file changes and test suite composition**
*Warm run performance varies from similar to cold run (minimal cache benefit) to significantly faster when many tests are cached.
```
