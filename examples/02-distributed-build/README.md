# Distributed Build Systems

What this shows: a Go microservices build that fetches and uploads cached artifacts to real cloud storage APIs running locally in Docker.

Vs [18-network-aware-builds](../18-network-aware-builds/README.md): this example focuses on the remote cache get/set mechanics against S3, Azure, and GCS; 18 focuses on network topology and multi-region cache selection.

## What you'll learn

- Fetching build outputs from a remote cache before building (`fetch-cache`).
- Uploading new outputs back to the remote cache after building (`upload-cache`).
- Switching between S3 (LocalStack), Azure Blob (Azurite), and GCS (fake-gcs-server) with one environment variable.
- Dependency-aware parallel service builds once the cache is warm.

## Prerequisites

- Go 1.16 or later (`brew install go`)
- Docker Desktop
- AWS CLI (`brew install awscli`)
- Azure CLI, optional, for the Azure backend (`brew install azure-cli`)
- gaffer-exec on your PATH

## Quick start

```bash
# Start LocalStack (S3), Azurite (Azure), and fake-gcs-server (GCS)
./scripts/start-storage.sh

# Point the build at the local S3 backend
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export STORAGE_BACKEND=s3

# Initialize Go modules
go mod tidy

# Run the distributed build (cold cache), then again for cache hits
gaffer-exec --workspace-root . run make:distributed-build
gaffer-exec --workspace-root . run make:distributed-build

# Stop the storage services
./scripts/stop-storage.sh
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `clean` | - | Removes compiled binaries and `.cache` entries |
| `init` | `clean` | Runs `go mod tidy` |
| `fetch-cache` | `init` | Fetches cached artifacts from the configured backend |
| `build-gateway` | `fetch-cache` | Builds `cmd/gateway` |
| `build-auth` | `fetch-cache` | Builds `cmd/auth` |
| `build-users` | `fetch-cache` | Builds `cmd/users` |
| `upload-cache` | `build-gateway`, `build-auth`, `build-users` | Uploads new artifacts to the backend |
| `distributed-build` | `upload-cache` | Full pipeline entry point (default goal) |
| `clean-build` | `distributed-build` | Alias that labels the run as a clean build |

## How it works

```
fetch-cache (check S3/Azure/GCS)
    ├── build-gateway (maybe cached)
    ├── build-auth    (maybe cached)
    └── build-users   (maybe cached)
            └──────────┼─────> upload-cache
```

Pattern: the same remote-cache-before-build, upload-after-build loop used by distributed CI systems. The three service builds are siblings, so once `fetch-cache` completes they run in parallel.

Select the backend with `STORAGE_BACKEND` (`s3`, `azure`, or `gcs`); the scripts read the matching endpoint and credentials.

## Expected output

First run (cold cache):

```text
Checking remote cache for artifacts (backend: s3)...
✗ Cache miss (S3): cmd/gateway/main
✗ Cache miss (S3): cmd/auth/main
✗ Cache miss (S3): cmd/users/main
Cache Summary: 0/3 artifacts found
Cache hit rate: 0%
Cache warming needed

Building gateway service...
Building auth service...
Building users service...

↑  Uploading new artifacts to remote cache (backend: s3)...
✓ Uploaded to S3: cmd/gateway/main
✓ Uploaded to S3: cmd/auth/main
✓ Uploaded to S3: cmd/users/main
Upload Summary: 3 artifacts uploaded, 0 failed
Cache updated successfully!
```

Second run (warm cache):

```text
Checking remote cache for artifacts (backend: s3)...
✓ Cache hit (S3): cmd/gateway/main
✓ Cache hit (S3): cmd/auth/main
✓ Cache hit (S3): cmd/users/main
Cache Summary: 3/3 artifacts found
Cache hit rate: 100%
Excellent cache performance!
```

Timings from a local machine, illustrative only (illustrative, not a benchmark): cold cache around 8-10 seconds, warm cache around 2-3 seconds.

## Testing

```bash
./test.sh
```

The suite starts the storage services, tests connectivity, runs a cold build, verifies uploads, runs a warm build, verifies cache hits, then stops and cleans up.

## Troubleshooting

- **Docker not running**: start Docker Desktop and confirm with `docker info`.
- **Services not healthy**: check `docker-compose ps` and `docker-compose logs -f`, then restart with `./scripts/stop-storage.sh && ./scripts/start-storage.sh`.
- **AWS CLI errors**: confirm `aws --version`, then test with `aws --endpoint-url=http://localhost:4566 s3 ls`.
- **Permission denied on scripts**: run `chmod +x scripts/*.sh`.

## Next example

[18-network-aware-builds](../18-network-aware-builds/README.md) builds on this cache concept with multi-region topology detection and network-aware cache selection.
