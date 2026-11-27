# Generates skills/<skill>/THIRD_PARTY_NOTICES.md from the root NOTICE (D-014).
# `npx skills add --skill <name>` copies only that skill folder, so every skill that holds
# third-party material carries its own copy of the matching NOTICE sections and license texts.
# -Check writes nothing and exits 1 when any generated file is missing, stale, or orphaned.
param([switch]$Check)
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Utf8 = New-Object System.Text.UTF8Encoding($false)
$FileName = "THIRD_PARTY_NOTICES.md"
$Separator = '^-{20,}$'
$EntryPattern = '^  - skills/([^/\s]+)/(\S+)'

function Read-Text([string]$Path) {
    [IO.File]::ReadAllText($Path, $Utf8).Replace("`r`n", "`n")
}

$NoticeLines = (Read-Text (Join-Path $RepoRoot "NOTICE")).TrimEnd("`n").Split("`n")

# Split NOTICE into sections on the dashed separator lines; the first chunk is the arcus-stack header.
$Sections = New-Object System.Collections.Generic.List[object]
$Current = New-Object System.Collections.Generic.List[string]
foreach ($Line in $NoticeLines) {
    if ($Line -match $Separator) {
        $Sections.Add($Current.ToArray())
        $Current = New-Object System.Collections.Generic.List[string]
    } else {
        $Current.Add($Line)
    }
}
$Sections.Add($Current.ToArray())
$ThirdParty = @($Sections | Select-Object -Skip 1)

$Skills = @($ThirdParty | ForEach-Object { $_ } | ForEach-Object {
    if ($_ -match $EntryPattern) { $Matches[1] }
} | Sort-Object -Unique)

function Get-SkillSection([string[]]$Lines, [string]$Skill) {
    $Kept = New-Object System.Collections.Generic.List[string]
    $Count = 0
    $InForeignEntry = $false
    foreach ($Line in $Lines) {
        if ($Line -match $EntryPattern) {
            $InForeignEntry = $Matches[1] -ne $Skill
            if ($InForeignEntry) { continue }
            $Count++
            $Kept.Add($Line)
        } elseif ($InForeignEntry -and $Line -match '^    \S') {
            continue
        } else {
            $InForeignEntry = $false
            $Kept.Add($Line)
        }
    }
    if ($Count -eq 0) { return $null }
    $Text = ($Kept -join "`n").Trim("`n")
    if ($Count -eq 1) {
        $Text = [regex]::Replace($Text, 'The following \d+ files are', 'The following file is')
    } else {
        $Text = [regex]::Replace($Text, 'The following \d+ files are', "The following $Count files are")
    }
    return $Text
}

function New-SkillNotice([string]$Skill) {
    $Parts = New-Object System.Collections.Generic.List[string]
    $Licenses = New-Object System.Collections.Generic.List[string]
    foreach ($Section in $ThirdParty) {
        $Text = Get-SkillSection $Section $Skill
        if ($null -eq $Text) { continue }
        foreach ($M in [regex]::Matches($Text, '\(LICENSES/([^)\s]+)\)')) {
            if (-not $Licenses.Contains($M.Groups[1].Value)) { $Licenses.Add($M.Groups[1].Value) }
        }
        $Parts.Add([regex]::Replace($Text, '\(LICENSES/[^)\s]+\)', '(full text below)'))
    }

    $Out = New-Object System.Text.StringBuilder
    [void]$Out.Append("# Third-Party Notices: $Skill`n`n")
    [void]$Out.Append("Generated from the root ``NOTICE`` of https://github.com/sacru2red/arcus-stack by ``scripts/sync-notices.ps1``. Do not edit by hand.`n")
    [void]$Out.Append("This skill folder ships these notices so that installing it alone keeps the third-party attributions. arcus-stack itself is MIT licensed (Copyright (c) 2026 sacru2red).`n`n")
    [void]$Out.Append("## Attributions`n`n")
    foreach ($Part in $Parts) {
        [void]$Out.Append("``````text`n$Part`n```````n`n")
    }
    [void]$Out.Append("## License Texts`n")
    foreach ($License in $Licenses) {
        $Body = (Read-Text (Join-Path (Join-Path $RepoRoot "LICENSES") $License)).Trim("`n")
        [void]$Out.Append("`n### $License`n`n``````text`n$Body`n```````n")
    }
    return $Out.ToString()
}

$Expected = @{}
foreach ($Skill in $Skills) {
    $Expected[(Join-Path (Join-Path (Join-Path $RepoRoot "skills") $Skill) $FileName)] = New-SkillNotice $Skill
}
$Existing = @(Get-ChildItem -Path (Join-Path $RepoRoot "skills") -Filter $FileName -Recurse -File -Force | ForEach-Object { $_.FullName })

$Problems = New-Object System.Collections.Generic.List[string]
foreach ($Path in ($Expected.Keys | Sort-Object)) {
    $Rel = $Path.Substring($RepoRoot.Length + 1).Replace('\', '/')
    if ($Check) {
        if (-not (Test-Path -LiteralPath $Path)) {
            $Problems.Add("missing $Rel")
        } elseif ([IO.File]::ReadAllText($Path, $Utf8) -cne $Expected[$Path]) {
            $Problems.Add("stale $Rel")
        }
    } else {
        [IO.File]::WriteAllText($Path, $Expected[$Path], $Utf8)
        Write-Host "[WROTE] $Rel"
    }
}
foreach ($Path in $Existing) {
    if (-not $Expected.ContainsKey($Path)) {
        $Rel = $Path.Substring($RepoRoot.Length + 1).Replace('\', '/')
        if ($Check) {
            $Problems.Add("orphaned $Rel (its skill has no NOTICE entries)")
        } else {
            Remove-Item -LiteralPath $Path
            Write-Host "[REMOVED] $Rel"
        }
    }
}

if ($Problems.Count -gt 0) {
    foreach ($P in $Problems) { Write-Host "[NOTICES] $P; run scripts/sync-notices.ps1" -ForegroundColor Red }
    exit 1
}
if ($Check) { Write-Host "[NOTICES] $($Expected.Count) per-skill notice files match NOTICE." }
exit 0
