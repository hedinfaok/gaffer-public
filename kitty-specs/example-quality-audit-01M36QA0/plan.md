# Research Plan: Example quality audit

**Mission**: `example-quality-audit-01M36QA0`

## Method

Structured case study of the 10 examples plus repository-level docs. Each example
is scored on a 1–5 rubric; findings are clustered into themes and ranked by
impact/effort. Runnability facts are taken from mission
`verify-examples-01M36AAT` (documented in `docs/verify-examples-report.md`).

## Rubric

| Dimension | 1 | 3 | 5 |
|-----------|---|---|---|
| **Accuracy** | Docs/code contradict reality | Minor overclaims | Docs match behavior exactly |
| **Runnability** | Does not run | Runs with fixing/blockers | Runs clean end-to-end |
| **Teaching value** | Toy / canned output | Illustrative but thin | Teaches a real, recognizable workflow |
| **Docs** | Missing/inconsistent | Adequate | Clear, consistent, well-structured |

## Evidence sources

- `examples/*/README.md`, `Makefile`, `test.sh`, source layout.
- `docs/verify-examples-report.md` (prior end-to-end verification, gaffer 0.8.0).
- `README.md` (root).
- CLI surface: `gaffer-exec --help` (0.8.0).

## Analysis steps

1. Inventory each example (files, LOC, README length, targets, tests).
2. Grep for simulation/overclaim signals; confirm against code.
3. Score each example on the rubric with cited evidence.
4. Cluster into themes (accuracy, coverage, pedagogy, docs).
5. Propose improvements and new examples; rank by impact/effort.
6. Communicator (`comms-cleo`) docs review with concrete rewrites.

## Limitations

- Runnability scores reflect one machine (macOS) and one CLI version (0.8.0).
- "Teaching value" is a judgement grounded in the code's realism, not user testing.
