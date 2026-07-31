# Architecture decision: distribution runtime

## Status

Accepted (2026-07-31)

## Context

gcpctx is a Bash CLI with shell integrations. Users asked for npm/Homebrew/Scoop/WinGet.

## Decision

Continue distributing **transparent Bash source** via npm and GitHub release archives. Provide PowerShell as a thin wrapper that invokes Bash (Git Bash/WSL). Do **not** rewrite in Go in this release.

## Consequences

- Portable where Bash exists
- Windows requires Git Bash/WSL (documented)
- WinGet native packaging deferred
- Easier auditability of credential handling
