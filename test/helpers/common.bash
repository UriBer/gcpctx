#!/usr/bin/env bash
# Common bats helpers
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export GCPCTX="$ROOT/bin/gcpctx"

setup_isolated_env() {
  export TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/gcpctx-test.XXXXXX")"
  export HOME="$TEST_TMP/home"
  export GCPCTX_HOME="$TEST_TMP/gcpctx"
  export CLOUDSDK_CONFIG="$TEST_TMP/gcloud"
  mkdir -p "$HOME" "$GCPCTX_HOME" "$CLOUDSDK_CONFIG" "$TEST_TMP/bin"
  # Prefer fake gcloud
  export PATH="$ROOT/test/helpers/bin:$PATH"
  unset GCPCTX_NAME GOOGLE_CLOUD_PROJECT GOOGLE_APPLICATION_CREDENTIALS GOOGLE_CLOUD_QUOTA_PROJECT CLOUDSDK_CORE_PROJECT CLOUDSDK_ACTIVE_CONFIG_NAME GCLOUD_PROJECT
}

teardown_isolated_env() {
  rm -rf "$TEST_TMP"
}

seed_context() {
  local name="${1:-dev}"
  local project="${2:-example-dev-123456}"
  mkdir -p -m 700 "$GCPCTX_HOME/contexts/$name"
  cat >"$GCPCTX_HOME/contexts/$name/meta.json" <<EOF
{
  "name": "$name",
  "account": "user@example.com",
  "project": "$project",
  "quota_project": "$project",
  "region": "us-central1",
  "zone": "us-central1-a",
  "gcloud_config": "$name",
  "protected": false
}
EOF
  # Fake authorized_user ADC — unmistakably fake values for scanners
  cat >"$GCPCTX_HOME/contexts/$name/credentials.json" <<'EOF'
{
  "type": "authorized_user",
  "client_id": "000000000000-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com",
  "client_secret": "GOCSPX-TESTONLY-NOT-A-REAL-SECRET",
  "refresh_token": "1//TESTONLY-NOT-A-REAL-REFRESH-TOKEN-VALUE",
  "quota_project_id": "example-dev-123456",
  "account": "user@example.com"
}
EOF
  chmod 600 "$GCPCTX_HOME/contexts/$name/credentials.json"
}
