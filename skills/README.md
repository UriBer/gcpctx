# gcpctx AI Agent Skills

This directory contains AI agent skills for using **gcpctx**, a GCP context management CLI tool.

## What is gcpctx?

gcpctx is a command-line tool for safely switching between Google Cloud Platform (GCP) accounts, projects, and credentials. Think of it as kubectl contexts, but for GCP.

- **GitHub:** https://github.com/UriBer/gcpctx
- **npm:** https://www.npmjs.com/package/gcpctx

## Available Skills

### 1. [gcpctx-usage](./gcpctx-usage/SKILL.md)
**Initialize and switch between GCP contexts using gcpctx**

Covers:
- Installing gcpctx
- Initializing contexts
- Switching contexts
- Multi-project management
- Folder markers for auto-activation
- Environment variables

Use when: User needs to manage multiple GCP contexts, switch projects, or set up GCP credentials.

### 2. [gcpctx-safety](./gcpctx-safety/SKILL.md)
**Safely manage GCP production environments with protection and assertions**

Covers:
- Protected contexts (prevent accidental prod access)
- Context assertions (fail fast if wrong context)
- Safe execution wrapper
- Best practices for destructive operations
- CI/CD safety patterns

Use when: User needs to prevent production accidents, add safety checks, or ensure commands run in correct context.

### 3. [gcpctx-troubleshooting](./gcpctx-troubleshooting/SKILL.md)
**Troubleshoot gcpctx issues and fix credential problems**

Covers:
- Health checks (`gcpctx doctor`)
- Common issues and fixes
- Credential permission problems
- Authentication errors
- Diagnostic commands
- Clean slate recovery

Use when: User reports gcpctx not working, has credential errors, or needs debugging help.

### 4. [gcpctx-cicd](./gcpctx-cicd/SKILL.md)
**Set up gcpctx in CI/CD pipelines and automate context management**

Covers:
- GitHub Actions integration
- GitLab CI setup
- CircleCI configuration
- Multi-environment deployments
- Service account authentication
- Terraform integration
- Secrets management

Use when: User wants to automate context switching in CI/CD, deploy to multiple environments, or integrate with pipelines.

## Installation

All skills assume gcpctx is installed:

```bash
npm install -g gcpctx
```

Verify installation:
```bash
gcpctx version
```

## Quick Start for AI Agents

### Checking Current Context

```bash
# Human-readable
gcpctx current

# JSON output for parsing
gcpctx current --json
```

### Switching Contexts

```bash
# Simple switch
gcpctx use dev

# With assertion
gcpctx use dev
gcpctx assert --context dev --project my-dev-project || exit 1
```

### Safety First

```bash
# Protect production immediately
gcpctx protect prod

# Always assert before destructive operations
gcpctx assert --context dev || exit 1
terraform destroy
```

### Troubleshooting

```bash
# Run health check
gcpctx doctor

# Auto-fix credential permissions
gcpctx secrets fix
```

## Skill Categories

| Category | Skills |
|----------|--------|
| **Core Usage** | gcpctx-usage |
| **Security** | gcpctx-safety |
| **Operations** | gcpctx-troubleshooting |
| **Automation** | gcpctx-cicd |

## Decision Tree for AI Agents

**User mentions GCP context/project issues:**
1. Check if gcpctx installed → Use gcpctx-usage
2. Need to switch contexts → Use gcpctx-usage
3. Prevent prod accidents → Use gcpctx-safety
4. Having errors → Use gcpctx-troubleshooting
5. Setting up CI/CD → Use gcpctx-cicd

**User has credential errors:**
1. Run `gcpctx doctor` → gcpctx-troubleshooting
2. Check common fixes → gcpctx-troubleshooting
3. Re-authenticate if needed → gcpctx-usage

**User asks about safety:**
1. Protect contexts → gcpctx-safety
2. Add assertions → gcpctx-safety
3. Use safe execution → gcpctx-safety

## Common Patterns

### Pattern 1: Initial Setup
```bash
# Initialize contexts
gcpctx init --name dev --account dev@company.com --project dev-123
gcpctx init --name prod --account admin@company.com --project prod-456

# Authenticate
gcpctx login dev
gcpctx login prod

# Protect production
gcpctx protect prod

# Use dev by default
gcpctx use dev
```

### Pattern 2: Safe Deployment
```bash
# Assert context
gcpctx assert --context staging --project staging-123 || exit 1

# Deploy
gcloud run deploy api --source .

# Verify
gcloud run services list
```

### Pattern 3: Troubleshooting
```bash
# Health check
gcpctx doctor

# Fix issues
gcpctx secrets fix

# Re-authenticate
gcpctx login dev

# Verify
gcpctx current
```

### Pattern 4: Multi-Project Work
```bash
# Scan projects
gcpctx scan dev

# List all projects
gcpctx projects dev

# Switch between projects
gcpctx use dev --project frontend-dev
gcpctx project backend-dev
```

## Environment Variables

gcpctx sets these when switching contexts:

- `GOOGLE_APPLICATION_CREDENTIALS` - Path to ADC credentials
- `GOOGLE_CLOUD_PROJECT` - Active project ID
- `GOOGLE_CLOUD_QUOTA_PROJECT` - Quota/billing project
- `CLOUDSDK_CORE_PROJECT` - gcloud CLI project
- `CLOUDSDK_ACTIVE_CONFIG_NAME` - gcloud config name
- `GCPCTX_NAME` - Active context name

## Security Considerations

gcpctx follows 20 security invariants:

✅ Credentials never printed or logged
✅ File permissions restricted (0600/0700)
✅ Input validation prevents injection
✅ Atomic credential updates
✅ No telemetry or external network calls
✅ Path confinement to ~/.gcpctx/

See: https://github.com/UriBer/gcpctx/blob/main/SECURITY.md

## Contributing Skills

To add new gcpctx skills:

1. Create a new directory: `skills/gcpctx-SKILLNAME/`
2. Add `SKILL.md` with frontmatter:
   ```yaml
   ---
   description: Brief description
   category: google-cloud
   tags: [relevant, tags]
   ---
   ```
3. Include:
   - When to use this skill
   - Prerequisites
   - Commands with examples
   - Common workflows
   - Error handling
   - AI agent best practices

## Resources

- **gcpctx GitHub:** https://github.com/UriBer/gcpctx
- **gcpctx npm:** https://www.npmjs.com/package/gcpctx
- **Security Policy:** https://github.com/UriBer/gcpctx/blob/main/SECURITY.md
- **Demo & Examples:** https://github.com/UriBer/gcpctx/tree/main/demo

## License

These skills are provided under the Apache 2.0 license, same as gcpctx.

## Support

- Issues: https://github.com/UriBer/gcpctx/issues
- Discussions: https://github.com/UriBer/gcpctx/discussions
