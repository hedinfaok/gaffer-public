# CI with GitHub Actions

What this shows: a tiny Node project whose build and test graph runs in GitHub Actions, with the build outputs restored from cache so unchanged commits skip the build.

Vs [02-distributed-build](../02-distributed-build/README.md): this example wires gaffer-exec into a real CI provider and uses the provider's cache storage; 02 shows the remote cache get/set mechanics against S3, Azure, and GCS.

## What you'll learn

- Generating a workflow from a graph with `gaffer-exec export --format github-actions`.
- Caching task outputs with `--cache sha256` so an unchanged build is a cache hit.
- Restoring and saving `.gaffer/cache` around the run with `actions/cache`.
- The `GAFFER_CACHE_KEY` and `GAFFER_CACHE_ARTIFACT` variables gaffer injects into cached tasks.
- Installing gaffer-exec from its attested releases with a verified checksum.

## Prerequisites

- gaffer-exec 0.8.0 on your PATH
- Node.js 18 or later and npm
- GNU make
- A GitHub repository, to run the workflow

## Quick start

```bash
# Run the whole pipeline locally: install, build, test
gaffer-exec --workspace-root . run make:ci

# Run the build with caching, twice. The second run restores dist/ from cache.
gaffer-exec --workspace-root . run --cache sha256 make:build
rm -rf dist node_modules
gaffer-exec --workspace-root . run --cache sha256 make:build

# Regenerate the GitHub Actions workflow that gaffer-exec ships for this graph
gaffer-exec --workspace-root . export make:build --format github-actions
```

`export` writes `.gaffer/exports/make-build.yml` and prints where it landed. The committed workflow in this example is `.github/workflows/gaffer-ci.yml`.

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `install` | - | Installs dependencies from `package-lock.json` with `npm ci` |
| `build` | `install` | Compiles `src/` into the `dist/` artifact (`dist/index.js`, `dist/math.js`, `dist/build-info.json`) |
| `test` | `install` | Runs the unit tests with `node --test` |
| `ci` | `install`, `build`, `test` | Full pipeline (default goal) |
| `clean` | - | Removes `dist/` and `node_modules/` |

## How it works

The workflow is a copy of gaffer-exec's own `export` output, adapted for caching:

```text
checkout ──► setup-node ──► install gaffer-exec (v0.8.0, checksum verified)
                                   │
                    restore .gaffer/cache  (actions/cache/restore)
                                   │
              gaffer-exec run --cache sha256 make:build
                                   │
                    save .gaffer/cache     (actions/cache/save)
                                   │
              gaffer-exec run make:test
```

The export command is the starting point:

```bash
gaffer-exec --workspace-root . export make:build --format github-actions
```

It writes a workflow that detects the runner platform, downloads the matching `gaffer-exec-<platform>-<arch>` release, caches `.gaffer`, and runs `gaffer-exec run make:build`. The committed workflow keeps that structure and makes three changes: it pins gaffer-exec to the `apps-gaffer-exec-v0.8.0` release and verifies the published `.sha256` before extracting; it sets up Node so `make:install` has a toolchain; and it restores and saves only `.gaffer/cache` with a key derived from the source inputs.

Pattern: let gaffer-exec own the task graph and its content hashing, and let the CI provider own durable storage. The cache key is:

```text
gaffer-<runner os>-<hash of package.json, package-lock.json, Makefile, src/**, scripts/**>
```

`actions/cache/restore` runs before the build, so gaffer-exec finds a warm `.gaffer/cache`; `actions/cache/save` runs after, so the next workflow run starts warm. Because the key hashes the inputs gaffer itself hashes, a source change produces a new key and a clean build, while an unchanged commit restores the previous outputs.

### The injected cache variables

When `--cache` is active, gaffer-exec injects two variables into every task:

- `GAFFER_CACHE_KEY`: the hex SHA-256 of the task's inputs (command plus source files). Use it to name a remote cache entry.
- `GAFFER_CACHE_ARTIFACT`: the path to the task's cached artifact when there is a local hit, or an empty string on a miss.

These are the variables a restore/save graph reads when you drive a remote cache through `--cache-get-remote <graph>` and `--cache-set-remote <graph>`. On gaffer-exec 0.8.0 those two flags parse and validate the named graphs, but the hooks are not invoked for Makefile-derived graphs (verified locally: only the cached task ran, and neither the restore nor the save graph appeared in the history). This example therefore restores and saves `.gaffer/cache` with `actions/cache` around the run, which works today and keeps the workflow portable. The `GAFFER_CACHE_KEY`/`GAFFER_CACHE_ARTIFACT` contract is still the right seam to build on; [22-remote-cache-s3](../22-remote-cache-s3/README.md) is the real remote-cache example.

## Expected output

`export` writes the workflow and tells you where it landed:

```text
Exported graph 'make:build' to: ./.gaffer/exports/make-build.yml

Copy to .github/workflows/ and commit to trigger CI.
Example: cp ./.gaffer/exports/make-build.yml .github/workflows/ci.yml
```

A cached build on a warm `.gaffer/cache` restores `dist/` instead of recompiling:

```text
→ make:install
→ make:build
[make:build] Cache hit: 73c08da09cdfc38e (artifacts restored)
✓ make:build
✓ make:install
```

A cold build compiles the sources:

```text
→ make:install
→ make:build
[make:build] built dist/index.js, dist/math.js, dist/build-info.json
✓ make:build
✓ make:install
```

The cache keys and hit rate in CI depend on which inputs changed; the hashes above are from a local run and are illustrative.

## Testing

```bash
cd examples/21-ci-github-actions
bash test.sh
```

The suite verifies the fixture and Makefile wiring, dry-runs `make:build`, `make:test`, and `make:ci`, checks the committed workflow, and confirms that `gaffer-exec export make:build --format github-actions` succeeds and writes a workflow that runs the graph. It skips the gaffer-exec checks gracefully when the binary is not on PATH.

## Troubleshooting

- **`gaffer-exec: command not found`**: install gaffer-exec 0.8.0 and put it on your PATH; the workflow installs it from the attested releases.
- **Build never hits the cache**: gaffer hashes the workspace, and the `dist/` output changes the key. A cache hit appears on the run after the outputs first exist, and in CI on the second workflow run, because each run checks out a clean tree.
- **Checksum verification fails**: the pinned `GAFFER_RELEASE` tag and the downloaded asset must match. Confirm the tag still exists under the repository's releases and that `sha256sum --check` is reading the matching `<asset>.sha256` file.
- **`npm ci` fails**: the committed `package-lock.json` must stay in sync with `package.json`; run `npm install --package-lock-only` after editing dependencies.

## Next example

[22-remote-cache-s3](../22-remote-cache-s3/README.md) moves the cache out of the CI provider and into a real S3-compatible remote cache.
