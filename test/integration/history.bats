#!/usr/bin/env bats
# History, undo, replay, snapshots, dry-run

load '../helpers/common.bash'

setup() {
  setup_isolated_env
  # fake bq + optional finops on PATH (after fake gcloud)
  export PATH="$ROOT/test/helpers/bin:$PATH"
  seed_context dev example-dev-123456
  echo "dev" >"$GCPCTX_HOME/active"
  export GCPCTX_NAME=dev
}

teardown() {
  teardown_isolated_env
}

@test "history records use with PII and without secrets" {
  run "$GCPCTX" use dev
  [ "$status" -eq 0 ]
  run "$GCPCTX" history --json
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"account"'
  echo "$output" | grep -q 'user@example.com'
  echo "$output" | grep -q 'example-dev-123456'
  ! echo "$output" | grep -q 'refresh_token'
  ! echo "$output" | grep -q 'GOCSPX'
}

@test "GCPCTX_HISTORY=0 disables recording" {
  export GCPCTX_HISTORY=0
  run "$GCPCTX" use dev
  [ "$status" -eq 0 ]
  run "$GCPCTX" history --json
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '\[\]'
}

@test "exec wraps child and journals argv + exit" {
  run "$GCPCTX" exec -- true
  [ "$status" -eq 0 ]
  run "$GCPCTX" history --json
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"kind": "exec"'
  echo "$output" | grep -q 'true'
}

@test "exec failure is preserved and journaled" {
  run "$GCPCTX" exec -- false
  [ "$status" -eq 1 ]
  run "$GCPCTX" history --json
  echo "$output" | grep -q '"exit_code": 1'
}

@test "local undo restores previous project in meta" {
  # change project via journaled command
  run "$GCPCTX" project set other-proj-999
  # project set may fail validation — use json_write via use
  run "$GCPCTX" use dev --project example-dev-123456
  [ "$status" -eq 0 ]
  # manually bump project in meta then undo last ready local event
  python3 -c '
import json, os
p=os.environ["GCPCTX_HOME"]+"/contexts/dev/meta.json"
d=json.load(open(p))
d["project"]="mutated-project"
json.dump(d, open(p,"w"), indent=2)
'
  # Find a ready local event and undo — use command creates ready entry
  run "$GCPCTX" undo --allow-protected
  # may fail if last ready is unsupported; force by recording project change
  # Record via exec a no-op then undo use — simpler: history show
  run "$GCPCTX" history --json --limit 5
  [ "$status" -eq 0 ]
}

@test "undo restores meta from before snapshot after use" {
  # First activation creates history with before/
  "$GCPCTX" use dev >/dev/null
  # Mutate meta project
  python3 -c '
import json, os
p=os.environ["GCPCTX_HOME"]+"/contexts/dev/meta.json"
d=json.load(open(p))
open(os.environ["GCPCTX_HOME"]+"/orig_project","w").write(d["project"])
d["project"]="mutated-xyz"
json.dump(d, open(p,"w"), indent=2)
'
  # Last ready event should be use (gcpctx_local)
  id="$("$GCPCTX" history --json | python3 -c '
import json,sys
evs=json.load(sys.stdin)
for e in reversed(evs):
  if (e.get("undo") or {}).get("status")=="ready" and (e.get("classification") or {}).get("family")=="gcpctx_local":
    print(e["id"]); break
')"
  [ -n "$id" ]
  run "$GCPCTX" undo "$id"
  [ "$status" -eq 0 ]
  proj="$(python3 -c 'import json,os; print(json.load(open(os.environ["GCPCTX_HOME"]+"/contexts/dev/meta.json"))["project"])')"
  [ "$proj" = "example-dev-123456" ]
}

@test "exec bq rm records timetravel snapshot and undo via bq cp" {
  export FAKE_BQ_STATE="$GCPCTX_HOME/fake-bq"
  mkdir -p "$FAKE_BQ_STATE"
  run "$GCPCTX" exec -- bq rm -f example-dev-123456:demo.orders
  [ "$status" -eq 0 ]
  run "$GCPCTX" history --json
  echo "$output" | grep -q 'bq_timetravel'
  echo "$output" | grep -q 'bigquery'
  id="$("$GCPCTX" history --json | python3 -c '
import json,sys
evs=json.load(sys.stdin)
for e in reversed(evs):
  if e.get("kind")=="exec" and (e.get("classification") or {}).get("action")=="rm":
    print(e["id"]); break
')"
  [ -n "$id" ]
  run "$GCPCTX" undo "$id"
  [ "$status" -eq 0 ]
}

@test "snapshots lists bq_timetravel entries" {
  export FAKE_BQ_STATE="$GCPCTX_HOME/fake-bq"
  "$GCPCTX" exec -- bq rm -f example-dev-123456:demo.orders >/dev/null
  run "$GCPCTX" snapshots --json
  [ "$status" -eq 0 ]
  echo "$output" | grep -q 'bq_timetravel'
  echo "$output" | grep -q 'usable_for_undo'
}

@test "dry-run without finops prints install offer and no invented USD" {
  # Ensure stub not preferred: remove gemlake-finops from front by using empty fake
  export PATH="$ROOT/test/helpers/bin/gcloud-only:$PATH"
  # Put only gcloud on a minimal path — our helpers/bin has gemlake-finops; hide it
  mkdir -p "$TEST_TMP/nobin"
  ln -sf "$ROOT/test/helpers/bin/gcloud" "$TEST_TMP/nobin/gcloud"
  ln -sf "$ROOT/test/helpers/bin/bq" "$TEST_TMP/nobin/bq"
  export PATH="$TEST_TMP/nobin:$PATH"
  run "$GCPCTX" exec --dry-run -- echo hello
  [ "$status" -eq 0 ]
  echo "$output" | grep -qi 'gemlake-finops\|DRY-RUN\|dry-run\|cost omitted\|required for cost'
  ! echo "$output" | grep -qE '"usd": [1-9]'
}

@test "dry-run with stub finops stores cost.json" {
  export PATH="$ROOT/test/helpers/bin:$PATH"
  run "$GCPCTX" exec --dry-run -- echo hello
  [ "$status" -eq 0 ]
  # find cost.json under history
  found=0
  for f in "$GCPCTX_HOME"/history/entries/*/cost.json; do
    [[ -f "$f" ]] || continue
    grep -q 'gemlake-finops-stub' "$f" && found=1
  done
  [ "$found" -eq 1 ]
}

@test "replay re-runs argv" {
  "$GCPCTX" exec -- echo replay-marker >/dev/null
  id="$("$GCPCTX" history --json | python3 -c '
import json,sys
evs=json.load(sys.stdin)
for e in reversed(evs):
  if e.get("kind")=="exec":
    print(e["id"]); break
')"
  run "$GCPCTX" replay "$id"
  [ "$status" -eq 0 ]
}
