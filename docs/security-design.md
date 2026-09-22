# Security design

## Goals

Prevent wrong-project cloud operations and prevent credential leakage / shell injection while remaining usable for interactive developers and automation.

## Non-goals

- Remote attestation of cloud identity
- Replacing OS ACLs or endpoint security
- Sandboxing arbitrary user commands

## Design pillars

### 1. Path credentials, never bodies

Public APIs (`current --json`, `env --export`, `env --json`, doctor) expose paths and identifiers only. Field readers for ADC use an allowlist (`quota_project_id`, `type`, `account`, …).

### 2. Allowlisted context identity

Context names: `^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$`  
Reject path separators, control chars, leading `-`.

### 3. Deterministic export encoding

`--export` stdout contains only:

- `export NAME=...` for allowlisted names, values via `printf %q`
- `unset NAME` on deactivate

All diagnostics go to stderr. gcloud side effects must redirect stdout away from the export stream.

### 4. Structured env for PowerShell

`gcpctx env --json` returns allowlisted keys. PowerShell assigns `$env:KEY` without parsing shell syntax.

### 5. Managed store layout

```text
$GCPCTX_HOME/           # 0700
  config.json           # 0600 — history.enabled (default true), retain_days
  contexts/<name>/      # 0700, name validated
    meta.json
    credentials.json    # 0600
    projects.json
  history/              # 0700 — command journal (PII: account/project/argv)
    events.jsonl
    entries/<id>/       # event.json, before/, after/, inverse.json, cost.json
  tmp/                  # 0700
  active
```

Writes: temp file in destination dir → chmod → rename.

History is **opt-out** (`history.enabled: false` or `GCPCTX_HISTORY=0`). Journal entries may include account email and full argv; they must never include ADC refresh tokens, private keys, or `client_secret`. `current --json` / `env --json` stay path/id-only; use `gcpctx history --json` for the journal.

### 6. Marker files

`.gcpctx` is JSON `{"name","project"}` (optional fields). Unknown fields ignored. Never sourced as shell.

### 7. Protected contexts

`meta.protected: true` → warnings on activate; `exec` / `undo` / `replay` may require `--allow-protected` or interactive confirm; `assert` for CI.

### 8. Fail closed

Malformed JSON meta → error. Missing credentials on activate → error. Assertion mismatch → nonzero exit. Unsupported undo families fail closed (no guessed cloud deletes). BQ delete undo expires when snapshot and time travel are both gone.

### 9. Cost dry-run

`--dry-run` never invents USD in gcpctx. Cost estimates delegate to `gemlake-finops` (or `GCPCTX_FINOPS`); if missing, gcpctx offers to install it.
## Testing strategy

Isolated `HOME` / `GCPCTX_HOME` / fake `gcloud`. Security tests attempt injection and assert no side-effect files and clean stdout.
