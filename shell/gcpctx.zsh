# gcpctx zsh integration
#
# Prefer:
#   gcpctx shell-setup
# Or manually:
#   source "$(gcpctx shell-path --zsh)"
#
# Provides:
#   - gcpctx shell function that auto-evals use/activate/deactivate/project
#   - chpwd hook to auto-activate nearest .gcpctx (like .venv)
#   - venv-style prompt prefix: (gcp:ctx:project)

# Resolve the real binary (avoid recursion through this function)
if [[ -z "${GCPCTX_BIN:-}" ]]; then
  if GCPCTX_BIN="$(whence -p gcpctx 2>/dev/null)"; then
    :
  elif [[ -x "$HOME/bin/gcpctx" ]]; then
    GCPCTX_BIN="$HOME/bin/gcpctx"
  elif [[ -x "$HOME/.local/bin/gcpctx" ]]; then
    GCPCTX_BIN="$HOME/.local/bin/gcpctx"
  else
    GCPCTX_BIN="${${(%):-%x}:A:h}/../bin/gcpctx"
  fi
fi

# shellcheck disable=SC1090
_GCPCTX_ROOT_DIR="${GCPCTX_BIN:A:h}/.."
source "$_GCPCTX_ROOT_DIR/shell/safe-eval.inc.sh"

gcpctx() {
  local cmd="${1:-}"
  case "$cmd" in
    use|activate|deactivate|env)
      shift
      _gcpctx_safe_eval "$("$GCPCTX_BIN" "$cmd" "$@" --export)"
      ;;
    project)
      if [[ "${2:-}" == "list" || "${2:-}" == "ls" || "${2:-}" == "scan" ]]; then
        "$GCPCTX_BIN" "$@"
      else
        shift
        _gcpctx_safe_eval "$("$GCPCTX_BIN" project "$@" --export)"
      fi
      ;;
    *)
      "$GCPCTX_BIN" "$@"
      ;;
  esac
}

# --- directory auto-activate ---
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
      _gcpctx_safe_eval "$("$GCPCTX_BIN" activate --export)" 2>/dev/null || true
    fi
  else
    if [[ -n "$_GCPCTX_LAST_MARKER" ]]; then
      _GCPCTX_LAST_MARKER=""
      _GCPCTX_LAST_MARKER_HASH=""
    fi
  fi
}

# --- venv-style prompt ---
# (gcp:ctx:project) built from env — no subprocess per prompt
# Disable: export GCPCTX_DISABLE_PROMPT=1
typeset -g _GCPCTX_BASE_PROMPT=""
typeset -g _GCPCTX_PROMPT_READY=0

_gcpctx_prompt_segment() {
  [[ -n "${GCPCTX_DISABLE_PROMPT:-}" ]] && return 0
  [[ -z "${GCPCTX_NAME:-}" ]] && return 0
  local seg="(gcp:${GCPCTX_NAME}"
  if [[ -n "${GOOGLE_CLOUD_PROJECT:-}" ]]; then
    seg+=":${GOOGLE_CLOUD_PROJECT}"
  fi
  seg+=") "
  print -rn -- "$seg"
}

gcpctx_prompt() {
  # Prefer env (fast); fall back to CLI for scripts when inactive shell state
  local seg
  seg="$(_gcpctx_prompt_segment)"
  if [[ -n "$seg" ]]; then
    print -rn -- "$seg"
  else
    "$GCPCTX_BIN" current --prompt 2>/dev/null
  fi
}

_gcpctx_prompt_precmd() {
  if [[ -z "${GCPCTX_DISABLE_PROMPT:-}" ]]; then
    if [[ "$_GCPCTX_PROMPT_READY" -eq 0 ]]; then
      _GCPCTX_BASE_PROMPT="$PROMPT"
      _GCPCTX_PROMPT_READY=1
    fi
    local seg
    seg="$(_gcpctx_prompt_segment)"
    if [[ -n "$seg" ]]; then
      PROMPT="${seg}${_GCPCTX_BASE_PROMPT}"
    else
      PROMPT="${_GCPCTX_BASE_PROMPT}"
    fi
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _gcpctx_auto
add-zsh-hook precmd _gcpctx_prompt_precmd
_gcpctx_auto
