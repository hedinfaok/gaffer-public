# Platform Field Guide

Comprehensive guide to using gaffer-exec's `platforms` field for cross-platform build workflows.

## Overview

The `platforms` field in task definitions controls **which operating systems** a task should execute on. Tasks without a `platforms` field execute on all platforms.

## Platform Values

### Supported Platforms

| Value | Description | Aliases |
|-------|-------------|---------|
| `"linux"` | Linux distributions (Ubuntu, Debian, RHEL, etc.) | - |
| `"darwin"` | macOS / Mac OS X | `"macos"` |
| `"macos"` | macOS / Mac OS X | `"darwin"` |
| `"windows"` | Windows (7, 10, 11, Server, etc.) | - |

### Platform Detection

Gaffer-exec determines the current platform using standard OS detection methods:
- On Linux: Checks for Linux kernel
- On macOS: Checks for Darwin kernel
- On Windows: Checks for Windows NT kernel

## Syntax

### Single Platform

Execute task only on one platform:

```json
{
  "build-linux": {
    "command": "make",
    "platforms": ["linux"]
  }
}
```

### Multiple Platforms

Execute task on multiple platforms:

```json
{
  "build-unix": {
    "command": "make",
    "platforms": ["linux", "darwin"]
  }
}
```

### No Platform Filter (Universal)

Execute task on all platforms:

```json
{
  "clean": {
    "command": "rm -rf build/"
  }
}
```

## Common Patterns

### Pattern 1: Platform-Specific Builds

Build the same artifact using different tools per platform:

```json
{
  "build-native-linux": {
    "command": "gcc src/main.c -o bin/app",
    "platforms": ["linux"]
  },
  "build-native-macos": {
    "command": "clang src/main.c -o bin/app",
    "platforms": ["darwin"]
  },
  "build-native-windows": {
    "command": "cl.exe src\\main.c /Fe:bin\\app.exe",
    "platforms": ["windows"]
  },
  "build-native": {
    "deps": ["build-native-linux", "build-native-macos", "build-native-windows"]
  }
}
```

Running `gaffer-exec run build-native` will:
- On Linux: Execute `build-native-linux`
- On macOS: Execute `build-native-macos`
- On Windows: Execute `build-native-windows`

### Pattern 2: Platform-Specific Dependencies

Install dependencies using the appropriate package manager:

```json
{
  "install-build-tools-debian": {
    "command": "sudo apt-get install -y build-essential",
    "platforms": ["linux"]
  },
  "install-build-tools-macos": {
    "command": "brew install gcc make",
    "platforms": ["darwin"]
  },
  "install-build-tools-windows": {
    "command": "choco install -y mingw make",
    "platforms": ["windows"]
  },
  "install-build-tools": {
    "deps": ["install-build-tools-debian", "install-build-tools-macos", "install-build-tools-windows"]
  }
}
```

### Pattern 3: Platform Detection Task

Run a detection script on all platforms, then branch:

```json
{
  "detect": {
    "command": "bash scripts/detect.sh"
  },
  "setup-linux": {
    "command": "bash scripts/setup-linux.sh",
    "platforms": ["linux"],
    "deps": ["detect"]
  },
  "setup-macos": {
    "command": "bash scripts/setup-macos.sh",
    "platforms": ["darwin"],
    "deps": ["detect"]
  },
  "setup": {
    "deps": ["setup-linux", "setup-macos"]
  }
}
```

### Pattern 4: Cross-Compilation

Build for multiple targets from any platform:

```json
{
  "cross-linux": {
    "command": "GOOS=linux GOARCH=amd64 go build -o dist/app-linux",
    "working_dir": "src"
  },
  "cross-macos": {
    "command": "GOOS=darwin GOARCH=amd64 go build -o dist/app-darwin",
    "working_dir": "src"
  },
  "cross-windows": {
    "command": "GOOS=windows GOARCH=amd64 go build -o dist/app-windows.exe",
    "working_dir": "src"
  },
  "cross-all": {
    "deps": ["cross-linux", "cross-macos", "cross-windows"]
  }
}
```

