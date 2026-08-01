# VSCode Extension for gcpctx Skills

This directory contains the VSCode extension that bundles gcpctx AI skills for VSCode and VSCode-based editors.

## Structure

```
vscode-extension/
├── package.json          # Extension manifest
├── tsconfig.json         # TypeScript configuration
├── README.md             # Extension documentation
├── CHANGELOG.md          # Version history
├── icon.png              # Extension icon
├── .vscodeignore         # Files to exclude from package
├── src/
│   └── extension.ts      # Extension entry point
├── skills/               # AI skills (copied from ../skills/)
│   ├── gcpctx-usage/
│   ├── gcpctx-safety/
│   ├── gcpctx-troubleshooting/
│   └── gcpctx-cicd/
└── out/                  # Compiled JavaScript (generated)
```

## Development

### Prerequisites

```bash
npm install -g @vscode/vsce
```

### Build

```bash
cd vscode-extension
npm install
npm run compile
```

### Package

```bash
npm run package
# Creates gcpctx-skills-1.0.0.vsix
```

### Install Locally

```bash
code --install-extension gcpctx-skills-1.0.0.vsix
```

### Publish to VSCode Marketplace

1. Create a publisher account at https://marketplace.visualstudio.com/manage
2. Get a Personal Access Token from Azure DevOps
3. Login:
   ```bash
   vsce login uriber
   ```
4. Publish:
   ```bash
   npm run publish
   ```

## Testing

1. Open this directory in VSCode
2. Press F5 to launch Extension Development Host
3. Test commands:
   - Open Command Palette (Ctrl+Shift+P)
   - Run "gcpctx: Show Available Skills"
   - Run "gcpctx: Open Documentation"
4. Test with AI assistant:
   - Open Copilot Chat or Continue
   - Ask "How do I switch GCP contexts with gcpctx?"
   - Verify the AI uses the skills

## Compatible Editors

This extension is compatible with:
- **Visual Studio Code** (1.90.0+) with GitHub Copilot
- **Cursor** (as fallback - native plugin is preferred)
- **Continue** VSCode extension
- **Windsurf**
- **VSCodium** with compatible AI extensions
- Any VSCode fork with AI chat capabilities

## Skills Included

1. **gcpctx-usage** - Initialize and switch GCP contexts
2. **gcpctx-safety** - Protect production environments
3. **gcpctx-troubleshooting** - Debug credential issues
4. **gcpctx-cicd** - Integrate with CI/CD pipelines

## Marketplace Submission

### Before Publishing

- [ ] Test extension in VSCode
- [ ] Test with GitHub Copilot
- [ ] Verify all skills load correctly
- [ ] Update version in package.json
- [ ] Update CHANGELOG.md
- [ ] Ensure icon.png is 128x128 or larger

### Submission Steps

1. **Create Publisher**:
   - Go to https://marketplace.visualstudio.com/manage
   - Click "Create publisher"
   - Publisher ID: `uriber`

2. **Package Extension**:
   ```bash
   npm run package
   ```

3. **Test Package**:
   ```bash
   code --install-extension gcpctx-skills-1.0.0.vsix
   ```

4. **Publish**:
   ```bash
   vsce publish
   ```

### Marketplace URLs

Once published:
- Marketplace: `https://marketplace.visualstudio.com/items?itemName=uriber.gcpctx-skills`
- Install command: `ext install uriber.gcpctx-skills`

## Alternative Distribution

### Open VSX Registry (for VSCodium, etc.)

```bash
npm install -g ovsx
ovsx publish gcpctx-skills-1.0.0.vsix
```

### Manual Distribution

Share the `.vsix` file via:
- GitHub Releases: https://github.com/UriBer/gcpctx/releases
- Direct download link in documentation

## Updating Skills

When skills are updated in the main repository:

1. Copy updated skills:
   ```bash
   rm -rf skills/*
   cp -r ../skills/* skills/
   ```

2. Update version in package.json

3. Update CHANGELOG.md

4. Rebuild and republish:
   ```bash
   npm run compile
   npm run package
   npm run publish
   ```

## Troubleshooting

### Extension not loading skills

- Check VSCode version (must be 1.90.0+)
- Verify skills are in the `skills/` directory
- Check VSCode Output panel for errors
- Ensure AI assistant extension is active

### Skills not appearing in AI chat

- Restart VSCode
- Check that Copilot/Continue is enabled
- Verify extension is activated (check Extensions panel)

## License

Apache-2.0 - see [LICENSE](../LICENSE)
