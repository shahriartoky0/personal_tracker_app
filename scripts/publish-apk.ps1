<#
.SYNOPSIS
  Build the SpendWise APK and place it under releases/ (no git operations).

.DESCRIPTION
  0. optional -Bump major|minor|patch|build raises the pubspec.yaml version first (+build always +1)
  1. flutter clean, flutter pub get, flutter build apk --release
     (skip the whole build with -SkipBuild, skip only the clean with -NoClean, debug with -Debug)
  2. copy to releases/spendwise-<version>.apk and releases/spendwise-latest.apk
  3. delete every other releases/spendwise-*.apk so only the current pubspec version is released
  4. refresh the download link in README.md (between the APK:START/APK:END markers)

  The script never stages, commits or pushes: git is left entirely to you. Each APK is a binary
  (~20-50 MB per version); GitHub rejects files > 100 MB.

.EXAMPLE
  ./scripts/publish-apk.ps1
  ./scripts/publish-apk.ps1 -Bump patch
  ./scripts/publish-apk.ps1 -NoClean
  ./scripts/publish-apk.ps1 -SkipBuild
#>
param(
  [switch]$SkipBuild,
  [switch]$NoClean,
  [switch]$Debug,
  [ValidateSet('major', 'minor', 'patch', 'build')]
  [string]$Bump
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$mode = if ($Debug) { 'debug' } else { 'release' }

# -Bump: raise the pubspec version before building so the APK carries it.
# The +build number always increases (Android needs a higher versionCode to update).
if ($Bump) {
  if ($SkipBuild) { throw "-Bump cannot be combined with -SkipBuild (the existing APK has the old version)" }
  $pubspec = Join-Path $root 'pubspec.yaml'
  $raw = [IO.File]::ReadAllText($pubspec)
  if ($raw -notmatch '(?m)^version:\s*(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?\s*$') {
    throw "pubspec.yaml version must look like 1.2.3+4"
  }
  $maj = [int]$Matches[1]; $min = [int]$Matches[2]; $pat = [int]$Matches[3]
  $bld = if ($Matches[4]) { [int]$Matches[4] } else { 0 }
  switch ($Bump) {
    'major' { $maj++; $min = 0; $pat = 0 }
    'minor' { $min++; $pat = 0 }
    'patch' { $pat++ }
  }
  $bld++
  $new = "$maj.$min.$pat+$bld"
  $raw = [regex]::Replace($raw, '(?m)^version:.*$', "version: $new", 1)
  [IO.File]::WriteAllText($pubspec, $raw, (New-Object Text.UTF8Encoding($false)))
  Write-Host "Bumped pubspec.yaml version to $new"
}

if (-not $SkipBuild) {
  if (-not $NoClean) {
    flutter clean
    if ($LASTEXITCODE -ne 0) { throw "flutter clean failed" }
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed" }
  }
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

# Only the current pubspec version stays released: drop every other APK.
Get-ChildItem $dir -Filter 'spendwise-*.apk' |
  Where-Object { $_.Name -ne $versioned -and $_.Name -ne 'spendwise-latest.apk' } |
  ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "Removed old release $($_.Name)"
  }

$sizeMb = [math]::Round((Get-Item $src).Length / 1MB, 1)
Write-Host "Copied $versioned and spendwise-latest.apk ($sizeMb MB) to releases/"
Write-Host "Local file : $(Join-Path $dir $versioned)"

# Read-only git queries, only used to build the download link for the README.
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
$remote = (git remote get-url origin).Trim() -replace '\.git$', ''

# Keep the README download section (between the APK markers) in sync with this release.
if (-not $Debug) {
  $name, $build = $version -split '\+', 2
  if (-not $build) { $build = '-' }

  $block = @"
<!-- APK:START -->
## Download

**[Download SpendWise v$name (APK)]($remote/raw/$branch/releases/spendwise-latest.apk)**

Version $name (build $build) - Android - $sizeMb MB
<!-- APK:END -->
"@

  $readme = Join-Path $root 'README.md'
  $text = [IO.File]::ReadAllText($readme)
  if ($text -match '(?s)<!-- APK:START -->.*?<!-- APK:END -->') {
    $text = [regex]::Replace($text, '(?s)<!-- APK:START -->.*?<!-- APK:END -->', { param($x) $block })
  } else {
    $text = $text.TrimEnd() + "`r`n`r`n" + $block + "`r`n"
  }
  [IO.File]::WriteAllText($readme, $text, (New-Object Text.UTF8Encoding($false)))
  Write-Host "Updated README.md download section"
}

Write-Host ""
Write-Host "Done. Nothing was committed or pushed - handle git yourself."
$changed = @('releases/')
if (-not $Debug) { $changed += 'README.md' }
if ($Bump) { $changed += 'pubspec.yaml' }
Write-Host "Files changed: $($changed -join ', ')"
if (-not $Debug) {
  Write-Host "Once pushed, the download link will be:"
  Write-Host "  $remote/raw/$branch/releases/spendwise-latest.apk"
}
