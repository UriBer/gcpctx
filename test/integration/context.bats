#!/usr/bin/env bats
load ../helpers/common

setup() {
  setup_isolated_env
  seed_context dev
  echo dev >"$GCPCTX_HOME/active"
}

teardown() { teardown_isolated_env; }

@test "use --export only allowlisted exports" {
  run "$GCPCTX" use dev --export
  [ "$status" -eq 0 ]
  # stdout must be export lines only
  while IFS= read -r line; do
    [[ "$line" == export\ * ]] || [[ -z "$line" ]]
  done <<<"$output"
  [[ "$output" != *"refresh_token"* ]]
  [[ "$output" != *"client_secret"* ]]
  [[ "$output" != *"GOCSPX"* ]]
}

@test "env --json has no secrets" {
  eval "$("$GCPCTX" use dev --export)"
  run "$GCPCTX" env --json
  [ "$status" -eq 0 ]
  [[ "$output" != *"refresh_token"* ]]
  [[ "$output" != *"client_secret"* ]]
  [[ "$output" == *"GCPCTX_NAME"* ]]
}

@test "current --json has credentials_path not token" {
  eval "$("$GCPCTX" use dev --export)"
  run "$GCPCTX" current --json
  [ "$status" -eq 0 ]
  [[ "$output" == *"credentials_path"* ]]
  [[ "$output" != *"refresh_token"* ]]
}

@test "assert --context succeeds" {
  eval "$("$GCPCTX" use dev --export)"
  run "$GCPCTX" assert --context dev --project example-dev-123456
  [ "$status" -eq 0 ]
}

@test "assert --context fails on mismatch" {
  eval "$("$GCPCTX" use dev --export)"
  run "$GCPCTX" assert --context prod
  [ "$status" -ne 0 ]
}

@test "protect and warn metadata" {
  run "$GCPCTX" protect dev
  [ "$status" -eq 0 ]
  run grep -q '"protected": "true"' "$GCPCTX_HOME/contexts/dev/meta.json"
  [ "$status" -eq 0 ]
}