No `platforms` field means these run on any platform (assuming Go is installed).

### Pattern 5: Platform-Specific Tests

Run tests using platform-native test runners:

```json
{
  "test-linux": {
    "command": "./run-tests.sh",
    "platforms": ["linux"]
  },
  "test-macos": {
    "command": "./run-tests.sh",
    "platforms": ["darwin"]
  },
  "test-windows": {
    "command": ".\\run-tests.bat",
    "platforms": ["windows"]
  },
  "test": {
    "deps": ["test-linux", "test-macos", "test-windows"]
  }
}
```

## Best Practices

### 1. Use Aggregator Tasks

Create a parent task that depends on all platform-specific variants:

```json
{
  "build": {
    "deps": ["build-linux", "build-macos", "build-windows"]
  }
}
```

This allows users to run `gaffer-exec run build` regardless of platform.

### 2. Keep Commands Simple

Avoid complex shell logic in commands. Use scripts instead:

**❌ Bad:**
```json
{
  "build-linux": {
    "command": "if [ -d build ]; then rm -rf build; fi && mkdir build && gcc ...",
    "platforms": ["linux"]
  }
}
```

**✅ Good:**
```json
{
  "build-linux": {
    "command": "bash scripts/build-linux.sh",
    "platforms": ["linux"]
  }
}
```

### 3. Use Both Platform Aliases

For macOS, specify both `darwin` and `macos` for compatibility:

```json
{
  "build-macos": {
    "command": "clang src/main.c -o bin/app",
    "platforms": ["darwin", "macos"]
  }
}
```

### 4. Document Platform Requirements

In your README, clearly state which platforms are supported and any prerequisites:

```markdown
## Platform Support

- **Linux**: Requires gcc 9+ and make
- **macOS**: Requires Xcode Command Line Tools
- **Windows**: Requires MinGW or MSVC
```

### 5. Validate on All Platforms

If possible, test your graph.json on all target platforms before committing:

```bash
# On Linux
gaffer-exec run test --graph graph.json

# On macOS
gaffer-exec run test --graph graph.json

# On Windows
gaffer-exec run test --graph graph.json
```

### 6. Use Platform-Agnostic Tools When Possible

Prefer tools that work the same across platforms:

- **Node.js scripts** instead of bash/PowerShell
- **Python scripts** instead of platform-specific binaries
- **Docker** for consistent build environments
- **Go/Rust** for portable compiled tools

### 7. Handle Path Separators

