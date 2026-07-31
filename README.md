# gcpctx

Switch Google Cloud **account + project + Application Default Credentials (ADC)** as one unit — so CLI tools, client libraries, and scripts stop creating resources in the wrong project or burning quota on the wrong billing/quota project.

## Install (npm)

```bash
npm install -g gcpctx
gcpctx shell-setup          # wires zsh and/or bash (and PowerShell if present)
# restart shell
gcpctx bootstrap
gcpctx doctor
```

Requires: `bash`, `python3`, [`gcloud`](https://cloud.google.com/sdk) CLI.

| Platform | Shells |
|----------|--------|
| macOS / Linux | **zsh**, **bash** |
| Windows | **PowerShell** (needs Git Bash or WSL) + **Git Bash** |
| Windows CMD | Not supported — use PowerShell or Git Bash |

```bash
# explicit shells
gcpctx shell-setup --zsh
gcpctx shell-setup --bash
gcpctx shell-setup --pwsh
gcpctx shell-setup --all
```

Fallback from a clone: `./install.sh`

## Prompt (venv-style)

When a context is active, the prompt shows the env before the caret:

```text
(gcp:prod:example-dev-123456) user@host ~ %
```

Works in zsh, bash, and PowerShell. Disable with:

```bash
export GCPCTX_DISABLE_PROMPT=1
# PowerShell: $env:GCPCTX_DISABLE_PROMPT = '1'
```

## Why

`gcloud config configurations activate` only affects the `gcloud` CLI.  
ADC is **global** and is what client libraries use. Mixing them causes wrong-project creates and quota errors.

`gcpctx` keeps a credentials file **per context** and activates them with env vars Google SDKs already understand.

## Three surfaces

| Surface | How |
|---------|-----|
| **Folder** (like `.venv`) | Put `.gcpctx` in a repo → shell cd-hook auto-activates |
| **Command** (like `npm`) | `gcpctx use prod` / `gcpctx exec -- …` |
| **API / apps** | Standard env vars + `gcpctx current --json` |

## Quick start

```bash
gcpctx bootstrap
gcpctx login prod
gcpctx login dev

gcpctx use prod              # prompt → (gcp:prod:…)
gcpctx scan
gcpctx projects
gcpctx use prod --project other-project
gcpctx project other-project

echo '{"name":"prod","project":"my-gcp-project"}' > .gcpctx
```

## App / API env vars

On activate (paths and ids only — **never** token contents):

| Variable | Purpose |
|----------|---------|
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to this context's ADC JSON |
| `GOOGLE_CLOUD_PROJECT` | Default project for SDKs |
| `GOOGLE_CLOUD_QUOTA_PROJECT` | Quota project for ADC |
| `CLOUDSDK_CORE_PROJECT` | gcloud project |
| `CLOUDSDK_ACTIVE_CONFIG_NAME` | Named gcloud configuration |
| `GCPCTX_NAME` | Active context name |

```bash
gcpctx current --json
gcpctx current --prompt    # (gcp:name:project)
```

## Security

**Invariant:** refresh tokens, client secrets, and credential JSON bodies never leave the machine via npm pack, CLI stdout/stderr, `--json`, or `--export`.

| Control | Behavior |
|---------|----------|
| Local store | `~/.gcpctx` mode `700`; `credentials.json` mode `600` |
| Export / JSON | Paths and project metadata only |
| Doctor | Permission checks; never dumps ADC JSON |
| Repair | `gcpctx secrets fix` or `gcpctx doctor --fix` |
| Publish | `npm run pack:check` blocks secret patterns in the tarball |

```bash
gcpctx secrets fix
gcpctx doctor
```

## Layout

```
~/.gcpctx/                    # mode 700
  contexts/<name>/            # mode 700
    meta.json
    credentials.json          # mode 600 — never commit
    projects.json
  tmp/

<repo>/.gcpctx                # {"name":"prod","project":"…"} — safe to commit
```

## Commands

```
gcpctx init | login | use | project | scan | projects
gcpctx activate | deactivate | list | current | env | exec
gcpctx doctor [--fix] | secrets fix
gcpctx bootstrap | sync-adc
gcpctx shell-setup | shell-path [--zsh|--bash|--ps1]
gcpctx which | version
```

Without the shell wrapper:

```bash
eval "$(gcpctx use prod --export)"
```

## License

UNLICENSED — all rights reserved. Install via npm for use; source remains private unless otherwise stated.
