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

Since gaffer-exec doesn't have a native `platforms` field, we use shell conditionals with `uname` to control platform-specific execution:

```json
{
  "build-c-linux": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then mkdir -p c-app/bin && gcc -o c-app/bin/app c-app/main.c && echo '✓ Built for Linux'; else echo '⊘ Skipping on '$(uname); fi"
  },
  "build-c-macos": {
    "command": "if [ \"$(uname)\" = \"Darwin\" ]; then mkdir -p c-app/bin && clang -o c-app/bin/app c-app/main.c && echo '✓ Built for macOS'; else echo '⊘ Skipping on '$(uname); fi"
  },
  "build-c-windows": {
    "command": "if [ \"$(uname -o 2>/dev/null || echo 'Unknown')\" = \"Msys\" ]; then mkdir -p c-app/bin && gcc -o c-app/bin/app.exe c-app/main.c && echo '✓ Built for Windows'; else echo '⊘ Skipping on '$(uname); fi"
  }
}
```

When you run the build, **only the task matching your current platform actually builds** - others print a skip message.

## Example Structure

This example includes four cross-platform applications:

- **C Application** (`c-app/`) - Demonstrates platform-specific compilers
- **Go CLI Tool** (`go-cli/`) - Shows cross-compilation for multiple architectures
- **Rust Binary** (`rust-bin/`) - Platform-specific build targets
- **Node.js App** (`node-native/`) - Platform detection and native module considerations

## How the `platforms` Field Works

### Valid Platform Values
Shell-Based Platform Detection Works

### Platform Detection Commands

- **Linux**: `[ "$(uname)" = "Linux" ]`
- **macOS**: `[ "$(uname)" = "Darwin" ]`  
- **Windows (Git Bash/MSYS)**: `[ "$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ]`

### Execution Pattern

Each platform-specific task:
1. **Checks the current platform** using `uname`
2. **Executes the command** if the platform matches
3. **Prints a skip message** if the platform doesn't match

This ensures tasks always succeed but only perform work on the correct platform.

### Example Patterns

**Platform-Specific Dependency Installation:**
```json
{
  "install-deps-linux": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then sudo apt-get install build-essential && echo '✓ Installed'; else echo '⊘ Skipping on '$(uname); fi"
  },
  "install-deps-macos": {
    "command": "if [ \"$(uname)\" = \"Darwin\" ]; then brew install gcc && echo '✓ Installed'; else echo '⊘ Skipping on '$(uname); fi"
  },
  "install-deps": {
    "deps": ["install-deps-linux", "install-deps-macos"]
  }
}
```

The `install-deps` task depends on both platform-specific tasks. Each checks the platform internally, so only the matching one actually installs packages.

**Cross-Compilation:**
```json
{
  "build-go-linux-amd64": {
    "command": "GOOS=linux GOARCH=amd64 go build -o bin/app-linux-amd64",
    "working_dir": "go-cli"
  },
  "build-go-darwin-arm64": {
    "command": "GOOS=darwin GOARCH=arm64 go build -o bin/app-darwin-arm64",
    "working_dir": "go-cli"
  }
}
```

These tasks can run on any platform because they use Go's cross-compilation features. No platform check needed since they work
### 1. Detect Your Platform

```bash
gaffer-exec run detect-platform --graph graph.json
```

This runs the platform detection script to identify your OS and architecture.

### 2. Build for Your Platform

```bash
gaffer-exec run build-all --graph graph.json
```

This executes all platform-specific build tasks, but only those matching your current platform will actually run.

### 3. Run All Applications

```bash
gaffer-exec run run-all --graph graph.json
```

Executes all four applications, displaying platform information from each.

### 4. Cross-Compile (Go Example)

```bash
gaffer-exec run cross-compile-go --graph graph.json
```

Builds Go binaries for multiple platforms and architectures:
- Linux (amd64, arm64)
- macOS (amd64, arm64)
- Windows (amd64)

### 5. Clean Build Artifacts

```bash
gaffer-exec run clean --graph graph.json
```

## Project Structure

