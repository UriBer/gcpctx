#!/usr/bin/env bash
# Demo Scenario 6: Doctor & Troubleshooting
# Duration: ~20 seconds
# Perfect for: Showing polish and production-readiness

set -e

echo "╔════════════════════════════════════════════╗"
echo "║  gcpctx Demo: Health Checks & Fixes       ║"
echo "╚════════════════════════════════════════════╝"
echo ""
sleep 1

echo "$ gcpctx doctor"
echo "🔍 Running health checks..."
echo ""
sleep 1

cat <<'DOCTOR'
✅ gcloud CLI found: /usr/local/bin/gcloud
✅ GCPCTX_HOME exists: /home/user/.gcpctx
✅ Active context file valid
✅ Context 'dev' metadata valid
✅ Context 'staging' metadata valid
⚠️  Context 'prod' credentials permissions: 0644 (should be 0600)
❌ Context 'test' credentials missing

Issues found: 2
DOCTOR
echo ""
sleep 3

echo "$ gcpctx secrets fix"
echo "🔧 Fixing credential permissions..."
echo "✓ Fixed: /home/user/.gcpctx/contexts/prod/credentials.json → 0600"
echo "✓ Fixed: /home/user/.gcpctx/contexts/prod → 0700"
echo ""
sleep 2

echo "$ gcpctx doctor"
echo "🔍 Running health checks..."
echo ""
sleep 1

cat <<'DOCTOR2'
✅ gcloud CLI found: /usr/local/bin/gcloud
✅ GCPCTX_HOME exists: /home/user/.gcpctx
✅ Active context file valid
✅ Context 'dev' metadata valid
✅ Context 'staging' metadata valid
✅ Context 'prod' credentials permissions: 0600
⚠️  Context 'test' credentials missing (consider: gcpctx login test)

Issues found: 1 (informational)
DOCTOR2
echo ""
sleep 2

echo ""
echo "🔧 Production-ready tooling includes health checks!"
sleep 2
