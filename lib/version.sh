# shellcheck shell=bash
# Version resolution: package.json > VERSION file > embedded fallback

GCPCTX_VERSION_FALLBACK="0.3.0"

gcpctx_read_version() {
  local root="${1:-}"
  local ver=""
  if [[ -n "$root" && -f "$root/package.json" ]]; then
    ver="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("version",""))' "$root/package.json" 2>/dev/null || true)"
  fi
  if [[ -z "$ver" && -n "$root" && -f "$root/VERSION" ]]; then
    ver="$(tr -d '[:space:]' <"$root/VERSION")"
  fi
  if [[ -z "$ver" ]]; then
    ver="$GCPCTX_VERSION_FALLBACK"
  fi
  printf '%s' "$ver"
}
