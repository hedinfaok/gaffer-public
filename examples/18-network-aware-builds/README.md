# Network-Aware Builds

What this shows: a multi-region build cache that detects network topology, selects the nearest healthy region, and keeps regional caches in sync.

Vs [02-distributed-build](../02-distributed-build/README.md): this example focuses on network topology and multi-region cache selection; 02 focuses on the remote cache get/set mechanics against S3, Azure, and GCS.

## What you'll learn

- Region detection and scoring by latency and bandwidth.
- Primary, secondary, and tertiary cache selection with automatic fallback.
- Cross-region cache synchronization.
- Compression selection driven by measured bandwidth.
- Failure recovery with exponential backoff and graceful degradation to the local cache.

## Prerequisites

- Go 1.16 or later (`brew install go`)
- Docker Desktop
- AWS CLI (`brew install awscli`)
- Python 3, for the network simulation scripts
- gaffer-exec on your PATH
- `tc` (traffic control), usually pre-installed on macOS and Linux

## Quick start

```bash
# Start the simulated regional cache nodes
./scripts/start-regions.sh

# Choose the region the build should behave as if it runs from
export BUILD_REGION=us-east-1
export PRIMARY_CACHE=us-east
export AWS_ENDPOINT_URL=http://localhost:4566

# Initialize Go modules
go mod tidy

# Run the network-aware build
gaffer-exec --workspace-root . run make:network-build

# Inspect live network metrics
./scripts/monitor-network.sh
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `clean` | - | Removes binaries and caches |
| `init` | `clean` | Runs `go mod tidy` and creates `bin/` and `.cache/` |
| `detect-network` | `init` | Detects the optimal cache region |
| `fetch-cache-us-east` | `detect-network` | Fetches artifacts from US-East |
| `fetch-cache-us-west` | `detect-network` | Fetches artifacts from US-West |
| `fetch-cache-eu` | `detect-network` | Fetches artifacts from EU-Central |
| `build-api` | `fetch-cache-us-east` | Builds the API service |
| `build-worker` | `fetch-cache-us-east` | Builds the worker service |
| `build-frontend` | `fetch-cache-us-east` | Builds the frontend service |
| `verify-builds` | `build-api`, `build-worker`, `build-frontend` | Verifies all binaries |
| `upload-cache` | `verify-builds` | Uploads artifacts to the primary cache |
| `sync-regions` | `upload-cache` | Synchronizes caches across regions |
| `network-build` | `sync-regions` | Full network-aware build (default goal) |
| `benchmark` | - | Runs the performance benchmark script |
| `monitor` | - | Prints live network metrics |
| `test-failure` | - | Exercises failure recovery |

## How it works

```
                    Build Orchestrator (gaffer-exec)
             ┌──────────────┬──────────────┬───────────────┐
        US-East          US-West        EU-Central
       (Primary)       (Secondary)      (Tertiary)
      S3 + Redis       S3 + Redis       S3 + Redis
```

Pattern: cache locality as a scheduling input. `detect-network` scores each region (latency weighted 0.4, bandwidth 0.6) and the build then fetches from the best one. If the primary fails, the build falls back to the secondary, then the tertiary, then the local cache.

Compression is chosen from measured bandwidth: no compression at 100Mbps and above, gzip between 50 and 100Mbps, and maximum zstd compression below 50Mbps.

Honest scope note: delta transfer is a design shown through simulated metrics. The current scripts perform full artifact sync with compression; the bandwidth savings reported by the demo are projected, not measured.

## Expected output

Region detection:

```text
Detected region: us-east-1
Network metrics:
   - Latency to us-east: 50ms
   - Latency to us-west: 100ms
   - Latency to eu-central: 150ms
✓ Selected primary cache: us-east (50ms, 100Mbps)
```

Monitoring:

```text
Region       | Latency | Bandwidth | Cache Hits | Status
-------------|---------|-----------|------------|--------
us-east      | 50ms    | 100Mbps   | 85%        | ✓
us-west      | 100ms   | 50Mbps    | 60%        | ✓
eu-central   | 150ms   | 25Mbps    | 40%        | ⚠
```

Fallback during a failure:

```text
Primary (us-east): Connection timeout
⚠  Falling back to secondary (us-west)
✓ Connected to us-west (100ms latency)
Resuming transfer from chunk 42/100
```

The latencies, bandwidths, and build times in this example are simulated demo values (illustrative, not a benchmark).

## Testing

```bash
./test.sh
./test.sh --scenario network-failure
./test.sh --scenario multi-region-sync
./test.sh --scenario bandwidth-optimization
```

The same scenarios are reachable through the Makefile:

```bash
gaffer-exec --workspace-root . run make:monitor
gaffer-exec --workspace-root . run make:test-failure
gaffer-exec --workspace-root . run make:benchmark
```

## Troubleshooting

- **Services not starting**: check `docker ps`, then `docker-compose logs localstack-us-east` and `docker-compose logs redis-us-east`; restart with `./scripts/stop-regions.sh && ./scripts/start-regions.sh`.
- **High latency**: check `./scripts/monitor-network.sh`, reset with `./scripts/simulate-network.sh --reset`, or pin a region with `export PRIMARY_CACHE=us-east` and `export FORCE_CACHE=true`.
- **Cache sync issues**: force a sync with `./scripts/sync-caches.sh --force`, then inspect buckets with `aws --endpoint-url=http://localhost:4566 s3 ls s3://gaffer-cache-us-east/`.
- **Cleanup**: `./scripts/stop-regions.sh` and `rm -rf .cache tmp/`.

## Next example

[02-distributed-build](../02-distributed-build/README.md) shows the underlying remote cache get/set mechanics against three cloud storage backends.
