# Platform Detection Guide

Comprehensive guide to using shell-based platform detection for cross-platform build workflows with gaffer-exec.

## Overview

gaffer-exec reads a standard `Makefile` and turns its targets and prerequisites into a schedulable, cacheable task graph. To control **which operating systems** a target executes on, the recipes use inline shell conditionals with `uname` to determine whether to execute or skip.

## Platform Detection Methods

### Supported Platforms

| Platform | Detection Command | Value |
|----------|------------------|-------|
| Linux | `[ "$(uname)" = "Linux" ]` | `Linux` |
| macOS | `[ "$(uname)" = "Darwin" ]` | `Darwin` |
| Windows (Git Bash/MSYS) | `[ "$(uname -o 2>/dev/null \|\| echo 'Unknown')" = "Msys" ]` | `Msys` |
| Windows (Cygwin) | `[ "$(uname -o 2>/dev/null \|\| echo 'Unknown')" = "Cygwin" ]` | `Cygwin` |

### How It Works

Each platform-specific target uses a shell conditional (`if`) to:
- Check the current platform using `uname`
- Execute the actual command if the platform matches
- Print a skip message if the platform doesn't match

This ensures targets always succeed but only perform work on the correct platform.

> **Note:** In a Makefile recipe, `$` starts a make variable reference. Write `$$(uname)` so make passes a literal `$(uname)` to the shell.

## Syntax

### Single Platform using a shell conditional:

```make
build-linux:
	@if [ "$$(uname)" = "Linux" ]; then make && echo '✓ Built'; else echo '⊘ Skipping on '$$(uname); fi
```

### Multiple Platforms (Combined Check)

Execute a target on multiple platforms using OR logic:

```make
build-unix:
	@if [ "$$(uname)" = "Linux" ] || [ "$$(uname)" = "Darwin" ]; then make && echo '✓ Built'; else echo '⊘ Skipping on '$$(uname); fi
```

### No Platform Filter (Universal)

Execute a target on all platforms:

```make
clean:
	@rm -rf build/
```

## Common Patterns

### Pattern 1: Platform-Specific Builds

Build the same artifact using different tools per platform:

```make
build-native-linux:
	@if [ "$$(uname)" = "Linux" ]; then gcc src/main.c -o bin/app && echo '✓ Built for Linux'; else echo '⊘ Skipping on '$$(uname); fi

build-native-macos:
	@if [ "$$(uname)" = "Darwin" ]; then clang src/main.c -o bin/app && echo '✓ Built for macOS'; else echo '⊘ Skipping on '$$(uname); fi

build-native-windows:
	@if [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ]; then gcc src/main.c -o bin/app.exe && echo '✓ Built for Windows'; else echo '⊘ Skipping on '$$(uname); fi

build-native: build-native-linux build-native-macos build-native-windows
	@echo '✓ Build attempted for all platforms'
```

Running `gaffer-exec --workspace-root . run make:build-native` will:
- On Linux: Execute the gcc command in `build-native-linux`, skip others
- On macOS: Execute the clang command in `build-native-macos`, skip others
- On Windows: Execute the gcc command in `build-native-windows`, skip others

### Pattern 2: Platform-Specific Dependencies

Install dependencies using the appropriate package manager:

```make
install-build-tools-debian:
	@if [ "$$(uname)" = "Linux" ]; then sudo apt-get install -y build-essential && echo '✓ Installed'; else echo '⊘ Skipping on '$$(uname); fi

install-build-tools-macos:
	@if [ "$$(uname)" = "Darwin" ]; then brew install gcc make && echo '✓ Installed'; else echo '⊘ Skipping on '$$(uname); fi

install-build-tools-windows:
	@if [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ]; then pacman -S mingw-w64-x86_64-gcc make --noconfirm && echo '✓ Installed'; else echo '⊘ Skipping on '$$(uname); fi

install-build-tools: install-build-tools-debian install-build-tools-macos install-build-tools-windows
	@echo '✓ Dependencies checked for all platforms'
```

### Pattern 3: Platform Detection Target

Run a detection script on all platforms, then branch:

```make
detect:
	@bash scripts/detect.sh

setup-linux: detect
	@if [ "$$(uname)" = "Linux" ]; then bash scripts/setup-linux.sh; else echo '⊘ Skipping on '$$(uname); fi

setup-macos: detect
	@if [ "$$(uname)" = "Darwin" ]; then bash scripts/setup-macos.sh; else echo '⊘ Skipping on '$$(uname); fi

setup: setup-linux setup-macos
	@echo '✓ Setup attempted'
```

### Pattern 4: Cross-Compilation

Build for multiple targets from any platform:

