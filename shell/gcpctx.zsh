# gcpctx zsh integration
#
# Add to ~/.zshrc:
#   source /path/to/gcpctx/shell/gcpctx.zsh
#
# Provides:
#   - gcpctx shell function that auto-evals use/activate/deactivate
#   - optional chpwd hook to auto-activate nearest .gcpctx (like .venv)

# Resolve the real binary (avoid recursion through this function)
if [[ -z "${GCPCTX_BIN:-}" ]]; then
  if [[ -x "${0:A:h}/../bin/gcpctx" ]]; then
    # when sourced as .../shell/gcpctx.zsh
    :
  fi
  if (( $+commands[gcpctx] )); then
    GCPCTX_BIN="$(command -v gcpctx)"
  elif [[ -x "$HOME/bin/gcpctx" ]]; then
    GCPCTX_BIN="$HOME/bin/gcpctx"
  elif [[ -x "$HOME/.local/bin/gcpctx" ]]; then
    GCPCTX_BIN="$HOME/.local/bin/gcpctx"
  else
    # Fall back to sibling bin relative to this file
    GCPCTX_BIN="${${(%):-%x}:A:h}/../bin/gcpctx"
  fi
fi

gcpctx() {
  local cmd="${1:-}"
  case "$cmd" in
    use|activate|deactivate|env)
      shift
      eval "$("$GCPCTX_BIN" "$cmd" "$@" --export)"
      ;;
    *)
      "$GCPCTX_BIN" "$@"
      ;;
  esac
}

# Auto-activate when entering a directory tree with .gcpctx
typeset -g _GCPCTX_LAST_MARKER=""

_gcpctx_auto() {
  local dir="$PWD" marker="" found=""
  while true; do
    if [[ -f "$dir/.gcpctx" ]]; then
      marker="$dir/.gcpctx"
      found=1
      break
    fi
    [[ "$dir" == "/" ]] && break
    dir="${dir:h}"
  done

  if [[ -n "$found" ]]; then
    if [[ "$marker" != "$_GCPCTX_LAST_MARKER" ]]; then
      _GCPCTX_LAST_MARKER="$marker"
      eval "$("$GCPCTX_BIN" activate --export)" 2>/dev/null || true
    fi
  else
    if [[ -n "$_GCPCTX_LAST_MARKER" ]]; then
      _GCPCTX_LAST_MARKER=""
      # Leave global context env in place when leaving a marked tree.
      # Uncomment to clear instead:
      # eval "$("$GCPCTX_BIN" deactivate --export)" 2>/dev/null || true
    fi
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _gcpctx_auto
# Activate for the shell's starting directory
_gcpctx_auto

# Optional prompt segment helper: $(gcpctx_prompt)
gcpctx_prompt() {
  "$GCPCTX_BIN" current --prompt 2>/dev/null
}
