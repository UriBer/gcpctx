# Security Policy

## Reporting a vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Email or use GitHub private vulnerability reporting (when enabled on the repository).

Include:

- affected version / commit
- reproduction steps
- impact assessment
- whether credentials or data were exposed (do **not** attach real credential files)

We aim to acknowledge reports within 7 days.

## Security invariants

1. Credential JSON contents are never printed to stdout/stderr.
2. Refresh tokens, private keys, and client secrets are never logged.
3. Credential files never enter npm packages, release archives, or git.
4. Context names, project IDs, accounts, and paths cannot inject shell commands.
5. Shell exports use allowlisted variable names and safe quoting.
6. `.gcpctx` marker files are never executed as shell.
7. Context directories are mode `0700` where the OS supports Unix modes.
8. Credential files are mode `0600` where supported.
9. Credential writes stay under the managed `GCPCTX_HOME` tree.
10. Temporary files are created under `GCPCTX_HOME/tmp` and cleaned up.
11. Metadata/credential updates prefer atomic replace.
12. Malformed metadata fails closed.
13. No telemetry or credential upload.
14. External tools are invoked with argument arrays (no shell string concat for secrets).
15. Secrets do not appear in errors, JSON APIs, or tests.
16. Protected contexts require explicit confirmation / flags for dangerous ops.
17. Package install does not run credential-touching lifecycle scripts.
18. Release artifacts are checksummed; provenance via CI when configured.
19. Runtime dependencies are minimized (Bash, Python 3, gcloud).
20. Security behavior is covered by automated tests.
21. History journals may store account/project/argv PII under `$GCPCTX_HOME/history/` (mode `0700`/`0600`) but never ADC bodies or secret fields.
22. `current --json` / `env --json` remain path/id-only; history is a separate API (`gcpctx history`).
23. Cost dry-run never invents USD; it delegates to gemlake-finops or omits cost.
24. Undo fails closed for unsupported families; BQ delete undo requires an existing snapshot or in-window time travel.

## What gcpctx does *not* guarantee

- It does not make every `gcloud`/Terraform/SDK call safe.
- It does not replace IAM least privilege.
- It cannot stop a process that ignores environment variables and uses another credential path.
- A compromised machine or malicious `gcloud` binary is outside the trust model.
- History undo cannot reconstruct arbitrary cloud state: unclassified scripts need `--undo-cmd`; BQ deletes expire after the time-travel window if no snapshot remains; unversioned GCS deletes need a prior `before/` copy.

## Supported platforms (security posture)

| Platform | Notes |
|----------|-------|
| macOS / Linux | Native Bash CLI; Unix permission model enforced |
| Windows + Git Bash / WSL | Bash CLI; PowerShell wrapper available |
| Windows CMD | Unsupported |

## Safe practices for AI coding agents

```bash
gcpctx assert --project expected-project-id
gcpctx exec --require-context dev -- your-command
```

Never ask an agent to `cat` credential files or paste ADC JSON into chat.
