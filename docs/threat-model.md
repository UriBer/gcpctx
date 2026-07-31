# Threat model

## Assets

- User ADC / refresh tokens / SA keys under `~/.gcpctx` and well-known ADC path
- Ability to create cloud resources (project selection / quota project)
- Shell environment integrity (no unexpected command execution)
- Trust in published packages and releases

## Trust boundaries

1. **Operator workstation** — user runs gcpctx
2. **Managed store** — `GCPCTX_HOME` (default `~/.gcpctx`)
3. **Untrusted repo** — `.gcpctx` marker checked into source control
4. **Shell** — evaluates allowlisted export lines only
5. **gcloud** — external binary on PATH
6. **Package registries / GitHub Releases** — distribution

## Threat actors

- Mistaken user / automation (wrong project)
- Malicious repository author (crafted `.gcpctx` / project names)
- Local malware with user privileges
- Compromised dependency or release artifact
- PATH hijacking (`gcloud` / `python3` impostors)

## Attack surfaces

| Surface | Threat | Mitigations |
|---------|--------|-------------|
| `--export` + `eval` | Command injection via values | Allowlisted vars; `printf %q`; no stdout noise; tests |
| Context name → path | Traversal / symlink write | Allowlist names; reject `/` `\`; stay under home |
| Marker JSON | Code execution if `eval`'d | Parse as JSON only; schema fields only |
| ADC copy/patch | Corrupt SA/external creds; leak | Type-aware patch; never print body |
| npm pack | Ship secrets | Allowlist files; pack:check; CI |
| PowerShell bridge | Mis-parse exports | Prefer `env --json` |
| Doctor / JSON APIs | Secret leakage | Redacted field access only |

## Local filesystem threats

- World-readable credentials → `secrets fix` / doctor fail
- Symlink race on credential path → write under validated directory, refuse unexpected symlinks where detected
- Temp file in `/tmp` → use `GCPCTX_HOME/tmp` mode 0700

## Shell injection

Malicious `projectId` or context name containing `$(...)`, backticks, newlines must not execute when activating.

## PATH hijacking

Tests use a fake `gcloud` ahead on PATH. Users should ensure `gcloud` authenticity (official SDK).

## Compromised package

Checksums + provenance (CI) + minimal packed surface. Report via SECURITY.md.

## Platform differences

- Unix modes ignored or partial on some Windows mounts — document; still set when possible
- PowerShell requires Bash runtime (Git Bash/WSL)

## Residual risks

- User-level malware can still read `0600` files
- `eval` remains in bash/zsh wrappers by design (mitigated by encoder + tests)
- Fake/malicious `gcloud` can exfiltrate during `login`/`scan`
- Protected contexts are advisory unless scripts use `assert` / `exec --require-context`
