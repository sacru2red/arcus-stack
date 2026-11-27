# Regression tests for scripts/validate.ps1: each case copies the tracked repo to a temp dir,
# injects one defect, and asserts the validator's exit code.
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Shell = (Get-Process -Id $PID).Path
$Failed = 0

function New-RepoCopy {
    $Dir = Join-Path ([IO.Path]::GetTempPath()) ("arcus-validate-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $Dir | Out-Null
    Push-Location $RepoRoot
    try {
        foreach ($Rel in (git ls-files)) {
            $Dest = Join-Path $Dir $Rel
            New-Item -ItemType Directory -Path (Split-Path -Parent $Dest) -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $RepoRoot $Rel) -Destination $Dest
        }
        foreach ($Rel in (git ls-files --others --exclude-standard)) {
            $Dest = Join-Path $Dir $Rel
            New-Item -ItemType Directory -Path (Split-Path -Parent $Dest) -Force | Out-Null
            Copy-Item -LiteralPath (Join-Path $RepoRoot $Rel) -Destination $Dest
        }
    } finally {
        Pop-Location
    }
    return $Dir
}

function Test-Case([string]$Name, [int]$ExpectedExit, [scriptblock]$Mutate) {
    $Dir = New-RepoCopy
    try {
        & $Mutate $Dir
        & $Shell -NoProfile -File (Join-Path $Dir "scripts\validate.ps1") *> $null
        $Actual = $LASTEXITCODE
        if ($Actual -eq $ExpectedExit) {
            Write-Host "[PASS] $Name (exit $Actual)"
        } else {
            Write-Host "[FAIL] $Name (expected exit $ExpectedExit, got $Actual)" -ForegroundColor Red
            $script:Failed++
        }
    } finally {
        Remove-Item -LiteralPath $Dir -Recurse -Force
    }
}

Test-Case "clean copy passes" 0 { param($d) }

Test-Case "broken backtick-labelled link fails" 1 {
    param($d)
    Add-Content -LiteralPath (Join-Path $d "skills\arcus-plan\SKILL.md") -Value "`nSee [``missing``](../arcus-nope/SKILL.md)."
}

Test-Case "stray non-arcus skill folder fails" 1 {
    param($d)
    New-Item -ItemType Directory -Path (Join-Path $d "skills\stray") | Out-Null
}

Test-Case "non-arcus skill folder with a matching SKILL.md fails the namespace check" 1 {
    param($d)
    $Old = Join-Path (Join-Path $d "skills") "arcus-why"
    $File = Join-Path $Old "SKILL.md"
    (Get-Content -LiteralPath $File -Raw) -replace '(?m)^name:\s*arcus-why', 'name: why' | Set-Content -LiteralPath $File -NoNewline
    Rename-Item -LiteralPath $Old -NewName "why"
}

Test-Case "tool state folder skills/.omc is ignored" 0 {
    param($d)
    New-Item -ItemType Directory -Path (Join-Path $d "skills\.omc\state") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $d "skills\.omc\state\notes.md") -Value "---`nfoo: bar`n---`n[x](./nope.md)"
}

Test-Case "invalid plugin manifest JSON fails" 1 {
    param($d)
    Set-Content -LiteralPath (Join-Path $d ".claude-plugin\plugin.json") -Value "{ not json"
}

Test-Case "frontmatter name mismatch fails" 1 {
    param($d)
    $File = Join-Path $d "skills\arcus-why\SKILL.md"
    (Get-Content -LiteralPath $File -Raw) -replace '(?m)^name:\s*arcus-why', 'name: arcus-whyy' | Set-Content -LiteralPath $File -NoNewline
}

Test-Case "NOTICE entry for a missing file fails" 1 {
    param($d)
    Add-Content -LiteralPath (Join-Path $d "NOTICE") -Value "  - skills/arcus-mode/internal/does-not-exist.md"
}

Test-Case "license text referenced by NOTICE but missing fails" 1 {
    param($d)
    Remove-Item -LiteralPath (Join-Path (Join-Path $d "LICENSES") "yoonmoon-MIT.txt")
}

if ($Failed -gt 0) {
    Write-Host "`n$Failed validate.ps1 regression case(s) failed." -ForegroundColor Red
    exit 1
}
Write-Host "`nAll validate.ps1 regression cases passed."
exit 0
