# shellcheck shell=bash
# Append-only command journal under $GCPCTX_HOME/history.

gcpctx_history_root() {
  echo "${GCPCTX_HOME:-$HOME/.gcpctx}/history"
}

gcpctx_history_events_file() {
  echo "$(gcpctx_history_root)/events.jsonl"
}

gcpctx_history_entry_dir() {
  local id="$1"
  echo "$(gcpctx_history_root)/entries/$id"
}

gcpctx_history_ensure() {
  gcpctx_ensure_dir_700 "$(gcpctx_history_root)"
  gcpctx_ensure_dir_700 "$(gcpctx_history_root)/entries"
  local ef
  ef="$(gcpctx_history_events_file)"
  if [[ ! -f "$ef" ]]; then
    : >"$ef"
    gcpctx_chmod_600 "$ef"
  fi
}

# Generate a short unique event id.
gcpctx_history_new_id() {
  python3 -c '
import time, uuid
print(time.strftime("%Y%m%dT%H%M%SZ", time.gmtime()) + "-" + uuid.uuid4().hex[:10])
'
}

# Start a new event directory; prints id. Caller fills event.json later.
# Args: kind argv_json (optional — written later via finalize)
gcpctx_history_begin() {
  gcpctx_history_ensure
  local id
  id="$(gcpctx_history_new_id)"
  local dir
  dir="$(gcpctx_history_entry_dir "$id")"
  gcpctx_ensure_dir_700 "$dir"
  gcpctx_ensure_dir_700 "$dir/before"
  gcpctx_ensure_dir_700 "$dir/after"
  echo "$id"
}

# Write event.json and append summary line to events.jsonl.
# Usage: gcpctx_history_finalize <id> <json-file-or-stdin via - >
gcpctx_history_finalize() {
  local id="$1"
  local json_src="${2:--}"
  local dir event_file
  dir="$(gcpctx_history_entry_dir "$id")"
  event_file="$dir/event.json"
  if [[ "$json_src" == "-" ]]; then
    cat >"$event_file"
  else
    cp "$json_src" "$event_file"
  fi
  gcpctx_chmod_600 "$event_file"
  # Append index line (compact)
  python3 -c '
import json, sys
path, index = sys.argv[1], sys.argv[2]
with open(path) as f:
    ev = json.load(f)
line = {
    "id": ev.get("id"),
    "ts": ev.get("ts"),
    "kind": ev.get("kind"),
    "argv": ev.get("argv"),
    "exit_code": ev.get("exit_code"),
    "context": (ev.get("pii") or {}).get("context"),
    "project": (ev.get("pii") or {}).get("project"),
    "account": (ev.get("pii") or {}).get("account"),
    "undo": (ev.get("undo") or {}).get("status"),
    "classification": (ev.get("classification") or {}).get("family"),
}
with open(index, "a") as f:
    f.write(json.dumps(line, separators=(",", ":")) + "\n")
' "$event_file" "$(gcpctx_history_events_file)"
  gcpctx_chmod_600 "$(gcpctx_history_events_file)"
}

# Build PII dict JSON fragment from active context (no secrets).
gcpctx_history_pii_json() {
  local name project account=""
  name="$(read_active_name 2>/dev/null || true)"
  project=""
  if [[ -n "$name" ]] && context_exists "$name" 2>/dev/null; then
    project="$(json_get "$(context_meta "$name")" project 2>/dev/null || true)"
    account="$(json_get "$(context_meta "$name")" account 2>/dev/null || true)"
  fi
  python3 -c '
import json, sys, os
print(json.dumps({
  "context": sys.argv[1],
  "project": sys.argv[2],
  "account": sys.argv[3],
  "cwd": os.getcwd(),
}))
' "${name:-}" "${project:-}" "${account:-}"
}

