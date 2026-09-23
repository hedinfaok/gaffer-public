# Cross-Platform Builds

What this shows: one Makefile task graph that builds C, Go, Rust, and Node.js applications across Linux, macOS, and Windows by detecting the platform at runtime.

## What you'll learn

- Platform detection with `uname` inside Make recipes.
- Targets that skip gracefully on the wrong platform instead of failing.
- Cross-compilation with Go's `GOOS`/`GOARCH` environment variables.
- Aggregator targets that combine platform-specific builds under one entry point.
- Content-based caching and dependency-aware scheduling applied to platform-aware targets.

## Prerequisites

- gaffer-exec on your PATH
- A toolchain for the languages you want to build: `gcc`/`clang` for C, Go for the CLI, Cargo for Rust, Node.js for the Node app
- Optional platform tools: Homebrew on macOS, `build-essential` on Linux

## Quick start

```bash
# Identify your OS and architecture
gaffer-exec --workspace-root . run make:detect-platform

# Build every application (only matching platform targets do work)
gaffer-exec --workspace-root . run make:build-all

# Run the compiled applications
gaffer-exec --workspace-root . run make:run-all
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `detect-platform` | - | Prints OS and architecture |
| `install-deps-linux` | - | Installs dependencies when `uname` is Linux |
| `install-deps-macos` | - | Installs dependencies when `uname` is Darwin |
| `install-deps-windows` | - | Installs dependencies under MSYS/Cygwin |
| `install-deps` | all three above | Runs the platform checks |
| `build-c-linux` / `-macos` / `-windows` | matching `install-deps-*` | Compiles the C app with the platform compiler |
| `build-c` | all three C targets | Attempts the C build on every platform |
| `run-c` | `run-c-linux`, `run-c-macos`, `run-c-windows` | Runs the C app on the matching platform |
| `build-go` | - | Builds the Go CLI for the host |
| `build-go-linux-amd64` / `-arm64`, `-darwin-amd64` / `-arm64`, `-windows-amd64` | - | Cross-compiles the Go CLI |
| `cross-compile-go` | all Go cross targets | Builds all Go binaries |
| `build-rust` | - | Builds the Rust binary for the host |
| `build-rust-linux-x86_64`, `-macos-aarch64`, `-macos-x86_64`, `-windows` | - | Builds Rust for the matching platform |
| `install-node-deps` | - | Installs Node dependencies |
| `build-node` | `install-node-deps` | Builds the Node app |
| `run-node` | - | Runs the Node app |
| `clean` | - | Removes build artifacts |
| `build-all` | `build-c`, `build-go`, `build-rust`, `build-node` | Builds every application (default goal) |
| `cross-compile-all` | `cross-compile-go` | Alias for cross-compilation |
| `run-all` | `run-c`, `run-go`, `run-rust`, `run-node` | Runs every application |
| `test` | - | Runs the validation suite |

## How it works

A Makefile task graph has no native `platforms` field, so each platform-specific target checks `uname` at runtime and either does the work or prints a skip message:

```make
build-c-linux:
	@if [ "$$(uname)" = "Linux" ]; then mkdir -p c-app/bin && gcc -o c-app/bin/app c-app/main.c -O2 && echo '✓ Built C app for Linux'; else echo '⊘ Skipping build-c-linux on '$$(uname); fi
```

In a recipe `$$` emits a literal `$` to the shell, so `$$(uname)` runs the `uname` command. Detection keys off:

- Linux: `[ "$(uname)" = "Linux" ]`
- macOS: `[ "$(uname)" = "Darwin" ]`
- Windows (Git Bash/MSYS): `[ "$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ]`

Pattern: keep one graph and make platform logic explicit rather than maintaining a separate file per OS. Aggregator targets list every platform variant as a prerequisite; the non-matching variants exit successfully with a skip message, so the build never fails just because it is on the wrong OS. Go cross-compilation targets need no check because `GOOS`/`GOARCH` work everywhere.

## Expected output

On macOS, `make:build-all` builds the macOS targets and skips the others:

```text
⊘ Skipping install-deps-linux on Darwin
✓ Installed macOS dependencies
⊘ Skipping install-deps-windows on Darwin
✓ Built C app for macOS
✓ Go application built
✓ Built Rust for macOS ARM64
✓ All applications built successfully
```

`make:cross-compile-go` produces one binary per platform and architecture:

```text
✓ Go application cross-compiled for all platforms
```

## Testing

```bash
./test.sh
```

The suite verifies that the Makefile declares the expected targets, that platform detection works, that cross-compilation targets exist, and that gaffer-exec can list and dry-run the graph. To exercise a single platform path explicitly:

```bash
gaffer-exec --workspace-root . run make:install-deps-macos
gaffer-exec --workspace-root . run make:build-c-macos
gaffer-exec --workspace-root . run make:run-c-macos
```

See [PLATFORM_GUIDE.md](PLATFORM_GUIDE.md) for a fuller detection reference and common pitfalls.

## Troubleshooting

- **A build target skips unexpectedly**: that is expected on a non-matching OS; confirm your platform with `make:detect-platform`.
- **C compiler missing**: install `build-essential` on Linux or Xcode Command Line Tools on macOS.
- **Go cross-compile fails**: confirm Go is installed and `go version` works; `GOOS`/`GOARCH` builds do not need a cross toolchain.
- **Rust target not installed**: add it with `rustup target add <triple>` before running the matching `build-rust-*` target.

## Next example

[01-monorepo-build](../01-monorepo-build/README.md) shows dependency-aware parallel builds inside a single-language monorepo.