```
19-cross-platform-builds/
├── graph.json                    # Platform-aware task definitions
├── README.md                     # This file
├── PLATFORM_GUIDE.md            # Detailed platform field documentation
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

### 1. Platform-Specific vs Cross-Platform Tasks

**Platform-Specific Tasks** (with shell conditionals):
- Check platform using `uname` at runtime
- Execute only on matching platforms (others skip gracefully)
- Use platform-native tools (gcc on Linux, clang on macOS)
- Handle platform-specific dependencies

**Cross-Platform Tasks** (no platform checks):
- Execute on all platforms
- Use portable commands or tools with built-in cross-compilation
- Platform-agnostic operations (cleaning, linting, etc.)

### 2. Dependency Hierarchies

```json
{
  "build-all": {
    "deps": ["build-c", "build-go", "build-rust", "build-node"]
  },
  "build-c": {
    "deps": ["build-c-linux", "build-c-macos", "build-c-windows"]
  }
}
```

The `build-all` task depends on `build-c`, which depends on three platform-specific tasks. All three run, but only the matching platform performs actual work - the others print skip messages.

### 3. Working Directory

Use `working_dir` to run commands in subdirectories:

```json
{
  "build-go": {
    "command": "go build -o bin/app",
    "working_dir": "go-cli"
  }
}
```

This is especially useful in monorepos with multiple language projects.

## Testing on Different Platforms

### Linux
```bash
# Install dependencies
gaffer-exec run install-deps-linux --graph graph.json

# Build C app with gcc
gaffer-exec run build-c-linux --graph graph.json

# Run it
gaffer-exec run run-c-linux --graph graph.json
```

### macOS
```bash
# Install dependencies
gaffer-exec run install-deps-macos --graph graph.json

# Build C app with clang
gaffer-exec run build-c-macos --graph graph.json

# Run it
gaffer-exec run run-c-macos --graph graph.json
```

### Windows
```bash
# Install dependencies
gaffer-exec run install-deps-windows --graph graph.json

# Build C app
gaffer-exec run build-c-windows --graph graph.json

# Run it
gaffer-exec run run-c-windows --graph graph.json
```

## Real-World Use Cases

### 1. Native Module Compilation
When building Node.js or Python packages with native extensions, use platform-specific build tasks to invoke the correct compiler.

### 2. Desktop Application Distribution
Build macOS `.app` bundles, Windows `.exe` installers, and Linux AppImages with platform-specific packaging tasks.

### 3. CI/CD Pipelines
Define matrix builds where the same graph.json works across multiple CI runners (Ubuntu, macOS, Windows) but executes only relevant tasks.

### 4. Development Environment Setup
Install platform-specific development tools automatically based on the developer's OS.

## Benefits of Platform-Aware Workflows

1. **Explicit Platform Logic**: Shell conditionals make platform requirements visible
3. **Clear Dependencies**: Platform-specific build chains are explicit
4. **Graceful Degradation**: Tasks skip on wrong platforms instead of failing
5. **CI/CD Ready**: Same config works across different runners
6. **No Special Features Required**: Uses standard shell commands, works with any task runner
5. **CI/CD Ready**: Same config works across different runners

## Common Patterns

### Pattern 1: Platform Detection First

```json
{
  "setup": {
    "deps": ["detect-platform", "install-deps"]
  },
  "build": {
    "deps": ["setup", "build-all"]
  }
}
```

Detect platform, install dependencies, then build.

### Pattern 2: Platform-Specific Then Combine

```json
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then ...; else echo '⊘ Skipping'; fi"
  },
  "build-macos": {
    "command": "if [ \"$(uname)\" = \"Darwin\" ]; then ...; else echo '⊘ Skipping'; fi"
  },
  "build-windows": {
    "command": "if [ \"$(uname -o 2>/dev/null)\" = \"Msys\" ]; then ...; else echo '⊘ Skipping'; fi"
  },
  "build-all": {
    "deps": ["build-linux", "build-macos", "build-windows"]
  }
}
```

Define specific builds with inline platform check

Define specific builds, combine under one task.

### Pattern 3: Cross-Compilation Bundle

```json
{
  "cross-compile-all": {
    "deps": [
      "build-linux-amd64",
      "build-linux-arm64",
      "build-darwin-amd64",
      "build-darwin-arm64"
    ]
  }
}
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
- `graph.json` is valid JSON
- Platform detection works
- Tasks are properly defined
- Cross-compilation targets exist

## Further Reading

See [PLATFORM_GUIDE.md](PLATFORM_GUIDE.md) for:
- Complete platform field reference
- Advanced platform filtering techniques
- Best practices for cross-platform builds
- Common pitfalls and solutions

## Next Steps

1. **Extend to More Platforms**: Add FreeBSD, OpenBSD, or other Unix variants
2. **Add Architecture Variants**: Separate tasks for x86_64, arm64, etc.
3. **Containerized Builds**: Use Docker for reproducible cross-platform builds
4. **Artifact Management**: Upload platform-specific binaries to release storage
5. **Matrix Testing**: Run tests on all platform/architecture combinations
