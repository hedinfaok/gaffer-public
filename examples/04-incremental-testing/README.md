# Incremental Testing

This example demonstrates **real incremental testing** across multiple test types and frameworks, similar to patterns used in large open source projects.

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
│   └── e2e/                 # End-to-end tests
├── package.json            # npm test configuration
├── jest.config.js          # Jest configuration
├── graph.json              # gaffer-exec test orchestration
└── coverage/               # Test coverage reports
```

## Test Dependency Graph

```
unit-tests-lib ────────────────────────────┐
unit-tests-api ────────────────────────────┤
unit-tests-ui ─────────────────────────────┼──> integration-tests ──> e2e-tests ──> test-all
                                           │                                               │
coverage-report ───────────────────────────┘                                       generate-report
```

**Key Features:**
- Unit tests run in parallel (no dependencies)
- Integration tests wait for all unit tests
- E2E tests run only after integration passes
- Coverage collected across all test types
- Real test frameworks (Jest, Supertest, etc.)

## How to Run

```bash
# Install test dependencies
npm install

# Run all tests incrementally  
gaffer-exec run test-all --graph graph.json

# Run just unit tests (in parallel)
gaffer-exec run unit-tests-lib unit-tests-api unit-tests-ui --graph graph.json

# Run with retry on failure
gaffer-exec run test-all --graph graph.json --retry 3

# Generate coverage report
gaffer-exec run coverage-report --graph graph.json
```

## Expected Output

**Incremental test execution:**
- Unit tests: lib, api, ui run in parallel
- Integration tests: wait for all unit tests to pass
- E2E tests: run only if integration passes
- Coverage report: aggregates results from all test types

## Real Test Implementation

Each test suite uses industry-standard frameworks:
- **Jest** for unit and integration testing
- **Supertest** for API integration tests  
- **Playwright/Puppeteer** for e2e tests
- **Istanbul/nyc** for coverage reporting
```
