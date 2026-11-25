# Windows PowerShell script to link arcus-stack skills globally across all 5 agents (including T3 Code provider sandboxes)
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SkillsSource = Join-Path $RepoRoot "skills"

$AgentSkillDirs = [System.Collections.Generic.List[string]]@(
    "$HOME\.agents\skills",
    "$HOME\.gemini\config\skills",
    "$HOME\.claude\skills",
    "$HOME\.codex\skills",
    "$HOME\.config\opencode\skills",
    "$HOME\.cursor\skills"
)

# Auto-detect any other dot-directories with a skills/ folder created by npx skills
Get-ChildItem -Path $HOME -Filter ".*" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $CandidateSkills = Join-Path $_.FullName "skills"
    if ((Test-Path $CandidateSkills) -and ($AgentSkillDirs -notcontains $CandidateSkills)) {
        $AgentSkillDirs.Add($CandidateSkills)
    }
}

# Auto-detect T3 Code isolated Antigravity provider config directories
$T3AgyBase = "$HOME\.t3\userdata\providers\antigravity"
if (Test-Path $T3AgyBase) {
    Get-ChildItem -Path $T3AgyBase -Directory | ForEach-Object {
        $T3ConfigSkills = Join-Path $_.FullName "config\skills"
        $AgentSkillDirs.Add($T3ConfigSkills)
    }
}

$SkillFolders = Get-ChildItem -Path $SkillsSource -Directory
$ActiveSkillNames = $SkillFolders | ForEach-Object { $_.Name }

foreach ($TargetBase in $AgentSkillDirs) {
    if (-not (Test-Path $TargetBase)) {
        New-Item -ItemType Directory -Path $TargetBase -Force | Out-Null
    }

    # Prune stale arcus-* skill links that were renamed or removed from skills/
    Get-ChildItem -Path $TargetBase -Filter "arcus-*" -Force -ErrorAction SilentlyContinue | ForEach-Object {
        if ($ActiveSkillNames -notcontains $_.Name) {
            Remove-Item -Path $_.FullName -Recurse -Force
            Write-Host "[PRUNED] Removed stale skill link $($_.FullName)"
        }
    }

    foreach ($Skill in $SkillFolders) {
        $Dest = Join-Path $TargetBase $Skill.Name
        if (Test-Path $Dest) {
            Remove-Item -Path $Dest -Recurse -Force
        }
        New-Item -ItemType Junction -Path $Dest -Target $Skill.FullName | Out-Null
        Write-Host "[OK] Linked $($Skill.Name) -> $Dest"
    }
}

# Clean stale arcus-* entries from ~/.agents/.skill-lock.json if present
$LockFile = "$HOME\.agents\.skill-lock.json"
if (Test-Path $LockFile) {
    $LockJson = Get-Content $LockFile -Raw | ConvertFrom-Json
    if ($null -ne $LockJson.skills) {
        $RemovedFromLock = $false
        $Props = @($LockJson.skills.PSObject.Properties | Where-Object { $_.Name -like "arcus-*" })
        foreach ($Prop in $Props) {
            if ($ActiveSkillNames -notcontains $Prop.Name) {
                $LockJson.skills.PSObject.Properties.Remove($Prop.Name)
                $RemovedFromLock = $true
                Write-Host "[PRUNED] Removed stale '$($Prop.Name)' from $LockFile"
            }
        }
        if ($RemovedFromLock) {
            $LockJson | ConvertTo-Json -Depth 10 | Set-Content -Path $LockFile -Encoding UTF8
        }
    }
}

Write-Host "`nARCUS-STACK skills are now linked globally for agy (CLI + T3 Code), Claude Code, Codex, Cursor, and OpenCode!"
