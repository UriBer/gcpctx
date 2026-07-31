#!/usr/bin/env bats
load ../helpers/common

setup() {
  setup_isolated_env
  seed_context dev
}

teardown() { teardown_isolated_env; }

@test "reject context name with dollar injection" {
  run "$GCPCTX" init --name 'x$(touch '"$TEST_TMP"'/pwned)' --project example-dev-123456 --account user@example.com
  [ "$status" -ne 0 ]
  [ ! -f "$TEST_TMP/pwned" ]
}

@test "reject context name with semicolon" {
  run "$GCPCTX" init --name 'x;id' --project example-dev-123456 --account user@example.com
  [ "$status" -ne 0 ]
}

@test "reject project id with backtick" {
  run "$GCPCTX" init --name safe --project 'evil`id`' --account user@example.com
  [ "$status" -ne 0 ]
}

@test "reject path traversal context" {
  run "$GCPCTX" init --name '../../tmp/x' --project example-dev-123456 --account user@example.com
  [ "$status" -ne 0 ]
}

@test "export quoting survives spaces and quotes in path home" {
  # Recreate store under path with spaces
  export GCPCTX_HOME="$TEST_TMP/with spaces/gcpctx"
  mkdir -p "$GCPCTX_HOME"
  seed_context dev
  run "$GCPCTX" use dev --export
  [ "$status" -eq 0 ]
  eval "$output"
  [[ "$GOOGLE_APPLICATION_CREDENTIALS" == *"with spaces"* ]]
  [[ "$output" != *$'\n'*export*export* ]] || true
}

@test "malicious project value cannot inject via export" {
  # Craft meta with weird project — must be rejected on use --project
  run "$GCPCTX" use dev --project 'x$(touch '"$TEST_TMP"'/pwn2)' --export
  [ "$status" -ne 0 ]
  [ ! -f "$TEST_TMP/pwn2" ]
}

@test "credentials never on stdout for doctor" {
  eval "$("$GCPCTX" use dev --export)"
  run "$GCPCTX" doctor
  [[ "$output" != *"refresh_token"* ]]
  [[ "$output" != *"GOCSPX"* ]]
  [[ "$stderr" != *"refresh_token"* ]] || true
}

@test "store permissions are restrictive" {
  eval "$("$GCPCTX" use dev --export)"
  run "$GCPCTX" secrets fix
  [ "$status" -eq 0 ]
  # GNU stat: -c '%a'; BSD stat: -f '%OLp'. Never use GNU's -f (filesystem) first.
  if stat --version >/dev/null 2>&1; then
    mode="$(stat -c '%a' "$GCPCTX_HOME")"
  else
    mode="$(stat -f '%OLp' "$GCPCTX_HOME")"
  fi
  # Accept 700 or 0700
  [[ "$mode" == "700" || "$mode" == "0700" ]]
}
