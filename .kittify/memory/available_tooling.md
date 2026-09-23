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

## Cleanup pass (Spec Kitty governed)

- Roles: `implementer-ivan` (Op `01M369FK5N7TZYZBEF91KDMYQV`) for the cleanup, `reviewer-renata` (Op `01M369H68WMFBRST9TGB31VZE9`) for independent verification.
- Removed the local, gitignored `examples/05-ml-workflows/venv/` (877 MB). It was being scanned by workspace discovery and produced 20 duplicate `npm:` sub-graph errors unrelated to the Makefile. Regenerate with `make setup`.
- Removed transient `.gaffer/` runtime state created by verification runs (gitignored; regenerates on use).
- Annotated historical docs (`04/COMPLETION.md`, `04/VERIFICATION_FIXES.md`) so stale `graph.json` mentions read as history, not current instructions.

## Verification result (reviewer)

- `gaffer-exec --workspace-root . validate` — OK for all 10 examples (05 now `Validated 10 graph(s): OK`).
- Zero `graph.json` files remain; all remaining mentions are intentional migration notes or obsolete-flag warnings.
- Target + dependency fidelity vs the original `graph.json` (from git): 0 mismatches.

## Missing-tool decisions / remediation

- None blocking. `jq`-based graph.json validators were replaced with Makefile existence/target checks so the tests no longer depend on `jq`.
