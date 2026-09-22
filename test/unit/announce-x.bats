#!/usr/bin/env bats
load ../helpers/common

setup() {
  setup_isolated_env
  local skill
  skill="$(python3 -c 'import os, pwd; from pathlib import Path; print(Path(pwd.getpwuid(os.getuid()).pw_dir) / ".cursor/skills/post-to-x/scripts/post_x.py")')"
  if [[ ! -f "$skill" ]]; then
    skip "post-to-x skill is not installed on this machine"
  fi
}
teardown() { teardown_isolated_env; }

ANNOUNCE="$ROOT/scripts/announce-x-release.py"

@test "summary uses the version section and the release link" {
  run python3 "$ANNOUNCE" summary 0.3.0
  [ "$status" -eq 0 ]
  [[ "$output" == "gcpctx v0.3.0"* ]]
  [[ "$output" == *"https://github.com/UriBer/gcpctx/releases/tag/v0.3.0" ]]
  [[ "$output" == *"Security:"* ]]
  [[ "$output" == *"Features:"* ]]
  [[ "$output" == *"Packaging:"* ]]
  [[ "$output" != *"Project scan"* ]]
  [[ "$output" != *"Command history"* ]]
}

@test "summary keeps the post inside the X character limit" {
  cat >"$TEST_TMP/CHANGELOG.md" <<'EOF'
# Changelog

## 1.2.3

### Features
- alpha change that is deliberately long enough to consume a line by itself in the post
- beta change that is deliberately long enough to consume a line by itself in the post
- gamma change that is deliberately long enough to consume a line by itself in the post
- delta change that is deliberately long enough to consume a line by itself in the post
- epsilon change that is deliberately long enough to consume a line by itself in the post
- zeta change that is deliberately long enough to consume a line by itself in the post
- eta change that is deliberately long enough to consume a line by itself in the post
EOF
  run python3 "$ANNOUNCE" summary 1.2.3 --changelog "$TEST_TMP/CHANGELOG.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"alpha change"* ]]
  [[ "$output" != *"eta change"* ]]
  python3 - "$output" <<'PY'
import re, sys
text = sys.argv[1]
weighted = len(re.sub(r"https://\S+", lambda _m: "x" * 23, text))
if weighted > 280:
    raise SystemExit(f"weighted length {weighted}")
PY
}

@test "summary rejects an unknown version" {
  run python3 "$ANNOUNCE" summary 9.9.9
  [ "$status" -ne 0 ]
}
