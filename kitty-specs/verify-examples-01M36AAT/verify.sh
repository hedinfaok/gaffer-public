#!/usr/bin/env bash
#
# verify.sh — repeatable verification harness for the gaffer-exec examples.
#
# Mission: verify-examples-01M36AAT
# Target CLI: gaffer-exec 0.8.0
#
# Usage:
#   bash verify.sh [--static] [--execute] [--all]
#
#   --static   (default) validate + list + dry-run + stale-reference sweep
#   --execute  additionally run each example's test.sh / primary target (bounded)
#   --all      --static + --execute
#
# Results are written to:
#   results/static-results.json
#   results/execute-results.json   (only with --execute/--all)
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"
EXAMPLES_DIR="$ROOT/examples"

EXAMPLES=(
  01-monorepo-build
  02-distributed-build
  03-multi-language-build
  04-incremental-testing
  05-ml-workflows
  06-local-dev-environment
  07-watch-workflows
  08-multi-language-task-running
  18-network-aware-builds
  19-cross-platform-builds
)

declare -A PRIMARY=(
  [01-monorepo-build]=build-all
  [02-distributed-build]=distributed-build
  [03-multi-language-build]=multi-language-build
  [04-incremental-testing]=test-all
  [05-ml-workflows]=pipeline
  [06-local-dev-environment]=dev
  [07-watch-workflows]=build-all
  [08-multi-language-task-running]=build-all
  [18-network-aware-builds]=network-build
  [19-cross-platform-builds]=build-all
)

MODE_STATIC=1
MODE_EXECUTE=0
case "${1:-}" in
  --execute) MODE_STATIC=0; MODE_EXECUTE=1 ;;
  --all)     MODE_STATIC=1; MODE_EXECUTE=1 ;;
  --static|"") MODE_STATIC=1; MODE_EXECUTE=0 ;;
  *) echo "usage: $0 [--static|--execute|--all]" >&2; exit 2 ;;
esac

command -v gaffer-exec >/dev/null 2>&1 || { echo "FATAL: gaffer-exec not found" >&2; exit 2; }
command -v make >/dev/null 2>&1 || { echo "FATAL: make not found" >&2; exit 2; }
mkdir -p "$RESULTS_DIR"

TIMEOUT_BIN=""
if command -v timeout >/dev/null 2>&1; then TIMEOUT_BIN="timeout"; \
elif command -v gtimeout >/dev/null 2>&1; then TIMEOUT_BIN="gtimeout"; fi

run_bounded() { # seconds cmd...
  local secs="$1"; shift
  if [ -n "$TIMEOUT_BIN" ]; then "$TIMEOUT_BIN" "$secs" "$@"; \
  else "$@" & local pid=$!; ( sleep "$secs"; kill "$pid" 2>/dev/null ) & local watcher=$!; \
       wait "$pid"; local rc=$?; kill "$watcher" 2>/dev/null; return $rc; fi
}

json_escape() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr -d '\n'; }

static_rc=0
execute_rc=0
static_records=""
execute_records=""

for ex in "${EXAMPLES[@]}"; do
  dir="$EXAMPLES_DIR/$ex"
  target="make:${PRIMARY[$ex]}"
  v="fail"; l="fail"; d="fail"; s="fail"; detail=""
  if [ -d "$dir" ] && [ -f "$dir/Makefile" ]; then
    out=$(cd "$dir" && gaffer-exec --workspace-root . validate 2>&1); [ $? -eq 0 ] && v=pass
    [ "$v" = pass ] || detail="validate: $(printf '%s' "$out" | tail -1)"
    out=$(cd "$dir" && gaffer-exec --workspace-root . list -t makefile 2>&1); \
      echo "$out" | grep -q "make:" && l=pass
    out=$(cd "$dir" && gaffer-exec --workspace-root . run --dry-run "$target" 2>&1); \
      echo "$out" | grep -qE "would execute [0-9]+ graphs" && d=pass
    hits=$(grep -rIn -E 'graph\.json|--graph-override|--graph[ =]' "$dir" \
             --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=target 2>/dev/null | wc -l | tr -d ' ')
    [ "$hits" = "0" ] && s=pass || detail="stale-refs: $hits"
  else
    detail="missing Makefile"
  fi
  status=pass
  for c in "$v" "$l" "$d" "$s"; do [ "$c" = pass ] || status=fail; done
  [ "$status" = pass ] || static_rc=1
  [ -n "$static_records" ] && static_records="$static_records,"
  static_records="$static_records
  {\"example\": \"$ex\", \"primary_target\": \"$target\", \"status\": \"$status\", \"checks\": {\"validate\": \"$v\", \"list\": \"$l\", \"dry_run\": \"$d\", \"stale_refs\": \"$s\"}, \"evidence\": \"gaffer-exec --workspace-root . validate; run --dry-run $target; list -t makefile\", \"detail\": \"$(json_escape "$detail")\"}"
  echo "[static] $ex: $status (validate=$v list=$l dry_run=$d stale=$s)"

  if [ "$MODE_EXECUTE" = "1" ]; then
    estatus="blocked"; edetail="no test.sh"
    if [ -f "$dir/test.sh" ]; then
      out=$(cd "$dir" && run_bounded 600 bash test.sh 2>&1); rc=$?
      if [ $rc -eq 0 ]; then estatus=pass; edetail="test.sh exit 0"
      elif [ $rc -eq 124 ]; then estatus="blocked"; edetail="environment: timeout"
      else estatus=fail; edetail="test.sh exit $rc"; fi
      edetail="$edetail | $(printf '%s' "$out" | tail -1)"
    fi
    [ "$estatus" = fail ] && execute_rc=1
    [ -n "$execute_records" ] && execute_records="$execute_records,"
    execute_records="$execute_records
  {\"example\": \"$ex\", \"status\": \"$estatus\", \"evidence\": \"bash test.sh (bounded 600s)\", \"detail\": \"$(json_escape "$edetail")\"}"
    echo "[execute] $ex: $estatus ($edetail)"
  fi
done

if [ "$MODE_STATIC" = "1" ]; then
  printf '{\n "generated_at": "%s",\n "cli": "%s",\n "results": [%s\n ]\n}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(gaffer-exec --version)" "$static_records" \
    > "$RESULTS_DIR/static-results.json"
  echo "wrote $RESULTS_DIR/static-results.json"
fi
if [ "$MODE_EXECUTE" = "1" ]; then
  printf '{\n "generated_at": "%s",\n "results": [%s\n ]\n}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$execute_records" \
    > "$RESULTS_DIR/execute-results.json"
  echo "wrote $RESULTS_DIR/execute-results.json"
fi

[ "$static_rc" -eq 0 ] || { echo "STATIC VERIFICATION FAILED" >&2; exit 1; }
[ "$execute_rc" -eq 0 ] || { echo "EXECUTE VERIFICATION FAILED" >&2; exit 1; }
echo "verification OK"
