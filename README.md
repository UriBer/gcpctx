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

Homebrew (after tap publish): `brew install UriBer/tap/gcpctx`  
Scoop: see `packaging/scoop/`  
WinGet: not offered yet — see `packaging/winget/README.md`

## Safety model

- Credential **paths** may be printed; credential **bodies** are never printed
- No telemetry
- Protected contexts, `assert`, and `exec --require-context` for scripts/agents
- See [SECURITY.md](SECURITY.md)

This does **not** make every command safe. Apply IAM least privilege.

## Common workflows

```bash
gcpctx login prod
gcpctx use prod --project other-id
gcpctx protect prod
gcpctx assert --context prod --project other-id
gcpctx exec --require-context prod -- terraform apply
```

Repo marker (safe to commit):

```json
{"name":"dev","project":"example-dev-123456"}
```

## Platform support

| Platform | Support |
|----------|---------|
| macOS / Linux | Native Bash CLI + zsh/bash hooks |
| Windows | npm install; run via **Git Bash** or **WSL**; PowerShell wrapper available |
| Windows CMD | Unsupported |

## License

Apache-2.0 — see [LICENSE](LICENSE)

## Contributing / Security

See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md).
