#!/usr/bin/env bash
# Report the health of the local database fixture.
set -euo pipefail

if [ -f build/db/state.txt ]; then
    echo "health: database is initialized"
else
    echo "health: database is not initialized (run scripts/db-init.sh)"
fi
