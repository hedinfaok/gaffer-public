#!/usr/bin/env bash
# Initialize the local database fixture for the dev stack.
set -euo pipefail

mkdir -p build/db
echo "database initialized" > build/db/state.txt
echo "db-init: initialized build/db/state.txt"
