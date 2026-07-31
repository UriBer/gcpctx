# shellcheck shell=bash
# Safe environment export encoder.
# Allowlisted names only; values via printf %q; diagnostics never on stdout.

GCPCTX_EXPORT_VARS=(
  GCPCTX_NAME
  GCPCTX_HOME
  GOOGLE_APPLICATION_CREDENTIALS
  GOOGLE_CLOUD_PROJECT
  GCLOUD_PROJECT
  GOOGLE_CLOUD_QUOTA_PROJECT
  CLOUDSDK_CORE_PROJECT
  CLOUDSDK_ACTIVE_CONFIG_NAME
)

gcpctx_is_export_var() {
  local needle="$1" v
  for v in "${GCPCTX_EXPORT_VARS[@]}"; do
    [[ "$v" == "$needle" ]] && return 0
  done
  return 1
}

# Emit: export NAME=safely_quoted_value
gcpctx_emit_export() {
  local name="$1" value="$2"
  gcpctx_is_export_var "$name" || gcpctx_die "refusing to export non-allowlisted var: $name"
  # Reject raw newlines in values (would break line-oriented eval)
  if [[ "$value" == *$'\n'* || "$value" == *$'\r'* ]]; then
    gcpctx_die "refusing to export value with newline for $name"
  fi
  printf 'export %s=%q\n' "$name" "$value"
}

gcpctx_emit_unset() {
  local name="$1"
  gcpctx_is_export_var "$name" || return 0
  printf 'unset %s\n' "$name"
}

gcpctx_emit_deactivate_exports() {
  local v
  for v in "${GCPCTX_EXPORT_VARS[@]}"; do
    gcpctx_emit_unset "$v"
  done
}

# JSON object with allowlisted env keys only (for PowerShell / agents)
gcpctx_emit_env_json() {
  python3 -c '
import json, os, sys
keys = [
  "GCPCTX_NAME", "GCPCTX_HOME", "GOOGLE_APPLICATION_CREDENTIALS",
  "GOOGLE_CLOUD_PROJECT", "GCLOUD_PROJECT", "GOOGLE_CLOUD_QUOTA_PROJECT",
  "CLOUDSDK_CORE_PROJECT", "CLOUDSDK_ACTIVE_CONFIG_NAME",
]
out = {}
for k in keys:
    if k in os.environ and os.environ[k] != "":
        out[k] = os.environ[k]
print(json.dumps({"env": out, "active": bool(out.get("GCPCTX_NAME"))}, indent=2))
'
}
