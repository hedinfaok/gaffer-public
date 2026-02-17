#!/bin/bash
# Traditional shell script approach - we'll replace this with graph.json

set -e

echo "Running Go tests..."
go test ./... -v -coverprofile=coverage.out
echo "Tests complete"

echo "Test coverage:"
go tool cover -func=coverage.out | tail -1
