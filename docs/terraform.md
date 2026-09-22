# Terraform

```bash
gcpctx use prod
gcpctx assert --project my-prod
gcpctx exec --require-context prod --dry-run -- terraform plan
gcpctx exec --require-context prod -- terraform apply
```

Provider Google uses ADC / `GOOGLE_APPLICATION_CREDENTIALS` — keep them aligned via gcpctx.

When history is enabled, `terraform apply`/`destroy` under `gcpctx exec` snapshots `terraform.tfstate` into the journal `before/` directory. `gcpctx undo` restores that state file (review and re-apply as needed). Cost dry-run delegates to gemlake-finops when available.
