# Official ARCUS-STACK Repository Validation Script
# Enforces D-001 (Universal Frontmatter & Relative Links), D-002/D-009/D-012 (15 Public Core Skills), D-003 (Zero Cursor/pstack Lock-in), and D-014 (Per-Skill Third-Party Notices)
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$SkillsRoot = Join-Path $RepoRoot "skills"
$Failures = [System.Collections.Generic.List[string]]::new()

Write-Host "=== ARCUS-STACK Validation Suite ==="

# 1. YAML Frontmatter Check (Strictly name & description in leading frontmatter block across skills/**/*.md)
$IgnoredPathPattern = '[\\/](\.git|\.omc|\.audit|node_modules)[\\/]'
$SkillMarkdownFiles = Get-ChildItem -Path $SkillsRoot -Filter "*.md" -Recurse | Where-Object { $_.FullName -notmatch $IgnoredPathPattern }
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
Write-Host "[1/6] Checked YAML frontmatter in $FrontmatterChecked skill markdown files."

# 2. Relative Markdown Link Resolution Check (Stripping fenced blocks, masking inline code spans)
$AllMarkdownFiles = Get-ChildItem -Path $RepoRoot -Filter "*.md" -Recurse | Where-Object {
    $_.FullName -notmatch $IgnoredPathPattern
}
$LinksChecked = 0

