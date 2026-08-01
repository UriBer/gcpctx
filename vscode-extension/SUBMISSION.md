# VSCode Extension Submission Guide

## Overview

The gcpctx Skills VSCode extension provides AI agent skills for managing GCP contexts in VSCode and VSCode-based editors.

## Extension Details

- **Name**: gcpctx-skills
- **Display Name**: gcpctx Skills for AI Assistants
- **Publisher**: uriber
- **Version**: 1.0.0
- **License**: Apache-2.0
- **Repository**: https://github.com/UriBer/gcpctx

## Files Included

```
gcpctx-skills-1.0.0.vsix (700 KB)
├── package.json          # Extension manifest
├── README.md             # User documentation
├── CHANGELOG.md          # Version history
├── LICENSE               # Apache-2.0 license
├── icon.png              # Extension icon
├── out/
│   └── extension.js      # Compiled extension code
└── skills/               # AI skills
    ├── gcpctx-usage/
    ├── gcpctx-safety/
    ├── gcpctx-troubleshooting/
    └── gcpctx-cicd/
```

## Submission to VSCode Marketplace

### Prerequisites

1. **Microsoft Account**: Sign in at https://marketplace.visualstudio.com/
2. **Azure DevOps Organization**: Create one if you don't have it
3. **Personal Access Token** (PAT):
   - Go to https://dev.azure.com/{your-org}/_usersSettings/tokens
   - Create new token with "Marketplace (Publish)" scope
   - Save the token securely

### Create Publisher

1. Go to https://marketplace.visualstudio.com/manage
2. Click "Create publisher"
3. Publisher ID: `uriber`
4. Display name: UriBer or your preferred name
5. Save publisher details

### Publish Extension

#### Option 1: Web UI

1. Go to https://marketplace.visualstudio.com/manage/publishers/uriber
2. Click "+ New extension" → "Visual Studio Code"
3. Upload `gcpctx-skills-1.0.0.vsix`
4. Fill in marketplace details
5. Publish

#### Option 2: Command Line

```bash
cd vscode-extension

# Login (one-time)
npx @vscode/vsce login uriber
# Enter your Personal Access Token when prompted

# Publish
npx @vscode/vsce publish
```

### Post-Publication

After publishing, the extension will be available at:
- **Marketplace**: https://marketplace.visualstudio.com/items?itemName=uriber.gcpctx-skills
- **Install Command**: `ext install uriber.gcpctx-skills`

## Submission to Open VSX Registry

Open VSX is an open-source alternative marketplace used by VSCodium, Gitpod, and others.

### Prerequisites

1. Create account at https://open-vsx.org/
2. Get access token from user settings

### Publish to Open VSX

```bash
npm install -g ovsx

# Login
ovsx create-namespace uriber
# Follow prompts to verify via GitHub

# Publish
cd vscode-extension
ovsx publish gcpctx-skills-1.0.0.vsix -p YOUR_TOKEN
```

### Open VSX URL

After publishing:
- https://open-vsx.org/extension/uriber/gcpctx-skills

## Alternative Distribution Methods

### 1. GitHub Releases

Upload `gcpctx-skills-1.0.0.vsix` to GitHub releases:

```bash
cd /workspace
gh release create vscode-v1.0.0 \
  vscode-extension/gcpctx-skills-1.0.0.vsix \
  --title "VSCode Extension v1.0.0" \
  --notes "Initial release of gcpctx Skills VSCode extension"
```

Users can download and install manually:
```bash
code --install-extension gcpctx-skills-1.0.0.vsix
```

### 2. Direct Download

Host the `.vsix` file on:
- GitHub Pages: https://uriber.github.io/gcpctx/vscode-extension/gcpctx-skills-1.0.0.vsix
- npm registry (as asset)
- CDN

### 3. Installation Instructions

Add to README.md:

```markdown
## Installation

### From VSCode Marketplace
1. Open VSCode
2. Go to Extensions (Ctrl+Shift+X)
3. Search "gcpctx Skills"
4. Click Install

### From VSIX File
```bash
# Download from releases
curl -LO https://github.com/UriBer/gcpctx/releases/download/vscode-v1.0.0/gcpctx-skills-1.0.0.vsix

# Install
code --install-extension gcpctx-skills-1.0.0.vsix
```
```

## Compatible Editors

This extension works with:

1. **Visual Studio Code** (primary target)
   - Requires: VSCode 1.90.0+
   - Works with: GitHub Copilot, Continue extension

2. **Cursor** (VSCode fork)
   - Note: Cursor has native plugin support (already implemented)
   - This extension provides fallback/alternative

3. **Windsurf** (VSCode-based)
   - AI-native code editor
   - Full compatibility

4. **VSCodium** (open-source VSCode)
   - Use Open VSX Registry for distribution
   - Full compatibility

5. **Eclipse Theia** (VSCode-compatible)
   - Cloud IDE platforms
   - Gitpod, AWS Cloud9, etc.

6. **Code-Server** (VSCode in browser)
   - Self-hosted browser IDE
   - Full compatibility

## Testing Before Publication

### Local Installation Test

```bash
cd vscode-extension

# Install locally
code --install-extension gcpctx-skills-1.0.0.vsix

# Test commands
# Open Command Palette (Ctrl+Shift+P)
# Run: "gcpctx: Show Available Skills"
# Run: "gcpctx: Open Documentation"
```

### AI Assistant Integration Test

1. **With GitHub Copilot**:
   ```
   Ask in Copilot Chat:
   "How do I switch my GCP context to staging?"
   
   Expected: AI uses gcpctx-usage skill
   ```

2. **With Continue Extension**:
   ```
   Ask in Continue:
   "Help me protect my production GCP environment"
   
   Expected: AI uses gcpctx-safety skill
   ```

### Verification Checklist

- [ ] Extension loads without errors
- [ ] Commands appear in Command Palette
- [ ] Skills directory is accessible
- [ ] AI assistants can discover and use skills
- [ ] Icon displays correctly
- [ ] README renders properly in marketplace
- [ ] Links work correctly

## Updating the Extension

When releasing a new version:

1. Update version in `package.json`
2. Update `CHANGELOG.md`
3. Rebuild:
   ```bash
   npm run compile
   ```
4. Repackage:
   ```bash
   npx @vscode/vsce package
   ```
5. Republish:
   ```bash
   npx @vscode/vsce publish
   ovsx publish gcpctx-skills-1.0.1.vsix -p TOKEN
   ```

## Marketplace Badges

Add to main README.md:

```markdown
[![VSCode Marketplace](https://img.shields.io/vscode-marketplace/v/uriber.gcpctx-skills)](https://marketplace.visualstudio.com/items?itemName=uriber.gcpctx-skills)
[![Installs](https://img.shields.io/vscode-marketplace/i/uriber.gcpctx-skills)](https://marketplace.visualstudio.com/items?itemName=uriber.gcpctx-skills)
[![Rating](https://img.shields.io/vscode-marketplace/r/uriber.gcpctx-skills)](https://marketplace.visualstudio.com/items?itemName=uriber.gcpctx-skills)
```

## Support

For issues and feature requests:
- GitHub Issues: https://github.com/UriBer/gcpctx/issues
- Label with `vscode-extension`

## License

Apache-2.0 - https://github.com/UriBer/gcpctx/blob/main/LICENSE
