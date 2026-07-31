# Terraform

```bash
gcpctx use prod
gcpctx assert --project my-prod
gcpctx exec --require-context prod -- terraform plan
```

Provider Google uses ADC / `GOOGLE_APPLICATION_CREDENTIALS` — keep them aligned via gcpctx.
