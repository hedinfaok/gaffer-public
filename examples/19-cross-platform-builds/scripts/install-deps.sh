#!/usr/bin/env bash
# Platform-specific dependency installation

set -e

echo "╔════════════════════════════════════════╗"
echo "║  Dependency Installation Utility        ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Detect platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="darwin"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    PLATFORM="windows"
else
    PLATFORM="unknown"
fi

echo "Detected Platform: $PLATFORM"
echo ""

install_linux_deps() {
    echo "Installing dependencies for Linux..."
    
    # Check if running as root or with sudo
    if [ "$EUID" -ne 0 ]; then
        echo "Note: Some packages may require sudo privileges"
        HAS_SUDO="sudo"
    else
        HAS_SUDO=""
    fi
    
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        echo "  Using apt-get (Debian/Ubuntu)"
        echo "  - build-essential (gcc, g++, make)"
        echo "  - curl"
        # Uncomment to actually install:
        # $HAS_SUDO apt-get update
        # $HAS_SUDO apt-get install -y build-essential curl
    elif command -v yum &> /dev/null; then
        echo "  Using yum (RHEL/CentOS)"
        echo "  - gcc, gcc-c++, make"
        echo "  - curl"
        # Uncomment to actually install:
        # $HAS_SUDO yum groupinstall -y "Development Tools"
        # $HAS_SUDO yum install -y curl
    elif command -v pacman &> /dev/null; then
        echo "  Using pacman (Arch Linux)"
        echo "  - base-devel"
        echo "  - curl"
        # Uncomment to actually install:
        # $HAS_SUDO pacman -S --noconfirm base-devel curl
    else
        echo "  Warning: Unknown package manager"
    fi
}

install_macos_deps() {
    echo "Installing dependencies for macOS..."
    
    if ! command -v brew &> /dev/null; then
        echo "  Homebrew not found. Install from: https://brew.sh"
        echo "  Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 1
    fi
    
    echo "  Using Homebrew"
    echo "  - llvm (clang)"
    echo "  - rustup"
    # Uncomment to actually install:
    # brew install llvm
}

install_windows_deps() {
    echo "Installing dependencies for Windows..."
    
    if ! command -v choco &> /dev/null; then
        echo "  Chocolatey not found. Install from: https://chocolatey.org"
        echo "  Run (as admin): Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        return 1
    fi
    
    echo "  Using Chocolatey"
    echo "  - mingw (GCC for Windows)"
    echo "  - visualstudio2022buildtools"
    # Uncomment to actually install:
    # choco install -y mingw
    # choco install -y visualstudio2022buildtools
}

# Install platform-specific dependencies
case $PLATFORM in
    linux)
        install_linux_deps
        ;;
    darwin)
        install_macos_deps
        ;;
    windows)
        install_windows_deps
        ;;
    *)
        echo "Error: Unknown platform $PLATFORM"
        exit 1
        ;;
esac

echo ""
echo "✓ Dependency check complete!"
echo ""
echo "Common dependencies you may need:"
echo "  - Go:    https://go.dev/dl/"
echo "  - Rust:  https://rustup.rs/"
echo "  - Node:  https://nodejs.org/"
