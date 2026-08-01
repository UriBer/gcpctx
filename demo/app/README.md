# gcpctx Demo Application

A sample Node.js application demonstrating gcpctx usage with real GCP services.

## What This App Does

This is a simple Cloud Storage file uploader that:
- Uses Google Cloud Storage API
- Reads credentials from ADC (Application Default Credentials)
- Gets project ID from environment variables
- Demonstrates context-aware GCP development

## Setup

### 1. Install dependencies

```bash
npm install
```

### 2. Setup gcpctx contexts

```bash
# Initialize contexts
gcpctx init --name dev --account dev@company.com --project your-dev-project
gcpctx init --name staging --account staging@company.com --project your-staging-project
gcpctx init --name prod --account admin@company.com --project your-prod-project

# Login to each context
gcpctx login dev
gcpctx login staging
gcpctx login prod

# Protect production
gcpctx protect prod
```

### 3. Create a context marker

```bash
# For local development, use dev context
echo '{"name":"dev","project":"your-dev-project"}' > .gcpctx
```

## Usage

### Switch contexts and run

```bash
# Use dev context
gcpctx use dev
npm start

# Switch to staging
gcpctx use staging
npm start

# Try production (protected!)
gcpctx use prod
# → Blocked! Need --force

gcpctx use prod --force
npm start
```

### Auto-activate context

```bash
# Activate context from .gcpctx file
gcpctx activate

# Run the app (uses context from .gcpctx)
npm start
```

### Safe execution

```bash
# Only run if in dev context
gcpctx exec --require-context dev -- npm start

# Only run if in specific project
gcpctx assert --project your-dev-project && npm start
```

## Environment Variables Set by gcpctx

When you run `gcpctx use` or `gcpctx activate`:

```bash
GOOGLE_APPLICATION_CREDENTIALS=/home/user/.gcpctx/contexts/dev/credentials.json
GOOGLE_CLOUD_PROJECT=your-dev-project
GOOGLE_CLOUD_QUOTA_PROJECT=your-dev-project
CLOUDSDK_CORE_PROJECT=your-dev-project
CLOUDSDK_ACTIVE_CONFIG_NAME=gcpctx-dev
GCPCTX_NAME=dev
```

The app automatically picks these up via the Google Cloud SDKs.

## Demo Scenarios

### Scenario 1: Multi-environment testing

```bash
# Test upload in dev
gcpctx use dev
node upload.js test-file.txt

# Test in staging
gcpctx use staging
node upload.js test-file.txt

# Verify in each bucket
gsutil ls gs://your-dev-bucket/
gsutil ls gs://your-staging-bucket/
```

### Scenario 2: Team collaboration

```bash
# Alice working on frontend (dev)
cd ~/projects/app-demo
cat .gcpctx
# {"name":"dev","project":"frontend-dev"}
gcpctx activate
npm start
# → Uses frontend-dev project

# Bob working on backend (dev)
cd ~/projects/app-demo-backend
cat .gcpctx
# {"name":"dev","project":"backend-dev"}
gcpctx activate
npm start
# → Uses backend-dev project
```

### Scenario 3: Safe production deployment

```bash
# Deploy to production with safety checks
gcpctx assert --context prod || exit 1
gcpctx assert --project prod-project-789 || exit 1

# Now safe to deploy
npm run deploy
```

## Files

- `index.js` - Main application (Cloud Storage uploader)
- `upload.js` - CLI tool for uploading files
- `package.json` - Dependencies
- `.gcpctx` - Context marker (dev by default)
- `.env.example` - Environment variables template

## Architecture

```
┌─────────────────┐
│   Your App      │
│  (index.js)     │
└────────┬────────┘
         │
         │ Uses ADC from
         ↓
┌─────────────────────────────┐
│  GOOGLE_APPLICATION_        │
│  CREDENTIALS env var        │
│  ↓                          │
│  ~/.gcpctx/contexts/dev/    │
│  credentials.json           │
└─────────────────────────────┘
         │
         │ Authenticates to
         ↓
┌─────────────────────────────┐
│  Google Cloud Storage       │
│  Project: GOOGLE_CLOUD_     │
│  PROJECT env var            │
└─────────────────────────────┘
```

## What gcpctx Does

1. **Switches account**: Updates gcloud active account
2. **Switches project**: Updates `GOOGLE_CLOUD_PROJECT` env var
3. **Updates ADC**: Points `GOOGLE_APPLICATION_CREDENTIALS` to right credentials file
4. **Sets quota project**: Ensures billing goes to right project
5. **Updates gcloud config**: Keeps gcloud CLI in sync

All at once, atomically, no mistakes.

## Troubleshooting

### "Error: ADC not found"

```bash
# Login to the context
gcpctx login dev

# Or manually set up ADC
gcloud auth application-default login
```

### "Error: Permission denied"

```bash
# Check context
gcpctx current

# Fix permissions
gcpctx secrets fix

# Re-login if needed
gcpctx login dev
```

### "Error: Wrong project"

```bash
# Verify active context
gcpctx current

# Verify environment variables
env | grep GOOGLE_

# Switch to correct context
gcpctx use dev
```

## Learn More

- [gcpctx Documentation](https://github.com/UriBer/gcpctx)
- [Google Cloud Node.js SDK](https://cloud.google.com/nodejs/docs/reference)
- [Application Default Credentials](https://cloud.google.com/docs/authentication/application-default-credentials)
