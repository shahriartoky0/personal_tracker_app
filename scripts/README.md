# scripts

## publish-apk.ps1

Builds the SpendWise APK and places it under `releases/`, and refreshes the download section of the root
`README.md`. **It never stages, commits or pushes** — git is entirely up to you.

### Usage

Run from the project root in PowerShell:

```powershell
./scripts/publish-apk.ps1                  # flutter clean + build release APK into releases/
./scripts/publish-apk.ps1 -NoClean         # build without `flutter clean` (faster)
./scripts/publish-apk.ps1 -Bump patch      # raise 1.0.0+1 -> 1.0.1+2 first (also: minor, major, build)
./scripts/publish-apk.ps1 -SkipBuild       # reuse the APK already in build/
./scripts/publish-apk.ps1 -Debug           # use the debug APK instead
```

### What it does

1. With `-Bump`, raises the `version:` in `pubspec.yaml` first.
2. Runs `flutter clean`, `flutter pub get`, then `flutter build apk --release` (`-NoClean` skips the
   clean; `-SkipBuild` skips all three; `-Debug` builds debug).
3. Reads `version:` from `pubspec.yaml` (e.g. `1.0.0+1`).
4. Copies the APK from `build/app/outputs/flutter-apk/` to:
   - `releases/spendwise-<version>.apk` (debug builds get a `-debug` suffix)
   - `releases/spendwise-latest.apk` (overwritten each run, stable link)
5. Deletes every other `releases/spendwise-*.apk`, so only the current pubspec version is kept.
6. Rewrites the download link and spec table (version, package, size, SHA-256, date, tooling, signing)
   in the root `README.md` between the `<!-- APK:START -->` / `<!-- APK:END -->` markers (release builds
   only).
7. Prints which files changed (`releases/`, `README.md`, and `pubspec.yaml` with `-Bump`) so you can
   review and commit them yourself.

### Parameters

| Flag | Effect |
|------|--------|
| `-NoClean` | Skip `flutter clean` / `pub get`; build incrementally |
| `-Bump <part>` | Raise `pubspec.yaml` version before building: `major`/`minor`/`patch` reset the lower parts, `build` only raises `+N`. The `+N` build number always increases. Not allowed with `-SkipBuild` |
| `-SkipBuild` | Don't clean or build; use the existing APK (errors if missing) |
| `-Debug` | Use `app-debug.apk` instead of release (README is not updated) |

### Requirements

- `flutter` on `PATH`
- `git` on `PATH` and an `origin` remote — only read-only queries, to build the download link in the README

### Caveats

- Each APK is ~20–50 MB and GitHub rejects single files over 100 MB. Old versions deleted from
  `releases/` stay in Git history once committed. Deleted files show up in `git status` as deletions
  for you to stage.
- The README link points at `<repo>/raw/<branch>/releases/spendwise-latest.apk` for the branch you are on
  when the script runs; it only works after you push that branch.
- The release APK is signed with the debug key unless a keystore is configured in
  `android/app/build.gradle.kts`. Fine for sideloading on your own devices, not for the Play Store.
- Use `-Bump` (or edit `version:` in `pubspec.yaml` by hand) for a new release; the previous version's APK is
  then removed. Without a bump the current versioned file is overwritten.

### Where to find the APK

- **Locally:** `releases/` in the project root.
- **On GitHub:** after you push, via the link in the root `README.md`.
