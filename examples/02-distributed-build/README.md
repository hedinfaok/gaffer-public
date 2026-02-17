# Distributed Build Systems

This example demonstrates a **real Go microservices project** with distributed caching using **real cloud storage backends** running in Docker containers.

## Real Open Source Project Pattern

This follows the same distributed caching patterns used by:
- **Kubernetes** (build caching across components)
- **Docker** (layer caching and multi-stage builds)  
- **Prometheus** (component build optimization)
- **etcd** (distributed artifact caching)

## Features

✨ **Real Cloud Storage Backends:**
- AWS S3 (LocalStack)
- Azure Blob Storage (Azurite)
- Google Cloud Storage (fake-gcs-server)

🐳 **Docker-based Mock Services:**
- No real cloud credentials needed
- Local development friendly
- Production-like behavior

## Prerequisites

Before running this example, you need:

- **Go** (1.16 or later) - `brew install go`
- **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop)
- **AWS CLI** - `brew install awscli` (for S3 operations)
- **Azure CLI** (optional) - `brew install azure-cli` (for Azure operations)
- **gaffer-exec** - The build orchestrator

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
├── scripts/
│   ├── start-storage.sh # Start Docker storage services
│   ├── stop-storage.sh  # Stop storage services
│   ├── fetch-cache.sh   # Fetch from cloud storage
│   └── upload-cache.sh  # Upload to cloud storage
├── .cache/              # Local build cache
├── docker-compose.yml   # Cloud storage services
├── go.mod               # Go module definition
├── graph.json           # gaffer-exec build graph
└── Makefile            # Build automation
```

## Quick Start

### 1. Start Cloud Storage Services

```bash
# Start LocalStack (S3), Azurite (Azure), and fake-gcs-server (GCS)
./scripts/start-storage.sh
```

This will:
- Start three Docker containers
- Create storage buckets/containers
- Display service endpoints and credentials
- Wait for all services to be healthy

### 2. Configure Environment

```bash
# For S3 (LocalStack) - default
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export STORAGE_BACKEND=s3

# For Azure (Azurite) - optional
export STORAGE_BACKEND=azure
export AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;"

# For GCS (fake-gcs-server) - optional
export STORAGE_BACKEND=gcs
export GCS_ENDPOINT=http://localhost:4443
```

### 3. Run the Build

```bash
# Initialize Go modules
go mod tidy

# Run the distributed build with cloud caching
gaffer-exec run distributed-build --graph graph.json

# Run again to see cache hits
gaffer-exec run distributed-build --graph graph.json
```

### 4. Stop Services

```bash
./scripts/stop-storage.sh
```

## Distributed Caching Workflow

```
fetch-cache (check S3/Azure/GCS)
    ├── build-common (maybe cached)
    └── build-models (maybe cached)
            └──────────┼──> build-gateway build-auth build-users
                                      └─────┼─────> upload-artifacts
```

## Verifying Storage is Working

### Check S3 (LocalStack)

```bash
# List buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# List cached artifacts
aws --endpoint-url=http://localhost:4566 s3 ls s3://gaffer-build-cache/ --recursive

# Download an artifact manually
aws --endpoint-url=http://localhost:4566 s3 cp s3://gaffer-build-cache/cmd/gateway/main ./test-download
```

### Check Azure (Azurite)

```bash
# List containers
az storage container list --connection-string "$AZURE_STORAGE_CONNECTION_STRING"

# List blobs
az storage blob list \
    --container-name gaffer-build-cache \
    --connection-string "$AZURE_STORAGE_CONNECTION_STRING"
```

### Check GCS (fake-gcs-server)

```bash
# List buckets
curl http://localhost:4443/storage/v1/b

# List objects in bucket
curl http://localhost:4443/storage/v1/b/gaffer-build-cache/o
```

## Expected Output

**First run (cold cache):**
```
🔍 Checking remote cache for artifacts (backend: s3)...
✗ Cache miss (S3): cmd/gateway/main
✗ Cache miss (S3): cmd/auth/main
✗ Cache miss (S3): cmd/users/main
📊 Cache Summary: 0/3 artifacts found
🎯 Cache hit rate: 0%
🔥 Cache warming needed

🔨 Building gateway service...
🔨 Building auth service...
🔨 Building users service...

