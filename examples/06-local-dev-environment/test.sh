#!/bin/bash

# Local Development Environment Example Test Script
# Tests the complete orchestration of DB → API → Frontend stack with gaffer-exec

set -e

cd "$(dirname "$0")"

echo "Testing Local Development Environment Example"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

run_test() {
    local test_name="$1"
    local test_description="$2"
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Test $((TESTS_RUN + 1)): $test_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "$test_description"
    
    TESTS_RUN=$((TESTS_RUN + 1))
}

pass_test() {
    echo -e "${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail_test() {
    local reason="$1"
    echo -e "${RED}✗ FAIL${NC}"
    echo "Reason: $reason"
    exit 1
}

# Cleanup from any previous runs
echo -e "${YELLOW}Cleaning up from previous runs...${NC}"
gaffer-exec --workspace-root . run make:clean > /dev/null 2>&1 || true
echo ""

# Test 1: Prerequisites check
run_test "Prerequisites Check" "Verifying required tools are available"

if ! command -v node &> /dev/null; then
    fail_test "Node.js is not installed"
fi
echo "✓ Node.js is available: $(node --version)"

if ! command -v npm &> /dev/null; then
    fail_test "npm is not installed"
fi
echo "✓ npm is available: $(npm --version)"

if ! command -v docker &> /dev/null; then
    fail_test "Docker is not installed"
fi
echo "✓ Docker is available: $(docker --version)"

if ! command -v gaffer-exec &> /dev/null; then
    fail_test "gaffer-exec is not installed"
fi
echo "✓ gaffer-exec is available"

pass_test

# Test 2: Setup and port assignment
run_test "Setup and Auto Port Assignment" "Testing environment setup with automatic port discovery"

if gaffer-exec --workspace-root . run make:setup > /dev/null 2>&1; then
    echo "✓ Setup completed successfully"
else
    fail_test "Setup command failed"
fi

if [ -f "setup.complete" ]; then
    echo "✓ setup.complete marker created"
else
    fail_test "setup.complete marker not found"
fi

if [ -f ".env" ]; then
    echo "✓ .env file created"
else
    fail_test ".env file not found"
fi

# Verify environment variables
source .env

if [ -z "$DB_PORT" ] || [ -z "$API_PORT" ] || [ -z "$FRONTEND_PORT" ]; then
    fail_test "Port environment variables not set correctly"
fi

echo "✓ Port assignments:"
echo "  - Database: ${DB_PORT}"
echo "  - API: ${API_PORT}"
echo "  - Frontend: ${FRONTEND_PORT}"

pass_test

# Test 3: Install dependencies
run_test "Dependency Installation" "Installing dependencies for all services"

start_time=$(date +%s)
if gaffer-exec --workspace-root . run make:install-deps > /dev/null 2>&1; then
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    echo "✓ Dependencies installed in ${duration}s"
else
    fail_test "Dependency installation failed"
fi

# Verify node_modules exist
if [ ! -d "node_modules" ]; then
    fail_test "Root node_modules not found"
fi
echo "✓ Root dependencies installed"

if [ ! -d "api/node_modules" ]; then
    fail_test "API node_modules not found"
fi
echo "✓ API dependencies installed"

if [ ! -d "frontend/node_modules" ]; then
    fail_test "Frontend node_modules not found"
fi
echo "✓ Frontend dependencies installed"

pass_test

# Test 4: Start database
run_test "Database Startup" "Starting PostgreSQL database in Docker"

if gaffer-exec --workspace-root . run make:db-start > /dev/null 2>&1; then
    echo "✓ Database started successfully"
else
    fail_test "Database startup failed"
fi

if [ -f "db.ready" ]; then
    echo "✓ db.ready marker created"
else
    fail_test "db.ready marker not found"
fi

# Test database connectivity
if docker exec taskmanager-db pg_isready -U devuser -d taskmanager > /dev/null 2>&1; then
    echo "✓ Database is accepting connections"
else
    fail_test "Database not accepting connections"
fi

# Test database has tables
if docker exec taskmanager-db psql -U devuser -d taskmanager -c "\dt" | grep -q "tasks"; then
    echo "✓ Database tables created"
else
    fail_test "Database tables not found"
fi

pass_test

# Test 5: Start API
run_test "API Startup" "Starting Express API server"

if gaffer-exec --workspace-root . run make:api-start > /dev/null 2>&1; then
    echo "✓ API started successfully"
else
    fail_test "API startup failed"
fi

if [ -f "api.ready" ]; then
    echo "✓ api.ready marker created"
else
    fail_test "api.ready marker not found"
fi

# Test API health endpoint
if curl -s http://localhost:${API_PORT}/health | grep -q "OK"; then
    echo "✓ API health check passed"
else
    fail_test "API health check failed"
fi

pass_test

# Test 6: Start frontend
run_test "Frontend Startup" "Starting React development server"

if gaffer-exec --workspace-root . run make:frontend-start > /dev/null 2>&1; then
    echo "✓ Frontend started successfully"
else
    fail_test "Frontend startup failed"
fi

if [ -f "frontend.ready" ]; then
    echo "✓ frontend.ready marker created"
else
    fail_test "frontend.ready marker not found"
fi

# Test frontend accessibility
if curl -s http://localhost:${FRONTEND_PORT} > /dev/null 2>&1; then
    echo "✓ Frontend is accessible"
else
    fail_test "Frontend not accessible"
fi

pass_test

# Test 7: Integration tests
run_test "Integration Tests" "Testing API endpoints and database operations"

