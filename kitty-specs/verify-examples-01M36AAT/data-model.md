# Data Model: Verify all gaffer-exec examples

**Mission**: `verify-examples-01M36AAT`

The verification harness produces records, not application data.

## VerificationResult

| Field | Type | Description |
|-------|------|-------------|
| `example` | string | Example directory name, e.g. `01-monorepo-build` |
| `primary_target` | string | Make target under test, e.g. `make:build-all` |
| `status` | enum | `pass` \| `fail` \| `blocked` |
| `blocked_reason` | string? | Present when `status == blocked` (e.g. `environment: docker`) |
| `evidence` | string | Exact command that produced the result |
| `detail` | string | Short raw outcome (last relevant line / exit code) |
| `checks` | object | Static sub-checks: `validate`, `list`, `dry_run`, `stale_refs` each `pass`/`fail` |
| `executed` | bool | Whether an example test/primary target actually ran |

## Defect

| Field | Type | Description |
|-------|------|-------------|
| `example` | string | Owning example |
| `symptom` | string | What failed |
| `evidence` | string | Reproducing command + output |
| `disposition` | enum | `fixed` \| `quarantined` |
| `fix_ref` | string? | File/path changed when `fixed` |
| `rationale` | string? | Why quarantined, when applicable |

## Example

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Directory name |
| `makefile` | path | `examples/<name>/Makefile` |
| `primary_target` | string | From research.md D-005 |
| `service_dependent` | bool | Requires Docker/external services |
| `prerequisites` | list<string> | Toolchains/services required |

## Relationships

- One `Example` → many `VerificationResult` checks (static + executed).
- One `VerificationResult` with `status == fail` → zero or one `Defect`.
- The consolidated report aggregates all `Example` + `VerificationResult` + `Defect`.
