# shellcheck shell=bash
# Doctor issue accumulation with stable machine-readable codes.

# Global arrays populated by doctor checks (Bash 3.2 compatible via parallel strings)
_GCPCTX_DOC_CODES=""
_GCPCTX_DOC_SEVS=""
_GCPCTX_DOC_MSGS=""
_GCPCTX_DOC_PATHS=""
_GCPCTX_DOC_COUNT=0

gcpctx_doctor_reset() {
  _GCPCTX_DOC_CODES=""
  _GCPCTX_DOC_SEVS=""
  _GCPCTX_DOC_MSGS=""
  _GCPCTX_DOC_PATHS=""
  _GCPCTX_DOC_COUNT=0
}

# gcpctx_doctor_add CODE SEVERITY MESSAGE [PATH]
# SEVERITY: error | warn | info
gcpctx_doctor_add() {
  local code="$1" sev="$2" msg="$3" path="${4:-}"
  _GCPCTX_DOC_COUNT=$((_GCPCTX_DOC_COUNT + 1))
  _GCPCTX_DOC_CODES="${_GCPCTX_DOC_CODES}${_GCPCTX_DOC_CODES:+$'\n'}${code}"
  _GCPCTX_DOC_SEVS="${_GCPCTX_DOC_SEVS}${_GCPCTX_DOC_SEVS:+$'\n'}${sev}"
  _GCPCTX_DOC_MSGS="${_GCPCTX_DOC_MSGS}${_GCPCTX_DOC_MSGS:+$'\n'}${msg}"
  _GCPCTX_DOC_PATHS="${_GCPCTX_DOC_PATHS}${_GCPCTX_DOC_PATHS:+$'\n'}${path}"
}

gcpctx_doctor_error_count() {
  local n=0 sev
  if [[ "${_GCPCTX_DOC_COUNT}" -eq 0 ]]; then
    echo 0
    return
  fi
  while IFS= read -r sev; do
    [[ "$sev" == "error" ]] && n=$((n + 1))
  done <<< "${_GCPCTX_DOC_SEVS}"
  echo "$n"
}

gcpctx_doctor_warn_count() {
  local n=0 sev
  if [[ "${_GCPCTX_DOC_COUNT}" -eq 0 ]]; then
    echo 0
    return
  fi
  while IFS= read -r sev; do
    [[ "$sev" == "warn" ]] && n=$((n + 1))
  done <<< "${_GCPCTX_DOC_SEVS}"
  echo "$n"
}

# Best-effort: can we enforce Unix modes on this store filesystem?
gcpctx_perms_supported() {
  local base="${1:-${GCPCTX_HOME:-}}"
  [[ -n "$base" ]] || return 1
  mkdir -p "$base/tmp" 2>/dev/null || return 1
  local t
  t="$(mktemp "$base/tmp/.permtest.XXXXXX" 2>/dev/null)" || return 1
  chmod 600 "$t" 2>/dev/null || {
    rm -f "$t"
    return 1
  }
  local mode
  if [[ "$(type -t file_mode_octal 2>/dev/null)" == "function" ]]; then
    mode="$(file_mode_octal "$t")"
  else
    mode="$(stat -c '%a' "$t" 2>/dev/null || stat -f '%OLp' "$t" 2>/dev/null || echo 0)"
  fi
  rm -f "$t"
  [[ "$mode" == "600" || "$mode" == "0600" ]]
}

gcpctx_doctor_emit_text() {
  if [[ "${_GCPCTX_DOC_COUNT}" -eq 0 ]]; then
    return 0
  fi
  paste -d $'\t' \
    <(printf '%s\n' "${_GCPCTX_DOC_CODES}") \
    <(printf '%s\n' "${_GCPCTX_DOC_SEVS}") \
    <(printf '%s\n' "${_GCPCTX_DOC_MSGS}") \
    <(printf '%s\n' "${_GCPCTX_DOC_PATHS}") |
    while IFS=$'\t' read -r code sev msg path; do
      [[ -z "$code" ]] && continue
      case "$sev" in
        error) echo "ERROR [$code]: $msg${path:+ ($path)}" ;;
        warn) echo "WARN [$code]: $msg${path:+ ($path)}" ;;
        *) echo "INFO [$code]: $msg${path:+ ($path)}" ;;
      esac
    done
}

gcpctx_doctor_emit_json() {
  local gcloud_bin="${1:-}"
  local perms_ok="${2:-false}"
  local active_name="${3:-}"
  local ok_flag
  local err_n
  err_n="$(gcpctx_doctor_error_count)"
  if [[ "$err_n" -eq 0 ]]; then
    ok_flag=true
  else
    ok_flag=false
  fi

  # Build issues JSON via Python for safe escaping
  GCPCTX_DOC_CODES="${_GCPCTX_DOC_CODES}" \
  GCPCTX_DOC_SEVS="${_GCPCTX_DOC_SEVS}" \
  GCPCTX_DOC_MSGS="${_GCPCTX_DOC_MSGS}" \
  GCPCTX_DOC_PATHS="${_GCPCTX_DOC_PATHS}" \
  GCPCTX_DOC_OK="$ok_flag" \
  GCPCTX_DOC_ERR="$err_n" \
  GCPCTX_DOC_WARN="$(gcpctx_doctor_warn_count)" \
  GCPCTX_DOC_GCLOUD="$gcloud_bin" \
  GCPCTX_DOC_PERMS="$perms_ok" \
  GCPCTX_DOC_ACTIVE="$active_name" \
  python3 - <<'PY'
import json, os

def lines(s):
    if not s:
        return []
    return s.split("\n")

codes = lines(os.environ.get("GCPCTX_DOC_CODES", ""))
sevs = lines(os.environ.get("GCPCTX_DOC_SEVS", ""))
msgs = lines(os.environ.get("GCPCTX_DOC_MSGS", ""))
paths = lines(os.environ.get("GCPCTX_DOC_PATHS", ""))
n = max(len(codes), len(sevs), len(msgs), len(paths))
issues = []
for i in range(n):
    code = codes[i] if i < len(codes) else ""
    if not code:
        continue
    issues.append({
        "code": code,
        "severity": sevs[i] if i < len(sevs) else "info",
        "message": msgs[i] if i < len(msgs) else "",
        "path": paths[i] if i < len(paths) else "",
    })

out = {
    "ok": os.environ.get("GCPCTX_DOC_OK") == "true",
    "error_count": int(os.environ.get("GCPCTX_DOC_ERR") or 0),
    "warn_count": int(os.environ.get("GCPCTX_DOC_WARN") or 0),
    "issue_count": len(issues),
    "issues": issues,
    "gcloud_bin": os.environ.get("GCPCTX_DOC_GCLOUD") or "",
    "perms_supported": os.environ.get("GCPCTX_DOC_PERMS") == "true",
    "active_context": os.environ.get("GCPCTX_DOC_ACTIVE") or "",
}
print(json.dumps(out, indent=2))
PY
}
