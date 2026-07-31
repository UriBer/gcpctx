#!/usr/bin/env bash
set -eo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if command -v shfmt >/dev/null 2>&1; then
  shfmt -d -i 2 -ci "$ROOT/lib" "$ROOT/scripts" || exit 1
else
  echo "shfmt not installed — skip" >&2
fi
