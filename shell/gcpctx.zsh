# gcpctx zsh integration
#
# Add to ~/.zshrc:
#   source /path/to/gcpctx/shell/gcpctx.zsh
#
# Provides:
#   - gcpctx shell function that auto-evals use/activate/deactivate/project
#   - optional chpwd hook to auto-activate nearest .gcpctx (like .venv)

# Resolve the real binary (avoid recursion through this function)
if [[ -z "${GCPCTX_BIN:-}" ]]; then
  if (( $+commands[gcpctx] )); then
    # Prefer non-function command if already on PATH from install
    GCPCTX_BIN="$(whence -p gcpctx 2>/dev/null || true)"
  fi
  if [[ -z "${GCPCTX_BIN:-}" && -x "$HOME/bin/gcpctx" ]]; then
    GCPCTX_BIN="$HOME/bin/gcpctx"
  elif [[ -z "${GCPCTX_BIN:-}" && -x "$HOME/.local/bin/gcpctx" ]]; then
    GCPCTX_BIN="$HOME/.local/bin/gcpctx"
  elif [[ -z "${GCPCTX_BIN:-}" ]]; then
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
    project)
      # list/scan are read-only; set/<id> must export env
      if [[ "${2:-}" == "list" || "${2:-}" == "ls" || "${2:-}" == "scan" ]]; then
        "$GCPCTX_BIN" "$@"
      else
        shift
        eval "$("$GCPCTX_BIN" project "$@" --export)"
      fi
      ;;
    *)
      "$GCPCTX_BIN" "$@"
      ;;
  esac
}

# Auto-activate when entering a directory tree with .gcpctx
typeset -g _GCPCTX_LAST_MARKER=""
typeset -g _GCPCTX_LAST_MARKER_HASH=""

_gcpctx_marker_hash() {
  local marker="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$marker" 2>/dev/null | awk '{print $1}'
  else
    cksum "$marker" 2>/dev/null | awk '{print $1" "$2}'
  fi
}

_gcpctx_auto() {
  local dir="$PWD" marker="" found="" hash=""
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
    hash="$(_gcpctx_marker_hash "$marker")"
    if [[ "$marker" != "$_GCPCTX_LAST_MARKER" || "$hash" != "$_GCPCTX_LAST_MARKER_HASH" ]]; then
      _GCPCTX_LAST_MARKER="$marker"
      _GCPCTX_LAST_MARKER_HASH="$hash"
      eval "$("$GCPCTX_BIN" activate --export)" 2>/dev/null || true
    fi
  else
    if [[ -n "$_GCPCTX_LAST_MARKER" ]]; then
      _GCPCTX_LAST_MARKER=""
      _GCPCTX_LAST_MARKER_HASH=""
      # Leave global context env in place when leaving a marked tree.
    fi
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _gcpctx_auto
# Activate for the shell's starting directory
_gcpctx_auto

# Optional prompt segment helper: $(gcpctx_prompt) → gcp:prod:my-project
gcpctx_prompt() {
  "$GCPCTX_BIN" current --prompt 2>/dev/null
}
