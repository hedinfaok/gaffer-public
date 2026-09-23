#!/bin/bash
# Traditional shell script approach - kept for reference. The root Makefile
# exposes this as the build-go target, run by gaffer-exec.

set -e

echo "Building Go API..."
go build -o bin/api-server .
echo "Build complete: bin/api-server"
