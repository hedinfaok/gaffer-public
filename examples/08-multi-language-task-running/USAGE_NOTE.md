# Note: gaffer-exec reads the Makefile directly

gaffer-exec discovers standard manifest files, including this example's root
`Makefile`. The Makefile targets are the task graph — there is no separate graph
definition to maintain.

Run the Makefile task graph with the `make:` prefix:

```bash
gaffer-exec --workspace-root . run make:build-all
gaffer-exec --workspace-root . run make:test-all
```

Because targets are addressed explicitly as `make:<target>`, the npm and Cargo
packages that gaffer-exec also discovers (from `node-frontend/package.json` and
`rust-cli/Cargo.toml`) do not interfere.
