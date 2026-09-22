# AI coding agents

Use gcpctx so agents do not operate on the wrong GCP project.

```bash
gcpctx use dev
gcpctx assert --project expected-project-id
gcpctx exec --require-context dev --deny-protected -- ./deploy.sh
```

## Rules for agents

1. Never `cat` or paste credential JSON / ADC files.
2. Prefer `gcpctx current --json` and `gcpctx env --json` (paths and ids only).
3. Fail closed with `assert` before Terraform/apply/destroy.
4. Treat protected contexts as requiring human confirmation.
5. Prefer `gcpctx exec --dry-run` before expensive mutations; install **gemlake-finops** when prompted for cost (do not invent USD).
6. Use `gcpctx history --json` / `gcpctx snapshots --json` for audit; never treat history PII as safe to paste into public tickets.
7. `gcpctx undo` on protected contexts needs the same confirmation flags as `exec`.

Works with Cursor, Codex, Claude Code, Gemini CLI, and generic autonomous agents that honor the shell environment.
