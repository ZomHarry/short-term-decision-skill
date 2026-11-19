# 仓库结构自检（CI 与本地共用）
# 用法：pwsh -NoProfile -File scripts/check-repo.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$errors = New-Object System.Collections.Generic.List[string]

$required = @(
    "SKILL.md", "README.md", "LICENSE", "CHANGELOG.md",
    "knowledge/formulas.md", "knowledge/method-decision-tree.md", "knowledge/common-errors.md",
    "prompts/system-prompt.md", "prompts/few-shot.md", "prompts/output-template.md",
    "tests/test-cases.md", "scripts/build-skill-zip.ps1"
)

foreach ($rel in $required) {
    $p = Join-Path $root $rel
    if (-not (Test-Path $p)) { $errors.Add("missing file: " + $rel); continue }
    if ((Get-Item $p).Length -eq 0) { $errors.Add("empty file: " + $rel) }
}

# SKILL.md：frontmatter 与索引表
$skillPath = Join-Path $root "SKILL.md"
if (Test-Path $skillPath) {
    $lines = Get-Content $skillPath -Encoding UTF8
    if ($lines[0].Trim() -ne "---") { $errors.Add("SKILL.md: frontmatter must start on line 1") }
    $close = -1
    for ($i = 1; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq "---") { $close = $i; break } }
    if ($close -lt 0) { $errors.Add("SKILL.md: unterminated frontmatter") }
    elseif ($close -gt 1) {
        $fm = $lines[1..($close - 1)] -join [Environment]::NewLine
        foreach ($key in @("name:", "description:", "license:")) {
            if ($fm -notmatch ("(?m)^" + [regex]::Escape($key))) { $errors.Add("SKILL.md: frontmatter missing " + $key) }
        }
    }
    $body = $lines -join [Environment]::NewLine
    foreach ($ref in @("knowledge/formulas.md", "knowledge/method-decision-tree.md", "knowledge/common-errors.md", "prompts/system-prompt.md")) {
        if ($body -notmatch [regex]::Escape($ref)) { $errors.Add("SKILL.md: does not reference " + $ref) }
    }
}

# 本地 Markdown 链接
$mdFiles = Get-ChildItem -Recurse -File -Path $root -Filter *.md | Where-Object { $_.FullName -notmatch "dist|node_modules" }
foreach ($f in $mdFiles) {
    $text = Get-Content $f.FullName -Raw -Encoding UTF8
    if (-not $text) { continue }
    foreach ($m in [regex]::Matches($text, '\]\(([^)\s]+)\)')) {
        $target = $m.Groups[1].Value
        if ($target -match '^(https?:|mailto:|#)') { continue }
        $target = ($target -split '#')[0]
        if ([string]::IsNullOrWhiteSpace($target)) { continue }
        if (-not (Test-Path (Join-Path $f.DirectoryName $target))) { $errors.Add($f.Name + ": broken link -> " + $target) }
    }
}

if ($errors.Count -gt 0) {
    Write-Host ("FAILED: " + $errors.Count + " problem(s)")
    foreach ($e in $errors) { Write-Host ("  - " + $e) }
    exit 1
}
Write-Host ("OK: " + $required.Count + " required files, " + $mdFiles.Count + " markdown files checked")
