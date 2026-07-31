#!/usr/bin/env bash
# Test runner — isolated HOME/GCPCTX_HOME, fake gcloud on PATH.
set -eo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v bats >/dev/null 2>&1; then
  echo "bats not installed; skipping (CI installs bats-core)" >&2
  echo "Install: brew install bats-core" >&2
  exit 0
fi

export PATH="$ROOT/test/helpers/bin:$PATH"
SUITE="${1:-}"
if [[ -n "$SUITE" ]]; then
  bats "test/$SUITE"/*.bats
else
  bats test/unit/*.bats test/integration/*.bats test/security/*.bats
fi
