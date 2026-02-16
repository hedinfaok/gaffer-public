#!/bin/bash
set -e

source .env

echo "🗄️  Starting PostgreSQL database..."

# Stop existing container if running
docker stop taskmanager-db 2>/dev/null || true
docker rm taskmanager-db 2>/dev/null || true

# Start PostgreSQL in Docker
docker run -d \
  --name taskmanager-db \
  -e POSTGRES_DB=taskmanager \
  -e POSTGRES_USER=devuser \
  -e POSTGRES_PASSWORD=devpass \
  -p ${DB_PORT}:5432 \
  -v $(pwd)/db/data:/var/lib/postgresql/data \
  postgres:15-alpine

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
  if docker exec taskmanager-db pg_isready -U devuser -d taskmanager > /dev/null 2>&1; then
    echo "✅ Database is ready!"
    break
  fi
  
  if [ $attempt -eq $max_attempts ]; then
    echo "❌ Database failed to start after $max_attempts attempts"
    exit 1
  fi
  
  echo "⏳ Attempt $attempt/$max_attempts - waiting for database..."
  sleep 2
  ((attempt++))
done

# Run database migrations
echo "🔄 Running database migrations..."
docker exec taskmanager-db psql -U devuser -d taskmanager -c "
CREATE TABLE IF NOT EXISTS tasks (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO tasks (title, description, status) VALUES 
  ('Setup Development Environment', 'Configure local dev stack with DB, API, and Frontend', 'completed'),
  ('Implement User Authentication', 'Add JWT-based authentication to API endpoints', 'pending'),
  ('Build Task Dashboard', 'Create React components for task management UI', 'in_progress'),
  ('Add Real-time Updates', 'Implement WebSocket connections for live task updates', 'pending')
ON CONFLICT DO NOTHING;

INSERT INTO users (email, name) VALUES
  ('developer@example.com', 'Dev User'),
  ('admin@example.com', 'Admin User')
ON CONFLICT DO NOTHING;
"

echo "DB_CONTAINER_ID=$(docker ps -q -f name=taskmanager-db)" > .temp/db.pid
touch db.ready
echo "✅ Database started on port ${DB_PORT}"