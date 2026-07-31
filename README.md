# gcpctx

Switch Google Cloud **account + project + Application Default Credentials (ADC)** as one unit — so CLI tools, client libraries, and scripts stop creating resources in the wrong project or burning quota on the wrong billing/quota project.

## Install (npm)

```bash
npm install -g gcpctx
gcpctx shell-setup
exec zsh
gcpctx bootstrap
gcpctx doctor
```

Requires: `bash`, `python3`, [`gcloud`](https://cloud.google.com/sdk) CLI. Supported on macOS / Linux / WSL.

Fallback from a clone:

```bash
./install.sh
```

## Why

`gcloud config configurations activate` only affects the `gcloud` CLI.  
ADC (`~/.config/gcloud/application_default_credentials.json`) is **global** and is what Python/Node/Go/Terraform/etc. use. Mixing them causes wrong-project creates and quota errors.

`gcpctx` keeps a credentials file **per context** and activates them with env vars Google SDKs already understand.

## Three surfaces

| Surface | How |
|---------|-----|
| **Folder** (like `.venv`) | Put `.gcpctx` in a repo → zsh cd-hook auto-activates |
| **Command** (like `npm`) | `gcpctx use prod` / `gcpctx exec -- …` |
| **API / apps** | Standard env vars + `gcpctx current --json` |

## Quick start

```bash
gcpctx bootstrap
gcpctx login prod
gcpctx login dev

gcpctx use prod
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
# includes credentials_path + credentials_present — not refresh_token / client_secret
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

Do **not** `cat` credential files into issues or chat logs.

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
  tmp/                        # private scan temp

<repo>/.gcpctx                # {"name":"prod","project":"…"} — safe to commit
```

## Commands

```
gcpctx init | login | use | project | scan | projects
gcpctx activate | deactivate | list | current | env | exec
gcpctx doctor [--fix] | secrets fix
gcpctx bootstrap | sync-adc | shell-setup | shell-path | which | version
```

Without the zsh wrapper:

```bash
eval "$(gcpctx use prod --export)"
```

## License

UNLICENSED — all rights reserved. Install via npm for use; source remains private unless otherwise stated.
