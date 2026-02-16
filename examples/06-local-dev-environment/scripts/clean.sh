#!/bin/bash
set -e

echo "🧹 Cleaning up development environment..."

# Remove generated files
rm -f setup.complete
rm -f node_modules/.installed
rm -f db.ready
rm -f api.ready
rm -f frontend.ready
rm -f .env

# Clean temporary files
rm -rf .temp
rm -rf logs

# Remove database data (optional - uncomment if you want full cleanup)
# rm -rf db/data

# Remove node_modules (optional - uncomment for full cleanup)
# echo "🗑️  Removing node_modules..."
# rm -rf node_modules
# rm -rf api/node_modules
# rm -rf frontend/node_modules

# Remove Docker container and volume
echo "🐳 Cleaning up Docker resources..."
docker stop taskmanager-db 2>/dev/null || true
docker rm taskmanager-db 2>/dev/null || true

echo "✅ Development environment cleaned"
echo ""
echo "💡 To start fresh, run: gaffer-exec run dev"