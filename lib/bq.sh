# shellcheck shell=bash
# BigQuery pre-delete snapshot + time-travel helpers for gcpctx history.

# Normalize table id to project:dataset.table when possible.
gcpctx_bq_normalize_id() {
  local id="$1" project="${2:-}"
  python3 -c '
import sys
tid, project = sys.argv[1], sys.argv[2]
tid = tid.strip()
if not tid:
    print("")
    raise SystemExit(0)
if "@" in tid:
    tid = tid.split("@", 1)[0]
if ":" in tid:
    print(tid)
elif tid.count(".") == 2:
    p, d, t = tid.split(".", 2)
    print(f"{p}:{d}.{t}")
elif tid.count(".") == 1 and project:
    print(f"{project}:{tid}")
else:
    print(tid)
' "$id" "$project"
}

# Snapshot table metadata + optional SNAPSHOT TABLE + deleted_at before rm.
# Writes into entry before/ and prints JSON snapshots array to stdout.
# Args: event_id table_id [project]
gcpctx_bq_prepare_delete() {
  local eid="$1" table_id="$2" project="${3:-}"
  local before dir
  dir="$(gcpctx_history_entry_dir "$eid")"
  before="$dir/before"
  gcpctx_ensure_dir_700 "$before"

  local norm deleted_at_ms snap_name snap_id=""
  norm="$(gcpctx_bq_normalize_id "$table_id" "$project")"
  deleted_at_ms="$(python3 -c 'import time; print(int(time.time()*1000))')"

  # bq show into before/
  if command -v bq >/dev/null 2>&1; then
    bq show --format=json "$norm" >"$before/bq_show.json" 2>/dev/null || true
    gcpctx_chmod_600 "$before/bq_show.json" 2>/dev/null || true
  fi

  local snaps='[]'
  if gcpctx_bq_snapshot_on_delete 2>/dev/null; then
    # snapshot table name: dataset._gcpctx_<shortid>_<table>
    snap_name="$(python3 -c '
import sys, re
norm, eid = sys.argv[1], sys.argv[2]
# project:dataset.table
if ":" in norm:
    proj, rest = norm.split(":", 1)
    ds, table = rest.split(".", 1)
else:
    parts = norm.split(".")
    proj, ds, table = (parts + ["", "", ""])[:3]
short = re.sub(r"[^A-Za-z0-9_]", "_", eid)[-20:]
safe_table = re.sub(r"[^A-Za-z0-9_]", "_", table)[:40]
print(f"{proj}:{ds}._gcpctx_{short}_{safe_table}")
print(table)
' "$norm" "$eid")"
    snap_id="$(echo "$snap_name" | head -1)"
    local orig_table
    orig_table="$(echo "$snap_name" | tail -1)"
    # CREATE SNAPSHOT TABLE via bq query
    if command -v bq >/dev/null 2>&1; then
      local sql
      sql="$(python3 -c '
import sys
snap, src = sys.argv[1], sys.argv[2]
# SQL ids use dots
def sql_id(bq_id):
    if ":" in bq_id:
        p, rest = bq_id.split(":", 1)
        return f"{p}.{rest}"
    return bq_id
print(f"CREATE SNAPSHOT TABLE `{sql_id(snap)}` CLONE `{sql_id(src)}`")
' "$snap_id" "$norm")"
      if bq query --use_legacy_sql=false --quiet "$sql" >/dev/null 2>"$before/snapshot_err.txt"; then
        info "created BQ snapshot $snap_id"
      else
        info "BQ snapshot create failed; will rely on time travel only"
        snap_id=""
      fi
    fi
  fi

  python3 -c '
import json, sys
norm, deleted_at, snap_id, travel_days = sys.argv[1], int(sys.argv[2]), sys.argv[3], int(sys.argv[4])
snaps = [{
  "kind": "bq_timetravel",
  "resource": f"{norm}@{deleted_at}",
  "original": norm,
  "deleted_at_ms": deleted_at,
  "expires": deleted_at + travel_days * 86400 * 1000,
}]
if snap_id:
    snaps.insert(0, {
      "kind": "bq_snapshot",
      "resource": snap_id,
      "original": norm,
    })
print(json.dumps(snaps))
' "$norm" "$deleted_at_ms" "${snap_id:-}" "$(gcpctx_bq_timetravel_days)"
}

# Execute BQ undo steps from inverse.json; prefer snapshot then timetravel.
# Args: inverse_json_file
# Returns 0 on success, 2 if expired, 1 on error.
gcpctx_bq_execute_undo() {
  local inverse_file="$1"
  python3 -c '
import json, sys, subprocess, time
path = sys.argv[1]
with open(path) as f:
    plan = json.load(f)
steps = plan.get("steps") or []
# Partition prefer
preferred = [s for s in steps if s.get("type") == "bq_cp" and s.get("prefer")]
fallback = [s for s in steps if s.get("type") == "bq_cp" and not s.get("prefer")]
other = [s for s in steps if s.get("type") != "bq_cp"]

def run_cp(step):
    src, dst = step["src"], step["dst"]
    args = ["bq", "cp"] + list(step.get("args") or []) + [src, dst]
    print("gcpctx: running:", " ".join(args), file=sys.stderr)
    r = subprocess.run(args)
    return r.returncode

ok = False
for s in preferred:
    if run_cp(s) == 0:
        ok = True
        break
if not ok:
    for s in fallback:
        # check time travel expiry if deleted_at present
        deleted = s.get("deleted_at_ms")
        if deleted:
            # default 7d
            if time.time() * 1000 > deleted + 7 * 86400 * 1000:
                print("gcpctx: time travel window expired", file=sys.stderr)
                continue
        if run_cp(s) == 0:
            ok = True
            break
if ok:
    raise SystemExit(0)
if any(s.get("type") == "bq_cp" for s in steps):
    raise SystemExit(2)  # expired / unavailable
for s in other:
    if s.get("type") == "bq_rm":
        args = ["bq", "rm"] + list(s.get("args") or []) + [s.get("resource") or ""]
        r = subprocess.run(args)
        raise SystemExit(r.returncode)
print("gcpctx: no usable BQ undo step", file=sys.stderr)
raise SystemExit(1)
' "$inverse_file"
}
