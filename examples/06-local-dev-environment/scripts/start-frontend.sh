#!/bin/bash
set -e

source .env

echo "🎨 Starting frontend development server..."

# Kill existing frontend process if running
if [ -f .temp/frontend.pid ]; then
  kill $(cat .temp/frontend.pid) 2>/dev/null || true
  rm -f .temp/frontend.pid
fi

# Start frontend server in background
cd frontend
BROWSER=none PORT=${FRONTEND_PORT} npm start > ../logs/frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..

echo $FRONTEND_PID > .temp/frontend.pid

# Wait for frontend to be ready
echo "⏳ Waiting for frontend to be ready..."
max_attempts=60  # Frontend takes longer to start
attempt=1

while [ $attempt -le $max_attempts ]; do
  if curl -s http://localhost:${FRONTEND_PORT} > /dev/null 2>&1; then
    echo "✅ Frontend is ready!"
    break
  fi
  
  if [ $attempt -eq $max_attempts ]; then
    echo "❌ Frontend failed to start after $max_attempts attempts"
    echo "📋 Frontend logs:"
    tail -20 logs/frontend.log
    exit 1
  fi
  
  echo "⏳ Attempt $attempt/$max_attempts - waiting for frontend..."
  sleep 3
  ((attempt++))
done

touch frontend.ready
echo "✅ Frontend started on port ${FRONTEND_PORT}"