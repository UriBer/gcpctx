#!/usr/bin/env bats
load ../helpers/common

setup() {
  setup_isolated_env
  seed_context dev
  mkdir -p "$CLOUDSDK_CONFIG"
  cp "$GCPCTX_HOME/contexts/dev/credentials.json" "$CLOUDSDK_CONFIG/application_default_credentials.json"
  chmod 600 "$CLOUDSDK_CONFIG/application_default_credentials.json"
}

teardown() { teardown_isolated_env; }

@test "doctor --json emits stable issue codes" {
  eval "$("$GCPCTX" use dev --export)"
  run "$GCPCTX" doctor --json
  [ "$status" -eq 0 ]
  [[ "$output" == *'"ok": true'* || "$output" == *'"ok":true'* ]]
  [[ "$output" == *'"issues"'* ]]
  [[ "$output" == *'"gcloud_bin"'* ]]
  [[ "$output" == *'"perms_supported"'* ]]
  [[ "$output" != *"refresh_token"* ]]
}

@test "doctor --json reports NO_ACTIVE_CONTEXT when inactive" {
  run "$GCPCTX" doctor --json
  [ "$status" -eq 0 ]
  [[ "$output" == *"NO_ACTIVE_CONTEXT"* ]]
  [[ "$output" == *'"issue_count"'* ]]
}

@test "safe-eval rejects injected command lines" {
  run bash -c '
    source "'"$ROOT"'/shell/safe-eval.inc.sh"
    _gcpctx_safe_eval "export GCPCTX_NAME=dev
touch '"$TEST_TMP"'/pwned"
  '
  [ "$status" -ne 0 ]
  [ ! -f "$TEST_TMP/pwned" ]
}

@test "safe-eval accepts allowlisted exports" {
  # shellcheck disable=SC1091
  source "$ROOT/shell/safe-eval.inc.sh"
  _gcpctx_safe_eval "export GCPCTX_NAME=dev"
  [[ "$GCPCTX_NAME" == "dev" ]]
}

@test "which prints resolved gcloud absolute path" {
  run "$GCPCTX" which
  [ "$status" -eq 0 ]
  [[ "$output" == *"gcloud: /"* ]]
}

@test "login refuses gcloud in world-writable dir" {
  mkdir -p "$TEST_TMP/tmpbin"
  cp "$ROOT/test/helpers/bin/gcloud" "$TEST_TMP/tmpbin/gcloud"
  chmod +x "$TEST_TMP/tmpbin/gcloud"
  chmod 777 "$TEST_TMP/tmpbin"
  export GCPCTX_GCLOUD="$TEST_TMP/tmpbin/gcloud"
  unset GCPCTX_ALLOW_UNSAFE_GCLOUD
  # Clear any prior resolve cache by subshell via fresh process (bats run)
  run env GCPCTX_GCLOUD="$TEST_TMP/tmpbin/gcloud" GCPCTX_HOME="$GCPCTX_HOME" HOME="$HOME" CLOUDSDK_CONFIG="$CLOUDSDK_CONFIG" PATH="$PATH" "$GCPCTX" login dev
  [ "$status" -ne 0 ]
}
