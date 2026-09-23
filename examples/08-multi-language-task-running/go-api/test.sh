#!/bin/bash
# Traditional shell script approach - kept for reference. The root Makefile
# exposes this as the test-go target, run by gaffer-exec.

set -e

echo "Running Go tests..."
go test ./... -v -coverprofile=coverage.out
echo "Tests complete"

echo "Test coverage:"
go tool cover -func=coverage.out | tail -1
