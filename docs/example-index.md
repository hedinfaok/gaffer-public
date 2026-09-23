# Example index

This page maps each gaffer-exec feature to the examples that demonstrate it, and
gives a one-line description of every example. Links are relative to this
directory. For orientation, start with
[01-monorepo-build](../examples/01-monorepo-build/).

## Feature to example

| Feature | Examples |
|---------|----------|
| Parallel scheduling | [01](../examples/01-monorepo-build/), [03](../examples/03-multi-language-build/), [04](../examples/04-incremental-testing/), [05](../examples/05-ml-workflows/), [06](../examples/06-local-dev-environment/), [08](../examples/08-multi-language-task-running/) |
| Content-based caching | [01](../examples/01-monorepo-build/), [02](../examples/02-distributed-build/), [04](../examples/04-incremental-testing/), [08](../examples/08-multi-language-task-running/) |
| Incremental / affected-only runs | [01](../examples/01-monorepo-build/), [04](../examples/04-incremental-testing/), [05](../examples/05-ml-workflows/), [07](../examples/07-watch-workflows/), [20](../examples/20-affected-ci/) |
| Watch mode | [07](../examples/07-watch-workflows/) |
| Remote / multi-region cache | [02](../examples/02-distributed-build/), [18](../examples/18-network-aware-builds/) |
| Cross-platform builds | [19](../examples/19-cross-platform-builds/) |
| Multi-language orchestration | [03](../examples/03-multi-language-build/), [08](../examples/08-multi-language-task-running/) |
| Alternate manifests (Makefile, npm, Cargo) | [01](../examples/01-monorepo-build/), [08](../examples/08-multi-language-task-running/) |
| Alternate manifests (Taskfile, justfile) | [23](../examples/23-alternate-manifests/) |
| Onboarding (first example) | [00](../examples/00-hello-gaffer/) |
| CI export + caching | [21](../examples/21-ci-github-actions/) |
| Remote cache (real round-trip) | [22](../examples/22-remote-cache-s3/) |
| Container build graphs | [24](../examples/24-docker-build-graph/) |
| All manifest types (incl. Procfile) + auto ports | [25](../examples/25-all-manifests-devstack/) |

## Examples

| Example | What it demonstrates |
|---------|----------------------|
| [01-monorepo-build](../examples/01-monorepo-build/) | A real TypeScript monorepo where independent packages build in parallel, with content-based caching and incremental rebuilds. |
| [02-distributed-build](../examples/02-distributed-build/) | A Go microservices project that stores build artifacts in remote cloud backends (S3, Azure Blob Storage, Google Cloud Storage) running locally in Docker. |
| [03-multi-language-build](../examples/03-multi-language-build/) | Builds a Rust backend, Go CLI, Node.js frontend, and Python module from a single dependency graph. |
| [04-incremental-testing](../examples/04-incremental-testing/) | Orchestrates unit, integration, and end-to-end test tiers with retry logic, caching, and dependency-aware ordering. |
| [05-ml-workflows](../examples/05-ml-workflows/) | Runs a machine-learning pipeline (data prep, feature engineering, training, evaluation, reporting) as dependent targets. |
| [06-local-dev-environment](../examples/06-local-dev-environment/) | Brings up a full local stack (PostgreSQL, Express API, React frontend) with automatic port assignment and health checks. |
| [07-watch-workflows](../examples/07-watch-workflows/) | Uses `fswatch` to detect changes and gaffer-exec to run dependency-aware cascading rebuilds across services. |
| [08-multi-language-task-running](../examples/08-multi-language-task-running/) | Defines one Makefile task graph for Node.js, Python, Go, and Rust, adding caching and parallel scheduling on top. |
| [18-network-aware-builds](../examples/18-network-aware-builds/) | Explores multi-region cache selection, network topology detection, and bandwidth-aware transfer; simulated transfer paths are labelled as such. |
| [19-cross-platform-builds](../examples/19-cross-platform-builds/) | Uses shell platform detection in a Makefile so only the target matching the host platform builds, across Linux, macOS, and Windows. |

| [00-hello-gaffer](../examples/00-hello-gaffer/) | The smallest working example: two independent tasks plus an aggregate, showing parallel scheduling and a cache hit. |
| [20-affected-ci](../examples/20-affected-ci/) | Selects only the affected targets (and their dependents) with `--affected`/`--since` on a small monorepo fixture. |
| [21-ci-github-actions](../examples/21-ci-github-actions/) | Runs a build in GitHub Actions with `export --format github-actions` and a cache restore/save strategy. |
| [22-remote-cache-s3](../examples/22-remote-cache-s3/) | Performs a real remote-cache round-trip against MinIO using the cache key/artifact contract. |
| [23-alternate-manifests](../examples/23-alternate-manifests/) | Shows gaffer-exec discovering and running a `Taskfile.yml` and a `justfile`. |
| [24-docker-build-graph](../examples/24-docker-build-graph/) | Builds two container images as a parallel graph with a dependency edge. |

| [25-all-manifests-devstack](../examples/25-all-manifests-devstack/) | A local-dev web stack where every manifest type participates (Make, npm, turbo, Cargo, Python, Procfile, Taskfile, just, script, Bazel), with Procfile processes receiving auto-assigned ports. |

## Related examples

- [03-multi-language-build](../examples/03-multi-language-build/) and
  [08-multi-language-task-running](../examples/08-multi-language-task-running/)
  both span several languages. 03 focuses on **building** four language
  toolchains from one graph; 08 focuses on **running tasks** (install, build,
  test, lint, format) across languages from a single manifest.
- [02-distributed-build](../examples/02-distributed-build/) and
  [18-network-aware-builds](../examples/18-network-aware-builds/) both cache
  artifacts remotely. 02 uses real cloud storage backends in Docker; 18 explores
  network topology and multi-region behaviour, with some paths simulated.
