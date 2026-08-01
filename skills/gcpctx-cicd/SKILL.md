---
description: Set up gcpctx in CI/CD pipelines and automate GCP context management
category: google-cloud
tags: [gcp, cicd, automation, github-actions, gitlab-ci]
---

# gcpctx: CI/CD Integration

Automate GCP context management in CI/CD pipelines using gcpctx.

## When to use this skill

- User wants to set up gcpctx in CI/CD
- User needs to manage multiple GCP environments in pipelines
- User asks about automating context switching
- User needs credential management in GitHub Actions, GitLab CI, etc.

## Installation in CI/CD

### GitHub Actions

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install gcpctx
        run: npm install -g gcpctx
      
      - name: Setup gcloud CLI
        uses: google-github-actions/setup-gcloud@v2
        with:
          service_account_key: ${{ secrets.GCP_SA_KEY }}
          project_id: ${{ secrets.GCP_PROJECT_ID }}
      
      - name: Initialize gcpctx context
        run: |
          gcpctx init --name ci \
            --account ${{ secrets.GCP_SERVICE_ACCOUNT }} \
            --project ${{ secrets.GCP_PROJECT_ID }}
      
      - name: Deploy
        run: |
          gcpctx use ci
          gcpctx assert --project ${{ secrets.GCP_PROJECT_ID }} || exit 1
          gcloud run deploy api --source .
```

### GitLab CI

```yaml
deploy:
  image: google/cloud-sdk:alpine
  
  before_script:
    - apk add --no-cache nodejs npm
    - npm install -g gcpctx
    - echo $GCP_SERVICE_ACCOUNT_KEY | base64 -d > /tmp/key.json
    - gcloud auth activate-service-account --key-file=/tmp/key.json
  
  script:
    - gcpctx init --name ci --account $GCP_SERVICE_ACCOUNT --project $GCP_PROJECT_ID
    - gcpctx use ci
    - gcpctx assert --context ci --project $GCP_PROJECT_ID
    - gcloud run deploy api --source .
  
  only:
    - main
```

### CircleCI

```yaml
version: 2.1

jobs:
  deploy:
    docker:
      - image: google/cloud-sdk:alpine
    
    steps:
      - checkout
      
      - run:
          name: Install gcpctx
          command: |
            apk add --no-cache nodejs npm
            npm install -g gcpctx
      
      - run:
          name: Authenticate
          command: |
            echo $GCP_SERVICE_ACCOUNT_KEY | base64 -d > /tmp/key.json
            gcloud auth activate-service-account --key-file=/tmp/key.json
      
      - run:
          name: Deploy
          command: |
            gcpctx init --name ci --project $GCP_PROJECT_ID
            gcpctx use ci
            gcpctx assert --project $GCP_PROJECT_ID
            gcloud run deploy api --source .

workflows:
  deploy:
    jobs:
      - deploy:
          filters:
            branches:
              only: main
```

## Multi-Environment Deployment

### GitHub Actions Matrix Strategy

```yaml
name: Deploy to Multiple Environments

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options:
          - dev
          - staging
          - prod

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Install gcpctx
        run: npm install -g gcpctx
      
      - name: Authenticate to GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets[format('GCP_SA_KEY_{0}', github.event.inputs.environment)] }}
      
      - name: Setup gcpctx context
        run: |
          gcpctx init --name ${{ github.event.inputs.environment }} \
            --account ${{ secrets[format('GCP_ACCOUNT_{0}', github.event.inputs.environment)] }} \
            --project ${{ secrets[format('GCP_PROJECT_{0}', github.event.inputs.environment)] }}
      
      - name: Deploy with assertions
        run: |
          gcpctx use ${{ github.event.inputs.environment }}
          gcpctx assert --context ${{ github.event.inputs.environment }} || exit 1
          gcpctx assert --project ${{ secrets[format('GCP_PROJECT_{0}', github.event.inputs.environment)] }} || exit 1
          
          echo "Deploying to ${{ github.event.inputs.environment }}"
          gcloud run deploy api --source . --region us-central1
