# Show HN: gcpctx – stop deploying to the wrong GCP project

gcloud configurations don't switch Application Default Credentials. SDKs and Terraform often use ADC, so you can be in "project A" in gcloud and still mutate project B.

gcpctx switches account, project, gcloud config, ADC, and quota project together, with a venv-style prompt and assert/exec guards for agents and CI.

Apache-2.0 · https://github.com/UriBer/gcpctx
