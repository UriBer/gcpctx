# Releasing

1. Ensure `package.json` version == `VERSION`
2. Update `CHANGELOG.md`
3. `npm run verify`
4. Complete [owner runbook](owner-runbook.md) security + npm steps
5. Tag `vX.Y.Z` and push tags
6. GitHub Actions Release builds archives, checksums, SBOM, attestations
7. Set repository variable `NPM_PUBLISH=true` and configure trusted publisher / `NPM_TOKEN` for npm
8. Update Homebrew formula SHA in `UriBer/homebrew-tap`
9. Update Scoop hash in `UriBer/scoop-gcpctx`

## Rollback

- GitHub: mark release as retracted; delete tag if needed
- npm: `npm deprecate gcpctx@X.Y.Z "message"`
