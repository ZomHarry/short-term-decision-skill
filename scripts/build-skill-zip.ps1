# 构建可安装的 Skill 压缩包（兼容 Windows PowerShell 5.1 / PowerShell 7）
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build-skill-zip.ps1 -Version 1.1.1
param(
    [string]$Version = "1.1.1",
    [string]$SkillName = "short-term-decision"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root  = Split-Path -Parent $PSScriptRoot
$dist  = Join-Path $root "dist"
$stage = Join-Path ([System.IO.Path]::GetTempPath()) ("skillpkg_" + [guid]::NewGuid().ToString("N").Substring(0, 8))
$pkg   = Join-Path $stage $SkillName

# 打进包里的内容：SKILL.md 是入口，其余由 SKILL.md 第九节索引表挂载
$include = @(
    "SKILL.md",
    "LICENSE",
    "README.md",
    "knowledge",
    "prompts",
    "tests",
    "docs"
)

New-Item -ItemType Directory -Force -Path $pkg, $dist | Out-Null
foreach ($item in $include) {
    $src = Join-Path $root $item
    if (-not (Test-Path $src)) { throw "缺少文件：$src" }
    if ((Get-Item $src).PSIsContainer) {
        Copy-Item -Recurse -Path $src -Destination $pkg
    } else {
        Copy-Item -Path $src -Destination (Join-Path $pkg $item)
    }
}

# 包内不需要的大文件：v1.0 合并快照（43KB，与最新内容重复）
$snapshot = Join-Path $pkg "docs/交付总览.md"
if (Test-Path $snapshot) { Remove-Item $snapshot -Force }

# 校验入口
$skillMd = Join-Path $pkg "SKILL.md"
if (-not (Test-Path $skillMd)) { throw "打包失败：SKILL.md 不在包根目录" }
$head = Get-Content $skillMd -TotalCount 20 -Encoding UTF8
if (-not ($head -contains "---")) { throw "打包失败：SKILL.md 缺少 YAML frontmatter" }

$zip = Join-Path $dist ("{0}-v{1}.zip" -f $SkillName, $Version)
if (Test-Path $zip) { Remove-Item $zip -Force }

# 用 ZipArchive 逐条写入，条目名统一为 "技能名/相对路径"
$fs = [System.IO.File]::Open($zip, [System.IO.FileMode]::Create)
try {
    $arch = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        Get-ChildItem -Recurse -File -Path $pkg | ForEach-Object {
            $rel = $_.FullName.Substring($pkg.Length + 1).Replace([char]92, [char]47)
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                $arch, $_.FullName, ($SkillName + "/" + $rel),
                [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
        }
    } finally { $arch.Dispose() }
} finally { $fs.Dispose() }

$count = 0
$zipRead = [System.IO.Compression.ZipFile]::OpenRead($zip)
try {
    $count = $zipRead.Entries.Count
    Write-Host ("条目清单：")
    $zipRead.Entries | ForEach-Object { Write-Host ("  " + $_.FullName) }
} finally { $zipRead.Dispose() }

Remove-Item -Recurse -Force $stage

Write-Host ""
Write-Host ("已生成：{0}" -f $zip)
Write-Host ("共 {0} 个文件，{1:N1} KB" -f $count, ((Get-Item $zip).Length / 1KB))
