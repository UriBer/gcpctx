# shellcheck shell=bash
# Filesystem helpers — restrictive modes, atomic replace, path confinement.

gcpctx_umask_secure() {
  umask 077
}

gcpctx_ensure_dir_700() {
  local d="$1"
  mkdir -p "$d"
  chmod 700 "$d" 2>/dev/null || true
}

gcpctx_chmod_600() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  chmod 600 "$f" 2>/dev/null || true
}

# Refuse if path is a symlink (best-effort; not all platforms)
gcpctx_reject_symlink() {
  local p="$1"
  if [[ -L "$p" ]]; then
    gcpctx_die "refusing to use symlink: $p"
  fi
}

# Ensure resolved path stays under root (best-effort; no GNU realpath required)
gcpctx_path_under() {
  local root="$1" path="$2"
  local root_abs path_abs
  root_abs="$(cd "$root" 2>/dev/null && pwd)" || return 1
  if [[ -d "$path" ]]; then
    path_abs="$(cd "$path" 2>/dev/null && pwd)" || return 1
  else
    local parent base
    parent="$(dirname "$path")"
    base="$(basename "$path")"
    parent="$(cd "$parent" 2>/dev/null && pwd)" || return 1
    path_abs="$parent/$base"
  fi
  case "$path_abs" in
    "$root_abs"|"$root_abs"/*) return 0 ;;
    *) return 1 ;;
  esac
}

# Atomic write of text file into destination directory
gcpctx_atomic_write() {
  local dest="$1"
  local content="$2"
  local dir mode="${3:-600}"
  dir="$(dirname "$dest")"
  gcpctx_ensure_dir_700 "$dir"
  gcpctx_reject_symlink "$dir"
  if [[ -e "$dest" ]]; then
    gcpctx_reject_symlink "$dest"
  fi
  local tmp
  tmp="$(mktemp "${dir}/.gcpctx-write.XXXXXX")" || gcpctx_die "mktemp failed"
  # shellcheck disable=SC2064
  trap "rm -f '$tmp'" RETURN
  printf '%s' "$content" >"$tmp"
  chmod "$mode" "$tmp" 2>/dev/null || true
  mv -f "$tmp" "$dest"
  trap - RETURN
  chmod "$mode" "$dest" 2>/dev/null || true
}

gcpctx_atomic_copy() {
  local src="$1" dest="$2" mode="${3:-600}"
  local dir tmp
  dir="$(dirname "$dest")"
  gcpctx_ensure_dir_700 "$dir"
  gcpctx_reject_symlink "$dir"
  [[ -f "$src" ]] || gcpctx_die "missing source file"
  tmp="$(mktemp "${dir}/.gcpctx-copy.XXXXXX")" || gcpctx_die "mktemp failed"
  # shellcheck disable=SC2064
  trap "rm -f '$tmp'" RETURN
  cp "$src" "$tmp"
  chmod "$mode" "$tmp" 2>/dev/null || true
  mv -f "$tmp" "$dest"
  trap - RETURN
  chmod "$mode" "$dest" 2>/dev/null || true
}
