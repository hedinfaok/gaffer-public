#!/bin/bash
set -e

echo "🛑 Stopping all services..."

# Stop frontend
if [ -f .temp/frontend.pid ]; then
  echo "🎨 Stopping frontend server..."
  kill $(cat .temp/frontend.pid) 2>/dev/null || true
  rm -f .temp/frontend.pid
  rm -f frontend.ready
  echo "✅ Frontend stopped"
fi

# Stop API
if [ -f .temp/api.pid ]; then
  echo "🚀 Stopping API server..."
  kill $(cat .temp/api.pid) 2>/dev/null || true
  rm -f .temp/api.pid
  rm -f api.ready
  echo "✅ API stopped"
fi

# Stop database
if [ -f .temp/db.pid ]; then
  echo "🗄️  Stopping database..."
  docker stop taskmanager-db 2>/dev/null || true
  rm -f .temp/db.pid
  rm -f db.ready
  echo "✅ Database stopped"
fi

echo "✅ All services stopped gracefully"