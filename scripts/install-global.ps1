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

Write-Host "`nARCUS-STACK skills are now linked globally for agy (CLI + T3 Code), Claude Code, Codex, Cursor, and OpenCode!"
