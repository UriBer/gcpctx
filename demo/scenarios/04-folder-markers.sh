#!/usr/bin/env bash
# Demo Scenario 4: Folder Markers
# Duration: ~20 seconds
# Perfect for: Developer workflow demos

set -e

echo "╔════════════════════════════════════════════╗"
echo "║  gcpctx Demo: Automatic Context Loading   ║"
echo "╚════════════════════════════════════════════╝"
echo ""
sleep 1

echo "$ cd ~/projects/frontend-app"
echo ""
sleep 1

echo "$ cat .gcpctx"
cat <<'MARKER'
{
  "name": "dev",
  "project": "frontend-dev-123"
}
MARKER
echo ""
sleep 2

echo "$ gcpctx activate"
echo "✓ Loaded context from .gcpctx"
echo "✓ Activated: dev → frontend-dev-123"
echo "✓ Environment configured"
echo ""
sleep 2

echo "$ env | grep GOOGLE_"
cat <<'ENV'
GOOGLE_APPLICATION_CREDENTIALS=/home/user/.gcpctx/contexts/dev/credentials.json
GOOGLE_CLOUD_PROJECT=frontend-dev-123
GOOGLE_CLOUD_QUOTA_PROJECT=frontend-dev-123
ENV
echo ""
sleep 2

echo "$ gcloud config list"
cat <<'GCLOUD'
[core]
account = dev@company.com
project = frontend-dev-123

[compute]
region = us-central1
zone = us-central1-a
GCLOUD
echo ""
sleep 2

echo ""
echo "📁 Your repo knows its GCP context automatically!"
sleep 2
