# SpendWise

An offline-first personal finance app: accounts, transactions, transfers, budgets/plan and reports, in BDT.
Built with Flutter, Riverpod, go_router, drift (local SQLite) and Supabase (auth and sync).

<!-- APK:START -->
## Download

**[Download SpendWise v1.0.1 (APK)](https://github.com/shahriartoky0/personal_tracker_app/raw/main/releases/spendwise-latest.apk)**

| Spec | Value |
|------|-------|
| Version | 1.0.1 (build 2) |
| Package | `com.shahriar.spendwise` |
| Platform | Android |
| Size | 72.3 MB |
| SHA-256 | `398879f653bca11a7af9f9671c254b31af4042fd52e11f0b6b182fb315fcc1d6` |
| Released | 02 Nov 2026 |
| Build | Release, Flutter 3.41.4 / Dart 3.11.1 |
| Signing | Debug key (sideload only, not for the Play Store) |

Older builds are not kept in `releases/`; this is always the latest version.
<!-- APK:END -->

## Development

- `flutter pub get`, then `flutter run`
- `flutter analyze` and `flutter test` before committing
- Docs live in `docs/` (module BRDs, ADRs, feature docs); see `CLAUDE.md` for the working agreement
- Release the APK with `./scripts/publish-apk.ps1` (see `scripts/README.md`)
