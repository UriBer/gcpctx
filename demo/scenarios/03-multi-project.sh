#!/usr/bin/env bash
# Demo Scenario 3: Multi-Project Workflow
# Duration: ~25 seconds
# Perfect for: DevOps/SRE communities

set -e

echo "╔════════════════════════════════════════════╗"
echo "║  gcpctx Demo: Multi-Project Management    ║"
echo "╚════════════════════════════════════════════╝"
echo ""
sleep 1

echo "$ gcpctx init --name dev --account dev@company.com --project dev-alpha"
echo "✓ Context 'dev' created"
echo "✓ ADC credentials initialized"
echo ""
sleep 2

echo "$ gcpctx scan dev"
echo "🔍 Scanning projects for dev@company.com..."
echo "✓ Found 12 projects"
echo ""
sleep 2

echo "$ gcpctx projects dev"
cat <<'PROJECTS'
  dev-alpha-123
  dev-beta-456
  dev-gamma-789
  integration-test-001
  integration-test-002
  sandbox-experiment-a
  sandbox-experiment-b
  ml-training-dev
  data-pipeline-dev
  frontend-dev
  backend-dev
  mobile-dev
PROJECTS
echo ""
sleep 3

echo "$ gcpctx use dev --project dev-beta-456"
echo "✓ Switched to dev → dev-beta-456"
echo ""
sleep 2

echo "$ gcpctx project ml-training-dev"
echo "✓ Switched project → ml-training-dev"
echo "ℹ  Same account, no re-authentication needed"
echo ""
sleep 2

echo "$ gcpctx current"
echo "📍 dev @ ml-training-dev"
echo ""
sleep 2

echo ""
echo "🔄 12 projects, 1 account, zero re-logins!"
sleep 2