⬆️  Uploading new artifacts to remote cache (backend: s3)...
✓ Uploaded to S3: cmd/gateway/main
✓ Uploaded to S3: cmd/auth/main
✓ Uploaded to S3: cmd/users/main
📤 Upload Summary: 3 artifacts uploaded, 0 failed
🎉 Cache updated successfully!
```

**Second run (warm cache):**
```
🔍 Checking remote cache for artifacts (backend: s3)...
✓ Cache hit (S3): cmd/gateway/main
✓ Cache hit (S3): cmd/auth/main
✓ Cache hit (S3): cmd/users/main
📊 Cache Summary: 3/3 artifacts found
🎯 Cache hit rate: 100%
🚀 Excellent cache performance!

⬆️  Uploading new artifacts to remote cache (backend: s3)...
📤 Upload Summary: 0 artifacts uploaded, 0 failed
ℹ️  No new artifacts to upload
```

## Service Endpoints

When storage services are running:

| Service | Type | Endpoint | Purpose |
|---------|------|----------|---------|
| LocalStack | S3 | http://localhost:4566 | AWS S3 emulation |
| Azurite | Azure Blob | http://localhost:10000 | Azure Storage emulation |
| fake-gcs-server | GCS | http://localhost:4443 | Google Cloud Storage emulation |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `STORAGE_BACKEND` | `s3` | Storage backend: `s3`, `azure`, or `gcs` |
| `AWS_ENDPOINT_URL` | `http://localhost:4566` | LocalStack endpoint |
| `AWS_ACCESS_KEY_ID` | `test` | AWS credentials (any value works) |
| `AWS_SECRET_ACCESS_KEY` | `test` | AWS credentials (any value works) |
| `AZURE_STORAGE_CONNECTION_STRING` | (see above) | Azurite connection string |
| `GCS_ENDPOINT` | `http://localhost:4443` | fake-gcs-server endpoint |

## Switching Storage Backends

```bash
# Use S3 (LocalStack)
export STORAGE_BACKEND=s3
gaffer-exec run distributed-build --graph graph.json

# Use Azure (Azurite)
export STORAGE_BACKEND=azure
gaffer-exec run distributed-build --graph graph.json

# Use GCS (fake-gcs-server)
export STORAGE_BACKEND=gcs
gaffer-exec run distributed-build --graph graph.json
```

## Docker Compose Services

The `docker-compose.yml` defines three storage services:

```yaml
services:
  localstack:    # AWS S3 emulation
  azurite:       # Azure Blob Storage emulation
  fake-gcs:      # Google Cloud Storage emulation
```

All services include health checks and will automatically create the required buckets/containers.

## Troubleshooting

### Docker not running
```bash
# Start Docker Desktop and verify
docker info
```

### Services not healthy
```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
./scripts/stop-storage.sh
./scripts/start-storage.sh
```

### AWS CLI errors
```bash
# Verify AWS CLI is installed
aws --version

# Test connection
aws --endpoint-url=http://localhost:4566 s3 ls
```

### Permission denied on scripts
```bash
chmod +x scripts/*.sh
```

## Real-World Usage

To use real cloud storage instead of mocks:

```bash
# For AWS S3
export STORAGE_BACKEND=s3
unset AWS_ENDPOINT_URL  # Use real AWS
aws configure  # Set up real credentials
export BUCKET_NAME=my-real-build-cache

# For Azure
export STORAGE_BACKEND=azure
az login
export AZURE_STORAGE_CONNECTION_STRING="<real connection string>"

# For GCS
export STORAGE_BACKEND=gcs
gcloud auth login
export GCS_ENDPOINT=""  # Use real GCS
```

## Performance Benchmarks

Run the benchmark script to measure cache performance:

```bash
# Clean build (no cache)
time gaffer-exec run clean-build --graph graph.json

# Warm cache build
time gaffer-exec run distributed-build --graph graph.json
```

Expected results:
- **Cold cache:** ~8-10 seconds
- **Warm cache:** ~2-3 seconds
- **Cache speedup:** 3-4x faster

## Key Features

- **Parallel microservice builds** - Gateway, auth, and users services build in parallel
- **Dependency-aware caching** - Common and models packages cached first
- **Multiple storage backends** - Switch between S3, Azure, and GCS
- **Production-like behavior** - Real cloud storage APIs without cloud costs
- **Cache efficiency metrics** - Shows hit rates and time savings
- **Docker-based** - Easy setup and teardown

## Testing

Run the comprehensive test suite:

```bash
./test.sh
```

This will:
1. Start storage services
2. Test storage connectivity
3. Run cold cache build
4. Verify cache uploads
5. Run warm cache build
6. Verify cache hits
7. Stop services and cleanup

## Clean Up

```bash
# Stop services
./scripts/stop-storage.sh

# Remove all data
rm -rf tmp/ .cache/

# Clean build artifacts
gaffer-exec run clean --graph graph.json
```
```
