#!/usr/bin/env bash
set -eo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
echo "== version consistency =="
PKG_VER="$(python3 -c 'import json;print(json.load(open("package.json"))["version"])')"
FILE_VER="$(tr -d '[:space:]' < VERSION)"
[[ "$PKG_VER" == "$FILE_VER" ]] || { echo "VERSION ($FILE_VER) != package.json ($PKG_VER)"; exit 1; }
echo "version=$PKG_VER ok"
echo "== lint =="
bash scripts/lint.sh || true
echo "== tests =="
bash scripts/run-tests.sh
echo "== pack:check =="
bash scripts/check-no-secrets.sh
echo "== verify ok =="
