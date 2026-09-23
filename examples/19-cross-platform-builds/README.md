# Example 19: Cross-Platform Builds

This example demonstrates **platform-aware build workflows** using shell-based platform detection to manage cross-platform builds effectively.

## The Problem

Building software for multiple operating systems and architectures presents several challenges:

1. **Platform-Specific Toolchains**: Different OSes use different compilers (gcc vs clang vs msvc)
2. **Conditional Execution**: Some build steps should only run on specific platforms
3. **Cross-Compilation**: Building binaries for platforms different from the host
4. **Dependency Management**: Different package managers per platform (apt, brew, choco)
5. **Path Differences**: Windows uses `\` while Unix uses `/`
6. **Binary Formats**: ELF (Linux), Mach-O (macOS), PE (Windows)

Traditional build tools require complex shell scripting or separate configuration files per platform.

## The Solution: Shell-Based Platform Detection

gaffer-exec consumes a standard `Makefile`: it reads the targets and prerequisites into a task graph and adds content-based caching and dependency-aware parallel scheduling on top. Since the Makefile task graph has no native `platforms` field, we use shell conditionals with `uname` to control platform-specific execution:

```make
build-c-linux:
	@if [ "$$(uname)" = "Linux" ]; then mkdir -p c-app/bin && gcc -o c-app/bin/app c-app/main.c && echo '✓ Built for Linux'; else echo '⊘ Skipping on '$$(uname); fi

build-c-macos:
	@if [ "$$(uname)" = "Darwin" ]; then mkdir -p c-app/bin && clang -o c-app/bin/app c-app/main.c && echo '✓ Built for macOS'; else echo '⊘ Skipping on '$$(uname); fi

build-c-windows:
	@if [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ]; then mkdir -p c-app/bin && gcc -o c-app/bin/app.exe c-app/main.c && echo '✓ Built for Windows'; else echo '⊘ Skipping on '$$(uname); fi
