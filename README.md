# The missing context manager for Google Cloud

> Switch your GCP account, project, gcloud configuration, ADC and quota project as one safe context.

**Stop deploying to the wrong GCP project.**

```bash
npm install -g gcpctx
gcpctx shell-setup
gcpctx bootstrap
gcpctx use prod
# prompt → (gcp:prod:your-project)
gcpctx assert --project your-project
gcpctx doctor
```

`gcloud config configurations` only change the CLI. Application Default Credentials (used by SDKs, Terraform providers, many AI coding agents) are separate and global. gcpctx aligns them.

## Why gcloud configurations alone are insufficient

| Mechanism | Affects `gcloud` CLI | Affects client libraries / ADC |
|-----------|---------------------|--------------------------------|
| `gcloud config configurations activate` | Yes | No |
| `gcloud auth application-default login` | No | Yes (global file) |
| **gcpctx use** | Yes | Yes (per-context ADC + env) |

## Install

```bash
# npm (macOS, Linux, Windows with Git Bash/WSL)
npm install -g gcpctx
gcpctx shell-setup

# from source
./install.sh
```

Homebrew: `brew tap UriBer/tap && brew install gcpctx`  
Scoop: `scoop bucket add gcpctx https://github.com/UriBer/scoop-gcpctx && scoop install gcpctx`  
WinGet: not offered yet — see `packaging/winget/README.md`

## Safety model

- Credential **paths** may be printed; credential **bodies** are never printed
- No telemetry
- Protected contexts, `assert`, and `exec --require-context` for scripts/agents
- Command **history** (on by default) journals argv + account/project PII under `$GCPCTX_HOME/history/` — never ADC bodies. Disable with `GCPCTX_HISTORY=0` or `config.json` `history.enabled: false`
- See [SECURITY.md](SECURITY.md)

This does **not** make every command safe. Apply IAM least privilege.

## Common workflows

```bash
gcpctx login prod
gcpctx use prod --project other-id
gcpctx protect prod
gcpctx assert --context prod --project other-id
gcpctx exec --require-context prod -- terraform apply

# History / undo / cost dry-run
gcpctx history
gcpctx snapshots
gcpctx exec --dry-run -- bq query --use_legacy_sql=false 'SELECT 1'
gcpctx undo
gcpctx replay <id> --project other-id
```

Repo marker (safe to commit):

```json
{"name":"dev","project":"example-dev-123456"}
```

### History and rollback

| Command | Purpose |
|---------|---------|
| `gcpctx history [--json]` | Timeline of recorded commands (PII included) |
| `gcpctx snapshots` | Which BQ snapshot / time-travel restore points still exist |
| `gcpctx undo [<id>]` | Apply inverse plan (local meta, BQ time travel, classified gcloud, …) |
| `gcpctx replay <id>` | Re-run argv, optionally with another context/project |
| `gcpctx exec --dry-run -- …` | Print plan; cost via **gemlake-finops** (offers install if missing) |

BQ table deletes journal `deleted_at` and optionally create a snapshot table; undo prefers the snapshot, then `bq cp table@timestamp` while time travel remains valid.
## Platform support

| Platform | Support |
|----------|---------|
| macOS / Linux | Native Bash CLI + zsh/bash hooks |
| Windows | npm install; run via **Git Bash** or **WSL**; PowerShell wrapper available |
| Windows CMD | Unsupported |

## AI agent skills

Teach Cursor, Claude Code, and other agents how to use gcpctx safely:

```bash
# Install skills (Cursor, Claude Code, Codex, etc.)
npx skills add UriBer/gcpctx

# Or import in Cursor: Customize → Plugins → Import marketplace
# https://github.com/UriBer/gcpctx
```

Skills included: `gcpctx-usage`, `gcpctx-safety`, `gcpctx-troubleshooting`, `gcpctx-cicd`.  
See [SKILLS_README.md](SKILLS_README.md).

## License

Apache-2.0 — see [LICENSE](LICENSE)

## Contributing / Security

See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md).
