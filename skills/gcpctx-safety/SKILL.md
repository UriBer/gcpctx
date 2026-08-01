---
description: Safely manage GCP production environments with gcpctx protection and assertions
category: google-cloud
tags: [gcp, security, production, safety, devops]
---

# gcpctx: Production Safety

Prevent accidental operations in production GCP environments using gcpctx safety features.

## When to use this skill

- User needs to protect production GCP contexts
- User wants to add safety checks before dangerous operations
- User asks about preventing production accidents
- User needs to ensure commands run in the correct GCP context
- User wants fail-fast behavior for context mismatches

## Safety Mechanisms

### 1. Protected Contexts

Mark contexts as protected to require explicit confirmation:

```bash
# Protect production
gcpctx protect prod

# Now switching requires --force
gcpctx use prod
# ❌ Error: Context 'prod' is protected! Use --force to switch

# Explicit switch
gcpctx use prod --force
# ✅ Switched (with confirmation required)
```

**When to protect:**
- Production environments
- Shared/team contexts
- High-cost project contexts
- Any context where mistakes are expensive

### 2. Context Assertions

Assert expected context before operations:

```bash
# Assert specific context
gcpctx assert --context dev
# Exit code: 0 if correct, 1 if wrong

# Assert specific project
gcpctx assert --project my-dev-project-123
# Exit code: 0 if correct, 1 if wrong

# Assert specific account
gcpctx assert --account dev@company.com
# Exit code: 0 if correct, 1 if wrong

# Combine multiple assertions
gcpctx assert --context dev --project my-dev-project --account dev@company.com
```

### 3. Safe Execution Wrapper

Only execute commands if in required context:

```bash
# Command only runs if in 'dev' context
gcpctx exec --require-context dev -- gcloud compute instances delete instance-1

# Command blocked if not in 'dev'
# ❌ Error: required context 'dev', but current context is 'staging'
```

## Best Practices for AI Agents

### Always Assert Before Destructive Operations

```bash
# Before terraform destroy
gcpctx assert --context dev || exit 1
terraform destroy

# Before deleting resources
gcpctx assert --project dev-project-123 || exit 1
gcloud compute instances delete my-instance

# Before database operations
gcpctx assert --context staging --project staging-db || exit 1
gcloud sql instances delete my-db-instance
```

### Use Safe Execution for User-Requested Operations

When user asks to perform operations:

```bash
# User: "Delete the test instance"
# AI should:

# 1. Check current context
CONTEXT=$(gcpctx current --json | jq -r '.name')

# 2. Ask for confirmation if in prod
if [ "$CONTEXT" = "prod" ]; then
  echo "⚠️  You are in PRODUCTION context. Are you sure? (yes/no)"
  # Wait for user confirmation
fi

# 3. Use assertion
gcpctx assert --context dev || {
  echo "❌ Not in dev context. Aborting for safety."
  exit 1
}

# 4. Execute
gcloud compute instances delete test-instance
```

### Protect Contexts Proactively

When setting up contexts:

```bash
# Initialize contexts
gcpctx init --name dev --account dev@company.com --project dev-123
gcpctx init --name staging --account staging@company.com --project staging-456
gcpctx init --name prod --account admin@company.com --project prod-789

# Immediately protect production
gcpctx protect prod

# Consider protecting staging too
gcpctx protect staging
```

### Use Folder Markers with Assertions

Combine folder markers with assertions:

```bash
# In project directory
echo '{"name":"dev","project":"frontend-dev"}' > .gcpctx

# In deploy script
gcpctx activate
gcpctx assert --project frontend-dev || exit 1
npm run deploy
```

## Dangerous Operations Checklist

Before performing these operations, ALWAYS assert context:

### Resource Deletion
```bash
gcpctx assert --context dev || exit 1
gcloud compute instances delete INSTANCE_NAME
gcloud sql instances delete DB_NAME
gcloud container clusters delete CLUSTER_NAME
```

### Database Operations
```bash
gcpctx assert --context dev --project my-dev-db || exit 1
gcloud sql databases delete DATABASE_NAME
```

