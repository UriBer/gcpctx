#!/usr/bin/env bash
# Install gcpctx onto this machine
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${GCPCTX_BIN_DIR:-$HOME/bin}"
ZSHRC="${ZSHRC:-$HOME/.zshrc}"

mkdir -p "$BIN_DIR"
install -m 0755 "$ROOT/bin/gcpctx" "$BIN_DIR/gcpctx"
echo "installed: $BIN_DIR/gcpctx"

# Ensure BIN_DIR on PATH in this shell instruction
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo "note: add to PATH → export PATH=\"$BIN_DIR:\$PATH\""
    ;;
esac

MARKER="# >>> gcpctx >>>"
if [[ -f "$ZSHRC" ]] && grep -qF "$MARKER" "$ZSHRC"; then
  echo "zshrc already contains gcpctx block"
else
  {
    echo ""
    echo "$MARKER"
    echo "export PATH=\"$BIN_DIR:\$PATH\""
    echo "source \"$ROOT/shell/gcpctx.zsh\""
    echo "# <<< gcpctx <<<"
  } >> "$ZSHRC"
  echo "appended gcpctx block to $ZSHRC"
fi

echo ""
echo "Next:"
echo "  1. exec zsh   # or: source $ZSHRC"
echo "  2. gcpctx bootstrap"
echo "  3. gcpctx login dev    # for contexts missing credentials"
echo "  4. gcpctx use prod     # or cd into a repo with .gcpctx"
echo "  5. gcpctx doctor"
