# Windows

gcpctx is a **Bash** CLI.

Supported:

- Git Bash
- WSL
- PowerShell wrapper (`shell/gcpctx.ps1`) that calls Bash

Unsupported:

- cmd.exe

```powershell
npm install -g gcpctx
# Ensure Git Bash `bash.exe` is on PATH
. "$(npm root -g)/gcpctx/shell/gcpctx.ps1"
gcpctx use dev
```
