# Remote Cache with MinIO

What this shows: a real (not simulated) remote cache round-trip. gaffer-exec runs a cached build while a restore hook pulls the artifact from MinIO before the task and a save hook pushes it back after the task succeeds, keyed by a content hash of the task inputs.

Vs [02-distributed-build](../02-distributed-build/README.md): that example fetches and uploads artifacts from inside the build recipes themselves. This one uses gaffer-exec's built-in `--cache-get-remote`/`--cache-set-remote` hook graphs and the `GAFFER_CACHE_KEY`/`GAFFER_CACHE_ARTIFACT` variables it injects.

## What you'll learn

- The `GAFFER_CACHE_KEY` and `GAFFER_CACHE_ARTIFACT` contract gaffer-exec injects into hook graphs when `--cache` is active.
- Wiring `--cache-get-remote` and `--cache-set-remote` to real S3-compatible storage (MinIO).
- Why a content-addressed key makes a shared remote cache work: the same source tree produces the same key on every machine.
- Degrading gracefully when Docker, MinIO, or an S3 client is unavailable.

## Prerequisites

- gaffer-exec 0.8.0 on your PATH.
- Docker Desktop (or Docker Engine with Compose).
- One S3 client on the host: `mc` (MinIO client) or `aws` (AWS CLI). If neither is installed, the scripts fall back to running `quay.io/minio/mc` in a container, so only Docker is strictly required.

## Quick start

```bash
# 1. Start MinIO and create the gaffer-cache bucket
docker compose up -d

# 2. First run: local and remote miss, build, then upload
gaffer-exec --workspace-root . run --cache sha256 \
  --cache-get-remote script:scripts:restore \
  --cache-set-remote script:scripts:save \
  make:build

# 3. Clear the local cache and rebuild: the artifact now comes from MinIO
rm -rf .gaffer dist
gaffer-exec --workspace-root . run --cache sha256 \
  --cache-get-remote script:scripts:restore \
  --cache-set-remote script:scripts:save \
  make:build

# 4. Inspect the bucket (mc or aws)
mc alias set gaffer http://localhost:9000 minioadmin minioadmin
mc ls gaffer/gaffer-cache
# or:
AWS_ACCESS_KEY_ID=minioadmin AWS_SECRET_ACCESS_KEY=minioadmin \
  aws --endpoint-url http://localhost:9000 s3 ls s3://gaffer-cache/
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `build` | - | Writes a deterministic artifact to `dist/` (default goal) |
| `cache-restore` | - | Calls `scripts/restore.sh` (Makefile-native restore hook) |
| `cache-save` | - | Calls `scripts/save.sh` (Makefile-native save hook) |
| `clean` | - | Removes `dist/` |

The executable scripts under `scripts/` are also discovered by gaffer-exec as atomic graphs (`script:scripts:restore`, `script:scripts:save`).

## How it works

```
   clean tree ──▶ gaffer-exec --cache sha256
                        │
        compute GAFFER_CACHE_KEY (hex sha256 of task inputs)
                        │
            ┌───────────┴────────────┐
            ▼                        ▼
   cache-get-remote          cache-set-remote
   scripts/restore.sh        scripts/save.sh
   (runs before the task)    (runs after success)
            │                        │
      object exists?            tar dist/ and
       ┌────┴────┐              upload to MinIO
       ▼         ▼                    │
   download    miss                  │
   + extract   (build runs)          │
       │                             │
       └──────────▶ make:build ◀─────┘
```

gaffer-exec injects two variables into every hook task when `--cache` is active:

| Variable | Meaning |
|----------|---------|
| `GAFFER_CACHE_KEY` | Hex sha256 of the task inputs (command plus source files). It is the remote object key. |
| `GAFFER_CACHE_ARTIFACT` | Absolute path to `.gaffer/cache/<key>.tar.gz` when a local cache hit exists, empty on a miss. |

`scripts/restore.sh` runs before the task. On a miss it derives the path from the key, checks MinIO for `gaffer-cache/<key>.tar.gz`, downloads it, and extracts it into the workspace. `scripts/save.sh` runs after the task succeeds and uploads the artifact under the same key. Because the key depends only on the source tree, a fresh clone on another machine computes the same key and gets a remote hit.

### Makefile-native hook names and the 0.8.0 caveat

The equivalent Makefile-native command is:

```bash
gaffer-exec --workspace-root . run --cache sha256 \
  --cache-get-remote make:cache-restore \
  --cache-set-remote make:cache-save \
  make:build
```

In gaffer-exec 0.8.0, Makefile targets are discovered as *composite* graphs, and only *atomic* hook graphs are executed. A composite hook graph is accepted by the argument parser but silently skipped at runtime, so the `make:cache-restore`/`make:cache-save` form does not fire. This example therefore ships the hooks as executable scripts, which gaffer-exec discovers atomically, and the Makefile targets call the same scripts so both entry points stay in sync. The commands above use the working `script:` names.

Honest scope note: gaffer-exec 0.8.0 does not materialize `.gaffer/cache/<key>.tar.gz` for Makefile-derived tasks (the injected `GAFFER_CACHE_ARTIFACT` is empty in practice), so `scripts/save.sh` archives `dist/` itself and `scripts/restore.sh` extracts the downloaded archive. The remote transfer, keying, and hit detection are real; the local tarball is produced by the example's scripts rather than by the tool.

## Expected output

First run (local and remote miss):

```text
→ make:build
[script:scripts:restore] restore: remote miss 96e3ce8e...c80906
[make:build] build: wrote build-info.json input.sha256 output.txt
[script:scripts:save] save: archived dist/ -> .gaffer/cache/96e3ce8e...c80906.tar.gz
[script:scripts:save] save: uploaded gaffer-cache/96e3ce8e...c80906.tar.gz
✓ make:build
```

Second run after `rm -rf .gaffer dist` (remote hit):

```text
→ make:build
[script:scripts:restore] restore: REMOTE HIT 96e3ce8e...c80906
[script:scripts:restore] restore: extracted artifact into the workspace
[make:build] build: dist/ already present (restored)
[script:scripts:save] save: uploaded gaffer-cache/96e3ce8e...c80906.tar.gz
✓ make:build
```

## Testing

```bash
bash test.sh
```

The suite always validates the graph with `gaffer-exec --dry-run make:build`. If Docker is available it starts MinIO, clears the bucket, runs the cached build twice, and asserts that the second run reports a remote hit and that `dist/output.txt` is restored with the expected content. If Docker is unavailable it records `blocked (environment: docker)`, still runs the dry-run, and exits 0. It exits non-zero only when the round-trip actually fails.

## Troubleshooting

- **`Could not connect to the endpoint URL`**: MinIO is not running; start it with `docker compose up -d` and confirm `curl http://localhost:9000/minio/health/live`.
- **`NoSuchBucket`**: the bucket was not created; run `docker compose run --rm createbucket` (idempotent).
- **`restore: no 'mc', 'aws', or 'docker' client available`**: install the MinIO client (`brew install minio/stable/mc`) or the AWS CLI, or make sure Docker is running for the container fallback.
- **`pull access denied` for `minio/minio`**: the compose file uses the `quay.io/minio/...` images, which do not require a Docker Hub login. If your network blocks them, the test records `blocked (environment: docker)`.
- **A local hit instead of a remote hit**: remove `.gaffer/` before the second run; a warm local cache is served without contacting MinIO.
- **Cleanup**: `docker compose down -v` and `rm -rf .gaffer dist`.

## Next example

[23-alternate-manifests](../23-alternate-manifests/README.md) shows gaffer-exec consuming non-Make manifests: a `Taskfile.yml` and a `justfile`.
