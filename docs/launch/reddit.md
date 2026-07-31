# Reddit (r/googlecloud / r/devops / r/devops)

**Title:** gcpctx – switch GCP account, project, and ADC together (open source)

**Body:**

gcloud configurations don't switch Application Default Credentials. If you juggle multiple GCP accounts/projects, SDKs and Terraform can still hit the wrong project via the global ADC file.

gcpctx treats context like a Python venv:

- `gcpctx use prod` → CLI + ADC + quota + prompt `(gcp:prod:project)`
- `.gcpctx` marker in repos for auto-activate
- `gcpctx assert` / `exec --require-context` for agents and CI
- Credential bodies never printed; Apache-2.0

Install:

```bash
npm install -g gcpctx && gcpctx shell-setup
```

Repo: https://github.com/UriBer/gcpctx  
npm: https://www.npmjs.com/package/gcpctx

Happy to take feedback / war stories about ADC vs gcloud config mismatches.
