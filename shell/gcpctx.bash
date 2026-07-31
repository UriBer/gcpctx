# gcpctx bash integration
#
# Prefer:
#   gcpctx shell-setup
# Or manually:
#   source "$(gcpctx shell-path --bash)"
#
# Provides:
#   - gcpctx shell function that auto-evals use/activate/deactivate/project
#   - PROMPT_COMMAND venv-style prefix: (gcp:ctx:project)
#   - lightweight cd wrapper for .gcpctx auto-activate
#
# Disable prompt: export GCPCTX_DISABLE_PROMPT=1

if [[ -z "${GCPCTX_BIN:-}" ]]; then
  if command -v gcpctx >/dev/null 2>&1; then
    # Prefer real binary, not this function once defined — resolve now
    GCPCTX_BIN="$(command -v gcpctx)"
    # If already a function, fall through to path search below
  fi
  if [[ -z "${GCPCTX_BIN:-}" || "${GCPCTX_BIN}" == "gcpctx" ]]; then
    if [[ -x "$HOME/bin/gcpctx" ]]; then
      GCPCTX_BIN="$HOME/bin/gcpctx"
    elif [[ -x "$HOME/.local/bin/gcpctx" ]]; then
      GCPCTX_BIN="$HOME/.local/bin/gcpctx"
    else
      GCPCTX_BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/gcpctx"
    fi
  fi
fi

# Re-resolve to absolute path if possible
if [[ -n "${GCPCTX_BIN:-}" && -x "${GCPCTX_BIN}" ]]; then
  :
elif command -v gcpctx >/dev/null 2>&1; then
  _gcpctx_wh="$(type -P gcpctx 2>/dev/null || true)"
  [[ -n "$_gcpctx_wh" ]] && GCPCTX_BIN="$_gcpctx_wh"
  unset _gcpctx_wh
fi

gcpctx() {
  local cmd="${1:-}"
  case "$cmd" in
    use|activate|deactivate|env)
      shift
      eval "$("$GCPCTX_BIN" "$cmd" "$@" --export)"
      ;;
    project)
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

# --- prompt segment from env ---
_gcpctx_prompt_segment() {
  [[ -n "${GCPCTX_DISABLE_PROMPT:-}" ]] && return 0
  [[ -z "${GCPCTX_NAME:-}" ]] && return 0
  local seg="(gcp:${GCPCTX_NAME}"
  if [[ -n "${GOOGLE_CLOUD_PROJECT:-}" ]]; then
    seg+=":${GOOGLE_CLOUD_PROJECT}"
  fi
  seg+=") "
  printf '%s' "$seg"
}

gcpctx_prompt() {
  local seg
  seg="$(_gcpctx_prompt_segment)"
  if [[ -n "$seg" ]]; then
    printf '%s' "$seg"
  else
    "$GCPCTX_BIN" current --prompt 2>/dev/null || true
  fi
}

# Save base PS1 once; inject via PROMPT_COMMAND
if [[ -z "${_GCPCTX_BASE_PS1+x}" ]]; then
  _GCPCTX_BASE_PS1="$PS1"
fi

_gcpctx_prompt_command() {
  if [[ -z "${GCPCTX_DISABLE_PROMPT:-}" ]]; then
    local seg
    seg="$(_gcpctx_prompt_segment)"
    if [[ -n "$seg" ]]; then
      PS1="${seg}${_GCPCTX_BASE_PS1}"
    else
      PS1="${_GCPCTX_BASE_PS1}"
    fi
  fi
}

# Chain with existing PROMPT_COMMAND
case ";${PROMPT_COMMAND:-};" in
  *";_gcpctx_prompt_command;"*) ;;
  *)
    if [[ -n "${PROMPT_COMMAND:-}" ]]; then
      PROMPT_COMMAND="_gcpctx_prompt_command; ${PROMPT_COMMAND}"
    else
      PROMPT_COMMAND="_gcpctx_prompt_command"
    fi
    ;;
esac

# --- lightweight .gcpctx auto-activate on cd ---
_GCPCTX_LAST_MARKER=""

_gcpctx_find_marker() {
  local dir="$PWD"
  while true; do
    if [[ -f "$dir/.gcpctx" ]]; then
      printf '%s' "$dir/.gcpctx"
      return 0
    fi
    [[ "$dir" == "/" ]] && return 1
    dir="$(dirname "$dir")"
  done
}

_gcpctx_auto() {
  local marker
  marker="$(_gcpctx_find_marker)" || {
    _GCPCTX_LAST_MARKER=""
    return 0
  }
  if [[ "$marker" != "${_GCPCTX_LAST_MARKER}" ]]; then
    _GCPCTX_LAST_MARKER="$marker"
    eval "$("$GCPCTX_BIN" activate --export)" 2>/dev/null || true
  fi
}

# Hook cd/pushd/popd
if [[ -z "${_GCPCTX_CD_WRAPPED:-}" ]]; then
  _GCPCTX_CD_WRAPPED=1
  if ! type -t __gcpctx_orig_cd >/dev/null 2>&1; then
    # shellcheck disable=SC2329
    __gcpctx_orig_cd() { builtin cd "$@"; }
    # shellcheck disable=SC2329
    __gcpctx_orig_pushd() { builtin pushd "$@"; }
    # shellcheck disable=SC2329
    __gcpctx_orig_popd() { builtin popd "$@"; }
  fi
  cd() { __gcpctx_orig_cd "$@" && _gcpctx_auto; }
  pushd() { __gcpctx_orig_pushd "$@" && _gcpctx_auto; }
  popd() { __gcpctx_orig_popd "$@" && _gcpctx_auto; }
fi

_gcpctx_auto