```

In a Makefile recipe `$$` emits a literal `$` to the shell, so `$$(uname)` runs the `uname` command.

When you run the build, **only the target matching your current platform actually builds** - others print a skip message.

## Example Structure

This example includes four cross-platform applications:

- **C Application** (`c-app/`) - Demonstrates platform-specific compilers
- **Go CLI Tool** (`go-cli/`) - Shows cross-compilation for multiple architectures
- **Rust Binary** (`rust-bin/`) - Platform-specific build targets
- **Node.js App** (`node-native/`) - Platform detection and native module considerations

## How Shell-Based Platform Detection Works

### Platform Detection Commands

- **Linux**: `[ "$(uname)" = "Linux" ]`
- **macOS**: `[ "$(uname)" = "Darwin" ]`  
- **Windows (Git Bash/MSYS)**: `[ "$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ]`

### Execution Pattern

Each platform-specific target:
1. **Checks the current platform** using `uname`
2. **Executes the command** if the platform matches
3. **Prints a skip message** if the platform doesn't match

This ensures targets always succeed but only perform work on the correct platform.

### Example Patterns

**Platform-Specific Dependency Installation:**
```make
install-deps-linux:
	@if [ "$$(uname)" = "Linux" ]; then sudo apt-get install build-essential && echo '✓ Installed'; else echo '⊘ Skipping on '$$(uname); fi

install-deps-macos:
	@if [ "$$(uname)" = "Darwin" ]; then brew install gcc && echo '✓ Installed'; else echo '⊘ Skipping on '$$(uname); fi

install-deps: install-deps-linux install-deps-macos
	@echo '✓ Dependencies checked'
```

The `install-deps` target lists both platform-specific targets as prerequisites. Each checks the platform internally, so only the matching one actually installs packages.

**Cross-Compilation:**
```make
build-go-linux-amd64:
	@cd go-cli && GOOS=linux GOARCH=amd64 go build -o bin/app-linux-amd64

build-go-darwin-arm64:
	@cd go-cli && GOOS=darwin GOARCH=arm64 go build -o bin/app-darwin-arm64
```

These targets can run on any platform because they use Go's cross-compilation features. No platform check is needed since they work everywhere.

## Usage

### 1. Detect Your Platform

```bash
gaffer-exec --workspace-root . run make:detect-platform
```

This runs the platform detection script to identify your OS and architecture.

### 2. Build for Your Platform

```bash
gaffer-exec --workspace-root . run make:build-all
```

This executes all platform-specific build targets, but only those matching your current platform will actually run.

### 3. Run All Applications

```bash
gaffer-exec --workspace-root . run make:run-all
```

Executes all four applications, displaying platform information from each.

### 4. Cross-Compile (Go Example)

```bash
gaffer-exec --workspace-root . run make:cross-compile-go
```

Builds Go binaries for multiple platforms and architectures:
- Linux (amd64, arm64)
- macOS (amd64, arm64)
- Windows (amd64)

### 5. Clean Build Artifacts

```bash
gaffer-exec --workspace-root . run make:clean
```

## Project Structure

```
19-cross-platform-builds/
├── Makefile                      # Platform-aware task graph
├── README.md                     # This file
├── PLATFORM_GUIDE.md            # Detailed platform detection documentation
├── test.sh                       # Validation test suite
├── c-app/
│   └── main.c                    # C program with platform detection
├── go-cli/
│   ├── main.go                   # Go CLI with runtime platform info
│   └── go.mod
├── rust-bin/
│   ├── Cargo.toml
│   └── src/main.rs              # Rust app with conditional compilation
├── node-native/
│   ├── package.json
│   └── index.js                 # Node.js with platform checks
└── scripts/
    ├── detect-platform.sh       # Platform detection utility
    ├── install-deps.sh          # Platform-specific installation
    └── clean.sh                 # Clean build artifacts
```

## Key Concepts

### 1. Platform-Specific vs Cross-Platform Targets

**Platform-Specific Targets** (with shell conditionals):
- Check platform using `uname` at runtime
- Execute only on matching platforms (others skip gracefully)
- Use platform-native tools (gcc on Linux, clang on macOS)
- Handle platform-specific dependencies

**Cross-Platform Targets** (no platform checks):
- Execute on all platforms
- Use portable commands or tools with built-in cross-compilation
- Platform-agnostic operations (cleaning, linting, etc.)

### 2. Dependency Hierarchies

```make
build-all: build-c build-go build-rust build-node
	@echo '✓ All applications built successfully'

build-c: build-c-linux build-c-macos build-c-windows
	@echo '✓ C application build attempted for all platforms'
```

The `build-all` target depends on `build-c`, which depends on three platform-specific targets. All three run, but only the matching platform performs actual work - the others print skip messages.

### 3. Working Directory

Prefix a recipe with `cd DIR &&` to run commands in a subdirectory:

```make
build-go:
	@cd go-cli && go build -o bin/app
```

This is especially useful in monorepos with multiple language projects.

## Testing on Different Platforms

### Linux
```bash
# Install dependencies
gaffer-exec --workspace-root . run make:install-deps-linux

# Build C app with gcc
gaffer-exec --workspace-root . run make:build-c-linux

# Run it
gaffer-exec --workspace-root . run make:run-c-linux
```

### macOS
```bash
# Install dependencies
gaffer-exec --workspace-root . run make:install-deps-macos

# Build C app with clang
gaffer-exec --workspace-root . run make:build-c-macos

# Run it
gaffer-exec --workspace-root . run make:run-c-macos
```

### Windows
```bash
# Install dependencies
gaffer-exec --workspace-root . run make:install-deps-windows

# Build C app
gaffer-exec --workspace-root . run make:build-c-windows

# Run it
gaffer-exec --workspace-root . run make:run-c-windows
```

## Real-World Use Cases

### 1. Native Module Compilation
When building Node.js or Python packages with native extensions, use platform-specific build targets to invoke the correct compiler.

### 2. Desktop Application Distribution
Build macOS `.app` bundles, Windows `.exe` installers, and Linux AppImages with platform-specific packaging targets.

### 3. CI/CD Pipelines
Define matrix builds where the same Makefile works across multiple CI runners (Ubuntu, macOS, Windows) but executes only relevant targets.

### 4. Development Environment Setup
Install platform-specific development tools automatically based on the developer's OS.

## Benefits of Platform-Aware Workflows

1. **Explicit Platform Logic**: Shell conditionals make platform requirements visible
2. **Clear Dependencies**: Platform-specific build chains are explicit as Make prerequisites
3. **Graceful Degradation**: Targets skip on wrong platforms instead of failing
4. **CI/CD Ready**: Same Makefile works across different runners
5. **No Special Features Required**: Uses standard shell commands, works with GNU Make and gaffer-exec

## Common Patterns

### Pattern 1: Platform Detection First

```make
setup: detect-platform install-deps
build: setup build-all
```

Detect platform, install dependencies, then build.

### Pattern 2: Platform-Specific Then Combine

```make
build-linux:
	@if [ "$$(uname)" = "Linux" ]; then ...; else echo '⊘ Skipping'; fi

build-macos:
	@if [ "$$(uname)" = "Darwin" ]; then ...; else echo '⊘ Skipping'; fi

build-windows:
	@if [ "$$(uname -o 2>/dev/null)" = "Msys" ]; then ...; else echo '⊘ Skipping'; fi

build-all: build-linux build-macos build-windows
	@echo '✓ Build attempted for all platforms'
```

Define specific builds with inline platform checks, then combine them under one aggregator target.

### Pattern 3: Cross-Compilation Bundle

```make
cross-compile-all: build-linux-amd64 build-linux-arm64 build-darwin-amd64 build-darwin-arm64
	@echo '✓ Cross-compilation complete'
```

Generate all platform binaries in one go (requires cross-compilation toolchain).

## Platform-Specific Considerations

### Linux
- Package managers: apt (Debian/Ubuntu), yum (RHEL/CentOS), pacman (Arch)
- Compilers: GCC, Clang
- Binary format: ELF
- Paths: Forward slash `/`

### macOS
- Package manager: Homebrew
- Compiler: Clang (via Xcode Command Line Tools)
- Binary format: Mach-O
- Paths: Forward slash `/`
- Codesigning: May be required for distribution

### Windows
- Package manager: Chocolatey, winget, scoop
- Compilers: MSVC, MinGW
- Binary format: PE (Portable Executable)
- Paths: Backslash `\` (but forward slash often works)
- UAC: Admin privileges for some operations

## Validation

Run the test suite to verify everything works:

```bash
./test.sh
```

This validates:
- `Makefile` exists and declares the expected targets
- Platform detection works
- Targets are properly defined
- Cross-compilation targets exist
- gaffer-exec can list and dry-run the Makefile graph

## Further Reading

See [PLATFORM_GUIDE.md](PLATFORM_GUIDE.md) for:
- Complete platform detection reference
- Advanced platform filtering techniques
- Best practices for cross-platform builds
- Common pitfalls and solutions

## Next Steps

1. **Extend to More Platforms**: Add FreeBSD, OpenBSD, or other Unix variants
2. **Add Architecture Variants**: Separate targets for x86_64, arm64, etc.
3. **Containerized Builds**: Use Docker for reproducible cross-platform builds
4. **Artifact Management**: Upload platform-specific binaries to release storage
5. **Matrix Testing**: Run tests on all platform/architecture combinations