foreach ($File in $AllMarkdownFiles) {
    $Raw = Get-Content -LiteralPath $File.FullName -Raw
    # Strip fenced code blocks; mask inline code spans with a placeholder so [`label`](path) links stay checkable
    $Stripped = [regex]::Replace($Raw, '(?s)```.*?```', '')
    $Stripped = [regex]::Replace($Stripped, '`[^`\r\n]+`', 'X')

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
Write-Host "[2/6] Checked $LinksChecked relative Markdown links across $($AllMarkdownFiles.Count) files."

# 3. Forbidden Unadapted pstack/Cursor Dependency Check in skills/
$ForbiddenPattern = "disable-model-invocation|arcus-in-your-own-words|comment-sicko|decision-log-template\.tsv|scripts/log\.sh|watch-pr/watch-pr|worktree-audit\.sh|pstack-models\.mdc|cursor-team-kit|/deslop|control-ui|control-cli|(?<!make a )control skill|create-skill|/loop\b|claude-opus-5-5-|claude-fable-5-2|gemini-4-neon-xhigh|poteto-mode|poteto-agent|subagent_type|generalPurpose|environment:\s*`"(cloud|local)`"|Cursor cloud agent|Cursor's|~/.cursor/projects|\.cursor/worktrees|\*\*(ketchup|why|in-your-own-words|explain)\*\*"
$ForbiddenHits = @($SkillMarkdownFiles | Select-String -Pattern $ForbiddenPattern)
foreach ($Hit in $ForbiddenHits) {
    $Failures.Add("[Forbidden Dependency] $($Hit.Path):$($Hit.LineNumber): $($Hit.Line.Trim())")
}
Write-Host "[3/6] Checked $($SkillMarkdownFiles.Count) skill files for unadapted Cursor/pstack dependencies (Hits: $($ForbiddenHits.Count))."

# 4. Two-Tier Public Skill Layout, Manifest JSON & .agents/skills.json Parity Check
$TopLevelSkills = @(Get-ChildItem -Path $SkillsRoot -Directory | Where-Object { -not $_.Name.StartsWith('.') } | Sort-Object Name)
if ($TopLevelSkills.Count -ne 15) {
    $Failures.Add("[Skill Count] Expected 15 public core skills under skills/, found $($TopLevelSkills.Count)")
}
foreach ($Dir in $TopLevelSkills) {
    if ($Dir.Name -notlike 'arcus-*') {
        $Failures.Add("[Skill Namespace] Public skill folder '$($Dir.Name)' must start with 'arcus-'")
    }
    $EntryFile = Join-Path $Dir.FullName "SKILL.md"
    if (-not (Test-Path -LiteralPath $EntryFile)) {
        $Failures.Add("[Skill Entry] Missing SKILL.md in $($Dir.FullName)")
        continue
    }
    $EntryFm = [regex]::Match((Get-Content -LiteralPath $EntryFile -Raw), '\A---\r?\n([\s\S]*?)\r?\n---')
    $NameMatch = [regex]::Match($EntryFm.Groups[1].Value, '(?m)^name:\s*['']?([A-Za-z0-9_-]+)['']?\s*$')
    if (-not $NameMatch.Success -or $NameMatch.Groups[1].Value -ne $Dir.Name) {
        $Failures.Add("[Skill Name] Frontmatter name in $EntryFile must equal folder name '$($Dir.Name)'")
    }
}

$ManifestFiles = @(
    (Join-Path $RepoRoot "plugin.json"),
    (Join-Path $RepoRoot ".agents\skills.json")
) + @(Get-ChildItem -Path (Join-Path $RepoRoot ".claude-plugin") -Filter "*.json" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
$ParsedManifests = @{}
foreach ($Manifest in $ManifestFiles) {
    if (-not (Test-Path -LiteralPath $Manifest)) {
        $Failures.Add("[Manifest] Missing $Manifest")
        continue
    }
    try {
        $ParsedManifests[$Manifest] = Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json
    } catch {
        $Failures.Add("[Manifest JSON] Invalid JSON in ${Manifest}: $($_.Exception.Message)")
    }
}

$SkillsJsonPath = Join-Path $RepoRoot ".agents\skills.json"
if ($ParsedManifests.ContainsKey($SkillsJsonPath)) {
    $EntryPaths = @($ParsedManifests[$SkillsJsonPath].entries | ForEach-Object { $_.path })
    if ($EntryPaths -notcontains "skills") {
        $Failures.Add("[Manifest Parity] .agents/skills.json entries ($($EntryPaths -join ', ')) must include 'skills'")
    }
}
Write-Host "[4/6] Verified $($TopLevelSkills.Count) public core skills and $($ManifestFiles.Count) JSON manifests."

# 5. License Attribution Check (LICENSE, NOTICE, LICENSES/ texts, and every NOTICE-listed file exists)
foreach ($Required in @("LICENSE", "NOTICE", "LICENSES\pstack-MIT.txt", "LICENSES\Apache-2.0.txt")) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $Required))) {
        $Failures.Add("[License] Missing $Required")
    }
}
$NoticePath = Join-Path $RepoRoot "NOTICE"
$NoticeEntries = @()
if (Test-Path -LiteralPath $NoticePath) {
    $NoticeRaw = Get-Content -LiteralPath $NoticePath -Raw
    $NoticeEntries = @([regex]::Matches($NoticeRaw, '(?m)^  - (\S+)') | ForEach-Object { $_.Groups[1].Value })
    # Any repo-relative LICENSES/ or LICENSES\ path, with or without parentheses, quotes, or backticks.
    # Accepts a leading ./, skips URL paths and names like THIRD-PARTY-LICENSES/, stops at a #fragment,
    # and drops trailing punctuation and Markdown emphasis. Every guard is pinned by test-validate.ps1.
    $NoticeLicenseRefs = @([regex]::Matches($NoticeRaw, '(?<![\w/\\=?&.-])(?:\.[/\\])?LICENSES[/\\][^\s()\[\]"''`<>#*]*[^\s()\[\]"''`<>#*.,;:!?]') | ForEach-Object { ($_.Value -replace '\\', '/') -replace '^\./', '' } | Sort-Object -Unique)
    foreach ($Entry in $NoticeEntries) {
        if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $Entry))) {
            $Failures.Add("[License] NOTICE references '$Entry' but the file does not exist")
        }
    }
    # Exact, case-sensitive name match: Test-Path on Windows ignores trailing dots and case.
    $LicenseFiles = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot "LICENSES") -File -ErrorAction SilentlyContinue | ForEach-Object { "LICENSES/" + $_.Name })
    foreach ($Ref in $NoticeLicenseRefs) {
        if ($LicenseFiles -cnotcontains $Ref) {
            $Failures.Add("[License] NOTICE references '$Ref' but no such file exists in LICENSES/")
        }
    }
}
Write-Host "[5/6] Checked license files, $($NoticeEntries.Count) NOTICE-attributed paths, and $($NoticeLicenseRefs.Count) license-text references."

# 6. Per-Skill Third-Party Notices (D-014): skills/<skill>/THIRD_PARTY_NOTICES.md must match what sync-notices.ps1 generates
# Windows PowerShell 5.1 turns redirected native stderr into a terminating error under "Stop".
$ErrorActionPreference = "Continue"
$NoticeSync = @(& (Get-Process -Id $PID).Path -NoProfile -File (Join-Path $PSScriptRoot "sync-notices.ps1") -Check 2>&1 | ForEach-Object { "$_" })
$NoticeSyncExit = $LASTEXITCODE
$ErrorActionPreference = "Stop"
if ($NoticeSyncExit -ne 0) {
    foreach ($Line in $NoticeSync) { $Failures.Add("[Notices] $Line") }
}
Write-Host "[6/6] Checked per-skill third-party notices against NOTICE."

if ($Failures.Count -gt 0) {
    Write-Host "`nVALIDATION FAILED ($($Failures.Count) issues):" -ForegroundColor Red
    foreach ($F in $Failures) {
        Write-Host "  - $F" -ForegroundColor Red
    }
    exit 1
}

Write-Host "`nALL CHECKS PASSED (0 errors)." -ForegroundColor Green
exit 0
