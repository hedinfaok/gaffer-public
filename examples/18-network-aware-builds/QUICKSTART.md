# Network-Aware Builds - Quick Start Guide

Get up and running with network-aware builds in 5 minutes.

## Prerequisites

Ensure you have installed:
- Go 1.16+
- Docker Desktop
- AWS CLI
- gaffer-exec

```bash
brew install go docker awscli
```

## Quick Start (5 minutes)

### 1. Start Multi-Region Infrastructure (30 seconds)

```bash
cd examples/18-network-aware-builds
./scripts/start-regions.sh
```

This starts 3 simulated regions with different network characteristics.

### 2. Build Services (2 minutes)

```bash
# Initialize Go dependencies
go mod tidy

# Run build with gaffer-exec
gaffer-exec run network-build --graph graph.json
```

Or build manually:

```bash
# Detect optimal cache region
./scripts/detect-region.sh

# Build all services
mkdir -p bin
go build -o bin/api ./cmd/api
go build -o bin/worker ./cmd/worker
go build -o bin/frontend ./cmd/frontend

# Upload to cache
./scripts/upload-cache.sh

# Sync across regions
./scripts/sync-caches.sh
```

### 3. Verify Everything Works

```bash
./scripts/verify-builds.sh
./scripts/show-stats.sh
```

## What You Just Built

- **3 microservices** (API, Worker, Frontend) in Go
- **3 cache regions** with different network characteristics:
  - US-East: 50ms latency, 100Mbps (Primary)
  - US-West: 100ms latency, 50Mbps (Secondary)
  - EU-Central: 150ms latency, 25Mbps (Tertiary)
- **Automatic region detection** based on network topology
- **Cross-region cache synchronization**

## See It In Action

### Monitor Network Performance

```bash
./scripts/monitor-network.sh
```

### Test Failure Recovery

```bash
./scripts/test-failure.sh
```

### Run Performance Benchmarks

```bash
./scripts/benchmark.sh
```

### Start Services

```bash
# Start API service
export BUILD_REGION=us-east-1
./bin/api &

# Visit dashboard
curl http://localhost:8080/api/network/topology | jq
```

## Common Operations

### Clean Rebuild

```bash
# Clean everything
rm -rf bin/ .cache/

# Rebuild from scratch
gaffer-exec run network-build --graph graph.json
```

### Warm Build (with cache)

```bash
# Clean binaries only
rm -rf bin/

# Rebuild with cache
gaffer-exec run network-build --graph graph.json
```

### Change Primary Region

```bash
# Simulate building from EU
export BUILD_REGION=eu-central-1
export PRIMARY_CACHE=eu-central
./scripts/detect-region.sh
```

### Sync Caches Manually

```bash
./scripts/sync-caches.sh
```

## Troubleshooting

### Services Won't Start

```bash
# Check Docker
docker ps

# Check logs
docker-compose logs

# Restart
./scripts/stop-regions.sh
./scripts/start-regions.sh
```

### Build Fails

```bash
# Ensure Go modules are up to date
go mod tidy

# Check Go version
go version  # Should be 1.16+

# Clean and rebuild
rm -rf bin/ .cache/
mkdir -p bin
go build -o bin/api ./cmd/api
```

### Cache Issues

```bash
# Verify cache connectivity
aws --endpoint-url=http://localhost:4566 s3 ls s3://gaffer-cache-us-east/

# Reset caches
./scripts/stop-regions.sh --clean
./scripts/start-regions.sh
```

## Next Steps

1. **Read the full README** for detailed architecture explanations
2. **Run benchmarks** to see performance comparisons
3. **Explore the code** to understand network-aware optimizations
4. **Customize** for your own projects

## Key Features Demonstrated

✅ **Network Topology Detection** - Automatic selection of optimal cache  
✅ **Multi-Region Caching** - 3 regions with different characteristics  
✅ **Intelligent Fallback** - Automatic failover on network issues  
✅ **Bandwidth Optimization** - Adaptive compression (delta transfers simulated)  
✅ **Cache Synchronization** - Cross-region artifact replication  
✅ **Performance Monitoring** - Real-time network metrics  
✅ **Failure Recovery** - Exponential backoff and resumable transfers  

## Cleanup

```bash
# Stop services
./scripts/stop-regions.sh

# Remove all data
./scripts/stop-regions.sh --clean
```

---

**Time to first successful build**: < 5 minutes  
**Build time (cold)**: ~45s  
**Build time (warm)**: ~8s  
**Bandwidth savings**: 95% potential with delta transfers (simulated in demo)
