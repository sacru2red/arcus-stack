# Official ARCUS-STACK Repository Validation Script
# Enforces D-001 (Universal Frontmatter & Relative Links), D-002/D-009/D-012 (15 Public Core Skills), and D-003 (Zero Cursor/pstack Lock-in)
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SkillsRoot = Join-Path $RepoRoot "skills"
$Failures = [System.Collections.Generic.List[string]]::new()

Write-Host "=== ARCUS-STACK Validation Suite ==="

# 1. YAML Frontmatter Check (Strictly name & description in leading frontmatter block across skills/**/*.md)
$SkillMarkdownFiles = Get-ChildItem -Path $SkillsRoot -Filter "*.md" -Recurse
$FrontmatterChecked = 0

foreach ($File in $SkillMarkdownFiles) {
    $Raw = Get-Content -LiteralPath $File.FullName -Raw
    $FmMatch = [regex]::Match($Raw, '\A---\r?\n([\s\S]*?)\r?\n---')
    if ($FmMatch.Success) {
        $FrontmatterChecked++
        $FmBody = $FmMatch.Groups[1].Value
        $KeyMatches = [regex]::Matches($FmBody, '(?m)^([a-zA-Z0-9_-]+)\s*:')
        foreach ($Km in $KeyMatches) {
            $KeyName = $Km.Groups[1].Value
            if ($KeyName -notin @('name', 'description')) {
                $Failures.Add("[Frontmatter] Forbidden key '$KeyName' in $($File.FullName)")
            }
        }
    } elseif ($File.Name -eq "SKILL.md") {
        $Failures.Add("[Frontmatter] Missing YAML frontmatter in $($File.FullName)")
    }
}
Write-Host "[1/4] Checked YAML frontmatter in $FrontmatterChecked skill markdown files."

# 2. Relative Markdown Link Resolution Check (Stripping fenced & inline code spans first)
$AllMarkdownFiles = Get-ChildItem -Path $RepoRoot -Filter "*.md" -Recurse | Where-Object {
    $_.FullName -notmatch '[\\/]\.git[\\/]'
}
$LinksChecked = 0

foreach ($File in $AllMarkdownFiles) {
    $Raw = Get-Content -LiteralPath $File.FullName -Raw
    # Strip fenced code blocks and inline code spans to prevent false positives on example links
    $Stripped = [regex]::Replace($Raw, '(?s)```.*?```', '')
    $Stripped = [regex]::Replace($Stripped, '`[^`\r\n]+`', '')

    $LinkMatches = [regex]::Matches($Stripped, '\[[^\]]+\]\(([^)]+)\)')
    foreach ($Lm in $LinkMatches) {
        $Target = $Lm.Groups[1].Value.Trim()
        if ($Target -match '^(https?|mailto|file|conversation):' -or $Target.StartsWith('#')) {
            continue
        }
        $CleanTarget = ($Target -split '#')[0].Trim()
        if ([string]::IsNullOrWhiteSpace($CleanTarget)) {
            continue
        }
        $LinksChecked++
        $ResolvedPath = Join-Path $File.DirectoryName $CleanTarget
        if (-not (Test-Path -LiteralPath $ResolvedPath)) {
            $Failures.Add("[Broken Link] '$Target' in $($File.FullName) -> does not exist at $ResolvedPath")
        }
    }
}
Write-Host "[2/4] Checked $LinksChecked relative Markdown links across $($AllMarkdownFiles.Count) files."

# 3. Forbidden Unadapted pstack/Cursor Dependency Check in skills/
$ForbiddenPattern = "disable-model-invocation|arcus-in-your-own-words|comment-sicko|decision-log-template\.tsv|scripts/log\.sh|watch-pr/watch-pr|worktree-audit\.sh|pstack-models\.mdc|cursor-team-kit|/deslop|control-ui|control-cli|(?<!make a )control skill|create-skill|/loop\b|claude-opus-5-5-|claude-fable-5-2|gemini-4-neon-xhigh|poteto-mode|poteto-agent|subagent_type|generalPurpose|environment:\s*`"(cloud|local)`"|Cursor cloud agent|Cursor's|~/.cursor/projects|\.cursor/worktrees|\*\*(ketchup|why|in-your-own-words|explain)\*\*"
$ForbiddenHits = @($SkillMarkdownFiles | Select-String -Pattern $ForbiddenPattern)
foreach ($Hit in $ForbiddenHits) {
    $Failures.Add("[Forbidden Dependency] $($Hit.Path):$($Hit.LineNumber): $($Hit.Line.Trim())")
}
Write-Host "[3/4] Checked $($SkillMarkdownFiles.Count) skill files for unadapted Cursor/pstack dependencies (Hits: $($ForbiddenHits.Count))."

# 4. Two-Tier Public Skill Count & .agents/skills.json Parity Check
$TopLevelSkills = @(Get-ChildItem -Path $SkillsRoot -Directory | Sort-Object Name)
if ($TopLevelSkills.Count -ne 15) {
    $Failures.Add("[Skill Count] Expected 15 public core skills under skills/, found $($TopLevelSkills.Count)")
}
foreach ($Dir in $TopLevelSkills) {
    $EntryFile = Join-Path $Dir.FullName "SKILL.md"
    if (-not (Test-Path -LiteralPath $EntryFile)) {
        $Failures.Add("[Skill Entry] Missing SKILL.md in $($Dir.FullName)")
    }
}

$SkillsJsonPath = Join-Path $RepoRoot ".agents\skills.json"
if (-not (Test-Path -LiteralPath $SkillsJsonPath)) {
    $Failures.Add("[Manifest] Missing .agents/skills.json")
} else {
    $SkillsJson = Get-Content -LiteralPath $SkillsJsonPath -Raw | ConvertFrom-Json
    $EntryPaths = @($SkillsJson.entries | ForEach-Object { $_.path })
    if ($EntryPaths -notcontains "skills") {
        $Failures.Add("[Manifest Parity] .agents/skills.json entries ($($EntryPaths -join ', ')) must include 'skills'")
    }
}
Write-Host "[4/4] Verified $($TopLevelSkills.Count) public core skills and .agents/skills.json parity."

if ($Failures.Count -gt 0) {
    Write-Host "`nVALIDATION FAILED ($($Failures.Count) issues):" -ForegroundColor Red
    foreach ($F in $Failures) {
        Write-Host "  - $F" -ForegroundColor Red
    }
    exit 1
}

Write-Host "`nALL CHECKS PASSED (0 errors)." -ForegroundColor Green
exit 0