Windows uses `\` while Unix uses `/`. Options:

**Option A: Use forward slashes (works on modern Windows):**
```json
{
  "copy-windows": {
    "command": "copy src/file.txt dest/file.txt",
    "platforms": ["windows"]
  }
}
```

**Option B: Use separate tasks:**
```json
{
  "copy-unix": {
    "command": "cp src/file.txt dest/file.txt",
    "platforms": ["linux", "darwin"]
  },
  "copy-windows": {
    "command": "copy src\\file.txt dest\\file.txt",
    "platforms": ["windows"]
  }
}
```

## Advanced Techniques

### Conditional Dependencies

Create dependency chains that only execute on specific platforms:

```json
{
  "install-deps-linux": {
    "command": "apt-get install -y libssl-dev",
    "platforms": ["linux"]
  },
  "build-linux": {
    "command": "gcc main.c -o app -lssl",
    "platforms": ["linux"],
    "deps": ["install-deps-linux"]
  }
}
```

On Linux: Both tasks run.
On macOS/Windows: Neither task runs.

### Platform-Specific Environment Variables

Use the `env` field with platform filtering:

```json
{
  "build-linux": {
    "command": "make",
    "platforms": ["linux"],
    "env": {
      "CC": "gcc",
      "CFLAGS": "-O2 -Wall"
    }
  },
  "build-macos": {
    "command": "make",
    "platforms": ["darwin"],
    "env": {
      "CC": "clang",
      "CFLAGS": "-O2 -Wall -Wextra"
    }
  }
}
```

### Platform-Specific Working Directories

Different source locations per platform:

```json
{
  "build-unix": {
    "command": "make",
    "working_dir": "unix-build",
    "platforms": ["linux", "darwin"]
  },
  "build-windows": {
    "command": "nmake",
    "working_dir": "windows-build",
    "platforms": ["windows"]
  }
}
```

## Common Pitfalls

### Pitfall 1: Forgetting to Aggregate

**Problem:**
```json
{
  "build-linux": { "platforms": ["linux"], ... },
  "build-macos": { "platforms": ["darwin"], ... }
}
```

Users must know which task to run for their platform.

**Solution:** Add an aggregator:
```json
{
  "build": {
    "deps": ["build-linux", "build-macos"]
  }
}
```

### Pitfall 2: Hardcoding Platform Logic in Scripts

**Problem:**
```bash
#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux-specific
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific
fi
```

This duplicates gaffer-exec's platform filtering.

**Solution:** Use separate scripts and platform tasks:
```json
{
  "setup-linux": {
    "command": "bash scripts/setup-linux.sh",
    "platforms": ["linux"]
  },
  "setup-macos": {
    "command": "bash scripts/setup-macos.sh",
    "platforms": ["darwin"]
  }
}
```

### Pitfall 3: Assuming Command Availability

**Problem:**
```json
{
  "build": {
    "command": "make"
  }
}
```

`make` may not be installed on all platforms.

**Solution:** Check in task or use platform-specific alternatives:
```json
{
  "build-unix": {
    "command": "make",
    "platforms": ["linux", "darwin"]
  },
  "build-windows": {
    "command": "nmake",
    "platforms": ["windows"]
  }
}
```

### Pitfall 4: Incorrect Platform Names

**Problem:**
```json
{
  "build-mac": {
    "platforms": ["mac", "osx"]
  }
}
```

`"mac"` and `"osx"` are not valid. Use `"darwin"` or `"macos"`.

**Solution:**
```json
{
  "build-macos": {
    "platforms": ["darwin", "macos"]
  }
}
```

### Pitfall 5: Platform-Specific Bugs

**Problem:** Not testing on all platforms leads to broken tasks.

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
        run: gaffer-exec run build --graph graph.json
```

Same `graph.json`, different runners, platform-specific execution.

### GitLab CI

```yaml
stages:
  - build

build-linux:
  stage: build
  tags: [linux]
  script:
    - gaffer-exec run build --graph graph.json

build-macos:
  stage: build
  tags: [macos]
  script:
    - gaffer-exec run build --graph graph.json

build-windows:
  stage: build
  tags: [windows]
  script:
    - gaffer-exec run build --graph graph.json
```

## Future Considerations

Potential enhancements for platform filtering:

1. **Architecture-specific tasks**: `"platforms": ["linux-amd64", "linux-arm64"]`
2. **Distribution-specific tasks**: `"platforms": ["ubuntu", "debian", "rhel"]`
3. **Version-specific tasks**: `"platforms": ["macos-13", "macos-14"]`
4. **Negation**: `"platforms": ["!windows"]` (all except Windows)
5. **Regex matching**: `"platforms": ["linux-.*"]`

For now, use scripts for fine-grained platform detection.

## Summary

- Use `"platforms"` field to control task execution by OS
- Valid values: `"linux"`, `"darwin"`, `"macos"`, `"windows"`
- Omit `"platforms"` for universal tasks
- Create aggregator tasks to unify platform-specific variants
- Test on all target platforms
- Keep commands simple, delegate complexity to scripts
- Document platform requirements clearly

The `platforms` field enables clean, maintainable cross-platform workflows without complex scripting or external tools.
