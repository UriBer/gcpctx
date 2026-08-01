#!/usr/bin/env bash
# Demo Scenario 1: Quick Context Switch
# Duration: ~15 seconds
# Perfect for: Twitter/X thread opener

set -e

# Add some visual flair
echo "╔════════════════════════════════════════════╗"
echo "║  gcpctx Demo: Quick Context Switch        ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Small delay for readability in recordings
sleep 1

echo "$ gcpctx current"
echo "📍 Current context: dev (my-dev-project-123)"
echo ""
sleep 2

echo "$ gcpctx list"
echo "  dev      ← active"
echo "  staging"
echo "  prod     (protected)"
echo ""
sleep 2

echo "$ gcpctx use staging"
echo "✓ Switched to staging → my-staging-456"
echo "✓ Updated ADC credentials"
echo ""
sleep 2

echo "$ gcpctx current --json"
cat <<'JSON'
{
  "name": "staging",
  "account": "admin@company.com",
  "project": "my-staging-456",
  "region": "us-central1",
  "zone": "us-central1-a"
}
JSON
echo ""
sleep 2

echo ""
echo "✨ Context switched in 2 seconds. Safe & instant."
sleep 2
