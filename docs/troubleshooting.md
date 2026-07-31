# Troubleshooting

| Symptom | Fix |
|---------|-----|
| `eval` errors on activate | Upgrade to ≥0.3.0; ensure `--export` stdout is only `export` lines (`gcpctx use x --export \| cat -A`) |
| Doctor permission errors | `gcpctx secrets fix` |
| PowerShell can't find bash | Install Git for Windows or WSL |
| Wrong project in SDKs | `gcpctx doctor`; confirm `GOOGLE_APPLICATION_CREDENTIALS` |
| Login quota-project flag error | Use ≥0.2.1 login path (`set-quota-project`) |
