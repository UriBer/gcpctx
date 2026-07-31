# gcpctx repository assessment

Date: 2026-07-31  
Branch: `release/production-hardening`  
Scope: pre-public-release hardening. No real credential contents inspected or recorded.

## Current architecture

```text
bin/gcpctx          # monolithic Bash CLI (~1400 LOC)
shell/gcpctx.zsh    # zsh wrapper + chpwd + prompt
shell/gcpctx.bash   # bash wrapper + cd hooks + prompt
shell/gcpctx.ps1    # PowerShell wrapper (invokes bash CLI) + prompt
install.sh          # symlink + shell-setup
scripts/check-no-secrets.sh
package.json        # npm bin package
~/.gcpctx/          # runtime store (contexts, credentials, tmp)
```

Activation sets env vars and syncs well-known ADC. Shell wrappers `eval` `--export` output.

## Supported commands (observed)

`init`, `login`, `use`, `project`, `scan`, `projects`, `activate`, `deactivate`, `list`, `current`, `env`, `exec`, `doctor`, `secrets fix`, `bootstrap`, `sync-adc`, `shell-setup`, `shell-path`, `which`, `version`, `help`.

## Credential lifecycle

1. `login` → `gcloud auth application-default login` → copy ADC into `~/.gcpctx/contexts/<name>/credentials.json` (mode 600)
2. `use`/`activate`/`project` → patch `quota_project_id`, sync to well-known ADC, export env paths
3. SDKs read `GOOGLE_APPLICATION_CREDENTIALS` path (not printed contents)

## Trust boundaries

| Boundary | Notes |
|----------|-------|
| Local filesystem `~/.gcpctx` | Trusted store |
| Repo `.gcpctx` marker | Untrusted JSON/name pointer |
| `gcloud` CLI | External; assumed available |
| Shell `eval` of exports | Critical trust boundary |
| npm package contents | Must never include credentials |
| PowerShell → bash bridge | Additional quoting surface |

## Findings

### Critical

| ID | Finding |
|----|---------|
| C1 | Shell wrappers `eval` CLI stdout; any stdout leak (gcloud “Updated property”) or unsafe quoting becomes RCE in user shell |
| C2 | `print_exports` / side-effect commands may emit gcloud chatter on stdout before/with exports when not carefully redirected |
| C3 | No automated tests; security claims unproven |

### High

| ID | Finding |
|----|---------|
| H1 | `package.json` `license: UNLICENSED` conflicts with intent to open-source; LICENSE is proprietary text |
| H2 | `"os": ["darwin","linux"]` excludes Windows while README advertises PowerShell |
| H3 | Version duplicated (`package.json` + `VERSION=` in `bin/gcpctx`) |
| H4 | Context/project/account inputs lack strict allowlist validation (injection risk via names) |
| H5 | Marker `.gcpctx` parsing is JSON but not schema-validated against unexpected fields/code |
| H6 | Filesystem writes are not uniformly atomic; limited symlink defenses |
| H7 | PowerShell parses Bash `export` lines — fragile vs structured JSON |
| H8 | ADC JSON patched with `account`/`quota_project_id` for all types — may be unsafe for SA/external-account |

### Medium

| ID | Finding |
|----|---------|
| M1 | No CI, ShellCheck, CodeQL, Scorecard, SBOM, provenance |
| M2 | No Homebrew/Scoop/WinGet manifests |
| M3 | No completions, assert/protect policies, `doctor --json` |
| M4 | `set -eo pipefail` without `-u` (bash 3.2 macOS compatibility) |
| M5 | Doctor permission checks Unix-centric |
| M6 | install.sh mutates shell profiles without backup/dry-run |

### Low

| ID | Finding |
|----|---------|
| L1 | Monolithic `bin/gcpctx` hard to test incrementally |
| L2 | Launch/docs/site absent |
| L3 | Comparison/threat-model docs absent |

## Portability

- Native: macOS/Linux Bash (+ zsh hooks)
- Windows: PowerShell wrapper requires Git Bash/WSL; CMD unsupported
- npm `os` field currently blocks Windows install

## Distribution gaps

npm only (unpublished / login blocked historically). No GitHub Release automation, Homebrew tap formula, Scoop, or WinGet.

## Documentation inconsistencies

- Proprietary LICENSE vs public npm packaging narrative
- Windows claims vs npm `os` exclude
- Security invariants described in README without test evidence

## Test gaps

No unit/integration/security suite; no fake `gcloud`; no isolated `HOME`/`GCPCTX_HOME` harness.

## Release blockers

1. License clarity (Apache-2.0 chosen for public release)
2. Automated tests + CI
3. Safe export encoding + injection tests
4. Platform claims matching reality
5. Pack/secret gates + provenance path
6. Version single source of truth

## Decision for this hardening pass

- Prefer **allow Windows npm install** + document Git Bash/WSL + PowerShell wrapper (preferred strategy)
- Incremental `lib/` modules for validation/exports/filesystem/version rather than full rewrite
- Fake fixtures only; never touch real `~/.gcpctx` or ADC in tests
