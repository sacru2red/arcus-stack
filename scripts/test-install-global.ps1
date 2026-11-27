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

function Invoke-Installer([string]$Log) {
    $SavedProfile = $env:USERPROFILE
    $env:USERPROFILE = $FakeHome
    try {
        & $Shell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Copy "scripts\install-global.ps1") *> (Join-Path $Work $Log)
        return $LASTEXITCODE
    } finally {
        $env:USERPROFILE = $SavedProfile
    }
}

function Test-IsRepoLink([string]$Path) {
    $Item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    return ($null -ne $Item -and $Item.LinkType -and ([string](@($Item.Target)[0])).StartsWith($CopySkills, [StringComparison]::OrdinalIgnoreCase))
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
    $Codex = Join-Path $FakeHome ".codex\skills"
    $Cursor = Join-Path $FakeHome ".cursor\skills"
    $Gemini = Join-Path $FakeHome ".gemini\config\skills"
    $OpenCode = Join-Path $FakeHome ".config\opencode\skills"
    $Hermes = Join-Path $FakeHome ".hermes\skills"
    New-Item -ItemType Directory -Path $Claude, $Agents, $Codex, $Cursor, $Gemini, $Hermes, (Split-Path -Parent $OpenCode) -Force | Out-Null

    $UserDir = Join-Path $Claude "arcus-old"
    New-Item -ItemType Directory -Path $UserDir | Out-Null
    Set-Content -LiteralPath (Join-Path $UserDir "notes.txt") -Value "user data"

    $GoneSource = Join-Path $CopySkills "arcus-gone"
    New-Item -ItemType Directory -Path $GoneSource | Out-Null
    New-Item -ItemType Junction -Path (Join-Path $Claude "arcus-gone") -Target $GoneSource | Out-Null
    Remove-Item -LiteralPath $GoneSource -Recurse -Force

    # A user-modified copy, an unmodified copy, a copy with an extra hidden file, and a copy with an extra empty folder.
    $ModifiedCopy = Join-Path $Agents "arcus-plan"
    New-Item -ItemType Directory -Path $ModifiedCopy | Out-Null
    Set-Content -LiteralPath (Join-Path $ModifiedCopy "SKILL.md") -Value "---`nname: arcus-plan`n---`nuser edit"
    Copy-Item -LiteralPath (Join-Path $CopySkills "arcus-why") -Destination (Join-Path $Codex "arcus-why") -Recurse
    Copy-Item -LiteralPath (Join-Path $CopySkills "arcus-ketchup") -Destination (Join-Path $Cursor "arcus-ketchup") -Recurse
    $HiddenFile = Join-Path $Cursor "arcus-ketchup\.user-notes"
    Set-Content -LiteralPath $HiddenFile -Value "hidden user note"
    (Get-Item -LiteralPath $HiddenFile -Force).Attributes = "Hidden"
    Copy-Item -LiteralPath (Join-Path $CopySkills "arcus-correct") -Destination (Join-Path $Gemini "arcus-correct") -Recurse
    New-Item -ItemType Directory -Path (Join-Path $Gemini "arcus-correct\extra") | Out-Null

    # An agent skills folder that is itself a link to the repo's skills/ must never lose the repo's files.
    New-Item -ItemType Junction -Path $OpenCode -Target $CopySkills | Out-Null
    $RepoSkillFiles = @(Get-ChildItem -LiteralPath $CopySkills -Recurse -File -Force).Count

    $LockFile = Join-Path $FakeHome ".agents\.skill-lock.json"
    [IO.File]::WriteAllText($LockFile, '{"version":3,"skills":{"arcus-plan":{"source":"x"},"arcus-gone":{"source":"x"},"other":{"source":"y"}}}')

    Assert-That "installer exits 0" ((Invoke-Installer "install.log") -eq 0)

    foreach ($Base in @(".agents\skills", ".gemini\config\skills", ".claude\skills", ".codex\skills", ".cursor\skills")) {
        $Links = @(Get-ChildItem -LiteralPath (Join-Path $FakeHome $Base) -Force | Where-Object { Test-IsRepoLink $_.FullName })
        Assert-That "$Base has 15 links into the repo" ($Links.Count -eq 15)
        Assert-That "$Base has no .omc tool-state link" (-not (Test-Path -LiteralPath (Join-Path (Join-Path $FakeHome $Base) ".omc")))
    }
    Assert-That "non-allowlisted ~/.hermes/skills untouched" (@(Get-ChildItem -LiteralPath $Hermes -Force).Count -eq 0)
    $UserNote = Join-Path $UserDir "notes.txt"
    Assert-That "user's real arcus-old directory kept" ((Test-Path -LiteralPath $UserNote) -and ((Get-Content -LiteralPath $UserNote -Raw).Trim() -eq "user data"))
    Assert-That "stale arcus-gone link into the repo pruned" (-not (Test-Path -LiteralPath (Join-Path $Claude "arcus-gone")))

    Assert-That "agent folder linked to the repo's skills/ keeps every repo file" (@(Get-ChildItem -LiteralPath $CopySkills -Recurse -File -Force).Count -eq $RepoSkillFiles)
    Assert-That "agent folder linked to the repo's skills/ is skipped with a warning" ((Get-Content -LiteralPath (Join-Path $Work "install.log") -Raw) -match "this repo's own skills/arcus-why")

    $BackupRoot = Join-Path $FakeHome ".arcus-stack-backups"
    $Runs = @(Get-ChildItem -LiteralPath $BackupRoot -Directory -Force -ErrorAction SilentlyContinue)
    Assert-That "one backup folder for the run" ($Runs.Count -eq 1)
    $Run = if ($Runs.Count -gt 0) { $Runs[0].FullName } else { Join-Path $BackupRoot "missing" }
    Assert-That "unmodified copy (codex arcus-why) replaced by a link" (Test-IsRepoLink (Join-Path $Codex "arcus-why"))
    Assert-That "unmodified copy (codex arcus-why) not backed up" (-not (Test-Path -LiteralPath (Join-Path $Run ".codex_skills")))
    Assert-That "modified copy (agents arcus-plan) replaced by a link" (Test-IsRepoLink $ModifiedCopy)
    $PlanBackup = Join-Path $Run ".agents_skills\arcus-plan\SKILL.md"
    Assert-That "modified copy (agents arcus-plan) backed up with the user's edit" ((Test-Path -LiteralPath $PlanBackup) -and ((Get-Content -LiteralPath $PlanBackup -Raw) -match "user edit"))
    Assert-That "copy with an extra hidden file (cursor arcus-ketchup) replaced by a link" (Test-IsRepoLink (Join-Path $Cursor "arcus-ketchup"))
    Assert-That "copy with an extra hidden file backed up with that file" (Test-Path -LiteralPath (Join-Path $Run ".cursor_skills\arcus-ketchup\.user-notes"))
    Assert-That "copy with an extra empty folder (gemini arcus-correct) replaced by a link" (Test-IsRepoLink (Join-Path $Gemini "arcus-correct"))
    Assert-That "copy with an extra empty folder backed up with that folder" (Test-Path -LiteralPath (Join-Path $Run ".gemini_config_skills\arcus-correct\extra"))
    $ScanBases = @($Claude, $Agents, $Codex, $Cursor, $Gemini, $OpenCode)
    Assert-That "backups live outside every agent skills folder" (@($ScanBases | Where-Object { $BackupRoot.StartsWith($_, [StringComparison]::OrdinalIgnoreCase) }).Count -eq 0)

    Assert-That "second run exits 0" ((Invoke-Installer "install-2.log") -eq 0)
    Assert-That "second run makes no new backup" (@(Get-ChildItem -LiteralPath $BackupRoot -Directory -Force -ErrorAction SilentlyContinue).Count -eq 1)

    $Bytes = [IO.File]::ReadAllBytes($LockFile)
    Assert-That "lock file has no UTF-8 BOM" (-not ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF))
    $Parsed = node -e "const d=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log(Object.keys(d.skills).sort().join(','))" $LockFile
    Assert-That "lock file parses with JSON.parse and keeps only live entries ($Parsed)" ($LASTEXITCODE -eq 0 -and $Parsed -eq "arcus-plan,other")
} finally {
    if (Test-Path $Work) {
        # Delete links first so recursive removal never walks through a junction into the repo copy.
        Get-ChildItem -Path $FakeHome -Recurse -Force -Attributes ReparsePoint -ErrorAction SilentlyContinue | ForEach-Object { $_.Delete() }
        Remove-Item -LiteralPath $Work -Recurse -Force
    }
}

if ($Failed -gt 0) {
    Write-Host "`n$Failed install-global.ps1 check(s) failed." -ForegroundColor Red
    exit 1
}
Write-Host "`nAll install-global.ps1 checks passed."
exit 0
