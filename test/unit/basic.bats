#!/usr/bin/env bats
load ../helpers/common

setup() { setup_isolated_env; }
teardown() { teardown_isolated_env; }

@test "version matches package.json" {
  run "$GCPCTX" version
  [ "$status" -eq 0 ]
  [[ "$output" == *"0.3.0"* ]]
}

@test "help exits 0" {
  run "$GCPCTX" help
  [ "$status" -eq 0 ]
}

@test "list empty store" {
  run "$GCPCTX" list
  [ "$status" -eq 0 ]
}

@test "init creates context" {
  cd "$TEST_TMP"
  run "$GCPCTX" init --name dev --project example-dev-123456 --account user@example.com
  [ "$status" -eq 0 ]
  [ -f "$GCPCTX_HOME/contexts/dev/meta.json" ]
}

@test "reject evil context name" {
  run "$GCPCTX" init --name '../evil' --project example-dev-123456 --account user@example.com
  [ "$status" -ne 0 ]
}

@test "current --prompt empty when inactive" {
  run "$GCPCTX" current --prompt
  [ "$status" -eq 0 ]
}
