# Regression test for scripts/install-global.ps1. Runs the installer from a throwaway repo copy against a
# throwaway home directory (USERPROFILE override), under the current PowerShell, and checks every invariant.
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Shell = (Get-Process -Id $PID).Path
$Work = Join-Path ([IO.Path]::GetTempPath()) ("arcus-install-" + [guid]::NewGuid().ToString("N"))
$Copy = Join-Path $Work "repo"
$FakeHome = Join-Path $Work "home"
$Failed = 0

function Assert-That([string]$Name, [bool]$Condition) {
    if ($Condition) { Write-Host "[PASS] $Name" } else { Write-Host "[FAIL] $Name" -ForegroundColor Red; $script:Failed++ }
}

try {
    Push-Location $RepoRoot
    foreach ($Rel in (git ls-files)) {
        $Dest = Join-Path $Copy $Rel
        New-Item -ItemType Directory -Path (Split-Path -Parent $Dest) -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $RepoRoot $Rel) -Destination $Dest
    }
    Pop-Location
    $CopySkills = Join-Path $Copy "skills"
    New-Item -ItemType Directory -Path (Join-Path $CopySkills ".omc\state") -Force | Out-Null

    $Claude = Join-Path $FakeHome ".claude\skills"
    $Agents = Join-Path $FakeHome ".agents\skills"
    $Hermes = Join-Path $FakeHome ".hermes\skills"
    New-Item -ItemType Directory -Path $Claude, $Agents, $Hermes -Force | Out-Null

    $UserDir = Join-Path $Claude "arcus-old"
    New-Item -ItemType Directory -Path $UserDir | Out-Null
    Set-Content -LiteralPath (Join-Path $UserDir "notes.txt") -Value "user data"

    $GoneSource = Join-Path $CopySkills "arcus-gone"
    New-Item -ItemType Directory -Path $GoneSource | Out-Null
    New-Item -ItemType Junction -Path (Join-Path $Claude "arcus-gone") -Target $GoneSource | Out-Null
    Remove-Item -LiteralPath $GoneSource -Recurse -Force

    $CopiedInstall = Join-Path $Agents "arcus-plan"
    New-Item -ItemType Directory -Path $CopiedInstall | Out-Null
    Set-Content -LiteralPath (Join-Path $CopiedInstall "SKILL.md") -Value "---`nname: arcus-plan`n---"

    $LockFile = Join-Path $FakeHome ".agents\.skill-lock.json"
    [IO.File]::WriteAllText($LockFile, '{"version":3,"skills":{"arcus-plan":{"source":"x"},"arcus-gone":{"source":"x"},"other":{"source":"y"}}}')

    $SavedProfile = $env:USERPROFILE
    $env:USERPROFILE = $FakeHome
    try {
        & $Shell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Copy "scripts\install-global.ps1") *> (Join-Path $Work "install.log")
        $ExitCode = $LASTEXITCODE
    } finally {
        $env:USERPROFILE = $SavedProfile
    }
    Assert-That "installer exits 0" ($ExitCode -eq 0)

    $Bases = @(".agents\skills", ".gemini\config\skills", ".claude\skills", ".codex\skills", ".config\opencode\skills", ".cursor\skills")
    foreach ($Base in $Bases) {
        $Links = @(Get-ChildItem -LiteralPath (Join-Path $FakeHome $Base) -Force | Where-Object {
            $_.LinkType -and ([string](@($_.Target)[0])).StartsWith($CopySkills, [StringComparison]::OrdinalIgnoreCase)
        })
        Assert-That "$Base has 15 links into the repo" ($Links.Count -eq 15)
    }
    $OmcLinks = @(Get-ChildItem -Path $FakeHome -Recurse -Force -Directory -Filter ".omc" -ErrorAction SilentlyContinue)
    Assert-That "no .omc tool-state link created" ($OmcLinks.Count -eq 0)
    Assert-That "non-allowlisted ~/.hermes/skills untouched" (@(Get-ChildItem -LiteralPath $Hermes -Force).Count -eq 0)
    $UserNote = Join-Path $UserDir "notes.txt"
    Assert-That "user's real arcus-old directory kept" ((Test-Path -LiteralPath $UserNote) -and ((Get-Content -LiteralPath $UserNote -Raw).Trim() -eq "user data"))
    Assert-That "stale arcus-gone link into the repo pruned" (-not (Test-Path -LiteralPath (Join-Path $Claude "arcus-gone")))
    $PlanItem = Get-Item -LiteralPath $CopiedInstall -Force
    Assert-That "copied arcus-plan install replaced by a link" ([bool]$PlanItem.LinkType)

    $Bytes = [IO.File]::ReadAllBytes($LockFile)
    Assert-That "lock file has no UTF-8 BOM" (-not ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF))
    $Parsed = node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(Object.keys(d.skills).sort().join(','))" $LockFile
    Assert-That "lock file parses with JSON.parse and keeps only live entries ($Parsed)" ($LASTEXITCODE -eq 0 -and $Parsed -eq "arcus-plan,other")
} finally {
    if (Test-Path $Work) {
        Get-ChildItem -Path $FakeHome -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.LinkType } | ForEach-Object { $_.Delete() }
        Remove-Item -LiteralPath $Work -Recurse -Force
    }
}

if ($Failed -gt 0) {
    Write-Host "`n$Failed install-global.ps1 check(s) failed." -ForegroundColor Red
    exit 1
}
Write-Host "`nAll install-global.ps1 checks passed."
exit 0
