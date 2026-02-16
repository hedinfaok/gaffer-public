#!/bin/bash
set -e

echo "🚀 Starting complete development environment..."

# Execute all dependencies in order
echo "📊 Starting services..."
gaffer-exec --graph graph.json run db:start
gaffer-exec --graph graph.json run api:start  
gaffer-exec --graph graph.json run frontend:start

# Run the dev validation
echo "✅ Validating development stack..."
gaffer-exec --graph graph.json run dev

echo ""
echo "🎉 Development environment is ready!"
echo "   • Frontend: http://localhost:3000"  
echo "   • API: http://localhost:3001"
echo "   • Database: localhost:5432"
echo ""
echo "🛑 To stop: gaffer-exec --graph graph.json run stop"