### Infrastructure Changes
```bash
gcpctx assert --context staging || exit 1
terraform destroy
```

### Billing/Quota Changes
```bash
gcpctx assert --context dev || exit 1
gcloud alpha billing projects link PROJECT_ID --billing-account=ACCOUNT_ID
```

### IAM Changes
```bash
gcpctx assert --project my-dev-project || exit 1
gcloud projects add-iam-policy-binding PROJECT_ID --member=user:EMAIL --role=ROLE
```

## Workflow: Safe Deployment

```bash
#!/bin/bash
set -e

# Function to safely deploy
safe_deploy() {
  local context=$1
  local project=$2
  
  echo "🎯 Deploying to $context..."
  
  # Switch context
  if [ "$context" = "prod" ]; then
    echo "⚠️  PRODUCTION DEPLOYMENT"
    echo "Are you sure? (type 'yes' to continue)"
    read confirmation
    [ "$confirmation" != "yes" ] && exit 1
    gcpctx use prod --force
  else
    gcpctx use $context
  fi
  
  # Assert context
  gcpctx assert --context $context --project $project || {
    echo "❌ Context assertion failed!"
    exit 1
  }
  
  # Deploy
  gcloud run deploy api --source .
  
  echo "✅ Deployed to $context successfully"
}

# Deploy to dev
safe_deploy dev my-dev-project

# Deploy to staging
safe_deploy staging my-staging-project

# Deploy to prod (will require confirmation)
safe_deploy prod my-prod-project
```

## Unprotecting Contexts

If you need to remove protection:

```bash
gcpctx unprotect CONTEXT_NAME
```

⚠️ Only do this temporarily, then re-protect:

```bash
gcpctx unprotect prod
# ... perform operations ...
gcpctx protect prod
```

## Error Handling

### Assertion Failed

```bash
gcpctx assert --context dev
if [ $? -ne 0 ]; then
  echo "❌ Not in dev context!"
  echo "Current context: $(gcpctx current)"
  echo "Switch with: gcpctx use dev"
  exit 1
fi
```

### Protected Context

```bash
gcpctx use prod 2>&1 | grep -q "protected"
if [ $? -eq 0 ]; then
  echo "⚠️  Production is protected"
  echo "Use: gcpctx use prod --force"
  echo "Or: gcpctx unprotect prod (not recommended)"
fi
```

## AI Agent Decision Tree

When user requests a GCP operation:

1. **Check operation type:**
   - Read-only? → No assertion needed
   - Write/modify? → Require assertion
   - Delete/destroy? → Require assertion + confirmation

2. **Check current context:**
   ```bash
   CONTEXT=$(gcpctx current --json | jq -r '.name')
   ```

3. **If production:**
   - Ask for explicit confirmation
   - Show what will be affected
   - Require typing "yes" or similar

4. **Assert before executing:**
   ```bash
   gcpctx assert --context $EXPECTED_CONTEXT || exit 1
   ```

5. **Execute with error handling:**
   ```bash
   gcpctx exec --require-context $EXPECTED_CONTEXT -- $COMMAND
   ```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Assert GCP Context
  run: |
    gcpctx use ${{ matrix.environment }}
    gcpctx assert --context ${{ matrix.environment }} --project ${{ secrets.PROJECT_ID }}
    
- name: Deploy
  run: |
    gcpctx exec --require-context ${{ matrix.environment }} -- ./deploy.sh
```

### GitLab CI

```yaml
deploy:
  script:
    - gcpctx use ${CI_ENVIRONMENT_NAME}
    - gcpctx assert --context ${CI_ENVIRONMENT_NAME} || exit 1
    - gcloud run deploy api --source .
```

## Summary

For AI agents working with gcpctx:

✅ **Always** assert context before destructive operations
✅ **Always** protect production contexts immediately
✅ **Always** ask for confirmation when operating on production
✅ **Always** use `gcpctx exec --require-context` for critical commands
✅ **Never** execute destructive operations without assertions
✅ **Never** bypass protection without user confirmation

## References

- GitHub: https://github.com/UriBer/gcpctx
- Security: https://github.com/UriBer/gcpctx/blob/main/SECURITY.md
