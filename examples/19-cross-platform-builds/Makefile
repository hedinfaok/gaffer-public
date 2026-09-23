# Cross-Platform Builds
#
# Platform-aware build workflow. gaffer-exec consumes this standard Makefile and
# adds content-based caching and dependency-aware parallel scheduling on top.
#
#   gaffer-exec --workspace-root . run make:build-all
#   make build-all

.DEFAULT_GOAL := build-all

.PHONY: detect-platform install-deps-linux install-deps-macos install-deps-windows \
        install-deps build-c-linux build-c-macos build-c-windows build-c \
        run-c-linux run-c-macos run-c-windows run-c build-go build-go-linux-amd64 \
        build-go-linux-arm64 build-go-darwin-amd64 build-go-darwin-arm64 \
        build-go-windows-amd64 cross-compile-go run-go build-rust \
        build-rust-linux-x86_64 build-rust-macos-aarch64 build-rust-macos-x86_64 \
        build-rust-windows run-rust install-node-deps build-node run-node clean \
        build-all cross-compile-all run-all test

detect-platform:
	@bash scripts/detect-platform.sh

install-deps-linux:
	@if [ "$$(uname)" = "Linux" ]; then bash scripts/install-deps.sh && echo '✓ Installed Linux dependencies'; else echo '⊘ Skipping install-deps-linux on '$$(uname); fi

install-deps-macos:
	@if [ "$$(uname)" = "Darwin" ]; then bash scripts/install-deps.sh && echo '✓ Installed macOS dependencies'; else echo '⊘ Skipping install-deps-macos on '$$(uname); fi

install-deps-windows:
	@if [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ] || [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Cygwin" ]; then bash scripts/install-deps.sh && echo '✓ Installed Windows dependencies'; else echo '⊘ Skipping install-deps-windows on '$$(uname); fi

install-deps: install-deps-linux install-deps-macos install-deps-windows
	@echo '✓ Dependencies checked for all platforms'

build-c-linux: install-deps-linux
	@if [ "$$(uname)" = "Linux" ]; then mkdir -p c-app/bin && gcc -o c-app/bin/app c-app/main.c -O2 && echo '✓ Built C app for Linux'; else echo '⊘ Skipping build-c-linux on '$$(uname); fi

build-c-macos: install-deps-macos
	@if [ "$$(uname)" = "Darwin" ]; then mkdir -p c-app/bin && clang -o c-app/bin/app c-app/main.c -O2 && echo '✓ Built C app for macOS'; else echo '⊘ Skipping build-c-macos on '$$(uname); fi

build-c-windows: install-deps-windows
	@if [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ] || [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Cygwin" ]; then mkdir -p c-app/bin && gcc -o c-app/bin/app.exe c-app/main.c -O2 && echo '✓ Built C app for Windows'; else echo '⊘ Skipping build-c-windows on '$$(uname); fi

build-c: build-c-linux build-c-macos build-c-windows
	@echo '✓ C application build attempted for all platforms'

run-c-linux: build-c-linux
	@if [ "$$(uname)" = "Linux" ]; then ./c-app/bin/app; else echo '⊘ Skipping run-c-linux on '$$(uname); fi

run-c-macos: build-c-macos
	@if [ "$$(uname)" = "Darwin" ]; then ./c-app/bin/app; else echo '⊘ Skipping run-c-macos on '$$(uname); fi

run-c-windows: build-c-windows
	@if [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ] || [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Cygwin" ]; then ./c-app/bin/app.exe; else echo '⊘ Skipping run-c-windows on '$$(uname); fi

run-c: run-c-linux run-c-macos run-c-windows
	@echo '✓ C application run attempted'

build-go:
	@cd go-cli && go build -o bin/cross-platform-go-cli

build-go-linux-amd64:
	@cd go-cli && mkdir -p bin && GOOS=linux GOARCH=amd64 go build -o bin/app-linux-amd64

build-go-linux-arm64:
	@cd go-cli && mkdir -p bin && GOOS=linux GOARCH=arm64 go build -o bin/app-linux-arm64

build-go-darwin-amd64:
	@cd go-cli && mkdir -p bin && GOOS=darwin GOARCH=amd64 go build -o bin/app-darwin-amd64

build-go-darwin-arm64:
	@cd go-cli && mkdir -p bin && GOOS=darwin GOARCH=arm64 go build -o bin/app-darwin-arm64

build-go-windows-amd64:
	@cd go-cli && mkdir -p bin && GOOS=windows GOARCH=amd64 go build -o bin/app-windows-amd64.exe

cross-compile-go: build-go-linux-amd64 build-go-linux-arm64 build-go-darwin-amd64 build-go-darwin-arm64 build-go-windows-amd64
	@echo '✓ Go application cross-compiled for all platforms'

run-go: build-go
	@cd go-cli && ./bin/cross-platform-go-cli 2>/dev/null || go run main.go

build-rust:
	@cd rust-bin && cargo build --release

build-rust-linux-x86_64:
	@cd rust-bin && if [ "$$(uname)" = "Linux" ]; then cargo build --release --target x86_64-unknown-linux-gnu && echo '✓ Built Rust for Linux x86_64'; else echo '⊘ Skipping build-rust-linux-x86_64 on '$$(uname); fi

build-rust-macos-aarch64:
	@cd rust-bin && if [ "$$(uname)" = "Darwin" ]; then cargo build --release --target aarch64-apple-darwin && echo '✓ Built Rust for macOS ARM64'; else echo '⊘ Skipping build-rust-macos-aarch64 on '$$(uname); fi

build-rust-macos-x86_64:
	@cd rust-bin && if [ "$$(uname)" = "Darwin" ]; then cargo build --release --target x86_64-apple-darwin && echo '✓ Built Rust for macOS x86_64'; else echo '⊘ Skipping build-rust-macos-x86_64 on '$$(uname); fi

build-rust-windows:
	@cd rust-bin && if [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ] || [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Cygwin" ]; then cargo build --release --target x86_64-pc-windows-msvc && echo '✓ Built Rust for Windows'; else echo '⊘ Skipping build-rust-windows on '$$(uname); fi

run-rust: build-rust
	@cd rust-bin && cargo run --release

install-node-deps:
	@cd node-native && npm install

build-node: install-node-deps
	@cd node-native && npm run build

run-node:
	@cd node-native && node index.js

clean:
	@bash scripts/clean.sh

build-all: build-c build-go build-rust build-node
	@echo '✓ All applications built successfully'

cross-compile-all: cross-compile-go
	@echo '✓ Cross-compilation complete for all targets'

run-all: run-c run-go run-rust run-node
	@echo '✓ All applications executed successfully'

test:
	@bash test.sh
