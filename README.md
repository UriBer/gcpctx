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
gcpctx use prod
gcpctx scan                 # discover projects for that account
gcpctx projects             # list cached projects
gcpctx use prod --project other-project
# or keep context and only change project:
gcpctx project other-project
gcpctx current
gcpctx doctor

# Folder-based: in an app repo
echo '{"name":"prod","project":"example-dev-123456"}' > .gcpctx
# cd away and back → auto-activate context + project

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
  "name": "prod",
  "account": "you@example.com",
  "project": "my-project",
  "quota_project": "my-project",
  "gcloud_config": "prod",
  "credentials_path": "/Users/you/.gcpctx/contexts/prod/credentials.json",
  "credentials_present": true,
  "projects_scanned": 12,
  "projects_scanned_at": "2026-07-31T06:00:00Z"
}
```

## Layout

```
~/.gcpctx/
  active
  contexts/
    <name>/
      meta.json           # account, active project, quota, region, gcloud_config
      credentials.json    # ADC for this context/account (never commit)
      projects.json       # cached scan of projects this account can access

<repo>/.gcpctx            # {"name":"prod","project":"my-gcp-project"}  — safe to commit
```

A **context** is an account/env (credentials). A **project** is selected inside that context after `gcpctx scan`.

## Commands

```
gcpctx init [--name --project --account --region --zone]
gcpctx login [NAME]
gcpctx use <name> [--project PROJECT]
gcpctx project <project-id>      # switch project in active context
gcpctx project set <project-id>
gcpctx scan [NAME] [--json]      # discover projects for context account
gcpctx projects [NAME] [--json] [--refresh]
gcpctx activate          # from nearest .gcpctx (honors project field)
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

- One ADC file per context/account (no shared global login across accounts)
- Quota project always aligned to the **selected** project on login/activate/project switch
- `gcpctx doctor` fails if gcloud project, env project, and ADC `quota_project_id` disagree
- `gcpctx scan` caches projects per context so `use`/`project` can resolve IDs (and warn if unknown)

## License

Private — all rights reserved.
