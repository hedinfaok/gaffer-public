#!/usr/bin/env bash
# Remote cache restore hook.
#
# gaffer-exec runs this graph before each cached task when --cache is active and
# injects:
#   GAFFER_CACHE_KEY      hex sha256 of the task inputs
#   GAFFER_CACHE_ARTIFACT absolute path to the local cache tarball on a hit,
#                         empty string on a miss
#
# On a miss we derive the tarball path from the key and pull it from MinIO.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib
. "$SCRIPT_DIR/lib"

KEY="${GAFFER_CACHE_KEY:-}"
if [ -z "$KEY" ]; then
  echo "restore: GAFFER_CACHE_KEY is not set (is --cache active?); nothing to do"
  exit 0
fi

CACHE_DIR="${GAFFER_CACHE_DIR:-.gaffer/cache}"
ARTIFACT="${GAFFER_CACHE_ARTIFACT:-$CACHE_DIR/$KEY.tar.gz}"
OBJECT="$MINIO_BUCKET/$KEY.tar.gz"

if [ -f "$ARTIFACT" ]; then
  echo "restore: local cache artifact present ($ARTIFACT)"
  exit 0
fi

if ! remote_available; then
  echo "restore: no 'mc', 'aws', or 'docker' client available; skipping remote restore" >&2
  exit 0
fi

mkdir -p "$(dirname "$ARTIFACT")"

if remote_exists "$OBJECT"; then
  if remote_get "$OBJECT" "$ARTIFACT"; then
    echo "restore: REMOTE HIT $KEY"
    if tar tzf "$ARTIFACT" >/dev/null 2>&1; then
      tar xzf "$ARTIFACT" -C .
      echo "restore: extracted artifact into the workspace"
    fi
    exit 0
  fi
  echo "restore: remote fetch failed for $OBJECT" >&2
  exit 0
fi

echo "restore: remote miss $KEY"
exit 0
