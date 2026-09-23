#!/usr/bin/env bash
# Remote cache save hook.
#
# gaffer-exec runs this graph after each cached task succeeds when --cache is
# active. It injects GAFFER_CACHE_KEY and GAFFER_CACHE_ARTIFACT; this script
# uploads the artifact to MinIO under the cache key.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib
. "$SCRIPT_DIR/lib"

KEY="${GAFFER_CACHE_KEY:-}"
if [ -z "$KEY" ]; then
  echo "save: GAFFER_CACHE_KEY is not set (is --cache active?); nothing to do"
  exit 0
fi

CACHE_DIR="${GAFFER_CACHE_DIR:-.gaffer/cache}"
ARTIFACT="${GAFFER_CACHE_ARTIFACT:-$CACHE_DIR/$KEY.tar.gz}"
OBJECT="$MINIO_BUCKET/$KEY.tar.gz"

# gaffer-exec 0.8.0 does not materialize a tarball for Makefile-derived tasks,
# so when the injected path is empty we archive the build output ourselves.
if [ ! -f "$ARTIFACT" ]; then
  if [ -d dist ]; then
    mkdir -p "$(dirname "$ARTIFACT")"
    tar czf "$ARTIFACT" dist
    echo "save: archived dist/ -> $ARTIFACT"
  else
    echo "save: no artifact at $ARTIFACT and no dist/ to archive" >&2
    exit 0
  fi
fi

if ! remote_available; then
  echo "save: no 'mc', 'aws', or 'docker' client available; skipping remote save" >&2
  exit 0
fi

if remote_put "$ARTIFACT" "$OBJECT"; then
  echo "save: uploaded $OBJECT"
else
  echo "save: upload failed for $OBJECT (is MinIO running?)" >&2
fi
exit 0
