# Incremental Testing with Intelligent Test Orchestration

This example demonstrates **gaffer-exec's advanced test orchestration capabilities** that go beyond traditional test runners like Jest, Cypress, and Playwright.

## 🎯 Key Differentiators vs Alternatives

### gaffer-exec Advantages:
✅ **Dependency-Aware Test Ordering** - Unit → Integration → E2E sequencing
✅ **Task Orchestration** - Coordinate multiple test tiers in a single graph
✅ **Parallel Execution** - Run independent test suites concurrently
✅ **Build Optimization** - Skip unnecessary rebuilds when dependencies haven't changed
✅ **Test Result Aggregation** - Comprehensive metrics across all test tiers

### Vs Alternatives:
- **Jest**: Runs tests in isolation, no orchestration across test tiers
- **Cypress**: E2E only, requires separate orchestration for unit/integration tests
- **Playwright**: Better parallelism but no dependency graph orchestration

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
└── graph.json              # gaffer-exec test orchestration with dependency graph
```

## Test Dependency Graph

```
                    ┌──────────────────┐
                    │   unit-tests-lib │ (runs after install)
                    └──────────────────┘
                             
                    ┌──────────────────┐
                    │   unit-tests-api │ (runs after install)
                    └────────┬─────────┘
                             │
                    ┌────────▼──────────┐
                    │ integration-tests │ (depends on lib + api)
                    └────────┬──────────┘
                             
                    ┌──────────────────┐
                    │   unit-tests-ui  │ (runs after install)
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │    e2e-tests     │ (depends on integration + ui)
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │     test-all     │ + metrics aggregation
                    └──────────────────┘
```

**Key Features:**
- ✅ **Dependency ordering** ensures tests run in the correct sequence
- ✅ **Parallel execution** of independent test suites (lib, api, ui run concurrently)
- ✅ Integration tests wait for all unit tests (proper test tier progression)
- ✅ E2E tests run only after integration passes (failure isolation)
- ✅ Flaky test demonstration with retry logic
- ✅ Performance benchmarking vs Jest/Cypress/Playwright
- ✅ Graceful signal handling with proper cleanup

## How to Run

### Basic Test Execution

```bash
# Install test dependencies
npm install

# Run all tests with intelligent orchestration
gaffer-exec run test-all --graph graph.json

# Run just unit tests (exploits parallelism)
gaffer-exec run unit-tests-lib unit-tests-api unit-tests-ui --graph graph.json
```

### Advanced Features

```bash
# Demonstrate flaky test retry with exponential backoff
gaffer-exec run unit-tests-flaky --graph graph.json
# Expected: Fails 2-3 times, then succeeds with exponential backoff delays

# Run with cache demonstration (2nd run is much faster)
gaffer-exec run test-all --graph graph.json  # Cold run
gaffer-exec run test-all --graph graph.json  # Warm run (cached)

# Performance benchmark vs alternatives
gaffer-exec run performance-benchmark --graph graph.json

# Test graceful signal handling (press Ctrl+C)
gaffer-exec run test-signal-handling --graph graph.json

# Full CI pipeline with all features
gaffer-exec run test-ci --graph graph.json
```

### Retry Configuration Examples

```bash
# Override retry configuration at runtime
gaffer-exec run e2e-tests --graph graph.json --retry 10

# Run with specific parallelism
gaffer-exec run unit-tests-lib --graph graph.json --parallel 8
```

## Expected Output

### Cache Optimization

**First run (cold cache):**
```
🧪 Running library unit tests...
🧪 Running API unit tests...
🧪 Running UI unit tests...
⏱️  Total time: 5000ms
```

**Second run (warm cache - no changes):**
```
✅ unit-tests-lib (cached, skipped)
✅ unit-tests-api (cached, skipped)
✅ unit-tests-ui (cached, skipped)
⚡ Total time: 100ms
⚡ Cache speedup: Results vary based on cache effectiveness
```

### Retry Logic with Exponential Backoff

**Flaky test execution:**
```
Attempt 1: ❌ Failed (retrying in 1000ms...)
Attempt 2: ❌ Failed (retrying in 2000ms...)
Attempt 3: ❌ Failed (retrying in 4000ms...)
Attempt 4: ✅ Passed

📊 Retry Statistics:
  Total attempts: 4
  Backoff strategy: Exponential (2.0x multiplier)
  Total delay: 7000ms
```

### Performance Metrics

```
📊 TEST EXECUTION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Tests: 45
Passed: 45 (100%)
Failed: 0
Total Execution Time: 3245ms

🔄 CACHE PERFORMANCE:
Cache Hit Rate: 70.0%
Cache Hits: 7
Cache Misses: 3

♻️  RETRY STATISTICS:
Total Retry Attempts: 3
Retry Strategy: Exponential backoff with 2.0x multiplier

📊 CODE COVERAGE:
Lines: 85.2%
Statements: 84.8%
Functions: 90.1%
Branches: 78.3%
```

## Configuration Details

### Retry Configuration (graph.json)

```json
{
  "unit-tests-lib": {
    "retry": {
      "max_attempts": 3,
      "initial_delay_ms": 500,
      "max_delay_ms": 5000,
      "backoff_multiplier": 2.0
    }
  }
}
```

**Retry delays:**
- Attempt 1: Immediate
- Attempt 2: 500ms delay
- Attempt 3: 1000ms delay (500ms × 2.0)
- Attempt 4: 2000ms delay (1000ms × 2.0)
- Attempt 5: 4000ms delay (2000ms × 2.0, capped at max_delay_ms)

### Cache Optimization (Merkle Tree)

Tests are cached based on input file hashes:
```json
{
  "unit-tests-lib": {
    "inputs": ["src/lib/**/*.js", "tests/unit/lib/**/*.test.js"],
    "outputs": ["coverage/lib/**"]
  }
}
```

**Cache behavior:**
- ✅ If inputs unchanged → skip execution, use cached outputs
- ❌ If inputs changed → re-run tests, update cache

### Resource-Aware Parallelization

```json
{
  "unit-tests-lib": {
    "parallelism": {
      "max_parallel": 4,
      "memory_limit_mb": 512
    }
  }
}
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

Run `gaffer-exec run performance-benchmark --graph graph.json` to compare:

| Tool | Cold Run | Warm Run | Cache Hit Rate | Retry Logic |
|------|----------|----------|----------------|-------------|
| **gaffer-exec** | ~5000ms | Varies* | Up to 70% | ✅ Exponential backoff |
| Jest | ~4500ms | ~4500ms | 0% | ⚠️ Basic (immediate retry) |
| Cypress | ~8000ms | ~8000ms | 0% | ⚠️ Manual configuration |
| Playwright | ~6000ms | ~6000ms | 0% | ⚠️ Manual configuration |

**Speedup: Cache effectiveness depends on actual file changes and test suite composition**
*Warm run performance varies from similar to cold run (minimal cache benefit) to significantly faster when many tests are cached.
```
