# shellcheck shell=bash
# Resolve a trusted absolute gcloud binary once; avoid PATH hijacks mid-run.

_GCPCTX_GCLOUD_BIN=""
_GCPCTX_GCLOUD_TRUSTED=""

gcpctx_dir_world_writable() {
  local d="$1"
  [[ -d "$d" ]] || return 1
  # Portable: prefer find -perm; fall back to octal mode check
  if find "$d" -maxdepth 0 -perm -0002 2>/dev/null | grep -q .; then
    return 0
  fi
  local mode
  if command -v gcpctx_file_mode_octal >/dev/null 2>&1; then
    mode="$(gcpctx_file_mode_octal "$d" 2>/dev/null || echo 0)"
  elif [[ "$(type -t file_mode_octal 2>/dev/null)" == "function" ]]; then
    mode="$(file_mode_octal "$d" 2>/dev/null || echo 0)"
  else
    mode=0
  fi
  mode=$((8#$mode))
  [[ $((mode & 2)) -ne 0 ]]
}

gcpctx_gcloud_path_looks_unsafe() {
  local bin="$1" dir
  [[ "$bin" == /* ]] || return 0
  dir="$(dirname "$bin")"
  case "$dir" in
    /tmp|/tmp/*|/var/tmp|/var/tmp/*|"$TMPDIR"|"$TMPDIR"/*)
      return 0
      ;;
  esac
  if gcpctx_dir_world_writable "$dir"; then
    return 0
  fi
  return 1
}

# Soft resolve — returns 1 if missing/invalid; does not exit.
gcpctx_try_resolve_gcloud() {
  if [[ -n "${_GCPCTX_GCLOUD_BIN:-}" ]]; then
    return 0
  fi

  local candidate=""
  if [[ -n "${GCPCTX_GCLOUD:-}" ]]; then
    candidate="$GCPCTX_GCLOUD"
    [[ "$candidate" == /* && -x "$candidate" ]] || return 1
  else
    # type -P ignores functions/aliases (critical: we define a gcloud() wrapper)
    candidate="$(type -P gcloud 2>/dev/null || true)"
    [[ -n "$candidate" ]] || return 1
    if [[ "$candidate" != /* ]]; then
      if [[ -x "./$candidate" ]]; then
        candidate="$(cd "$(dirname "./$candidate")" && pwd)/$(basename "$candidate")"
      else
        return 1
      fi
    fi
    [[ -x "$candidate" ]] || return 1
  fi

  _GCPCTX_GCLOUD_BIN="$candidate"
  if gcpctx_gcloud_path_looks_unsafe "$candidate"; then
    _GCPCTX_GCLOUD_TRUSTED=0
  else
    _GCPCTX_GCLOUD_TRUSTED=1
  fi
  return 0
}

# Resolve and cache absolute gcloud path (fatal on failure).
# Override: GCPCTX_GCLOUD=/absolute/path/to/gcloud
# Escape hatch: GCPCTX_ALLOW_UNSAFE_GCLOUD=1
gcpctx_resolve_gcloud() {
  if gcpctx_try_resolve_gcloud; then
    if [[ "${_GCPCTX_GCLOUD_TRUSTED:-0}" != "1" && "${GCPCTX_ALLOW_UNSAFE_GCLOUD:-}" != "1" ]]; then
      echo "gcpctx: WARN: gcloud binary may be hijackable: ${_GCPCTX_GCLOUD_BIN}" >&2
      echo "gcpctx: set GCPCTX_GCLOUD to a trusted absolute path, or GCPCTX_ALLOW_UNSAFE_GCLOUD=1" >&2
    fi
    return 0
  fi
  if [[ -n "${GCPCTX_GCLOUD:-}" ]]; then
    gcpctx_die "GCPCTX_GCLOUD is missing or not an absolute executable: $GCPCTX_GCLOUD"
  fi
  gcpctx_die "gcloud not found on PATH (install Google Cloud SDK or set GCPCTX_GCLOUD)"
}

gcpctx_require_trusted_gcloud() {
  gcpctx_resolve_gcloud
  if [[ "${_GCPCTX_GCLOUD_TRUSTED:-0}" != "1" && "${GCPCTX_ALLOW_UNSAFE_GCLOUD:-}" != "1" ]]; then
    # Soft policy for login/scan: still allow if not world-writable temp, but fail closed on tmp
    local dir
    dir="$(dirname "${_GCPCTX_GCLOUD_BIN}")"
    case "$dir" in
      /tmp|/tmp/*|/var/tmp|/var/tmp/*)
        gcpctx_die "refusing to run credential operation with gcloud in temp dir: ${_GCPCTX_GCLOUD_BIN}"
        ;;
    esac
    if gcpctx_dir_world_writable "$dir"; then
      gcpctx_die "refusing to run credential operation with gcloud in world-writable dir: $dir (set GCPCTX_ALLOW_UNSAFE_GCLOUD=1 to override)"
    fi
  fi
}

gcpctx_gcloud_bin() {
  gcpctx_resolve_gcloud
  printf '%s' "${_GCPCTX_GCLOUD_BIN}"
}

# Shadow PATH lookups inside this process with a fixed absolute binary.
gcloud() {
  gcpctx_resolve_gcloud
  command "${_GCPCTX_GCLOUD_BIN}" "$@"
}
