#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "🧹 Stopping multi-region infrastructure..."

# Stop Docker containers
if docker-compose ps 2>/dev/null | grep -q "Up"; then
    docker-compose down
    echo "✅ Services stopped"
else
    echo "ℹ️  No services running"
fi

# Optional: Clean up temporary files
if [ "$1" = "--clean" ]; then
    echo "🗑️  Cleaning temporary files..."
    rm -rf tmp/
    rm -rf .cache/
    echo "✅ Cleanup complete"
fi

echo "✅ Infrastructure stopped"
