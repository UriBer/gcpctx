# LinkedIn / professional post

**Stop deploying to the wrong GCP project.**

`gcloud config configurations` only change the CLI. Application Default Credentials (used by client libraries, Terraform, and many AI coding agents) are a separate global file. That mismatch is a classic footgun: CLI on project A, SDKs still billing/mutating project B.

I open-sourced **gcpctx** — a small context manager that switches account + project + gcloud config + ADC + quota project as one unit, with a venv-style prompt and `assert` / `exec --require-context` guards for agents and CI.

```bash
npm install -g gcpctx
gcpctx shell-setup
gcpctx use prod
gcpctx assert --project your-project
```

Apache-2.0 · npm: https://www.npmjs.com/package/gcpctx  
GitHub: https://github.com/UriBer/gcpctx

#GCP #GoogleCloud #DevTools #Security #OpenSource #Terraform
