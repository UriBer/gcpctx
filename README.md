# gcpctx

Switch Google Cloud **account + project + Application Default Credentials (ADC)** as one unit — so CLI tools, client libraries, and scripts stop creating resources in the wrong project or burning quota on the wrong billing/quota project.

## Why

`gcloud config configurations activate` only affects the `gcloud` CLI.  
ADC (`~/.config/gcloud/application_default_credentials.json`) is **global** and is what Python/Node/Go/Terraform/etc. use. Mixing them causes:

- objects created in the wrong project
- quota / API enablement errors on the wrong project
- silent auth as the wrong user

`gcpctx` keeps a credentials file **per context** and activates them together with env vars Google SDKs already understand.

## Three surfaces

| Surface | How |
|---------|-----|
| **Folder** (like `.venv`) | Put `.gcpctx` in a repo → zsh cd-hook auto-activates |
| **Command** (like `npm`) | `gcpctx use dev` / `gcpctx exec -- …` |
| **API / apps** | Standard env vars + `gcpctx current --json` |

## Install

```bash
./install.sh
exec zsh
gcpctx bootstrap
gcpctx login dev    # browser login per account that needs ADC
gcpctx use prod
gcpctx doctor
```

Installs `~/bin/gcpctx` and wires `shell/gcpctx.zsh` into `~/.zshrc`.

## Quick start

```bash
# Import your existing gcloud configurations (dev/prod/…)
gcpctx bootstrap

# Login ADC into a context (once per account)
gcpctx login prod
gcpctx login dev

# Switch (zsh wrapper auto-evals env)
gcpctx use dev
gcpctx current
gcpctx doctor

# Folder-based: in an app repo
echo '{"name":"dev"}' > .gcpctx
# cd away and back → auto-activate

# Run one command in context (scripts/CI)
gcpctx use prod
gcpctx exec -- gcloud projects describe "$(gcpctx current --json | python3 -c 'import json,sys;print(json.load(sys.stdin)["project"])')"
```

## App / API env vars

On activate, these are set (and well-known ADC is synced):

| Variable | Purpose |
|----------|---------|
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to this context's ADC JSON |
| `GOOGLE_CLOUD_PROJECT` | Default project for SDKs |
| `GOOGLE_CLOUD_QUOTA_PROJECT` | Quota / billing project for ADC |
| `CLOUDSDK_CORE_PROJECT` | gcloud project |
| `CLOUDSDK_ACTIVE_CONFIG_NAME` | Named gcloud configuration |
| `GCPCTX_NAME` | Active context name |

Machine-readable:

```bash
gcpctx current --json
```

```json
{
  "active": true,
  "name": "dev",
  "account": "you@example.com",
  "project": "my-project",
  "quota_project": "my-project",
  "gcloud_config": "dev",
  "credentials_path": "/Users/you/.gcpctx/contexts/dev/credentials.json",
  "credentials_present": true
}
```

## Layout

```
~/.gcpctx/
  active
  contexts/
    <name>/
      meta.json           # account, project, quota, region, gcloud_config
      credentials.json    # ADC for this context only (never commit)

<repo>/.gcpctx            # {"name":"dev"}  — safe to commit
```

## Commands

```
gcpctx init [--name --project --account --region --zone]
gcpctx login [NAME]
gcpctx use <name>
gcpctx activate          # from nearest .gcpctx
gcpctx deactivate
gcpctx list
gcpctx current [--json|--prompt]
gcpctx env [--export]
gcpctx exec -- <cmd>...
gcpctx doctor
gcpctx bootstrap
gcpctx sync-adc [NAME]
gcpctx which
gcpctx version
```

Without the zsh wrapper, export env explicitly:

```bash
eval "$(gcpctx use dev --export)"
```

## Safety

- One ADC file per context (no shared global login across accounts)
- Quota project always aligned to the context project on login/activate
- `gcpctx doctor` fails if gcloud project, env project, and ADC `quota_project_id` disagree

## License

Private — all rights reserved.