# Test API tasks endpoint
if curl -s http://localhost:${API_PORT}/api/tasks | grep -q "Setup Development Environment"; then
    echo "✓ API tasks endpoint returns data"
else
    fail_test "API tasks endpoint failed"
fi

# Test API users endpoint
if curl -s http://localhost:${API_PORT}/api/users | grep -q "developer@example.com"; then
    echo "✓ API users endpoint returns data"
else
    fail_test "API users endpoint failed"
fi

# Test creating a new task via API
task_response=$(curl -s -X POST http://localhost:${API_PORT}/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task from test.sh","description":"Integration test","status":"pending"}')

if echo "$task_response" | grep -q "Test Task from test.sh"; then
    echo "✓ API can create tasks"
else
    fail_test "API create task failed"
fi

# Extract task ID for update and delete tests
task_id=$(echo "$task_response" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
if [ -n "$task_id" ]; then
    echo "✓ Task created with ID: $task_id"
else
    fail_test "Could not extract task ID"
fi

# Test updating the task
update_response=$(curl -s -X PUT http://localhost:${API_PORT}/api/tasks/${task_id} \
  -H "Content-Type: application/json" \
  -d '{"status":"completed"}')

if echo "$update_response" | grep -q "completed"; then
    echo "✓ API can update tasks"
else
    fail_test "API update task failed"
fi

# Test deleting the task
delete_response=$(curl -s -X DELETE http://localhost:${API_PORT}/api/tasks/${task_id})

if echo "$delete_response" | grep -q "deleted successfully"; then
    echo "✓ API can delete tasks"
else
    fail_test "API delete task failed"
fi

pass_test

# Test 8: Graceful shutdown
run_test "Graceful Shutdown" "Testing proper cleanup of all services"

if gaffer-exec --workspace-root . run make:stop > /dev/null 2>&1; then
    echo "✓ Stop command executed successfully"
else
    fail_test "Stop command failed"
fi

# Verify services stopped
sleep 1

if docker ps | grep -q "taskmanager-db"; then
    fail_test "Database container still running"
fi
echo "✓ Database stopped"

if [ -f ".temp/api.pid" ]; then
    fail_test "API PID file still exists"
fi
echo "✓ API process cleaned up"

if [ -f ".temp/frontend.pid" ]; then
    fail_test "Frontend PID file still exists"
fi
echo "✓ Frontend process cleaned up"

# Verify ready markers removed
if [ -f "db.ready" ] || [ -f "api.ready" ] || [ -f "frontend.ready" ]; then
    fail_test "Ready markers not cleaned up"
fi
echo "✓ Ready markers cleaned up"

pass_test

# Test 9: Full lifecycle with gaffer-exec
run_test "Complete Lifecycle Test" "Testing full dev workflow with gaffer-exec"

# Start the complete stack
start_time=$(date +%s)
if gaffer-exec --workspace-root . run make:dev > /dev/null 2>&1; then
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    echo "✓ Complete development stack started in ${duration}s"
else
    fail_test "Dev workflow failed"
fi

# Verify all services are running
if ! docker exec taskmanager-db pg_isready -U devuser -d taskmanager > /dev/null 2>&1; then
    fail_test "Database not running after dev command"
fi
echo "✓ Database is running"

if ! curl -s http://localhost:${API_PORT}/health > /dev/null 2>&1; then
    fail_test "API not running after dev command"
fi
echo "✓ API is running"

if ! curl -s http://localhost:${FRONTEND_PORT} > /dev/null 2>&1; then
    fail_test "Frontend not running after dev command"
fi
echo "✓ Frontend is running"

# Run integration tests
if gaffer-exec --workspace-root . run make:test > /dev/null 2>&1; then
    echo "✓ Integration tests passed"
else
    fail_test "Integration tests failed"
fi

# Stop all services
if gaffer-exec --workspace-root . run make:stop > /dev/null 2>&1; then
    echo "✓ All services stopped gracefully"
else
    fail_test "Failed to stop services"
fi

pass_test

# Test 10: Cleanup
run_test "Cleanup" "Testing complete cleanup of environment"

if gaffer-exec --workspace-root . run make:clean > /dev/null 2>&1; then
    echo "✓ Clean command executed successfully"
else
    fail_test "Clean command failed"
fi

# Verify cleanup
if [ -f ".env" ]; then
    fail_test ".env file not cleaned up"
fi
echo "✓ .env file removed"

if [ -f "setup.complete" ]; then
    fail_test "setup.complete not cleaned up"
fi
echo "✓ setup.complete removed"

if [ -d ".temp" ]; then
    fail_test ".temp directory not cleaned up"
fi
echo "✓ .temp directory removed"

pass_test

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}TEST SUMMARY${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Tests Run:    ${TESTS_RUN}"
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}$((TESTS_RUN - TESTS_PASSED))${NC}"
echo ""

if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "The Local Development Environment example is working correctly:"
    echo "  ✓ Auto port assignment"
    echo "  ✓ Dependency-aware startup (DB → API → Frontend)"
    echo "  ✓ Health checks and readiness validation"
    echo "  ✓ Integration testing"
    echo "  ✓ Graceful shutdown"
    echo "  ✓ Complete cleanup"
    echo ""
    echo "To use this example:"
    echo "  1. Run: gaffer-exec --workspace-root . run make:dev"
    echo "  2. Open: http://localhost:3000"
    echo "  3. Stop: gaffer-exec --workspace-root . run make:stop"
    exit 0
else
    echo -e "${RED}✗ Some tests failed!${NC}"
    exit 1
fi
