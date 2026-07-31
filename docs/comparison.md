# Comparison

| Capability | gcloud configurations | direnv | aws-vault | kubectx | gcpctx |
|------------|----------------------|--------|-----------|---------|--------|
| gcloud account/project | Yes | Indirect | N/A | N/A | Yes |
| ADC per context | No | Via env file | N/A | N/A | Yes |
| Quota project alignment | Manual | Manual | N/A | N/A | Yes |
| Repo-local marker | No | `.envrc` | No | No | `.gcpctx` |
| Prompt | No | No | No | Yes | Yes |
| Assertions | No | No | No | No | `assert` / `exec --require-context` |

gcpctx is Google Cloud–specific. It complements—not replaces—IAM and CI controls.
