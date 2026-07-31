# Show HN: gcpctx – stop deploying to the wrong GCP project

## Title
Show HN: gcpctx – stop deploying to the wrong GCP project

## URL
https://github.com/UriBer/gcpctx

## Text (optional body)

gcloud configurations don't switch Application Default Credentials. SDKs, Terraform providers, and many AI coding agents use ADC — a separate global file — so you can be "in project A" on the CLI and still mutate project B.

gcpctx switches account, project, gcloud config, ADC, and quota project together:

```
npm install -g gcpctx
gcpctx shell-setup
gcpctx use prod
# prompt → (gcp:prod:your-project)
gcpctx assert --project your-project
```

Also: repo `.gcpctx` markers (like `.venv`), protect/assert/exec guards for agents, Apache-2.0.

https://www.npmjs.com/package/gcpctx  
https://github.com/UriBer/gcpctx
