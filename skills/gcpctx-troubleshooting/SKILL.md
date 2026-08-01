---
name: gcpctx-troubleshooting
description: Troubleshoot gcpctx issues and fix credential problems. Use when gcpctx fails, ADC is missing, permissions are wrong, or gcloud uses the wrong project.
---

# gcpctx: Troubleshooting

Diagnose and fix common gcpctx and GCP credential issues.

## When to use this skill

- User reports gcpctx not working
- User has credential or authentication errors
- User can't switch contexts
- User has permission denied errors
- User's gcloud commands use wrong project/account
- User asks how to debug gcpctx issues

## Quick Diagnosis

### Run Health Check

```bash
gcpctx doctor
```

Shows:
- ✅ gcloud CLI found
- ✅ Context metadata valid
- ✅ Credential permissions correct
- ⚠️ Warnings for fixable issues
- ❌ Errors requiring attention

With JSON output for parsing:
```bash
gcpctx doctor --json
```

## Common Issues and Fixes

### Issue 1: "gcloud not found"

**Symptoms:**
```
❌ gcloud CLI not found on PATH
```

**Fix:**
```bash
# Install gcloud SDK
# macOS
brew install google-cloud-sdk

# Linux
curl https://sdk.cloud.google.com | bash

# Verify installation
gcloud --version

# If installed but not on PATH
export PATH="$PATH:$HOME/google-cloud-sdk/bin"

# Make permanent (zsh)
echo 'export PATH="$PATH:$HOME/google-cloud-sdk/bin"' >> ~/.zshrc

# Make permanent (bash)
echo 'export PATH="$PATH:$HOME/google-cloud-sdk/bin"' >> ~/.bashrc
```

### Issue 2: "Permission denied" on credential files

**Symptoms:**
```
❌ Context 'dev' credentials permissions: 0644 (should be 0600)
Permission denied: /home/user/.gcpctx/contexts/dev/credentials.json
```

**Fix:**
```bash
# Auto-fix all permission issues
gcpctx secrets fix

# Manual fix
chmod 0700 ~/.gcpctx/contexts/*
chmod 0600 ~/.gcpctx/contexts/*/credentials.json
```

### Issue 3: "Application Default Credentials not found"

**Symptoms:**
```
Error: Could not load the default credentials
DefaultCredentialsError: Could not load ADC
```

**Fix:**
```bash
# Check current context
gcpctx current

# Re-authenticate
gcpctx login CONTEXT_NAME

# Verify ADC file exists
ls -la ~/.gcpctx/contexts/CONTEXT_NAME/credentials.json

# Verify environment variable
echo $GOOGLE_APPLICATION_CREDENTIALS

# If missing, reactivate context
gcpctx use CONTEXT_NAME
```

### Issue 4: Context metadata corrupted

**Symptoms:**
```
❌ Context 'dev' metadata invalid
Error: Failed to parse context metadata
```

**Fix:**
```bash
# Backup existing context
cp -r ~/.gcpctx/contexts/dev ~/.gcpctx/contexts/dev.backup

# Re-initialize context
gcpctx init --name dev --account dev@company.com --project my-dev-project

# Re-authenticate
gcpctx login dev

# If you had projects scanned, rescan
gcpctx scan dev
```

### Issue 5: Wrong project being used

**Symptoms:**
- gcloud commands target wrong project
- API calls use unexpected project
- Billing goes to wrong project

**Diagnosis:**
```bash
# Check gcpctx context
gcpctx current --json

# Check gcloud config
gcloud config list

# Check environment variables
env | grep GOOGLE_
env | grep CLOUDSDK_

# Check which gcloud config is active
gcloud config configurations list
```

**Fix:**
```bash
# Use correct context
gcpctx use CORRECT_CONTEXT

# Verify project
gcpctx current

# If project wrong in context, switch it
gcpctx project CORRECT_PROJECT_ID

# Verify
gcloud config get-value project
echo $GOOGLE_CLOUD_PROJECT
```

### Issue 6: gcpctx commands don't affect environment

**Symptoms:**
- Environment variables not set after `gcpctx use`
- gcloud still uses old project

**Cause:**
Commands need to be evaluated in current shell.

**Fix:**
```bash
# Instead of:
gcpctx use dev

# Use eval (bash/zsh):
eval "$(gcpctx use dev --export)"

# Or install shell integration (one-time):
gcpctx shell-setup

# Reload shell
exec $SHELL

# Now regular commands work:
gcpctx use dev
gcpctx activate
gcpctx deactivate
```

### Issue 7: Protected context can't be accessed

**Symptoms:**
```
⚠️  Context 'prod' is protected!
Use --force to switch, or --protected=false to remove protection
```

**Fix:**
```bash
# Intentional switch (use force)
gcpctx use prod --force

# Or temporarily unprotect (not recommended)
gcpctx unprotect prod
gcpctx use prod
gcpctx protect prod  # Re-protect immediately
```

### Issue 8: "Context does not exist"

**Symptoms:**
```
❌ Context 'staging' does not exist
Run: gcpctx list
```

**Fix:**
```bash
# List available contexts
gcpctx list

# Initialize missing context
gcpctx init --name staging --account staging@company.com --project staging-project

# Login
gcpctx login staging
```

