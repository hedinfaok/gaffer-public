# Distributed Build Example Makefile
#
# This demonstrates the same build orchestration that gaffer-exec provides,
# but using traditional make. Compare with: gaffer-exec run distributed-build

.PHONY: all clean build-services build-packages test

# Go build settings
GO := go
GOFLAGS := -v

# Build directories
PKG_DIR := pkg
CMD_DIR := cmd
CACHE_DIR := .cache

# Package targets
COMMON_PKG := $(PKG_DIR)/common/common.a
MODELS_PKG := $(PKG_DIR)/models/models.a

# Service targets  
GATEWAY_BIN := $(CMD_DIR)/gateway/main
AUTH_BIN := $(CMD_DIR)/auth/main
USERS_BIN := $(CMD_DIR)/users/main

# Default target - same as gaffer-exec run distributed-build
all: build-services

# Clean all artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(CMD_DIR)/*/main $(CMD_DIR)/*/*.exe
	@rm -rf $(PKG_DIR)/*/*.a
	@rm -rf $(CACHE_DIR)/cmd $(CACHE_DIR)/pkg

# Initialize and fetch dependencies
init: clean
	@echo "📦 Initializing Go modules..."
	@$(GO) mod tidy

# Build packages (can run in parallel)
build-packages: $(COMMON_PKG) $(MODELS_PKG)

$(COMMON_PKG): $(PKG_DIR)/common/*.go
	@echo "🔨 Building common package..."
	@$(GO) build -buildmode=archive -o $@ ./$(PKG_DIR)/common

$(MODELS_PKG): $(PKG_DIR)/models/*.go  
	@echo "🔨 Building models package..."
	@$(GO) build -buildmode=archive -o $@ ./$(PKG_DIR)/models

# Build services (depends on packages)
build-services: build-packages $(GATEWAY_BIN) $(AUTH_BIN) $(USERS_BIN)
	@echo "✅ All microservices built successfully!"

$(GATEWAY_BIN): $(CMD_DIR)/gateway/*.go $(COMMON_PKG) $(MODELS_PKG)
	@echo "🔨 Building gateway service..."
	@$(GO) build -o $@ ./$(CMD_DIR)/gateway

$(AUTH_BIN): $(CMD_DIR)/auth/*.go $(COMMON_PKG) $(MODELS_PKG)
	@echo "🔨 Building auth service..."
	@$(GO) build -o $@ ./$(CMD_DIR)/auth

$(USERS_BIN): $(CMD_DIR)/users/*.go $(COMMON_PKG) $(MODELS_PKG)
	@echo "🔨 Building users service..."
	@$(GO) build -o $@ ./$(CMD_DIR)/users

# Test all services
test: build-services
	@echo "🧪 Testing services..."
	@$(GO) test ./pkg/...
	@echo "✅ All tests passed!"

# Show build info
info:
	@echo "🏗️  Distributed Build System"
	@echo "📁 Structure:"
	@echo "   - Packages: common, models"  
	@echo "   - Services: gateway, auth, users"
	@echo ""
	@echo "🚀 Commands:"
	@echo "   make all          # Build everything (== gaffer-exec run distributed-build)"
	@echo "   make clean        # Clean artifacts" 
	@echo "   make build-packages # Build just packages"
	@echo "   make test         # Build and test"
	@echo ""
	@echo "⚡ gaffer-exec equivalent:"
	@echo "   gaffer-exec run distributed-build --graph graph.json"