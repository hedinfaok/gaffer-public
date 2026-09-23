#!/bin/bash
set -e

source .env

echo "⏳ Waiting for all services to be ready..."

# Check if all services are running
services_ready=true

if [ ! -f db.ready ]; then
  echo "✗ Database not ready"
  services_ready=false
fi

if [ ! -f api.ready ]; then
  echo "✗ API not ready"
  services_ready=false
fi

if [ ! -f frontend.ready ]; then
  echo "✗ Frontend not ready" 
  services_ready=false
fi

if [ "$services_ready" = false ]; then
  echo "✗ Some services are not ready"
  exit 1
fi

# Final connectivity test
echo "Testing service connectivity..."

# Test database connection
if ! docker exec taskmanager-db pg_isready -U devuser -d taskmanager > /dev/null 2>&1; then
  echo "✗ Database connection test failed"
  exit 1
fi

# Test API connection
if ! curl -s http://localhost:${API_PORT}/health > /dev/null 2>&1; then
  echo "✗ API connection test failed"
  exit 1
fi

# Test frontend connection
if ! curl -s http://localhost:${FRONTEND_PORT} > /dev/null 2>&1; then
  echo "✗ Frontend connection test failed"
  exit 1
fi

echo ""
echo "All services are ready!"
echo ""
echo "Development Stack Status:"
echo "   Database:  http://localhost:${DB_PORT} (PostgreSQL)"
echo "   API:       http://localhost:${API_PORT}"
echo "   Frontend:  http://localhost:${FRONTEND_PORT}"
echo ""
echo "You can now:"
echo "   • Open your browser to http://localhost:${FRONTEND_PORT}"
echo "   • Test API at http://localhost:${API_PORT}/api/tasks"
echo "   • Check API health at http://localhost:${API_PORT}/health"
echo ""
echo "Logs are available in:"
echo "   • API: logs/api.log"
echo "   • Frontend: logs/frontend.log"
echo ""
echo "To stop all services: gaffer-exec --workspace-root . run make:stop"