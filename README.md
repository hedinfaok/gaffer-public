# gaffer-exec Examples

This repository is a set of worked examples for **gaffer-exec**, a build
orchestration tool. Each example is a small, runnable project that shows one
capability in a realistic setting. They are written for developers evaluating
gaffer-exec or looking for patterns to adapt in their own repositories.

If you are new here, start with [01-monorepo-build](examples/01-monorepo-build/)
and work outward. The [example index](docs/example-index.md) maps every feature
to the examples that demonstrate it.

## What these examples show

- Parallel, dependency-aware scheduling of build and test targets.
- Content-based caching that skips work when inputs have not changed.
- Incremental and affected-only runs, including per-tier test orchestration.
- Multi-language builds and tasks coordinated from one manifest.
- Remote, multi-region, watch, and cross-platform build workflows.

## Feature to example

| Feature | Examples |
|---------|----------|
| Parallel scheduling | [01](examples/01-monorepo-build/), [03](examples/03-multi-language-build/), [04](examples/04-incremental-testing/), [05](examples/05-ml-workflows/), [06](examples/06-local-dev-environment/), [08](examples/08-multi-language-task-running/) |
| Content-based caching | [01](examples/01-monorepo-build/), [02](examples/02-distributed-build/), [04](examples/04-incremental-testing/), [08](examples/08-multi-language-task-running/) |
| Incremental / affected-only | [01](examples/01-monorepo-build/), [04](examples/04-incremental-testing/), [05](examples/05-ml-workflows/), [07](examples/07-watch-workflows/), [20](examples/20-affected-ci/) |
| Watch mode | [07](examples/07-watch-workflows/) |
| Remote / multi-region cache | [02](examples/02-distributed-build/), [18](examples/18-network-aware-builds/) |
| Cross-platform builds | [19](examples/19-cross-platform-builds/) |
| Multi-language orchestration | [03](examples/03-multi-language-build/), [08](examples/08-multi-language-task-running/) |
| Alternate manifests (Makefile, npm, Cargo) | [01](examples/01-monorepo-build/), [08](examples/08-multi-language-task-running/) |
| Onboarding (first example) | [00](examples/00-hello-gaffer/) |
| CI export + caching | [21](examples/21-ci-github-actions/) |
| Remote cache (real round-trip) | [22](examples/22-remote-cache-s3/) |
| Alternate manifests (Taskfile, justfile) | [23](examples/23-alternate-manifests/) |
| Container build graphs | [24](examples/24-docker-build-graph/) |

For per-example descriptions and longer notes, see
[docs/example-index.md](docs/example-index.md).

## Getting started

1. Install gaffer-exec 0.8.0. See the [gaffer-exec repository](https://github.com/hedinfaok/gaffer)
   for installation instructions.
2. Clone this repository and enter the example you want to run:
   ```bash
   git clone https://github.com/hedinfaok/gaffer-public.git
   cd gaffer-public/examples/01-monorepo-build
   ```
3. Follow that example's `README.md` for prerequisites, commands, and expected
   output. Most examples build and run with:
   ```bash
   gaffer-exec --workspace-root . run make:<target>
   ```

Each example documents its own prerequisites and verification steps. The
[example index](docs/example-index.md) is the fastest way to find the example
that matches what you want to do.

## Provenance and limitations

These examples were generated with Large Language Model (LLM) assistance as part
of exploring automated software development workflows. This disclosure applies
only to the examples, not to the tool.

- gaffer-exec itself is real, production-quality software (private source).
  Official releases are attested by GitHub and available in this repository.
- The examples are synthesized starting points, not production-ready code.
  They may contain implementation gaps, and some components use mock services or
  simplified logic for demonstration.
- Performance figures are illustrative, not measured benchmarks, unless an
  example explicitly says otherwise.
- Test thoroughly and verify claims against your environment before adapting
  any example for real use.
