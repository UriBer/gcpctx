#!/usr/bin/env bash
# Build release archives under dist/
set -eo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
VER="$(tr -d '[:space:]' < VERSION)"
STAGE="dist/stage/gcpctx-$VER"
rm -rf dist
mkdir -p "$STAGE"
cp -R bin lib shell VERSION LICENSE README.md SECURITY.md CHANGELOG.md "$STAGE/" 2>/dev/null || true
cp -R completions "$STAGE/" 2>/dev/null || true
mkdir -p dist
tar -C dist/stage -czf "dist/gcpctx-$VER.tar.gz" "gcpctx-$VER"
(cd dist/stage && zip -qr "../gcpctx-$VER.zip" "gcpctx-$VER")
(
  cd dist
  shasum -a 256 "gcpctx-$VER.tar.gz" "gcpctx-$VER.zip" > checksums.txt
)
# Minimal SPDX-ish SBOM
python3 - <<PY
import json, hashlib, pathlib
ver = open("VERSION").read().strip()
files = []
for p in pathlib.Path("dist").glob("gcpctx-*"):
    if p.suffix in (".gz",) or p.name.endswith(".tar.gz") or p.suffix == ".zip":
        h = hashlib.sha256(p.read_bytes()).hexdigest()
        files.append({"name": p.name, "sha256": h})
doc = {
  "spdxVersion": "SPDX-2.3",
  "name": f"gcpctx-{ver}",
  "packages": [{"name": "gcpctx", "versionInfo": ver, "licenseConcluded": "Apache-2.0"}],
  "files": files,
}
pathlib.Path("dist/sbom.spdx.json").write_text(json.dumps(doc, indent=2) + "\n")
print("wrote dist/ artifacts")
PY
