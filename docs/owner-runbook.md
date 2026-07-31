# Owner runbook — release and security setup

This document tracks repository-owner actions for a public-ready `gcpctx` release.
Automations in CI handle most packaging; a few steps need human credentials or org settings.

## One-time GitHub security

1. **Private vulnerability reporting**
   - Settings → Code security → Enable private vulnerability reporting
   - Or: `gh api -X PUT repos/UriBer/gcpctx/private-vulnerability-reporting`
2. **Dependency graph / Dependabot alerts** (free on private)
   - Settings → Code security → Dependency graph → Enable
   - Dependabot alerts → Enable
3. **Secret scanning** (recommended; GHAS may be required on private)
4. **Branch protection on `main`**
   - Require PR reviews (optional while solo)
   - Require status checks: `verify (ubuntu-latest)`, `verify (macos-latest)`, `verify (windows-latest)`
   - Disallow force pushes
5. **GHAS-gated workflows** (CodeQL, dependency-review, Scorecard)
   - Auto-skip while the repo is private
   - After going public (or buying GHAS), set repo variables:
     - `ENABLE_CODEQL=true`
     - `ENABLE_DEPENDENCY_REVIEW=true`
     - `ENABLE_SCORECARD=true`

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
