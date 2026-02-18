#!/usr/bin/env bash
# Platform detection script for cross-platform builds

set -e

echo "╔════════════════════════════════════════╗"
echo "║  Platform Detection Utility            ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Detect OS
detect_os() {
    local os_type=""
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os_type="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="darwin"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        os_type="windows"
    else
        os_type="unknown"
    fi
    
    echo "$os_type"
}

# Detect architecture
detect_arch() {
    local arch=""
    
    case $(uname -m) in
        x86_64|amd64)
            arch="amd64"
            ;;
        aarch64|arm64)
            arch="arm64"
            ;;
        i386|i686)
            arch="386"
            ;;
        armv7l)
            arch="arm"
            ;;
        *)
            arch=$(uname -m)
            ;;
    esac
    
    echo "$arch"
}

# Get OS details
get_os_details() {
    local os=$(detect_os)
    
    case $os in
        linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                echo "$NAME $VERSION"
            elif [ -f /etc/redhat-release ]; then
                cat /etc/redhat-release
            else
                echo "Linux (unknown distribution)"
            fi
            ;;
        darwin)
            sw_vers -productVersion 2>/dev/null || echo "macOS (version unknown)"
            ;;
        windows)
            echo "Windows"
            ;;
        *)
            echo "Unknown OS"
            ;;
    esac
}

# Main output
OS=$(detect_os)
ARCH=$(detect_arch)
OS_DETAILS=$(get_os_details)

echo "Platform Information:"
echo "  OS:           $OS"
echo "  Architecture: $ARCH"
echo "  Details:      $OS_DETAILS"
echo "  Kernel:       $(uname -s)"
echo "  Kernel Ver:   $(uname -r)"
echo ""

# Export for use in other scripts
echo "Exported Variables:"
echo "  GAFFER_OS=$OS"
echo "  GAFFER_ARCH=$ARCH"

export GAFFER_OS="$OS"
export GAFFER_ARCH="$ARCH"

# Write to file for sourcing
cat > /tmp/gaffer-platform.env <<EOF
export GAFFER_OS="$OS"
export GAFFER_ARCH="$ARCH"
export GAFFER_OS_DETAILS="$OS_DETAILS"
EOF

echo ""
echo "✓ Platform detection complete!"
echo "  Source with: source /tmp/gaffer-platform.env"
