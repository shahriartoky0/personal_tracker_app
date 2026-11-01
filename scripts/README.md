# scripts

## publish-apk.ps1

Builds the SpendWise APK and publishes it into this Git repo under `releases/`, so it shows up in the
project on GitHub.

### Usage

Run from the project root in PowerShell:

```powershell
./scripts/publish-apk.ps1                  # build release APK, commit, push
./scripts/publish-apk.ps1 -SkipBuild       # reuse the APK already in build/
./scripts/publish-apk.ps1 -NoPush          # commit only, don't push
./scripts/publish-apk.ps1 -Debug           # publish the debug APK instead
./scripts/publish-apk.ps1 -SkipBuild -NoPush   # safe dry-ish run to check output
```

### What it does

1. Runs `flutter build apk --release` (skipped with `-SkipBuild`; `-Debug` builds debug).
2. Reads `version:` from `pubspec.yaml` (e.g. `1.0.0+1`).
3. Copies the APK from `build/app/outputs/flutter-apk/` to:
   - `releases/spendwise-<version>.apk` (kept per version; debug builds get a `-debug` suffix)
   - `releases/spendwise-latest.apk` (overwritten each run, stable link)
4. Stages **only** `releases/` (with `git add -f`), commits `release: apk <version>`.
5. Pushes the current branch to `origin` and prints the GitHub URL of the file.

If nothing changed in `releases/`, it exits without committing.

### Parameters

| Flag | Effect |
|------|--------|
| `-SkipBuild` | Don't run `flutter build`; use the existing APK (errors if missing) |
| `-Debug` | Build/publish `app-debug.apk` instead of release |
| `-NoPush` | Commit locally, skip `git push` |

### Requirements

- `flutter` and `git` on `PATH`
- `origin` remote configured and push access
- Run on a branch you are happy to commit to (it pushes the current branch)

### Caveats

- Each versioned APK is a binary stored in Git history: expect ~20–50 MB growth per release. GitHub
  rejects single files over 100 MB.
- The release APK is signed with the debug key unless a keystore is configured in
  `android/app/build.gradle.kts`. Fine for sideloading on your own devices, not for the Play Store.
- Bump `version:` in `pubspec.yaml` before a run if you want a new versioned file rather than
  overwriting the existing one.
- Your other uncommitted changes are never staged or committed by this script.

### Where to find the APK

- **Locally:** `releases/` in the project root (the script prints the full path).
- **On GitHub:** after a push the script prints three links: the `releases/` folder, the versioned file,
  and a direct download link for `spendwise-latest.apk`
  (`<repo>/raw/<branch>/releases/spendwise-latest.apk`).