```make
cross-linux:
	@cd src && GOOS=linux GOARCH=amd64 go build -o ../dist/app-linux

cross-macos:
	@cd src && GOOS=darwin GOARCH=amd64 go build -o ../dist/app-darwin

cross-windows:
	@cd src && GOOS=windows GOARCH=amd64 go build -o ../dist/app-windows.exe

cross-all: cross-linux cross-macos cross-windows
	@echo '✓ Cross-compilation complete'
```

These targets have no platform guard, so they run on any platform (assuming Go is installed).

### Pattern 5: Platform-Specific Tests

Run tests using platform-native test runners:

```make
test-linux:
	@if [ "$$(uname)" = "Linux" ]; then ./run-tests.sh; else echo '⊘ Skipping on '$$(uname); fi

test-macos:
	@if [ "$$(uname)" = "Darwin" ]; then ./run-tests.sh; else echo '⊘ Skipping on '$$(uname); fi

test-windows:
	@if [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ]; then ./run-tests.sh; else echo '⊘ Skipping on '$$(uname); fi
```

Create a parent target that depends on all platform-specific variants:

```make
build: build-linux build-macos build-windows
	@echo '✓ Build attempted for all platforms'
```

This allows users to run `gaffer-exec --workspace-root . run make:build` regardless of platform.

## Best Practices

### 1. Aggregate Platform-Specific Targets

Users should not need to know which target to run for their platform. Create an aggregator:

```make
build: build-linux build-macos build-windows
	@echo '✓ Build attempted for all platforms'
```

Each platform-specific target will check internally and either execute or skip gracefully.

### 2. Keep Commands Readable

For complex commands, extract to scripts and keep the conditional simple:

**✗ Hard to read:**
```make
build-linux:
	@if [ "$$(uname)" = "Linux" ]; then if [ -d build ]; then rm -rf build; fi && mkdir build && gcc ...; else echo '⊘ Skipping'; fi
```

**✓ Better:**
```make
build-linux:
	@if [ "$$(uname)" = "Linux" ]; then bash scripts/build-linux.sh; else echo '⊘ Skipping on '$$(uname); fi
```

### 3. Consistent Skip Messages

Use a consistent pattern for skip messages to make logs readable:

```make
	@echo '⊘ Skipping task-name on '$$(uname)
```

### 4. Document Platform Requirements

In your README, clearly state which platforms are supported and any prerequisites:

```markdown
## Platform Support

- **Linux**: Requires gcc 9+ and make
- **macOS**: Requires Xcode Command Line Tools
- **Windows**: Requires MSYS2 or Git Bash with MinGW
```

### 5. Test on All Platforms

If possible, test your Makefile on all target platforms before committing:

```bash
# On Linux
gaffer-exec --workspace-root . run make:test

# On macOS
gaffer-exec --workspace-root . run make:test

# On Windows (Git Bash)
gaffer-exec --workspace-root . run make:test
```

### 6. Use Platform-Agnostic Tools When Possible

Prefer tools that work the same across platforms:

- **Node.js scripts** instead of bash/PowerShell
- **Python scripts** instead of platform-specific binaries
- **Docker** for consistent build environments
- **Go/Rust** for portable compiled tools

### 7. Handle Path Separators

Windows traditionally uses `\` while Unix uses `/`. In modern shells (Git Bash, MSYS2), forward slashes usually work everywhere:

```make
copy-files:
	@cp src/file.txt dest/file.txt
```

## Advanced Techniques

### Conditional Dependencies

Create dependency chains that only execute on specific platforms:

```make
install-deps-linux:
	@if [ "$$(uname)" = "Linux" ]; then apt-get install -y libssl-dev; else echo '⊘ Skipping'; fi

build-linux: install-deps-linux
	@if [ "$$(uname)" = "Linux" ]; then gcc main.c -o app -lssl; else echo '⊘ Skipping'; fi
```

On Linux: Both targets execute commands.
On macOS/Windows: Both targets skip with messages.

### Platform-Specific Environment Variables

Prefix the recipe with the environment variables:

```make
build-linux:
	@if [ "$$(uname)" = "Linux" ]; then CC=gcc CFLAGS="-O2 -Wall" make; else echo '⊘ Skipping'; fi

build-macos:
	@if [ "$$(uname)" = "Darwin" ]; then CC=clang CFLAGS="-O2 -Wall -Wextra" make; else echo '⊘ Skipping'; fi
```

### Platform-Specific Working Directories

Different source locations per platform:

```make
build-unix-linux:
	@cd unix-build && if [ "$$(uname)" = "Linux" ]; then make; else echo '⊘ Skipping'; fi

build-unix-macos:
	@cd unix-build && if [ "$$(uname)" = "Darwin" ]; then make; else echo '⊘ Skipping'; fi

build-windows:
	@cd windows-build && if [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ]; then nmake; else echo '⊘ Skipping'; fi
```

## Common Pitfalls

### Pitfall 1: Forgetting to Aggregate

**Problem:**
```make
build-linux:
	@if [ "$$(uname)" = "Linux" ]; then ...; fi

