# Local Development Environment Example

This example demonstrates how to use **gaffer-exec** to orchestrate a complete local development stack with automatic port assignment, graceful startup/shutdown, and integrated testing.

## Architecture

**Full-Stack Application:**
- **Database**: PostgreSQL (running in Docker)
- **API**: Node.js/Express REST API  
- **Frontend**: React single-page application
- **Orchestration**: gaffer-exec managing the entire stack

**Key Features:**
- 🚀 Automatic port discovery and assignment
- 🔄 Dependency-aware startup sequence (DB → API → Frontend)
- ✅ Health checks and readiness validation
- 🧪 Integrated testing framework
- 🛑 Graceful shutdown of all services
- 📊 Real-time development environment status

## Prerequisites

1. **Node.js 18+** - `node --version`
2. **npm** - `npm --version` 
3. **Docker** - `docker --version`
4. **gaffer-exec** - Install from [gaffer-exec repository](https://github.com/hedinfaok/gaffer)

## Quick Start

```bash
# Clone and navigate to this example
cd examples/06-local-dev-environment

# Start the complete development stack
gaffer-exec run dev
```

The system will:
1. ✅ Find available ports (DB, API, Frontend)
2. 🐳 Start PostgreSQL database in Docker
3. 🚀 Start Express API server
4. 🎨 Start React development server
5. ✅ Run health checks and connectivity tests

## Available Commands

### Core Development Commands
```bash
# Start complete development stack
gaffer-exec run dev

# Run integration tests
gaffer-exec run test

# Stop all services gracefully  
gaffer-exec run stop

# Clean up all generated files
gaffer-exec run clean
```

### Individual Service Commands
```bash
# Setup environment only
gaffer-exec run setup

# Install dependencies
gaffer-exec run install-deps

# Start services individually
gaffer-exec run db:start
gaffer-exec run api:start
gaffer-exec run frontend:start
```

### NPM Shortcuts (Optional)
```bash
npm run dev     # Same as gaffer-exec run dev
npm run test    # Same as gaffer-exec run test  
npm run stop    # Same as gaffer-exec run stop
npm run clean   # Same as gaffer-exec run clean
```

## What You'll See

Once `gaffer-exec run dev` completes successfully:

```
🎉 All services are ready!

📊 Development Stack Status:
   Database:  http://localhost:5433 (PostgreSQL)
   API:       http://localhost:3001
   Frontend:  http://localhost:3000

🏃 You can now:
   • Open your browser to http://localhost:3000
   • Test API at http://localhost:3001/api/tasks
   • Check API health at http://localhost:3001/health
```

## Application Features

The **Task Manager** application demonstrates a real-world development environment:

### Frontend (React)
- 📋 Task management interface
- 📊 Real-time statistics dashboard
- 🔄 Live API health monitoring
- 📱 Responsive design

### API (Express)
- 🔗 RESTful endpoints (`/api/tasks`, `/api/users`)
- 🏥 Health check endpoint (`/health`)
- 🗄️ PostgreSQL database integration
- 🛡️ Error handling and validation

### Database (PostgreSQL)
- 📊 Pre-populated sample data
- 🔄 Automatic migrations
- 💾 Persistent data storage

## Testing

The integration test suite validates:

```bash
gaffer-exec run test
```

**Test Coverage:**
- ✅ Database connectivity
- ✅ API endpoint functionality  
- ✅ CRUD operations (Create, Read, Update, Delete)
- ✅ Frontend accessibility
- ✅ Service health checks

## How It Works

### 1. **Auto Port Assignment**
The setup discovers available ports starting from standard defaults:
- PostgreSQL: 5432+ 
- API: 3001+
- Frontend: 3000+

### 2. **Dependency Chain**
gaffer-exec manages startup dependencies:
```
setup → install-deps → db:start → api:start
                   └→ frontend:start
                      ↓  
                     dev (wait for all)
```

### 3. **Health Checks** 
Each service validates readiness:
- **Database**: `pg_isready` check
- **API**: HTTP health endpoint
- **Frontend**: Static asset availability

### 4. **Graceful Shutdown**
`gaffer-exec run stop` cleanly terminates:
1. Frontend development server
2. API server (with connection cleanup)  
3. PostgreSQL Docker container

## File Structure

```
06-local-dev-environment/
├── graph.json              # gaffer-exec task definitions
├── package.json            # Root project configuration
├── README.md              # This file
├── scripts/               # Orchestration scripts
│   ├── setup.sh          # Environment setup
│   ├── install-deps.sh   # Dependency installation
│   ├── start-db.sh       # Database startup
│   ├── start-api.sh      # API server startup
│   ├── start-frontend.sh # Frontend server startup
│   ├── wait-for-services.sh # Service readiness check
│   ├── run-tests.sh      # Integration testing
│   ├── stop-services.sh  # Graceful shutdown
│   └── clean.sh          # Environment cleanup
├── api/                  # Express.js API
│   ├── package.json      # API dependencies
│   └── server.js         # API server implementation
└── frontend/             # React application
    ├── package.json      # Frontend dependencies
    ├── public/
    │   └── index.html    # HTML template
    └── src/
        ├── index.js      # React entry point
        ├── App.js        # Main application component
        ├── App.css       # Application styles
        └── index.css     # Global styles
```

## Environment Configuration

The system automatically generates `.env` with discovered ports:

```bash
DB_PORT=5433
API_PORT=3001  
FRONTEND_PORT=3000
DATABASE_URL=postgresql://devuser:devpass@localhost:5433/taskmanager
API_URL=http://localhost:3001
```

## Troubleshooting

### Port Conflicts
If services fail to start due to port conflicts:
```bash
gaffer-exec run clean
gaffer-exec run setup  # Will find new available ports
gaffer-exec run dev
```

### Database Issues
Check Docker and database status:
```bash
docker ps                    # Check container status
docker logs taskmanager-db  # Check database logs
```

### API Connection Issues
Verify API health and logs:
```bash
curl http://localhost:$API_PORT/health
tail -f logs/api.log
```

### Frontend Build Issues
Check frontend logs:
```bash
tail -f logs/frontend.log
```

## Real-World Usage Patterns

This example demonstrates patterns applicable to:

### 🏢 **Enterprise Development**
- Multi-service applications
- Database-dependent development  
- Integration testing automation

### 🚀 **Microservices**
- Service orchestration
- Health check coordination
- Port management

### 👥 **Team Development**
- Consistent development environments
- Automated dependency startup
- One-command environment setup

## Next Steps

Extend this example by:

1. **Adding more services** (Redis, message queues)
2. **Docker Compose integration**
3. **Environment-specific configurations** 
4. **Monitoring and logging**
5. **CI/CD pipeline integration**

## Why gaffer-exec?

Traditional approaches require:
```bash
# Manual coordination
docker run postgres...
cd api && npm start &
cd frontend && npm start &
# Wait... test... stop... cleanup...
```

With **gaffer-exec**:
```bash
gaffer-exec run dev  # Everything coordinated automatically
```

**Benefits:**
- ⚡ Single command for complex environments
- 🔄 Dependency management built-in
- 🧪 Testing integration  
- 🛑 Graceful shutdown handling
- 📊 Status visibility throughout