# List events as JSON array (newest last by default; --reverse for newest first in display).
# Env filters: GCPCTX_HIST_LIMIT, GCPCTX_HIST_CONTEXT, GCPCTX_HIST_PROJECT
gcpctx_history_list_json() {
  local limit="${1:-50}"
  local ctx_filter="${2:-}"
  local proj_filter="${3:-}"
  gcpctx_history_ensure
  python3 -c '
import json, sys, os
index, limit, ctx_f, proj_f = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
root = os.path.dirname(index)
entries = []
if os.path.isfile(index):
    with open(index) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except json.JSONDecodeError:
                continue
            if ctx_f and row.get("context") != ctx_f:
                continue
            if proj_f and row.get("project") != proj_f:
                continue
            entries.append(row)
# newest last in file; take last N
if limit > 0 and len(entries) > limit:
    entries = entries[-limit:]
# enrich from event.json when present
out = []
for row in entries:
    eid = row.get("id")
    ef = os.path.join(root, "entries", eid or "", "event.json")
    if eid and os.path.isfile(ef):
        try:
            with open(ef) as f:
                full = json.load(f)
            out.append(full)
            continue
        except Exception:
            pass
    out.append(row)
print(json.dumps(out, indent=2))
' "$(gcpctx_history_events_file)" "$limit" "$ctx_filter" "$proj_filter"
}

gcpctx_history_show_json() {
  local id="$1"
  local ef
  ef="$(gcpctx_history_entry_dir "$id")/event.json"
  [[ -f "$ef" ]] || return 1
  cat "$ef"
}

gcpctx_history_last_ready_id() {
  gcpctx_history_ensure
  python3 -c '
import json, sys, os
index = sys.argv[1]
root = os.path.dirname(index)
last = ""
if not os.path.isfile(index):
    print("")
    raise SystemExit(0)
with open(index) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        eid = row.get("id")
        if not eid:
            continue
        ef = os.path.join(root, "entries", eid, "event.json")
        status = row.get("undo")
        if os.path.isfile(ef):
            try:
                with open(ef) as efh:
                    ev = json.load(efh)
                status = (ev.get("undo") or {}).get("status")
            except Exception:
                pass
        if status == "ready":
            last = eid
print(last)
' "$(gcpctx_history_events_file)"
}

# Mark undo status on an existing event.
gcpctx_history_set_undo_status() {
  local id="$1" status="$2"
  local ef
  ef="$(gcpctx_history_entry_dir "$id")/event.json"
  [[ -f "$ef" ]] || return 1
  python3 -c '
import json, sys
path, status = sys.argv[1], sys.argv[2]
with open(path) as f:
    ev = json.load(f)
undo = ev.get("undo") or {}
undo["status"] = status
ev["undo"] = undo
with open(path, "w") as f:
    json.dump(ev, f, indent=2)
    f.write("\n")
' "$ef" "$status"
  gcpctx_chmod_600 "$ef"
}

