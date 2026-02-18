# Platform Detection Guide

Comprehensive guide to using shell-based platform detection for cross-platform build workflows with gaffer-exec.

## Overview

Since gaffer-exec doesn't have a native `platforms` field, we use shell conditionals to control **which operating systems** a task should execute on. Tasks include inline platform checks using `uname` to determine whether to execute or skip.

## Platform Detection Methods

### Supported Platforms

| Platform | Detection Command | Value |
|----------|------------------|-------|
| Linux | `[ "$(uname)" = "Linux" ]` | `Linux` |
| macOS | `[ "$(uname)" = "Darwin" ]` | `Darwin` |
| Windows (Git Bash/MSYS) | `[ "$(uname -o 2>/dev/null \|\| echo 'Unknown')" = "Msys" ]` | `Msys` |
| Windows (Cygwin) | `[ "$(uname -o 2>/dev/null \|\| echo 'Unknown')" = "Cygwin" ]` | `Cygwin` |

### How It Works

Each platform-specific task uses a shell conditional (`if`) to:
- Check the current platform using `uname`
- Execute the actual command if the platform matches
- Print a skip message if the platform doesn't match

This ensures tasks always succeed but only perform work on the correct platform.

## Syntax

### Single Platform using a shell conditional:

```json
{
  "build-linux": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then make && echo '✓ Built'; else echo '⊘ Skipping on '$(uname); fi"
  }
}
```

### Multiple Platforms (Combined Check)

Execute task on multiple platforms using OR logic:

```json
{
  "build-unix": {
    "command": "if [ \"$(uname)\" = \"Linux\" ] || [ \"$(uname)\" = \"Darwin\" ]; then make && echo '✓ Built'; else echo '⊘ Skipping on '$(uname); fi"
  }
}
```

### No Platform Filter (Universal)

Execute task on all platforms without a checkrsal)

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
  },if [ \"$(uname)\" = \"Linux\" ]; then gcc src/main.c -o bin/app && echo '✓ Built for Linux'; else echo '⊘ Skipping on '$(uname); fi"
  },
  "build-native-macos": {
    "command": "if [ \"$(uname)\" = \"Darwin\" ]; then clang src/main.c -o bin/app && echo '✓ Built for macOS'; else echo '⊘ Skipping on '$(uname); fi"
  },
  "build-native-windows": {
    "command": "if [ \"$(uname -o 2>/dev/null || echo 'Unknown')\" = \"Msys\" ]; then gcc src/main.c -o bin/app.exe && echo '✓ Built for Windows'; else echo '⊘ Skipping on '$(uname); fi"
  },
  "build-native": {
    "deps": ["build-native-linux", "build-native-macos", "build-native-windows"]
  }
}
```

Running `gaffer-exec run build-native` will:
- On Linux: Execute the gcc command in `build-native-linux`, skip others
- On macOS: Execute the clang command in `build-native-macos`, skip others
- On Windows: Execute the gcc command in `build-native-windows`, skip others

### Pattern 2: Platform-Specific Dependencies

Install dependencies using the appropriate package manager:

```json
{
  "install-build-tools-debian": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then sudo apt-get install -y build-essential && echo '✓ Installed'; else echo '⊘ Skipping on '$(uname); fi"
  },
  "install-build-tools-macos": {
    "command": "if [ \"$(uname)\" = \"Darwin\" ]; then brew install gcc make && echo '✓ Installed'; else echo '⊘ Skipping on '$(uname); fi"
  },
  "install-build-tools-windows": {
    "command": "if [ \"$(uname -o 2>/dev/null || echo 'Unknown')\" = \"Msys\" ]; then pacman -S mingw-w64-x86_64-gcc make --noconfirm && echo '✓ Installed'; else echo '⊘ Skipping on '$(uname); fi"
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
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then bash scripts/setup-linux.sh; else echo '⊘ Skipping on '$(uname); fi",
    "deps": ["detect"]
  },
  "setup-macos": {
    "command": "if [ \"$(uname)\" = \"Darwin\" ]; then bash scripts/setup-macos.sh; else echo '⊘ Skipping on '$(uname); fi"
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
   platform check means these run on any platform (assuming Go is installed).

### Pattern 5: Platform-Specific Tests

Run tests using platform-native test runners:

```json
{
  "test-linux": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then ./run-tests.sh; else echo '⊘ Skipping on '$(uname); fi"
  },
  "test-macos": {
    "command": "if [ \"$(uname)\" = \"Darwin\" ]; then ./run-tests.sh; else echo '⊘ Skipping on '$(uname); fi"
  },
  "test-windows": {
    "command": "if [ \"$(uname -o 2>/dev/null || echo 'Unknown')\" = \"Msys\" ]; then ./run-tests.sh; else echo '⊘ Skipping on '$(uname); fi"

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
} Each platform-specific task will check internally and either execute or skip gracefully.

### 2. Keep Commands Readable

For complex commands, extract to scripts and keep the conditional simple:

**❌ Hard to read:**
```json
{
  "build-linux": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then if [ -d build ]; then rm -rf build; fi && mkdir build && gcc ...; else echo '⊘ Skipping'; fi"
  }
}
```

**✅ Better:**
```json
{
  "build-linux": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then bash scripts/build-linux.sh; else echo '⊘ Skipping on '$(uname); fi"
  }
}
```

### 3. Consistent Skip Messages

Use a consistent pattern for skip messages to make logs readable:

```bash
echo '⊘ Skipping task-name on '$(uname)
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

