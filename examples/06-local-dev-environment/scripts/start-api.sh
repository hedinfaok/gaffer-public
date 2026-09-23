#!/bin/bash
set -e

source .env

echo "Starting API server..."

# Ensure logs directory exists
mkdir -p ../logs

# Kill existing API process if running
if [ -f .temp/api.pid ]; then
  kill $(cat .temp/api.pid) 2>/dev/null || true
  rm -f .temp/api.pid
fi

# Start API server in background
cd api
npm start > ../logs/api.log 2>&1 &
API_PID=$!
cd ..

echo $API_PID > .temp/api.pid

# Wait for API to be ready
echo "⏳ Waiting for API to be ready..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
  if curl -s http://localhost:${API_PORT}/health > /dev/null 2>&1; then
    echo "✓ API is ready!"
    break
  fi
  
  if [ $attempt -eq $max_attempts ]; then
    echo "✗ API failed to start after $max_attempts attempts"
    echo "API logs:"
    tail -20 logs/api.log
    exit 1
  fi
  
  echo "⏳ Attempt $attempt/$max_attempts - waiting for API..."
  sleep 2
  ((attempt++))
done

touch api.ready
echo "✓ API started on port ${API_PORT}"