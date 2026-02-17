#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "🛑 Stopping cloud storage services..."

# Stop and remove containers
docker-compose down

echo "✅ All services stopped"
echo ""
echo "💡 To remove all data: rm -rf tmp/"
echo "🚀 To start again: ./scripts/start-storage.sh"
