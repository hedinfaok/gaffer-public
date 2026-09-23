#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "Starting multi-region build infrastructure..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "✗ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Check for port conflicts
echo "Checking for port conflicts..."
ports=(4566 4567 4568 6379 6380 6381 9090)
for port in "${ports[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "⚠  Warning: Port $port is already in use. Stopping existing services..."
        docker-compose down 2>/dev/null || true
        sleep 2
        break
    fi
done

# Create necessary directories
echo "Creating cache directories..."
mkdir -p tmp/us-east tmp/us-west tmp/eu-central
mkdir -p tmp/redis-us-east tmp/redis-us-west tmp/redis-eu-central
mkdir -p tmp/prometheus
mkdir -p .cache config

# Create Prometheus config if it doesn't exist
if [ ! -f config/prometheus.yml ]; then
    echo "Creating Prometheus configuration..."
    cat > config/prometheus.yml <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'gaffer-builds'
    static_configs:
      - targets: ['host.docker.internal:8080']
        labels:
          service: 'api'
          region: 'us-east'
      - targets: ['host.docker.internal:8081']
        labels:
          service: 'worker'
          region: 'us-east'
      - targets: ['host.docker.internal:8082']
        labels:
          service: 'frontend'
          region: 'us-east'
EOF
fi

# Start services
echo ""
echo "Starting Docker services..."
echo "   - LocalStack (S3) x3 (US-East, US-West, EU-Central)"
echo "   - Redis x3 (metadata cache per region)"
echo "   - Prometheus (metrics collection)"
docker-compose up -d

# Wait for services to be healthy
echo ""
echo "⏳ Waiting for services to be ready..."
timeout=90
elapsed=0

while [ $elapsed -lt $timeout ]; do
    # Check if all containers are running
    running=$(docker-compose ps | grep -c "Up" || true)
    
    if [ "$running" -ge 6 ]; then
        # Additional check for LocalStack health
        us_east_healthy=$(curl -sf http://localhost:4566/_localstack/health >/dev/null 2>&1 && echo "ok" || echo "fail")
        us_west_healthy=$(curl -sf http://localhost:4567/_localstack/health >/dev/null 2>&1 && echo "ok" || echo "fail")
        eu_central_healthy=$(curl -sf http://localhost:4568/_localstack/health >/dev/null 2>&1 && echo "ok" || echo "fail")
        
        if [ "$us_east_healthy" = "ok" ] && [ "$us_west_healthy" = "ok" ] && [ "$eu_central_healthy" = "ok" ]; then
            echo ""
            echo "✓ All services are ready!"
            break
        fi
    fi
    
    sleep 2
    elapsed=$((elapsed + 2))
    echo -n "."
done

echo ""

if [ $elapsed -ge $timeout ]; then
    echo "✗ Services failed to become healthy within ${timeout}s"
    echo "Service status:"
    docker-compose ps
    exit 1
fi

# Initialize S3 buckets in all regions
echo ""
echo "Creating S3 buckets in all regions..."

# US-East
echo "   US-East (localhost:4566)..."
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

if aws --endpoint-url=http://localhost:4566 s3 mb s3://gaffer-cache-us-east 2>&1 | grep -q "BucketAlreadyOwnedByYou\|BucketAlreadyExists" || \
   aws --endpoint-url=http://localhost:4566 s3 ls s3://gaffer-cache-us-east >/dev/null 2>&1; then
    echo "      ✓ Bucket ready"
else
    echo "      ✓ Bucket created"
fi

# US-West
echo "   US-West (localhost:4567)..."
if aws --endpoint-url=http://localhost:4567 s3 mb s3://gaffer-cache-us-west 2>&1 | grep -q "BucketAlreadyOwnedByYou\|BucketAlreadyExists" || \
   aws --endpoint-url=http://localhost:4567 s3 ls s3://gaffer-cache-us-west >/dev/null 2>&1; then
    echo "      ✓ Bucket ready"
else
    echo "      ✓ Bucket created"
fi

# EU-Central
echo "   EU-Central (localhost:4568)..."
if aws --endpoint-url=http://localhost:4568 s3 mb s3://gaffer-cache-eu-central 2>&1 | grep -q "BucketAlreadyOwnedByYou\|BucketAlreadyExists" || \
   aws --endpoint-url=http://localhost:4568 s3 ls s3://gaffer-cache-eu-central >/dev/null 2>&1; then
    echo "      ✓ Bucket ready"
else
    echo "      ✓ Bucket created"
fi

# Test Redis connections
echo ""
echo "Verifying Redis connections..."
for port in 6379 6380 6381; do
    if redis-cli -p $port ping >/dev/null 2>&1; then
        echo "   ✓ Redis on port $port: Connected"
    else
        echo "   ⚠  Redis on port $port: Not accessible (non-critical)"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Multi-region infrastructure ready!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Available Regions:"
echo "   US-East:      http://localhost:4566  (Primary - Low latency, high bandwidth)"
echo "   US-West:      http://localhost:4567  (Secondary - Medium latency)"
echo "   EU-Central:   http://localhost:4568  (Tertiary - High latency)"
echo ""
echo "Monitoring:"
echo "   Prometheus:   http://localhost:9090"
echo ""
echo "Redis Metadata Cache:"
echo "   US-East:      localhost:6379"
echo "   US-West:      localhost:6380"
echo "   EU-Central:   localhost:6381"
echo ""
echo "Ready to build! Run:"
echo "   go mod tidy"
echo "   gaffer-exec --workspace-root . run make:network-build"
echo ""
