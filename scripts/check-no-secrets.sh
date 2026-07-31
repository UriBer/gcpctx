#!/usr/bin/env bash
# Fail if the npm pack tarball contains secrets or unexpected paths.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/gcpctx-packcheck.XXXXXX")"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

echo "gcpctx pack:check — packing…"
TARBALL="$(npm pack --silent)"
mv "$TARBALL" "$TMPDIR/"
tar -xzf "$TMPDIR/$TARBALL" -C "$TMPDIR"

PKG="$TMPDIR/package"
echo "gcpctx pack:check — listing contents:"
find "$PKG" -type f | sed "s|^$TMPDIR/||" | sort

hits=0

# Only allowlisted paths may exist
while IFS= read -r f; do
  rel="${f#"$PKG"/}"
  case "$rel" in
    bin/*|lib/*|shell/*|completions/*|README.md|LICENSE|SECURITY.md|CHANGELOG.md|VERSION|package.json) ;;
    *)
      echo "ERROR: unexpected path in tarball: $rel" >&2
      hits=$((hits + 1))
      ;;
  esac
done < <(find "$PKG" -type f)

# Credential-looking filenames must not appear (ADC files, keys, etc.)
while IFS= read -r f; do
  echo "ERROR: credential-like filename in tarball: ${f#"$TMPDIR"/}" >&2
  hits=$((hits + 1))
done < <(find "$PKG" \( \
  -iname 'credentials.json' -o \
  -iname 'application_default_credentials.json' -o \
  -iname '*token*.json' -o \
  -iname '*.pem' -o \
  -iname '*.key' -o \
  -iname '*.p12' \
\))

# JSON secret field assignments (not mere deny-list string mentions in source)
if grep -RInE --include='*' \
  -e '"refresh_token"[[:space:]]*:' \
  -e '"client_secret"[[:space:]]*:' \
  -e '"private_key"[[:space:]]*:' \
  -e '"private_key_id"[[:space:]]*:' \
  "$PKG" >/dev/null 2>&1; then
  echo "ERROR: credential JSON field assignment found in tarball:" >&2
  grep -RInE --include='*' \
    -e '"refresh_token"[[:space:]]*:' \
    -e '"client_secret"[[:space:]]*:' \
    -e '"private_key"[[:space:]]*:' \
    -e '"private_key_id"[[:space:]]*:' \
    "$PKG" >&2 || true
  hits=$((hits + 1))
fi

# PEM blocks
if grep -RInE --include='*' -e 'BEGIN (RSA )?PRIVATE KEY' "$PKG" >/dev/null 2>&1; then
  echo "ERROR: private key PEM block found in tarball" >&2
  hits=$((hits + 1))
fi

# Accidental home-store path material
if grep -RInE --include='*' -e '\.gcpctx/contexts/.*/credentials' "$PKG" >/dev/null 2>&1; then
  echo "ERROR: packed reference looks like a real credentials path under .gcpctx/contexts" >&2
  hits=$((hits + 1))
fi

if [[ "$hits" -gt 0 ]]; then
  echo "FAIL: $hits secret/pack issue(s)" >&2
  exit 1
fi

echo "OK: pack contains no secrets; allowlist only"
