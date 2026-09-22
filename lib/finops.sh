# shellcheck shell=bash
# Delegate cost dry-run to gemlake-finops (never port cost math).

gcpctx_finops_bin() {
  if [[ -n "${GCPCTX_FINOPS:-}" && -x "${GCPCTX_FINOPS}" ]]; then
    echo "$GCPCTX_FINOPS"
    return 0
  fi
  if command -v gemlake-finops >/dev/null 2>&1; then
    command -v gemlake-finops
    return 0
  fi
  return 1
}

gcpctx_finops_install_hint() {
  cat <<'EOF'
gemlake-finops is required for cost dry-run (gcpctx does not invent USD figures).

Install when published:
  npm install -g gemlake-finops

Or from the sibling repo (development):
  cd /path/to/gemlake-finops && npm install && npm run build
  export GCPCTX_FINOPS="$(pwd)/dist/cli/index.js"
  # or: npm link

Then re-run with --dry-run.
EOF
}

# Offer install. Returns 0 if finops available after, 1 otherwise.
# Flags via env: GCPCTX_INSTALL_FINOPS=1 to auto-approve non-interactive.
gcpctx_finops_offer_install() {
  if gcpctx_finops_bin >/dev/null 2>&1; then
    return 0
  fi
  info "gemlake-finops not found on PATH (or GCPCTX_FINOPS)"
  gcpctx_finops_install_hint >&2
  local do_install=false
  if [[ "${GCPCTX_INSTALL_FINOPS:-}" == "1" ]]; then
    do_install=true
  elif [[ -t 0 ]]; then
    info "Download and install gemlake-finops now? [y/N]"
    local ans
    read -r ans || true
    [[ "$ans" == "y" || "$ans" == "Y" || "$ans" == "yes" ]] && do_install=true
  else
    info "non-interactive: pass --install-finops (or GCPCTX_INSTALL_FINOPS=1) to install"
    return 1
  fi
  if ! $do_install; then
    info "skipped finops install; dry-run will be plan-only (no cost)"
    return 1
  fi
  if command -v npm >/dev/null 2>&1; then
    info "running: npm install -g gemlake-finops"
    if npm install -g gemlake-finops; then
      gcpctx_finops_bin >/dev/null 2>&1 && return 0
    fi
    info "npm install -g gemlake-finops failed (package may be private/unpublished)"
  else
    info "npm not found; cannot auto-install"
  fi
  return 1
}

# Run finops cost estimate; write JSON to dest file.
# Args: dest_json project location argv...
# Returns 0 on success, 1 if unavailable / unsupported.
gcpctx_finops_estimate() {
  local dest="$1" project="$2" location="$3"
  shift 3
  local bin
  if ! bin="$(gcpctx_finops_bin)"; then
    return 1
  fi
  gcpctx_ensure_dir_700 "${GCPCTX_HOME}/tmp"
  local tmp
  tmp="$(mktemp "${GCPCTX_HOME}/tmp/finops.XXXXXX")"
  # shellcheck disable=SC2064
  trap "rm -f '$tmp'" RETURN
  if "$bin" estimate --json --project "$project" --location "$location" -- "$@" >"$tmp" 2>/dev/null; then
    :
  elif "$bin" dry-run --json --project "$project" --location "$location" -- "$@" >"$tmp" 2>/dev/null; then
    :
  else
    python3 -c '
import json, sys
print(json.dumps({
  "status": "unsupported",
  "engine": "gemlake-finops",
  "usd": None,
  "evidenceType": None,
  "warnings": [
    "gemlake-finops has no estimate/dry-run JSON subcommand yet; upgrade gemlake-finops",
    "gcpctx will not invent a heuristic USD figure",
  ],
  "assumptions": [],
}))
' >"$tmp"
  fi
  cp "$tmp" "$dest"
  gcpctx_chmod_600 "$dest"
  return 0
}
