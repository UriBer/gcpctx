# gcpctx PowerShell integration
#
# Prefer:
#   gcpctx shell-setup
# Or manually:
#   . (Join-Path ... 'shell\gcpctx.ps1')
#
# Requires Git Bash or WSL so the bash CLI (bin/gcpctx) can run.
# Provides:
#   - gcpctx function that applies --export env into $env:
#   - venv-style prompt prefix: (gcp:ctx:project)
#
# Disable prompt: $env:GCPCTX_DISABLE_PROMPT = '1'

$script:GcpctxPs1Dir = $PSScriptRoot

function Get-GcpctxBash {
    $candidates = @(
        'bash',
        'C:\Program Files\Git\bin\bash.exe',
        'C:\Program Files\Git\usr\bin\bash.exe',
        "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe",
        'wsl'
    )
    foreach ($c in $candidates) {
        if ($c -eq 'wsl') {
            if (Get-Command wsl -ErrorAction SilentlyContinue) { return @{ Kind = 'wsl'; Exe = 'wsl' } }
            continue
        }
        $cmd = Get-Command $c -ErrorAction SilentlyContinue
        if ($cmd) { return @{ Kind = 'bash'; Exe = $cmd.Source } }
        if (Test-Path -LiteralPath $c) { return @{ Kind = 'bash'; Exe = $c } }
    }
    return $null
}

function Get-GcpctxBin {
    if ($env:GCPCTX_BIN -and (Test-Path -LiteralPath $env:GCPCTX_BIN)) {
        return $env:GCPCTX_BIN
    }
    $sibling = Join-Path (Split-Path -Parent $script:GcpctxPs1Dir) 'bin\gcpctx'
    if (Test-Path -LiteralPath $sibling) { return $sibling }

    $cmd = Get-Command gcpctx.cmd -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $cmd = Get-Command gcpctx -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source -notmatch '\.ps1$') { return $cmd.Source }

    if ($env:APPDATA) {
        $npmBin = Join-Path $env:APPDATA 'npm\node_modules\gcpctx\bin\gcpctx'
        if (Test-Path -LiteralPath $npmBin) { return $npmBin }
    }
    return $null
}

function ConvertTo-UnixPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    $bash = Get-GcpctxBash
    if (-not $bash) { return $Path }
    if ($bash.Kind -eq 'wsl') {
        $out = & wsl wslpath -a $Path 2>$null
        if ($LASTEXITCODE -eq 0 -and $out) { return ($out | Select-Object -First 1).ToString().Trim() }
    }
    # Git Bash: C:\foo -> /c/foo
    if ($Path -match '^[A-Za-z]:\\') {
        $drive = $Path.Substring(0, 1).ToLower()
        $rest = $Path.Substring(2) -replace '\\', '/'
        return "/$drive$rest"
    }
    return ($Path -replace '\\', '/')
}

function Invoke-GcpctxBash {
    param([Parameter(Mandatory = $true)][string[]]$CliArgs)
    $bash = Get-GcpctxBash
    if (-not $bash) {
        throw "gcpctx: bash not found. Install Git Bash or WSL to use gcpctx from PowerShell."
    }
    $bin = Get-GcpctxBin
    if (-not $bin) {
        throw "gcpctx: CLI not found. Install with npm i -g gcpctx or set GCPCTX_BIN."
    }
    $unixBin = ConvertTo-UnixPath -Path $bin
    # Quote args for bash
    $quoted = @()
    foreach ($a in $CliArgs) {
        $escaped = $a -replace "'", "'\''"
        $quoted += "'$escaped'"
    }
    $argStr = [string]::Join(' ', $quoted)
    if ($bash.Kind -eq 'wsl') {
        $out = & wsl bash -lc "& '$unixBin' $argStr" 2>&1
    } else {
        $out = & $bash.Exe -lc "& '$unixBin' $argStr" 2>&1
    }
    return @{ ExitCode = $LASTEXITCODE; Output = ($out | Out-String) }
}

function Import-GcpctxExport {
    param([Parameter(Mandatory = $true)][string]$ExportText)
    foreach ($line in ($ExportText -split "`n")) {
        $line = $line.Trim()
        if ($line -match '^unset\s+([A-Za-z_][A-Za-z0-9_]*)\s*$') {
            Remove-Item -Path "Env:$($Matches[1])" -ErrorAction SilentlyContinue
            continue
        }
        if ($line -match '^export\s+([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
            $name = $Matches[1]
            $val = $Matches[2].Trim()
            # Strip surrounding single quotes from bash printf %q / simple quotes
            if ($val.StartsWith("'") -and $val.EndsWith("'") -and $val.Length -ge 2) {
                $val = $val.Substring(1, $val.Length - 2) -replace "'\\''", "'"
            }
            Set-Item -Path "Env:$name" -Value $val
        }
    }
}

function Get-GcpctxPromptSegment {
    if ($env:GCPCTX_DISABLE_PROMPT) { return '' }
    if (-not $env:GCPCTX_NAME) { return '' }
    $seg = "(gcp:$($env:GCPCTX_NAME)"
    if ($env:GOOGLE_CLOUD_PROJECT) {
        $seg += ":$($env:GOOGLE_CLOUD_PROJECT)"
    }
    $seg += ') '
    return $seg
}

function gcpctx_prompt {
    $seg = Get-GcpctxPromptSegment
    if ($seg) { return $seg.TrimEnd() }
    return ''
}

function gcpctx {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )
    if (-not $Args -or $Args.Count -eq 0) {
        $r = Invoke-GcpctxBash -CliArgs @('help')
        Write-Host $r.Output
        return
    }
    $cmd = $Args[0]
    $rest = @()
    if ($Args.Count -gt 1) { $rest = $Args[1..($Args.Count - 1)] }

    $needsExport = $false
    if ($cmd -in @('use', 'activate', 'deactivate', 'env')) {
        $needsExport = $true
    } elseif ($cmd -eq 'project') {
        if ($rest.Count -eq 0 -or $rest[0] -notin @('list', 'ls', 'scan')) {
            $needsExport = $true
        }
    }

    if ($needsExport) {
        $cli = @($cmd) + $rest + @('--export')
        $r = Invoke-GcpctxBash -CliArgs $cli
        if ($r.ExitCode -ne 0) {
            Write-Error $r.Output
            return
        }
        Import-GcpctxExport -ExportText $r.Output
        return
    }

    $r = Invoke-GcpctxBash -CliArgs $Args
    Write-Host $r.Output
    if ($r.ExitCode -ne 0) {
        $global:LASTEXITCODE = $r.ExitCode
    }
}

# --- prompt injection (venv-style) ---
if (-not $global:__GcpctxOriginalPrompt) {
    $cmd = Get-Command prompt -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.CommandType -eq 'Function') {
        $global:__GcpctxOriginalPrompt = $function:prompt
    } else {
        $global:__GcpctxOriginalPrompt = {
            "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
        }
    }
}

function prompt {
    $seg = Get-GcpctxPromptSegment
    $base = & $global:__GcpctxOriginalPrompt
    return "$seg$base"
}
