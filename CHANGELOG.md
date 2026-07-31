# Changelog

## 0.3.0 — 2026-07-31

### Security
- Apache-2.0 license; SECURITY.md and threat model
- Input validation for context/project/account
- Safe export encoder (`printf %q`, allowlisted vars)
- Shell `_gcpctx_safe_eval` allowlist gate before `eval`
- Absolute `gcloud` resolve; refuse temp/world-writable binaries for login/scan
- `env --json` for PowerShell (no Bash export parsing)
- Atomic/credential filesystem helpers; type-aware ADC quota patching
- Injection tests with isolated HOME / fake gcloud
- `doctor --json` with stable issue codes (`STORE_PERMS_OPEN`, `GCLOUD_UNTRUSTED`, …)

### Features
- `assert`, `protect` / `unprotect`, `exec --require-context`, completions
- Cross-shell venv-style prompt (zsh/bash/pwsh)
- CI, Scorecard, CodeQL, release artifact scripts (GHAS workflows gated on private)
- Homebrew/Scoop packaging templates; WinGet status documented
- Owner runbook for npm/GitHub security setup

### Packaging
- npm allows win32 (Git Bash/WSL + PowerShell wrapper)
- Single version source: `package.json` + `VERSION`

## 0.2.1
- Venv-style prompts and multi-shell setup

## 0.2.0
- Project scan / in-context project switch; npm packaging; secret pack gates
