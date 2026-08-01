#!/usr/bin/env bash
# Demo Scenario 2: Project Safety
# Duration: ~20 seconds
# Perfect for: LinkedIn/Twitter with security angle

set -e

echo "╔════════════════════════════════════════════╗"
echo "║  gcpctx Demo: Production Safety           ║"
echo "╚════════════════════════════════════════════╝"
echo ""
sleep 1

echo "$ gcpctx protect prod"
echo "🔒 Context 'prod' is now protected"
echo ""
sleep 2

echo "$ gcpctx use prod"
echo "⚠️  Context 'prod' is protected!"
echo "   Use --force to switch, or --protected=false to remove protection"
echo ""
sleep 3

echo "$ gcpctx current"
echo "📍 Current: dev (my-dev-project-123)"
echo ""
sleep 2

echo "$ gcpctx assert --context dev --project my-dev-project-123"
echo "✅ Assertion passed: you are in the expected context"
echo ""
sleep 2

echo "$ gcpctx assert --context prod"
echo "❌ Assertion failed!"
echo "   Expected: prod"
echo "   Actual:   dev"
echo "   Exit code: 1"
echo ""
sleep 2

echo ""
echo "🛡️  Assertions prevent production accidents!"
sleep 2