```

### GitLab CI Multi-Environment

```yaml
.deploy_template: &deploy_template
  image: google/cloud-sdk:alpine
  before_script:
    - apk add --no-cache nodejs npm
    - npm install -g gcpctx
    - echo $GCP_SERVICE_ACCOUNT_KEY | base64 -d > /tmp/key.json
    - gcloud auth activate-service-account --key-file=/tmp/key.json
    - gcpctx init --name $CI_ENVIRONMENT_NAME --project $GCP_PROJECT_ID
  script:
    - gcpctx use $CI_ENVIRONMENT_NAME
    - gcpctx assert --context $CI_ENVIRONMENT_NAME --project $GCP_PROJECT_ID
    - gcloud run deploy api --source . --region us-central1

deploy_dev:
  <<: *deploy_template
  environment:
    name: dev
  variables:
    GCP_PROJECT_ID: $DEV_PROJECT_ID
    GCP_SERVICE_ACCOUNT_KEY: $DEV_SA_KEY
  only:
    - develop

deploy_staging:
  <<: *deploy_template
  environment:
    name: staging
  variables:
    GCP_PROJECT_ID: $STAGING_PROJECT_ID
    GCP_SERVICE_ACCOUNT_KEY: $STAGING_SA_KEY
  only:
    - main

deploy_prod:
  <<: *deploy_template
  environment:
    name: prod
  variables:
    GCP_PROJECT_ID: $PROD_PROJECT_ID
    GCP_SERVICE_ACCOUNT_KEY: $PROD_SA_KEY
  when: manual
  only:
    - main
```

## Service Account Authentication

### Using Service Account Key

```bash
#!/bin/bash
# Script: ci-deploy.sh

# Activate service account
gcloud auth activate-service-account \
  --key-file="$GCP_SERVICE_ACCOUNT_KEY_FILE"

# Initialize gcpctx context
gcpctx init --name ci \
  --account "$GCP_SERVICE_ACCOUNT_EMAIL" \
  --project "$GCP_PROJECT_ID"

# Use context
gcpctx use ci

# Verify
gcpctx assert --project "$GCP_PROJECT_ID" || exit 1

# Deploy
gcloud run deploy api --source .
```

### Using Workload Identity (GitHub Actions)

```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
    service_account: ${{ secrets.WIF_SERVICE_ACCOUNT }}

- name: Setup gcpctx
  run: |
    gcpctx init --name ci --project ${{ secrets.GCP_PROJECT_ID }}
    gcpctx use ci
```

## Assertions in CI/CD

### Pre-Deployment Assertions

```bash
#!/bin/bash
set -e

ENVIRONMENT=$1
PROJECT_ID=$2

echo "🔍 Verifying deployment context..."

# Switch to environment
gcpctx use "$ENVIRONMENT"

# Assert project
gcpctx assert --project "$PROJECT_ID" || {
  echo "❌ Project mismatch! Expected: $PROJECT_ID"
  gcpctx current --json
  exit 1
}

# Assert context name
gcpctx assert --context "$ENVIRONMENT" || {
  echo "❌ Context mismatch! Expected: $ENVIRONMENT"
  gcpctx current --json
  exit 1
}

echo "✅ Context verified: $ENVIRONMENT @ $PROJECT_ID"

# Deploy
gcloud run deploy api --source .
```

### Safe Deployment Script

```bash
#!/bin/bash
# safe-deploy.sh

set -e

ENVIRONMENT=${1:-dev}
PROJECT_ID=$2

if [ -z "$PROJECT_ID" ]; then
  echo "❌ Usage: $0 ENVIRONMENT PROJECT_ID"
  exit 1
fi

# Use gcpctx safe execution
gcpctx exec --require-context "$ENVIRONMENT" -- bash -c "
  set -e
  
  # Verify project
  CURRENT_PROJECT=\$(gcloud config get-value project)
  if [ \"\$CURRENT_PROJECT\" != \"$PROJECT_ID\" ]; then
    echo \"❌ Project mismatch: \$CURRENT_PROJECT != $PROJECT_ID\"
    exit 1
  fi
  
  echo \"✅ Deploying to $ENVIRONMENT ($PROJECT_ID)\"
  
  # Deploy
  gcloud run deploy api --source . --region us-central1
  
  echo \"✅ Deployment complete\"
"
```

## Terraform Integration

### Using gcpctx with Terraform

```hcl
# terraform/backend.tf
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "terraform/state"
  }
}
```

```bash
#!/bin/bash
# terraform-deploy.sh

