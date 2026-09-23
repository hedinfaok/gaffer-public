# Monorepo Build Orchestration
#
# Task graph for the TypeScript monorepo. gaffer-exec reads this Makefile and
# runs the targets with dependency-aware parallelism and caching:
#
#   gaffer-exec --workspace-root . run make:build-all
#
# The same targets also work with plain make:
#
#   make build-all

.PHONY: clean shared-lib auth-service user-service api-gateway web-app build-all start

# Remove all build artifacts
clean:
	@rm -rf packages/*/dist && echo 'Cleaned all build artifacts'

# Shared library (required by every service)
shared-lib:
	@echo 'Building shared-lib...' && npx tsc -p packages/shared-lib/tsconfig.json && echo '✓ shared-lib complete'

# Application services (build in parallel, both depend on shared-lib)
auth-service: shared-lib
	@echo 'Building auth-service...' && npx tsc -p packages/auth-service/tsconfig.json && echo '✓ auth-service complete'

user-service: shared-lib
	@echo 'Building user-service...' && npx tsc -p packages/user-service/tsconfig.json && echo '✓ user-service complete'

# API gateway (depends on both services)
api-gateway: auth-service user-service
	@echo 'Building api-gateway...' && npx tsc -p packages/api-gateway/tsconfig.json && echo '✓ api-gateway complete'

# Web application (top of the dependency chain)
web-app: api-gateway
	@echo 'Building web-app...' && npx tsc -p packages/web-app/tsconfig.json && echo '✓ web-app complete'

# Build everything
build-all: web-app
	@echo '' && echo '════════════════════════════════════════' && echo '✓ All packages built successfully!' && echo '════════════════════════════════════════' && echo 'Built: shared-lib, auth-service, user-service, api-gateway, web-app' && echo ''

# Run the web application (builds first if needed)
start: build-all
	@node packages/web-app/dist/index.js
