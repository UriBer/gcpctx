#!/usr/bin/env bash
# Demo Scenario 5: Safe Execution
# Duration: ~15 seconds
# Perfect for: Security-focused posts

set -e

echo "╔════════════════════════════════════════════╗"
echo "║  gcpctx Demo: Safe Command Execution      ║"
echo "╚════════════════════════════════════════════╝"
echo ""
sleep 1

echo "$ gcpctx current"
echo "📍 Current: staging"
echo ""
sleep 1

echo "$ gcpctx exec --require-context dev -- gcloud compute instances list"
echo "❌ Error: required context 'dev', but current context is 'staging'"
echo "   Command blocked for safety"
echo "   Exit code: 1"
echo ""
sleep 3

echo "$ gcpctx use dev"
echo "✓ Switched to dev"
echo ""
sleep 1

echo "$ gcpctx exec --require-context dev -- gcloud compute instances list"
echo "✓ Context verified: dev"
echo "NAME           ZONE           MACHINE_TYPE  STATUS"
echo "dev-instance-1 us-central1-a  n1-standard-1 RUNNING"
echo "dev-instance-2 us-central1-a  n1-standard-2 RUNNING"
echo ""
sleep 3

echo "$ gcpctx assert --project dev-project-123 && terraform apply"
echo "✅ Assertion passed"
echo "⏳ Running: terraform apply..."
echo ""
sleep 2

echo ""
echo "⚠️  Wrong context? Command won't run. Period."
sleep 2