build-macos:
	@if [ "$$(uname)" = "Darwin" ]; then ...; fi
```

Users must know which target to run for their platform.

**Solution:** Add an aggregator:
```make
build: build-linux build-macos
	@echo '✓ Build attempted for all platforms'
```

### Pitfall 2: Duplicating Platform Logic

**Problem:**
```bash
#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux-specific
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific
fi
```

This duplicates the platform check already in the target definition.

**Solution:** Use the shell conditional in the target and keep scripts simple:
```make
setup-linux:
	@if [ "$$(uname)" = "Linux" ]; then bash scripts/setup.sh; else echo '⊘ Skipping'; fi
```

### Pitfall 3: Assuming Command Availability

**Problem:**
```make
build:
	@make
```

`make` may not be installed on all platforms.

**Solution:** Use platform-specific alternatives:
```make
build-unix:
	@if [ "$$(uname)" = "Linux" ] || [ "$$(uname)" = "Darwin" ]; then make; else echo '⊘ Skipping'; fi

build-windows:
	@if [ "$$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ]; then nmake; else echo '⊘ Skipping'; fi
```

### Pitfall 4: Incorrect uname Values

**Problem:**
```make
build-mac:
	@if [ "$$(uname)" = "macOS" ]; then ...; fi
```

`uname` returns `Darwin`, not `macOS`.

**Solution:**
```make
build-macos:
	@if [ "$$(uname)" = "Darwin" ]; then ...; fi
```

### Pitfall 5: Forgetting to Escape `$`

**Problem:**
```make
build-linux:
	@if [ "$(uname)" = "Linux" ]; then ...; fi
```

Make expands `$(uname)` as a make variable (usually empty), so the shell test never matches.

**Solution:** Escape the dollar sign so the shell sees the command substitution:
```make
build-linux:
	@if [ "$$(uname)" = "Linux" ]; then ...; fi
```

### Pitfall 6: Platform-Specific Bugs

**Problem:** Not testing on all platforms leads to broken targets.

**Solution:**
- Use CI/CD with matrix builds (Linux, macOS, Windows runners)
- Test locally with VMs or containers
- Write platform-agnostic code when possible

## Platform Detection in Scripts

If you need platform detection within scripts:

### Bash

```bash
#!/usr/bin/env bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="darwin"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
    PLATFORM="windows"
else
    PLATFORM="unknown"
fi

echo "Detected platform: $PLATFORM"
```

### Node.js

```javascript
const os = require('os');

const platform = os.platform(); // 'linux', 'darwin', 'win32'
const arch = os.arch();           // 'x64', 'arm64', etc.

console.log(`Platform: ${platform}`);
console.log(`Architecture: ${arch}`);
```

### Python

```python
import platform

system = platform.system()  # 'Linux', 'Darwin', 'Windows'
machine = platform.machine()  # 'x86_64', 'arm64', etc.

print(f"System: {system}")
print(f"Machine: {machine}")
```

### Go

```go
package main

import (
    "fmt"
    "runtime"
)

func main() {
    fmt.Printf("OS: %s\n", runtime.GOOS)       // linux, darwin, windows
    fmt.Printf("Arch: %s\n", runtime.GOARCH)   // amd64, arm64, etc.
}
```

### Rust

```rust
fn main() {
    println!("OS: {}", std::env::consts::OS);       // linux, macos, windows
    println!("Arch: {}", std::env::consts::ARCH);   // x86_64, aarch64, etc.
}
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Cross-Platform Build

on: [push, pull_request]

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: gaffer-exec --workspace-root . run make:build
```

Same `Makefile`, different runners, platform-specific execution.

### GitLab CI

```yaml
stages:
  - build

build-linux:
  stage: build
  tags: [linux]
  script:
    - gaffer-exec --workspace-root . run make:build

build-macos:
  stage: build
  tags: [macos]
  script:
    - gaffer-exec --workspace-root . run make:build

build-windows:
  stage: build
  tags: [windows]
  script:
    - gaffer-exec --workspace-root . run make:build
```

## Summary

- gaffer-exec consumes a standard `Makefile` and adds caching and parallel scheduling
- Use shell conditionals with `uname` to control target execution by OS
- Linux: `[ "$(uname)" = "Linux" ]`
- macOS: `[ "$(uname)" = "Darwin" ]`
- Windows (Git Bash/MSYS): `[ "$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ]`
- Escape make's `$` as `$$` inside recipes: `[ "$$(uname)" = "Linux" ]`
- Targets without platform checks run everywhere
- Create aggregator targets (via prerequisites) to unify platform-specific variants
- Test on all target platforms
- Keep commands readable with clear skip messages
- Document platform requirements clearly

Shell-based platform detection enables clean, maintainable cross-platform workflows without requiring special task runner features.