ENVIRONMENT=$1

# Switch context
gcpctx use "$ENVIRONMENT"

# Assert before Terraform operations
gcpctx assert --context "$ENVIRONMENT" || exit 1

# Initialize Terraform
terraform init -reconfigure \
  -backend-config="prefix=terraform/state/$ENVIRONMENT"

# Plan
terraform plan -var-file="$ENVIRONMENT.tfvars" -out=tfplan

# Apply with confirmation
if [ "$ENVIRONMENT" = "prod" ]; then
  echo "⚠️  Production deployment. Review plan and confirm."
  read -p "Apply? (yes/no): " confirm
  [ "$confirm" != "yes" ] && exit 1
fi

terraform apply tfplan
```

### GitHub Actions with Terraform

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3

- name: Setup gcpctx
  run: npm install -g gcpctx

- name: Terraform Deploy
  env:
    ENVIRONMENT: ${{ github.event.inputs.environment }}
    PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
  run: |
    gcpctx use $ENVIRONMENT
    gcpctx assert --context $ENVIRONMENT --project $PROJECT_ID || exit 1
    
    terraform init -backend-config="prefix=terraform/state/$ENVIRONMENT"
    terraform plan -var-file="$ENVIRONMENT.tfvars" -out=tfplan
    terraform apply -auto-approve tfplan
```

## Automated Testing

### Test with Multiple Contexts

```yaml
name: Integration Tests

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup gcpctx
        run: npm install -g gcpctx
      
      - name: Initialize context
        run: |
          gcpctx init --name ${{ matrix.environment }} \
            --project ${{ secrets[format('PROJECT_ID_{0}', matrix.environment)] }}
      
      - name: Run tests
        run: |
          gcpctx use ${{ matrix.environment }}
          npm test
        env:
          TEST_ENVIRONMENT: ${{ matrix.environment }}
```

## Caching

### Cache gcpctx Installation

```yaml
- name: Cache gcpctx
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-gcpctx-${{ hashFiles('**/package-lock.json') }}

- name: Install gcpctx
  run: npm install -g gcpctx
```

## Secrets Management

### Required Secrets

For GitHub Actions, set these secrets:

```bash
# For each environment:
GCP_SA_KEY_DEV      # Service account key JSON (base64 or raw)
GCP_PROJECT_DEV     # Project ID
GCP_ACCOUNT_DEV     # Service account email

GCP_SA_KEY_STAGING
GCP_PROJECT_STAGING
GCP_ACCOUNT_STAGING

GCP_SA_KEY_PROD
GCP_PROJECT_PROD
GCP_ACCOUNT_PROD
```

### Using Secrets in Workflow

```yaml
- name: Setup context from secrets
  run: |
    # Decode service account key
    echo "${{ secrets.GCP_SA_KEY }}" | base64 -d > /tmp/sa-key.json
    
    # Authenticate
    gcloud auth activate-service-account --key-file=/tmp/sa-key.json
    
    # Setup gcpctx
    gcpctx init --name ci \
      --account "${{ secrets.GCP_ACCOUNT }}" \
      --project "${{ secrets.GCP_PROJECT }}"
    
    # Use context
    gcpctx use ci
    
    # Clean up key
    rm /tmp/sa-key.json
```

## Best Practices for CI/CD

1. **Always use assertions:**
   ```bash
   gcpctx assert --context $ENV --project $PROJECT_ID || exit 1
   ```

2. **Use context names matching environments:**
   - `dev`, `staging`, `prod` (not `alice-dev`, `test123`)

3. **Verify before destructive operations:**
   ```bash
   gcpctx doctor
   gcpctx current --json | jq -r '.project'
   ```

4. **Clean up credentials:**
   ```bash
   rm -f /tmp/*.json
   unset GCP_SERVICE_ACCOUNT_KEY
   ```

5. **Use safe execution for critical commands:**
   ```bash
   gcpctx exec --require-context $ENV -- terraform apply
   ```

## References

- GitHub Actions: https://docs.github.com/en/actions
- GitLab CI: https://docs.gitlab.com/ee/ci/
- gcpctx: https://github.com/UriBer/gcpctx