### Issue 9: gcpctx not found after npm install

**Symptoms:**
```
bash: gcpctx: command not found
```

**Fix:**
```bash
# Verify installation
npm list -g gcpctx

# If not installed globally
npm install -g gcpctx

# If installed but not on PATH, find it
npm root -g
# Add to PATH: /usr/local/lib/node_modules/.bin or similar

# Or use npx
npx gcpctx current

# Check npm global bin path
npm bin -g
# Add that directory to PATH
```

### Issue 10: Credentials expired

**Symptoms:**
```
Error: Request had invalid authentication credentials
Error 401: Unauthorized
```

**Fix:**
```bash
# Re-authenticate
gcpctx login CONTEXT_NAME

# Verify tokens
gcloud auth print-access-token

# If still failing, clear and re-auth
rm ~/.gcpctx/contexts/CONTEXT_NAME/credentials.json
gcpctx login CONTEXT_NAME
```

## Diagnostic Commands

### Check Installation

```bash
# gcpctx version
gcpctx version

# gcpctx location
gcpctx which

# gcloud version
gcloud --version

# Node.js version (for npm install)
node --version
npm --version
```

### Check Context State

```bash
# Current context
gcpctx current --json

# All contexts
gcpctx list

# Context metadata
cat ~/.gcpctx/active
cat ~/.gcpctx/contexts/CONTEXT_NAME/metadata.json
```

### Check Credentials

```bash
# ADC location
echo $GOOGLE_APPLICATION_CREDENTIALS

# ADC content (DO NOT share publicly!)
cat $GOOGLE_APPLICATION_CREDENTIALS | jq .type

# gcloud auth
gcloud auth list

# Active account
gcloud config get-value account
```

### Check Environment

```bash
# All GCP-related env vars
env | grep -E "(GOOGLE_|GCLOUD|CLOUDSDK_|GCPCTX_)"

# Active project
echo $GOOGLE_CLOUD_PROJECT
gcloud config get-value project

# gcloud config
gcloud config configurations list
gcloud config configurations describe $(gcloud config get-value core/account)
```

### Check Permissions

```bash
# Context directory permissions
ls -la ~/.gcpctx/
ls -la ~/.gcpctx/contexts/

# Credential file permissions
ls -la ~/.gcpctx/contexts/*/credentials.json

# Should be:
# drwx------ (0700) for directories
# -rw------- (0600) for credential files
```

## Advanced Troubleshooting

### Enable Debug Mode

```bash
# Set bash debug mode
set -x

# Run gcpctx command
gcpctx use dev

# Disable debug mode
set +x
```

### Check for Conflicts

```bash
# Check for environment variables that might conflict
env | grep -E "(GOOGLE_|GCLOUD|CLOUDSDK_)"

# Unset conflicting variables
unset GOOGLE_CLOUD_PROJECT
unset GOOGLE_APPLICATION_CREDENTIALS

# Reactivate context
gcpctx use dev
```

### Verify API Access

```bash
# Test API access
gcloud projects list

# Test specific API
gcloud compute instances list

# Check quotas
gcloud compute project-info describe --project=PROJECT_ID
```

### Clean Slate Recovery

If all else fails:

```bash
# Backup current state
cp -r ~/.gcpctx ~/.gcpctx.backup

# Remove gcpctx state
rm -rf ~/.gcpctx

# Reinitialize
gcpctx init --name dev --account dev@company.com --project dev-project
gcpctx login dev
gcpctx use dev

# Verify
gcpctx doctor
gcpctx current
gcloud config list
```

## AI Agent Troubleshooting Workflow

When user reports issues:

1. **Run health check:**
   ```bash
   gcpctx doctor --json
   ```

2. **Parse and report issues:**
   ```bash
   issues=$(gcpctx doctor --json | jq -r '.issues[]')
   ```

3. **Auto-fix if possible:**
   ```bash
   gcpctx secrets fix
   ```

4. **Verify fix:**
   ```bash
   gcpctx doctor
   ```

5. **If still broken, guide user through manual steps**

6. **As last resort, suggest clean reinstall**

## Logging and Debugging

gcpctx doesn't log by default (security), but you can:

```bash
# Capture command output
gcpctx current 2>&1 | tee gcpctx.log

# Verify behavior
strace gcpctx use dev 2>&1 | grep -E "(open|exec|stat)"
```

⚠️ **Never share logs publicly** - they may contain credential paths.

## Getting Help

If issue persists:

```bash
# Collect safe diagnostic info
echo "gcpctx version: $(gcpctx version)"
echo "gcloud version: $(gcloud --version | head -1)"
echo "OS: $(uname -a)"
echo "Shell: $SHELL"
gcpctx list
gcpctx doctor

# Submit issue
# GitHub: https://github.com/UriBer/gcpctx/issues
```

DO NOT include:
- Credential file contents
- Actual project IDs (unless public)
- Account emails
- Access tokens

## References

- GitHub Issues: https://github.com/UriBer/gcpctx/issues
- Security: https://github.com/UriBer/gcpctx/blob/main/SECURITY.md
- GCP Auth Docs: https://cloud.google.com/docs/authentication
