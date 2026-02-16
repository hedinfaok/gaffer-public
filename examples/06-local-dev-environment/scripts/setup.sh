#!/bin/bash
set -e

echo "🚀 Setting up local development environment..."

# Create necessary directories
mkdir -p db/data
mkdir -p logs
mkdir -p .temp

# Check for required tools
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required. Please install Node.js 18+"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm is required. Please install npm"
    exit 1
fi

# Check for Docker (for PostgreSQL)
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required for PostgreSQL. Please install Docker"
    exit 1
fi

# Find available ports using a simpler approach
echo "🔍 Finding available ports..."

# Function to find available port
find_available_port() {
  local start_port=$1
  local port=$start_port
  while netstat -an | grep -q ":${port}.*"; do
    ((port++))
  done
  echo $port
}

DB_PORT=$(find_available_port 5432)
API_PORT=$(find_available_port 3001)  
FRONTEND_PORT=$(find_available_port 3000)

# Write environment file
cat > .env << EOF
DB_PORT=${DB_PORT}
API_PORT=${API_PORT}
FRONTEND_PORT=${FRONTEND_PORT}
DATABASE_URL=postgresql://devuser:devpass@localhost:${DB_PORT}/taskmanager
API_URL=http://localhost:${API_PORT}
EOF

echo "✅ Environment configured:"
echo "   Database: localhost:${DB_PORT}"
echo "   API: localhost:${API_PORT}"  
echo "   Frontend: localhost:${FRONTEND_PORT}"

touch setup.complete
echo "✅ Setup complete!"