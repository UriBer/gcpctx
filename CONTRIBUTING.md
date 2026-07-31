# Contributing

## Development

```bash
npm run verify
```

Requires Bash, Python 3, and optionally `bats`, `shellcheck`, `shfmt`.

## Tests

Tests use an isolated `HOME` / `GCPCTX_HOME` and a fake `gcloud`. They never read your real ADC.

## Pull requests

- Prefer conventional commits (`feat:`, `fix:`, `security:`, `docs:`)
- Do not commit credentials or real project secrets
- Keep security-sensitive changes reviewable

## Code of conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
