---
description: Initialize and switch between GCP contexts using gcpctx
category: google-cloud
tags: [gcp, credentials, context-switching, devops]
---

# gcpctx: GCP Context Management

Use gcpctx to safely switch between Google Cloud Platform accounts, projects, and credentials.

## When to use this skill

- User asks to switch GCP contexts, projects, or accounts
- User needs to manage multiple GCP environments (dev/staging/prod)
- User mentions confusion about which GCP project they're in
- User wants to set up GCP credentials for different contexts
- User needs to prevent production accidents when working with GCP

## Prerequisites

Check if gcpctx is installed:

```bash
command -v gcpctx || npm install -g gcpctx
```

## Core Commands

### 1. Check Current Context

```bash
gcpctx current
# Or with JSON output
gcpctx current --json
```

### 2. List Available Contexts

```bash
gcpctx list
```

### 3. Initialize a New Context

```bash
gcpctx init --name CONTEXT_NAME --account ACCOUNT_EMAIL --project PROJECT_ID
```

Example:
```bash
gcpctx init --name dev --account dev@company.com --project my-dev-project
gcpctx init --name staging --account staging@company.com --project my-staging-project
gcpctx init --name prod --account admin@company.com --project my-prod-project
```

### 4. Switch Context

```bash
gcpctx use CONTEXT_NAME
```

This atomically switches:
- GCP account
- Default project
- ADC (Application Default Credentials)
- Environment variables (GOOGLE_CLOUD_PROJECT, GOOGLE_APPLICATION_CREDENTIALS, etc.)

### 5. Login to a Context

After initializing, authenticate:

```bash
gcpctx login CONTEXT_NAME
```

This opens the browser for OAuth authentication.

## Multi-Project Management

### Scan for Projects

Discover all projects accessible to a context's account:

```bash
gcpctx scan CONTEXT_NAME
```

### List Projects

```bash
gcpctx projects CONTEXT_NAME
# Or with JSON
gcpctx projects CONTEXT_NAME --json
```

### Switch Project Within Context

```bash
# Switch to a different project in the same context
gcpctx use CONTEXT_NAME --project OTHER_PROJECT_ID

# Or just switch the project in active context
gcpctx project OTHER_PROJECT_ID
```

## Folder Markers (Auto-Activation)

For project-specific contexts, create a `.gcpctx` marker file:

```bash
# In your project directory
echo '{"name":"dev","project":"my-dev-project"}' > .gcpctx

# Activate context from marker
gcpctx activate
```

Now all GCP commands in this directory use the specified context.

## Safety Features

### Protect Production

```bash
gcpctx protect prod
```

Now switching to `prod` requires `--force` flag.

### Assert Context Before Dangerous Operations

```bash
# Fail fast if not in expected context
gcpctx assert --context dev
gcpctx assert --project my-dev-project
gcpctx assert --account dev@company.com

# Use in commands
gcpctx assert --context dev && terraform apply
```

### Safe Execution

```bash
# Only run command if in specific context
gcpctx exec --require-context dev -- gcloud compute instances delete my-instance
```

If current context is not `dev`, the command will not execute.

## Troubleshooting

### Health Check

```bash
gcpctx doctor
# Or with JSON output
gcpctx doctor --json
```

Checks:
- gcloud CLI installation
- Context metadata validity
- Credential file permissions
- ADC configuration

### Fix Credential Permissions

```bash
gcpctx secrets fix
```

Auto-repairs common issues:
- Sets directory permissions to 0700
- Sets credential file permissions to 0600

### Get Package Location

```bash
gcpctx which
```

## Best Practices for AI Agents

1. **Always check current context before GCP operations:**
   ```bash
   gcpctx current --json
   ```

2. **Use assertions for safety:**
   ```bash
   gcpctx assert --context dev || exit 1
   ```

3. **Create folder markers in project repos:**
   ```bash
   echo '{"name":"dev"}' > .gcpctx
   gcpctx activate
   ```

4. **Protect production contexts immediately:**
   ```bash
   gcpctx protect prod
   ```

5. **Use `--json` flag for parsing output in scripts:**
   ```bash
   CURRENT=$(gcpctx current --json | jq -r '.name')
   ```

## Common Workflows

### Setup new environment

```bash
# Initialize contexts
gcpctx init --name dev --account dev@company.com --project dev-123
gcpctx init --name prod --account admin@company.com --project prod-456

# Authenticate
gcpctx login dev
gcpctx login prod

# Protect production
gcpctx protect prod

# Scan for projects
gcpctx scan dev

# Set up folder marker
echo '{"name":"dev"}' > .gcpctx
```

### Switch for deployment

```bash
# Deploy to dev
gcpctx use dev
gcloud run deploy api --source .

# Deploy to staging
gcpctx use staging
gcloud run deploy api --source .

# Deploy to prod (requires --force due to protection)
gcpctx use prod --force
gcpctx assert --project prod-456 && gcloud run deploy api --source .
```

### Troubleshoot credential issues

```bash
# Check health
gcpctx doctor

# Fix permissions
gcpctx secrets fix

# Re-authenticate if needed
gcpctx login dev

# Verify
gcpctx current
gcloud auth list
```

## Environment Variables Set by gcpctx

When you switch contexts, these are set:

- `GOOGLE_APPLICATION_CREDENTIALS` - Path to ADC credentials
- `GOOGLE_CLOUD_PROJECT` - Active project ID
- `GOOGLE_CLOUD_QUOTA_PROJECT` - Quota/billing project
- `CLOUDSDK_CORE_PROJECT` - gcloud CLI project
- `CLOUDSDK_ACTIVE_CONFIG_NAME` - gcloud config name
- `GCPCTX_NAME` - Active context name

## Error Handling

If operations fail:

1. Check context: `gcpctx current`
2. Run health check: `gcpctx doctor`
3. Fix permissions: `gcpctx secrets fix`
4. Re-authenticate: `gcpctx login CONTEXT_NAME`
5. Verify gcloud: `gcloud auth list`

## References

- GitHub: https://github.com/UriBer/gcpctx
- npm: https://www.npmjs.com/package/gcpctx
- Security: https://github.com/UriBer/gcpctx/blob/main/SECURITY.md
