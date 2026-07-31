#!/usr/bin/env bash
set -eo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -x "$ROOT/bin/gcpctx" "$ROOT/lib/"*.sh "$ROOT/scripts/"*.sh || fail=1
else
  echo "shellcheck not installed — skip" >&2
fi
exit "$fail"
