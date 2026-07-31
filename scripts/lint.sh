#!/usr/bin/env bash
set -eo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -S warning -x "$ROOT/bin/gcpctx" "$ROOT/lib/"*.sh "$ROOT/scripts/"*.sh
else
  echo "shellcheck not installed — skip" >&2
fi
