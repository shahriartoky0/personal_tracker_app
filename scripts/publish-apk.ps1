<#
.SYNOPSIS
  Build the SpendWise APK and publish it into the Git repo under releases/.

.DESCRIPTION
  1. flutter build apk --release   (skip with -SkipBuild, debug with -Debug)
  2. copy to releases/spendwise-<version>.apk and releases/spendwise-latest.apk
  3. git add releases/ only, commit, push to origin (skip push with -NoPush)

  Notes: each APK is a binary committed to Git (repo grows ~20-50 MB per version).
  GitHub rejects files > 100 MB. Only releases/ is staged; other changes are untouched.

.EXAMPLE
  ./scripts/publish-apk.ps1
  ./scripts/publish-apk.ps1 -SkipBuild -NoPush
#>
param(
  [switch]$SkipBuild,
  [switch]$Debug,
  [switch]$NoPush
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$mode = if ($Debug) { 'debug' } else { 'release' }

if (-not $SkipBuild) {
  flutter build apk "--$mode"
  if ($LASTEXITCODE -ne 0) { throw "flutter build failed" }
}

$src = Join-Path $root "build/app/outputs/flutter-apk/app-$mode.apk"
if (-not (Test-Path $src)) { throw "APK not found: $src (run without -SkipBuild)" }

$m = Select-String -Path (Join-Path $root 'pubspec.yaml') -Pattern '^version:\s*(\S+)'
if (-not $m) { throw "version not found in pubspec.yaml" }
$version = $m.Matches[0].Groups[1].Value
$suffix = if ($Debug) { "$version-debug" } else { $version }

$dir = Join-Path $root 'releases'
New-Item -ItemType Directory -Force $dir | Out-Null
$versioned = "spendwise-$suffix.apk"
Copy-Item $src (Join-Path $dir $versioned) -Force
Copy-Item $src (Join-Path $dir 'spendwise-latest.apk') -Force

$sizeMb = [math]::Round((Get-Item $src).Length / 1MB, 1)
Write-Host "Copied $versioned and spendwise-latest.apk ($sizeMb MB) to releases/"
Write-Host "Local file : $(Join-Path $dir $versioned)"

git add -f -- releases
git diff --cached --quiet -- releases
if ($LASTEXITCODE -eq 0) { Write-Host "No changes to commit."; exit 0 }
git commit -m "release: apk $suffix" -- releases
if ($LASTEXITCODE -ne 0) { throw "git commit failed" }

if ($NoPush) { Write-Host "Committed (not pushed)."; exit 0 }

$branch = (git rev-parse --abbrev-ref HEAD).Trim()
git push origin $branch
if ($LASTEXITCODE -ne 0) { throw "git push failed" }

$remote = (git remote get-url origin).Trim() -replace '\.git$', ''
Write-Host ""
Write-Host "APK published. Find it at:"
Write-Host "  Folder   : $remote/tree/$branch/releases"
Write-Host "  Versioned: $remote/blob/$branch/releases/$versioned"
Write-Host "  Download : $remote/raw/$branch/releases/spendwise-latest.apk"
