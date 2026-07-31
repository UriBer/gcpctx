# WinGet

## Status: Blocked (documented)

`gcpctx` is implemented in Bash. A WinGet package that claims native Windows execution would be misleading.

### Prerequisites for a future WinGet package

1. A Windows entrypoint that clearly requires Git Bash or WSL
2. Automated Windows CI covering that entrypoint
3. Installer that does not silently depend on undocumented Bash

Until then, Windows users should:

```text
npm install -g gcpctx
# with Git Bash or WSL on PATH
gcpctx shell-setup --bash
# or from PowerShell after Git Bash is installed:
. (Join-Path (npm root -g) 'gcpctx\shell\gcpctx.ps1')
```

Do not publish WinGet manifests that imply a native Win32 binary.
