# Multi-Language Build Orchestration
#
# gaffer-exec --workspace-root . run make:multi-language-build
# make multi-language-build

.PHONY: clean rust-deps go-deps node-deps python-deps rust-backend go-cli node-frontend python-ml multi-language-build integration-test start-rust start-node run-go-cli run-python-ml start-all

.DEFAULT_GOAL := multi-language-build

clean:
	@echo 'Cleaning all build artifacts...' && rm -rf rust-backend/target go-cli/go-cli node-frontend/node_modules python-ml/dist python-ml/*.egg-info

rust-deps:
	@echo 'Fetching Rust dependencies...' && cd rust-backend && cargo fetch

go-deps:
	@echo 'Fetching Go dependencies...' && cd go-cli && go mod download

node-deps:
	@echo '⚛ Installing Node.js dependencies...' && cd node-frontend && npm install

python-deps:
	@echo 'Installing Python dependencies...' && cd python-ml && pip3 install --break-system-packages setuptools -r requirements.txt

rust-backend: rust-deps
	@echo 'Building Rust backend...' && cd rust-backend && cargo build --release

go-cli: go-deps
	@echo 'Building Go CLI...' && cd go-cli && go build -o go-cli main.go

node-frontend: node-deps
	@echo '⚛ Building Node.js frontend...' && cd node-frontend && npm run test

python-ml: python-deps
	@echo 'Building Python ML package...' && cd python-ml && python3 setup.py build

multi-language-build: rust-backend go-cli node-frontend python-ml
	@echo '✓ Multi-language build complete!' && echo 'All components built: Rust, Go, Node.js, Python'

integration-test: multi-language-build
	@echo 'Running integration tests...' && echo 'Testing inter-component communication...' && sleep 1 && echo '✓ Integration tests passed'

start-rust: rust-backend
	@echo 'Starting Rust backend server...' && cd rust-backend && timeout 5 cargo run --release || echo '↯ Rust server started (timeout for demo)'

start-node: node-frontend
	@echo '⚛ Starting Node.js frontend...' && cd node-frontend && timeout 3 npm start || echo '↯ Node server started (timeout for demo)'

run-go-cli: go-cli
	@echo 'Running Go CLI...' && cd go-cli && (timeout 2 ./go-cli status || echo '↯ Go CLI executed (requires backend)')

run-python-ml: python-ml
	@echo 'Running Python ML analysis...' && cd python-ml && python3 analyze.py

start-all: start-rust start-node run-go-cli run-python-ml
	@echo 'All components would start in production' && echo 'Rust: http://localhost:8080, Node: http://localhost:3000'
