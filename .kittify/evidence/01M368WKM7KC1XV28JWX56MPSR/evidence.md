# Available Tooling

Session record for gaffer-exec examples migration (graph.json -> Makefile).

## Local tools used

- `rg` (ripgrep) — repository search across examples, excluding `node_modules/`, `venv/`, `target/`.
- `gaffer-exec` 0.7.1 — `/Users/rob/.cargo/bin/gaffer-exec`; used for workspace discovery, dependency validation (`list -t makefile`), dry-runs, and visualization.
- `make` (GNU Make) — validated every generated Makefile with `make -n <target>`.
- `git` — status/diff inspection only; no commits made.
- `bash -n` / `node --check` — syntax validation of changed scripts.

## Session decisions

- JSON graph format removed from gaffer-exec; examples now define task graphs in standard `Makefile` manifests.
- gaffer-exec is nested inside a git repo, so every invocation passes `--workspace-root .`.
- Make target names cannot contain `:` (GNU Make parses it as a rule separator). Example 06's `db:start`, `api:start`, `frontend:start` were renamed to `db-start`, `api-start`, `frontend-start`.

## Missing-tool decisions / remediation

- None blocking. `jq`-based graph.json validators were replaced with Makefile existence/target checks so the tests no longer depend on `jq`.