# Collect all snapshots from events and check existence (BQ + local).
# Prints JSON array.
gcpctx_history_snapshots_json() {
  local project_filter="${1:-}"
  gcpctx_history_ensure
  python3 -c '
import json, sys, os, subprocess, time
index, proj_f = sys.argv[1], sys.argv[2]
root = os.path.dirname(index)
travel_days = int(os.environ.get("GCPCTX_BQ_TIMETRAVEL_DAYS", "7"))
now_ms = int(time.time() * 1000)
results = []

def bq_exists(table_id):
    # table_id like project:dataset.table or project.dataset.table
    tid = table_id.replace(".", ":", 1) if table_id.count(":") == 0 and table_id.count(".") >= 2 else table_id
    try:
        r = subprocess.run(
            ["bq", "show", "--format=json", tid],
            capture_output=True, text=True, timeout=30,
        )
        return r.returncode == 0
    except Exception:
        return False

if not os.path.isfile(index):
    print("[]")
    raise SystemExit(0)

with open(index) as f:
    lines = f.readlines()

for line in lines:
    line = line.strip()
    if not line:
        continue
    try:
        row = json.loads(line)
    except json.JSONDecodeError:
        continue
    eid = row.get("id")
    if not eid:
        continue
    ef = os.path.join(root, "entries", eid, "event.json")
    if not os.path.isfile(ef):
        continue
    try:
        with open(ef) as fh:
            ev = json.load(fh)
    except Exception:
        continue
    snaps = ev.get("snapshots") or []
    pii = ev.get("pii") or {}
    if proj_f and pii.get("project") != proj_f:
        continue
    for s in snaps:
        kind = s.get("kind") or "local_before"
        resource = s.get("resource") or ""
        exists = False
        expires = s.get("expires")
        usable = False
        if kind == "local_before":
            path = s.get("path") or resource
            exists = bool(path and os.path.exists(path))
            usable = exists
        elif kind == "bq_snapshot":
            exists = bq_exists(resource)
            usable = exists
            if not expires and s.get("expiration_ms"):
                expires = s.get("expiration_ms")
        elif kind == "bq_timetravel":
            deleted_at = int(s.get("deleted_at_ms") or 0)
            window_ms = travel_days * 86400 * 1000
            deadline = deleted_at + window_ms
            expires = deadline
            exists = deleted_at > 0 and now_ms < deadline
            usable = exists
        results.append({
            "event_id": eid,
            "created": ev.get("ts"),
            "kind": kind,
            "resource": resource,
            "exists": exists,
            "expires": expires,
            "usable_for_undo": usable,
            "project": pii.get("project"),
            "context": pii.get("context"),
        })

print(json.dumps(results, indent=2))
' "$(gcpctx_history_events_file)" "$project_filter"
}

# Snapshot local context state into entry before/ for undo.
gcpctx_history_snapshot_local() {
  local id="$1"
  local name="${2:-}"
  local before
  before="$(gcpctx_history_entry_dir "$id")/before"
  gcpctx_ensure_dir_700 "$before"
  if [[ -f "$ACTIVE_FILE" ]]; then
    cp "$ACTIVE_FILE" "$before/active" 2>/dev/null || true
  fi
  if [[ -n "$name" ]] && context_exists "$name" 2>/dev/null; then
    cp "$(context_meta "$name")" "$before/meta.json" 2>/dev/null || true
  elif [[ -n "$(read_active_name 2>/dev/null || true)" ]]; then
    local an
    an="$(read_active_name)"
    if context_exists "$an" 2>/dev/null; then
      cp "$(context_meta "$an")" "$before/meta.json" 2>/dev/null || true
    fi
  fi
}

# Record a generic command after it ran (non-exec).
# Args: kind exit_code argv...
gcpctx_history_record_simple() {
  gcpctx_history_enabled || return 0
  local kind="$1" exit_code="$2"
  shift 2
  local id ts pii_json argv_json
  id="$(gcpctx_history_begin)"
  gcpctx_history_snapshot_local "$id"
  ts="$(python3 -c 'import datetime; print(datetime.datetime.utcnow().replace(microsecond=0).isoformat()+"Z")')"
  pii_json="$(gcpctx_history_pii_json)"
  argv_json="$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1:]))' "$kind" "$@")"
  local undo_status="ready"
  case "$kind" in
    help|version|completion|history|timeline|snapshots|current|list|ls|env|which|doctor|assert)
      undo_status="unsupported"
      ;;
  esac
  python3 -c '
import json, sys
id, ts, kind, exit_code, pii_s, argv_s, undo_status = sys.argv[1:8]
ev = {
  "id": id,
  "ts": ts,
  "kind": "gcpctx",
  "subcommand": kind,
  "argv": json.loads(argv_s),
  "cwd": json.loads(pii_s).get("cwd"),
  "exit_code": int(exit_code),
  "pii": json.loads(pii_s),
  "classification": {"family": "gcpctx_local", "action": kind},
  "undo": {"status": undo_status},
  "snapshots": [{
    "kind": "local_before",
    "resource": "before/meta.json",
    "path": None,
  }],
}
print(json.dumps(ev, indent=2))
' "$id" "$ts" "$kind" "$exit_code" "$pii_json" "$argv_json" "$undo_status" \
    | gcpctx_history_finalize "$id" -
}
