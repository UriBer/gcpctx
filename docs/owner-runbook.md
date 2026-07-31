# Owner runbook — release and security setup

This document tracks repository-owner actions for a public-ready `gcpctx` release.
Automations in CI handle most packaging; a few steps need human credentials or org settings.

## One-time GitHub security

> **Private free-tier limits:** Branch protection, secret scanning, CodeQL, and
> dependency review require **GitHub Pro** or a **public** repository. Dependency
> graph / Dependabot may still be toggled in the UI.

1. **Private vulnerability reporting**
   - Settings → Code security → Enable private vulnerability reporting
   - UI path required on some plans (API may 404)
2. **Dependency graph / Dependabot alerts** (when available)
   - Settings → Code security → Dependency graph → Enable
   - Dependabot alerts → Enable
3. **Secret scanning** (requires Pro/GHAS on private, free on public)
4. **Branch protection on `main`** (requires Pro on private, free on public)
   - Require status checks: `verify (ubuntu-latest)`, `verify (macos-latest)`, `verify (windows-latest)`
   - Disallow force pushes
5. **Or go public** when ready — unlocks CodeQL / dependency-review / Scorecard / branch protection without Pro
6. **GHAS-gated workflows** (CodeQL, dependency-review, Scorecard)
   - Auto-skip while the repo is private (`if: !private || vars.ENABLE_*=true`)
   - After going public (or buying GHAS), set:
     - `ENABLE_CODEQL=true`
     - `ENABLE_DEPENDENCY_REVIEW=true`
     - `ENABLE_SCORECARD=true`

### Distribution repos created

- https://github.com/UriBer/homebrew-tap — `Formula/gcpctx.rb` (SHA256 pending)
- https://github.com/UriBer/scoop-gcpctx — `bucket/gcpctx.json` (hash pending)

## npm publish

1. Create an npm account / org and claim the `gcpctx` name if needed
2. Prefer **trusted publishing** (OIDC) from GitHub Actions on tag `v*`
   - npm → package settings → Trusted Publisher → GitHub Actions
   - Repository: `UriBer/gcpctx`, workflow: `release.yml`
3. Fallback: set repository secret `NPM_TOKEN` (automation token)
4. Set repository variable `NPM_PUBLISH=true` only when ready to publish on tag
5. Tag release: `git tag v0.3.0 && git push origin v0.3.0`

## GitHub Release / Homebrew / Scoop

1. Push tag `v0.3.0` → Release workflow builds archives, checksums, SBOM, attestations
2. Copy SHA256 from `checksums.txt` into:
   - `UriBer/homebrew-tap` formula `Formula/gcpctx.rb`
   - `UriBer/scoop-gcpctx` manifest `bucket/gcpctx.json`
3. GitHub Pages (optional): Settings → Pages → deploy `site/` from `main`

## Local verification before tag

```bash
npm run verify
./bin/gcpctx doctor --json
```

## Remaining residual risks (accepted / mitigated)

| Risk | Mitigation |
|------|------------|
| bash/zsh still `eval` allowlisted exports | `_gcpctx_safe_eval` line allowlist + injection tests |
| PATH-hijacked `gcloud` | Absolute resolve, refuse temp/world-writable for login/scan |
| Unix modes on Windows mounts | `PERMS_UNSUPPORTED` doctor warn; best-effort chmod |
| Monolithic CLI | Incremental `lib/{validation,exports,filesystem,gcloud,doctor,version}.sh` |
