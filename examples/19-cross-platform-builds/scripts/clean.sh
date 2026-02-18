#!/usr/bin/env bash
# Clean build artifacts across all platforms

set -e

echo "Cleaning build artifacts..."

# C app
rm -rf c-app/bin c-app/*.o c-app/*.exe c-app/app

# Go CLI
rm -rf go-cli/bin go-cli/cross-platform-go-cli go-cli/cross-platform-go-cli.exe

# Rust binary
rm -rf rust-bin/target

# Node native
rm -rf node-native/node_modules

# Clean platform detection artifacts
rm -f /tmp/gaffer-platform.env

echo "✓ Clean complete!"
