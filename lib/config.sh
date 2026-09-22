# shellcheck shell=bash
# gcpctx config.json — history and related preferences.

gcpctx_config_path() {
  echo "${GCPCTX_HOME:-$HOME/.gcpctx}/config.json"
}

# Ensure default config exists (history on by default).
gcpctx_config_ensure() {
  local path
  path="$(gcpctx_config_path)"
  gcpctx_ensure_dir_700 "$(dirname "$path")"
  if [[ ! -f "$path" ]]; then
    gcpctx_atomic_write "$path" '{
  "history": {
    "enabled": true,
    "retain_days": 90,
    "bq_snapshot_on_delete": true,
    "bq_timetravel_days": 7
  }
}
' 600
  fi
}

# Print JSON value for dotted key under history.* or top-level; empty if missing.
gcpctx_config_get() {
  local key="$1"
  local path
  path="$(gcpctx_config_path)"
  gcpctx_config_ensure
  python3 -c '
import json, sys
path, key = sys.argv[1], sys.argv[2]
try:
    with open(path) as f:
        data = json.load(f)
except Exception:
    data = {}
cur = data
for part in key.split("."):
    if not isinstance(cur, dict) or part not in cur:
        print("")
        raise SystemExit(0)
    cur = cur[part]
if isinstance(cur, bool):
    print("true" if cur else "false")
elif cur is None:
    print("")
else:
    print(cur)
' "$path" "$key"
}

# Returns 0 if history recording is enabled.
gcpctx_history_enabled() {
  if [[ "${GCPCTX_HISTORY:-1}" == "0" || "${GCPCTX_HISTORY:-}" == "false" || "${GCPCTX_HISTORY:-}" == "off" ]]; then
    return 1
  fi
  local v
  v="$(gcpctx_config_get history.enabled)"
  if [[ "$v" == "false" || "$v" == "0" ]]; then
    return 1
  fi
  return 0
}

gcpctx_history_retain_days() {
  local v
  v="$(gcpctx_config_get history.retain_days)"
  [[ -n "$v" ]] || v=90
  echo "$v"
}

gcpctx_bq_snapshot_on_delete() {
  local v
  v="$(gcpctx_config_get history.bq_snapshot_on_delete)"
  [[ "$v" != "false" && "$v" != "0" ]]
}

gcpctx_bq_timetravel_days() {
  local v
  v="$(gcpctx_config_get history.bq_timetravel_days)"
  [[ -n "$v" ]] || v=7
  echo "$v"
}
