# gcpctx - AI Agent Skills

[![npm version](https://img.shields.io/npm/v/gcpctx.svg)](https://www.npmjs.com/package/gcpctx)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Socket.dev Security](https://img.shields.io/badge/socket.dev-analyzed-brightgreen)](https://socket.dev/npm/package/gcpctx)

AI agent skills for **gcpctx**, a command-line tool for safely managing Google Cloud Platform contexts, projects, and credentials.

## What is gcpctx?

gcpctx is like kubectl contexts, but for GCP. It lets you:

- ✅ Switch between GCP accounts/projects instantly
- ✅ Prevent production accidents with protected contexts
- ✅ Use assertions to fail fast if in wrong context
- ✅ Auto-activate contexts per directory with folder markers
- ✅ Manage credentials securely with 20 documented security invariants

**Links:**
- **GitHub:** https://github.com/UriBer/gcpctx
- **npm:** https://www.npmjs.com/package/gcpctx
- **Security:** https://github.com/UriBer/gcpctx/blob/main/SECURITY.md

## Available Skills

### 1. [gcpctx-usage](./skills/gcpctx-usage/SKILL.md)
**Initialize and switch between GCP contexts**

For: Context management, project switching, credential setup
```bash
gcpctx init --name dev --project my-dev-project
gcpctx use dev
gcpctx current --json
```

### 2. [gcpctx-safety](./skills/gcpctx-safety/SKILL.md)
**Safely manage production environments with protection and assertions**

For: Production safety, preventing accidents, fail-fast checks
```bash
gcpctx protect prod
gcpctx assert --context dev || exit 1
gcpctx exec --require-context dev -- terraform apply
```

### 3. [gcpctx-troubleshooting](./skills/gcpctx-troubleshooting/SKILL.md)
**Troubleshoot gcpctx issues and fix credential problems**

For: Debugging, credential errors, health checks
```bash
gcpctx doctor
gcpctx secrets fix
```

### 4. [gcpctx-cicd](./skills/gcpctx-cicd/SKILL.md)
**Set up gcpctx in CI/CD pipelines**

For: GitHub Actions, GitLab CI, automation, multi-environment deployments
```yaml
- run: gcpctx init --name ci --project ${{ secrets.GCP_PROJECT }}
- run: gcpctx assert --context ci && deploy
```

## Installation

### For Cursor IDE

#### Option 1: Cursor Marketplace (Coming Soon)
Install from **Cursor → Customize → Plugins** → Search "gcpctx"

#### Option 2: Team Marketplace (Immediate)
1. Open **Cursor → Customize → Plugins**
2. Click **Import marketplace** or **Add marketplace**
3. Paste: `https://github.com/UriBer/gcpctx`
4. Install the "gcpctx" plugin

#### Option 3: Direct Installation (Manual)
```bash
# Clone into Cursor's local plugins directory
git clone https://github.com/UriBer/gcpctx ~/.cursor/plugins/local/gcpctx

# Or just the skills
mkdir -p ~/.cursor/skills
cp -r skills/* ~/.cursor/skills/
```

### For Claude Code / Other Agents

```bash
# Using npx skills CLI
npx skills add UriBer/gcpctx

# Or manual installation
git clone https://github.com/UriBer/gcpctx
cp -r gcpctx/skills ~/.claude/skills/
```

### Prerequisites

Install gcpctx CLI:
```bash
npm install -g gcpctx
```

Verify:
```bash
gcpctx version
```

## Quick Start

### 1. Initialize contexts
```bash
gcpctx init --name dev --account dev@company.com --project dev-123
gcpctx init --name prod --account admin@company.com --project prod-456
```

### 2. Protect production
```bash
gcpctx protect prod
```

### 3. Switch contexts
```bash
gcpctx use dev
gcpctx current --json
```

### 4. Use assertions for safety
```bash
gcpctx assert --context dev || exit 1
terraform apply
```

## For AI Agents

These skills teach AI agents to:

✅ **Check current context** before GCP operations  
✅ **Switch contexts** safely with assertions  
✅ **Protect production** from accidental changes  
✅ **Troubleshoot** credential and permission issues  
✅ **Automate** context management in CI/CD  

### Example Agent Workflow

```bash
# Agent checks context
CONTEXT=$(gcpctx current --json | jq -r '.name')

# Agent asserts before destructive operation
gcpctx assert --context dev --project my-dev-project || {
  echo "❌ Not in dev context! Aborting."
  exit 1
}

# Agent executes safely
gcloud compute instances delete my-instance
```

## Plugin Structure

```
gcpctx/
├── .cursor-plugin/
│   ├── plugin.json           # Plugin manifest
│   └── marketplace.json      # Marketplace metadata
│
├── skills/
│   ├── gcpctx-usage/         # Core usage skill
│   ├── gcpctx-safety/        # Production safety skill
│   ├── gcpctx-troubleshooting/  # Debugging skill
│   └── gcpctx-cicd/          # CI/CD integration skill
│
├── demo/                      # Demo scenarios and examples
├── assets/                    # Logo and visual assets
└── README.md
```

## Skill Format

Each skill follows the open Agent Skills standard:

```markdown
---
description: Brief description
category: google-cloud
tags: [gcp, relevant, tags]
---

# Skill Title

## When to use this skill
- User mentions X
- User needs to Y

## Commands
\```bash
gcpctx command --flag value
\```

## Best Practices for AI Agents
- Always check context first
- Use assertions for safety
```

## Contributing

Contributions welcome! To add new skills:

1. Create `skills/skill-name/SKILL.md`
2. Follow the Agent Skills format
3. Test with Cursor or Claude Code
4. Submit a PR

See [CONTRIBUTING.md](./CONTRIBUTING.md) for details.

## Security

gcpctx follows 20 documented security invariants:

- ✅ Credentials never printed or logged
- ✅ File permissions restricted (0600/0700)
- ✅ Input validation prevents injection
- ✅ No telemetry or external calls
- ✅ Path confinement to `~/.gcpctx/`

Full security policy: https://github.com/UriBer/gcpctx/blob/main/SECURITY.md

**Socket.dev Analysis:** https://socket.dev/npm/package/gcpctx
- Supply Chain Score: 51 (expected for shell-based CLI)
- Vulnerability Score: 100
- License Score: 100

## Support

- **Issues:** https://github.com/UriBer/gcpctx/issues
- **Discussions:** https://github.com/UriBer/gcpctx/discussions
- **Security:** See [SECURITY.md](./SECURITY.md)

## Resources

- **Demo & Examples:** [demo/](./demo/)
- **Social Media Content:** [demo/SOCIAL_MEDIA_CONTENT.md](./demo/SOCIAL_MEDIA_CONTENT.md)
- **Socket.dev Analysis:** [demo/SOCKET_ANALYSIS.md](./demo/SOCKET_ANALYSIS.md)

## License

Apache 2.0 - See [LICENSE](./LICENSE)

## Acknowledgments

Built with the [Agent Skills](https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills) open standard.

Compatible with:
- ✅ Cursor IDE
- ✅ Claude Code
- ✅ VS Code (with extensions)
- ✅ Any agent supporting Agent Skills standard