If possible, test your graph.json on all target platforms before committing:

```bash
# On Linux
gaffer-exec run test --graph graph.json

# On macOS
gaffer-exec run test --graph graph.json

# On Windows (Git Bash)
gaffer-exec run test --graph graph.json
```

### 6. Use Platform-Agnostic Tools When Possible

Prefer tools that work the same across platforms:

- **Node.js scripts** instead of bash/PowerShell
- **Python scripts** instead of platform-specific binaries
- **Docker** for consistent build environments
- **Go/Rust** for portable compiled tools

### 7. Handle Path Separators

Windows traditionally uses `\` while Unix uses `/`. In modern shells (Git Bash, MSYS2), forward slashes usually work everywhere:

```json
{
  "copy-files": {
    "command": "cp src/file.txt dest/file.txt"
  }
}
```
## Advanced Techniques

### Conditional Dependencies

Create dependency chains that only execute on specific platforms:

```json
{
  "install-deps-linux": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then apt-get install -y libssl-dev; else echo '⊘ Skipping'; fi"
  },
  "build-linux": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then gcc main.c -o app -lssl; else echo '⊘ Skipping'; fi",
    "deps": ["install-deps-linux"]
  }
}
```

On Linux: Both tasks execute commands.
On macOS/Windows: Both tasks skip with messages.

### Platform-Specific Environment Variables

Use the `env` field with shell conditionals:

```json
{
  "build-linux": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then make; else echo '⊘ Skipping'; fi",
    "env": {
      "CC": "gcc",
      "CFLAGS": "-O2 -Wall"
    }
  },
  "build-macos": {
    "command": "if [ \"$(uname)\" = \"Darwin\" ]; then make; else echo '⊘ Skipping'; fi",
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
  "build-unix-linux": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then make; else echo '⊘ Skipping'; fi",
    "working_dir": "unix-build"
  },
  "build-unix-macos": {
    "command": "if [ \"$(uname)\" = \"Darwin\" ]; then make; else echo '⊘ Skipping'; fi",
    "working_dir": "unix-build"
  },
  "build-windows": {
    "command": "if [ \"$(uname -o 2>/dev/null || echo 'Unknown')\" = \"Msys\" ]; then nmake; else echo '⊘ Skipping'; fi",
    "working_dir": "windows-build"
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
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then ...; fi"
  },
  "build-macos": {
    "command": "if [ \"$(uname)\" = \"Darwin\" ]; then ...; fi"
  }
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

This duplicates the platform check already in the task definition.

**Solution:** Use the shell conditional in the task and keep scripts simple:
```json
{
  "setup-linux": {
    "command": "if [ \"$(uname)\" = \"Linux\" ]; then bash scripts/setup.sh; else echo '⊘ Skipping'; fi"
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

**Solution:** Use platform-specific alternatives:
```json
{
  "build-unix": {
    "command": "if [ \"$(uname)\" = \"Linux\" ] || [ \"$(uname)\" = \"Darwin\" ]; then make; else echo '⊘ Skipping'; fi"
  },
  "build-windows": {
    "command": "if [ \"$(uname -o 2>/dev/null || echo 'Unknown')\" = \"Msys\" ]; then nmake; else echo '⊘ Skipping'; fi"
  }
}
```

### Pitfall 4: Incorrect uname Values

**Problem:**
```json
{
  "build-mac": {
    "command": "if [ \"$(uname)\" = \"macOS\" ]; then ...; fi"
  }
}
```

`uname` returns `Darwin`, not `macOS`.

**Solution:**
```json
{
  "build-macos": {
    "command": "if [ \"$(uname)\" = \"Darwin\" ]; then ...; fi"
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
Summary

- Use shell conditionals with `uname` to control task execution by OS
- Linux: `[ "$(uname)" = "Linux" ]`
- macOS: `[ "$(uname)" = "Darwin" ]`
- Windows (Git Bash/MSYS): `[ "$(uname -o 2>/dev/null || echo 'Unknown')" = "Msys" ]`
- Tasks without platform checks run everywhere
- Create aggregator tasks to unify platform-specific variants
- Test on all target platforms
- Keep commands readable with clear skip messages
- Document platform requirements clearly

Shell-based platform detection enables clean, maintainable cross-platform workflows without requiring special task runner feature