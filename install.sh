#!/usr/bin/env bash
# Local/dev install helper. Prefer: npm install -g gcpctx && gcpctx shell-setup
set -eo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${GCPCTX_BIN_DIR:-$HOME/bin}"

mkdir -p "$BIN_DIR"
# Symlink so package_root / shell-path resolve into this repo (or npm package)
ln -sfn "$ROOT/bin/gcpctx" "$BIN_DIR/gcpctx"
echo "installed: $BIN_DIR/gcpctx -> $ROOT/bin/gcpctx"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo "note: add to PATH → export PATH=\"$BIN_DIR:\$PATH\""
    export PATH="$BIN_DIR:$PATH"
    ;;
esac

export GCPCTX_PACKAGE_ROOT="$ROOT"
"$BIN_DIR/gcpctx" shell-setup

echo ""
echo "Next:"
echo "  1. exec zsh"
echo "  2. gcpctx bootstrap"
echo "  3. gcpctx login <context>   # if credentials missing"
echo "  4. gcpctx secrets fix && gcpctx doctor"
