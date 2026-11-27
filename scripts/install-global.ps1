# Windows PowerShell script to link arcus-stack skills globally across all 5 agents (including T3 Code provider sandboxes)
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SkillsSource = (Resolve-Path (Join-Path $RepoRoot "skills")).Path

# Explicit allowlist of agent skill folders; never auto-discover other tools' dot-directories.
$AgentSkillDirs = [System.Collections.Generic.List[string]]@(
    "$HOME\.agents\skills",
    "$HOME\.gemini\config\skills",
    "$HOME\.claude\skills",
    "$HOME\.codex\skills",
    "$HOME\.config\opencode\skills",
    "$HOME\.cursor\skills"
)

# T3 Code isolated Antigravity provider config directories
$T3AgyBase = "$HOME\.t3\userdata\providers\antigravity"
if (Test-Path $T3AgyBase) {
    Get-ChildItem -Path $T3AgyBase -Directory | ForEach-Object {
        $T3ConfigSkills = Join-Path $_.FullName "config\skills"
        if ($AgentSkillDirs -notcontains $T3ConfigSkills) {
            $AgentSkillDirs.Add($T3ConfigSkills)
        }
    }
}

# Only public arcus-* skill folders with a SKILL.md (skips tool state such as skills/.omc/)
$SkillFolders = @(Get-ChildItem -Path $SkillsSource -Directory -Filter "arcus-*" | Where-Object {
    Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md")
})
$ActiveSkillNames = @($SkillFolders | ForEach-Object { $_.Name })

function Get-LinkTarget($Item) {
    if ($null -eq $Item -or [string]::IsNullOrEmpty($Item.LinkType)) { return $null }
    return [string](@($Item.Target)[0])
}

function Test-LinksIntoRepo($Item) {
    $Target = Get-LinkTarget $Item
    if ($null -eq $Target) { return $false }
    $Normalized = $Target -replace '^\\\\\?\\', ''
    $Prefix = $SkillsSource.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    return $Normalized.StartsWith($Prefix, [StringComparison]::OrdinalIgnoreCase)
}

foreach ($TargetBase in $AgentSkillDirs) {
    if (-not (Test-Path $TargetBase)) {
        New-Item -ItemType Directory -Path $TargetBase -Force | Out-Null
    }

    # Prune stale arcus-* links that point into this repo's skills/ but whose skill was renamed or removed.
    # Real directories and links to anything else are left alone.
    Get-ChildItem -Path $TargetBase -Filter "arcus-*" -Force -ErrorAction SilentlyContinue | ForEach-Object {
        if (($ActiveSkillNames -notcontains $_.Name) -and (Test-LinksIntoRepo $_)) {
            $_.Delete()
            Write-Host "[PRUNED] Removed stale skill link $($_.FullName)"
        }
    }

    foreach ($Skill in $SkillFolders) {
        $Dest = Join-Path $TargetBase $Skill.Name
        $Existing = Get-Item -LiteralPath $Dest -Force -ErrorAction SilentlyContinue
        if ($null -ne $Existing) {
            if ($null -ne (Get-LinkTarget $Existing)) {
                $Existing.Delete()
            } elseif (Test-Path -LiteralPath (Join-Path $Dest "SKILL.md")) {
                # A copied install of this same skill (e.g. from npx skills); replace it with the live link.
                Remove-Item -LiteralPath $Dest -Recurse -Force
            } else {
                Write-Warning "Skipped $Dest because it is a directory without SKILL.md that this script did not create."
                continue
            }
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
            # BOM-less UTF-8: Windows PowerShell 5.1's Set-Content -Encoding UTF8 adds a BOM that breaks JSON.parse in npx skills
            $Json = $LockJson | ConvertTo-Json -Depth 10
            [IO.File]::WriteAllText($LockFile, $Json + "`n", (New-Object System.Text.UTF8Encoding($false)))
        }
    }
}

Write-Host "`nARCUS-STACK skills are now linked globally for agy (CLI + T3 Code), Claude Code, Codex, Cursor, and OpenCode!"
