# Releasing

1. Ensure `package.json` version == `VERSION`
2. Update `CHANGELOG.md`
3. `npm run verify`
4. Tag `vX.Y.Z` and push tags
5. GitHub Actions Release builds archives, checksums, SBOM, attestations
6. Set repository variable `NPM_PUBLISH=true` and configure trusted publisher / `NPM_TOKEN` for npm
7. Update Homebrew formula SHA in `UriBer/homebrew-tap`
8. Update Scoop hash when publishing the bucket

## Rollback

- GitHub: mark release as retracted; delete tag if needed
- npm: `npm deprecate gcpctx@X.Y.Z "message"`
