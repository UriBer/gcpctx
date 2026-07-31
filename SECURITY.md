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

## What gcpctx does *not* guarantee

- It does not make every `gcloud`/Terraform/SDK call safe.
- It does not replace IAM least privilege.
- It cannot stop a process that ignores environment variables and uses another credential path.
- A compromised machine or malicious `gcloud` binary is outside the trust model.

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
