# gcpctx Skills for VSCode

AI agent skills for managing Google Cloud Platform contexts, projects, and credentials using the [gcpctx](https://github.com/UriBer/gcpctx) CLI.

## Features

This extension provides four specialized AI skills that help AI assistants (GitHub Copilot, Continue, Windsurf, etc.) work with gcpctx:

### 🚀 gcpctx-usage
Initialize and switch between GCP contexts. The AI can help you:
- Set up new GCP contexts
- Switch between dev/staging/prod environments
- Check current context and project
- Manage ADC credentials

### 🛡️ gcpctx-safety
Safely manage GCP production environments. The AI can help you:
- Add production protection with `--require-context`
- Implement context assertions in scripts
- Set up folder markers for auto-context switching
- Add fail-fast checks to prevent accidents

### 🔧 gcpctx-troubleshooting
Troubleshoot gcpctx issues and fix credential problems. The AI can help you:
- Diagnose "wrong project" errors
- Fix missing or stale ADC credentials
- Debug permission issues
- Resolve gcloud/ADC mismatches

### 🔄 gcpctx-cicd
Set up gcpctx in CI/CD pipelines. The AI can help you:
- Configure gcpctx in GitHub Actions
- Set up gcpctx in GitLab CI
- Manage service account authentication
- Implement multi-environment deployments

## Requirements

- [gcpctx](https://github.com/UriBer/gcpctx) CLI must be installed:
  ```bash
  npm install -g gcpctx
  ```

- Google Cloud SDK (`gcloud`) must be installed and configured

## Usage

Once installed, these skills are automatically available to AI assistants in VSCode. Simply ask your AI assistant questions like:

- "How do I switch to my staging GCP context?"
- "Set up gcpctx to protect my production environment"
- "Why is gcloud using the wrong project?"
- "Add gcpctx to my GitHub Actions workflow"

The AI will use the appropriate skill to provide accurate, gcpctx-specific guidance.

## Commands

This extension contributes the following commands:

- `gcpctx: Show Available Skills` - Display all available gcpctx skills
- `gcpctx: Open Documentation` - Open the gcpctx GitHub repository

## Compatible Editors

This extension works with:
- **Visual Studio Code** with GitHub Copilot
- **Cursor** (already has native support via Cursor plugin)
- **Continue** VSCode extension
- **Windsurf**
- Any VSCode-based editor with AI chat capabilities

## Installation

### From VSCode Marketplace
1. Open VSCode
2. Go to Extensions (Ctrl+Shift+X / Cmd+Shift+X)
3. Search for "gcpctx Skills"
4. Click Install

### From VSIX
1. Download the `.vsix` file from [releases](https://github.com/UriBer/gcpctx/releases)
2. Open VSCode
3. Go to Extensions (Ctrl+Shift+X / Cmd+Shift+X)
4. Click "..." menu → "Install from VSIX..."
5. Select the downloaded file

## Security

These skills follow gcpctx's security invariants:
- No credential logging or exposure
- Input validation for all parameters
- Read-only operations by default
- Secure file permissions

For more details, see [SECURITY.md](https://github.com/UriBer/gcpctx/blob/main/SECURITY.md)

## Contributing

Issues and pull requests are welcome at [github.com/UriBer/gcpctx](https://github.com/UriBer/gcpctx)

## License

Apache-2.0 - see [LICENSE](https://github.com/UriBer/gcpctx/blob/main/LICENSE)

## Links

- [gcpctx GitHub Repository](https://github.com/UriBer/gcpctx)
- [gcpctx npm Package](https://www.npmjs.com/package/gcpctx)
- [Documentation](https://uriber.github.io/gcpctx/)
- [Report Issues](https://github.com/UriBer/gcpctx/issues)
