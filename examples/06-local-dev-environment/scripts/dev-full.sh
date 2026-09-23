#!/bin/bash
set -e

echo "🚀 Starting complete development environment..."

# Execute all dependencies in order
echo "📊 Starting services..."
gaffer-exec --workspace-root . run make:db-start
gaffer-exec --workspace-root . run make:api-start  
gaffer-exec --workspace-root . run make:frontend-start

# Run the dev validation
echo "✅ Validating development stack..."
gaffer-exec --workspace-root . run make:dev

echo ""
echo "🎉 Development environment is ready!"
echo "   • Frontend: http://localhost:3000"  
echo "   • API: http://localhost:3001"
echo "   • Database: localhost:5432"
echo ""
echo "🛑 To stop: gaffer-exec --workspace-root . run make:stop"