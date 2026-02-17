#!/bin/bash
# Traditional shell script approach - we'll replace this with graph.json

set -e

echo "Building Go API..."
go build -o bin/api-server .
echo "Build complete: bin/api-server"
