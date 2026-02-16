# Distributed Build Systems

This example demonstrates a **real Go microservices project** with distributed caching patterns similar to those used by major open source projects.

## Real Open Source Project Pattern

This follows the same distributed caching patterns used by:
- **Kubernetes** (build caching across components)
- **Docker** (layer caching and multi-stage builds)  
- **Prometheus** (component build optimization)
- **etcd** (distributed artifact caching)

## Project Structure

```
02-distributed-build/
├── cmd/
│   ├── gateway/         # API Gateway service
│   ├── auth/            # Authentication service
│   └── users/           # User service
├── pkg/
│   ├── common/          # Shared utilities
│   └── models/          # Data models
├── .cache/              # Local build cache
├── go.mod               # Go module definition
├── graph.json           # gaffer-exec build graph
└── Makefile            # Build automation
```

## Distributed Caching Workflow

```
fetch-cache (check S3/remote cache)
    ├── build-common (maybe cached)
    └── build-models (maybe cached)
            └──────────┼──> build-gateway build-auth build-users
                                      └─────┼─────> upload-artifacts
```

## How to Run

```bash
# Initialize Go modules
go mod tidy

# Run the distributed build
gaffer-exec run distributed-build --graph graph.json

# Simulate warm cache scenario
gaffer-exec run distributed-build --graph graph.json

# Clean and rebuild all
gaffer-exec run clean-build --graph graph.json
```

## Expected Output

**First run (cold cache):**
- All components build from source
- Artifacts uploaded to cache
- Build time: ~8 seconds

**Second run (warm cache):**
- Most artifacts restored from cache
- Only changed components rebuild
- Build time: ~2 seconds

## Real-World Usage

Replace simulation with real caching:
```bash
# Install AWS CLI and configure
aws configure

# Set your S3 bucket
export CACHE_BUCKET=your-build-cache-bucket
```

## Cache Simulation

This example simulates distributed caching behavior:
- `.cache/` directory represents local cache
- Cache hits/misses based on file modification times
- Upload simulation shows what would go to S3/GCS
- Real cache integration examples provided

## Key Features

- **Parallel microservice builds** - Gateway, auth, and users services
- **Dependency-aware caching** - Common and models packages cached first
- **Realistic build times** - Simulates actual Go compilation time
- **Cache efficiency metrics** - Shows hit rates and time savings
  },
  "upload-cache": {
    "command": "aws s3 sync .cache/ s3://build-cache/.cache/gaffer"
  }
}
```
