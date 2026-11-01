---
name: project-conventions
description: How the personal_expense_tracker Flutter codebase is structured and written — folder layout, Riverpod providers, drift database, Supabase sync, Money in minor units, Result/Failure error handling, naming, and a known-debt checklist. Read before adding or changing any feature, repository, provider, screen, table or sync code.
---

# Project conventions

## Stack
Flutter, `flutter_riverpod` (state/DI), `go_router`, `drift` (local SQLite, source of truth on device),
`supabase_flutter` (auth + remote sync), `flutter_secure_storage`, `flutter_dotenv` (`.env`, gitignored).

## Folder map
- `lib/main.dart` — bootstrap only.
- `lib/app/` — app wiring: `app.dart`, `providers.dart` (shared providers), `session_controller.dart`, `shell.dart`, `theme.dart`.
- `lib/core/domain/` — pure Dart: `money.dart`, `result.dart`, `entities.dart`, `calculators.dart`, `reports.dart`, `validation.dart`, `local_date.dart`.
- `lib/core/data/` — `db/` (drift tables, database, key store), `remote/` (gateway, failures), `sync/` (outbox, push/pull engines), `ledger_repository.dart`.
- `lib/core/error/` — `app_error.dart` (`toFailure`), `ui_guard.dart`.
- `lib/core/{logging,platform,ui}/` — `AppLog`, notifications/app lock, shared widgets and motion.
- `lib/features/<feature>/` — screens plus `application/` (providers/controllers). Features: auth, transactions, transfers, budgets, reports, settings, common.
- `supabase/migrations/`, `supabase/functions/` — backend schema and edge functions.

## Rules
1. **Money is an `int` of minor units** (poisha). Parse with `parseMoney`, format with the helpers in `money.dart`. Never `double`.
2. **Errors are values.** Repositories and use-cases return `Result<T>` (`Ok`/`Err` with `Failure`). Convert thrown objects with `toFailure`. User-facing messages are safe; technical detail goes to `AppLog`.
3. **UI actions go through `ui_guard`** so failures surface consistently.
4. **State via Riverpod.** Shared providers live in `lib/app/providers.dart`; feature-specific ones in `features/<f>/application/`. Widgets read, never construct, repositories.
5. **Offline-first.** Writes hit drift and the outbox first; sync engines reconcile with Supabase. Do not call the remote gateway from widgets.
6. **Schema changes** need a drift schema update (regenerate `database.g.dart` with build_runner) and a matching Supabase migration.
7. **Naming:** files `snake_case.dart`; one primary class per file; screens end in `_screen.dart`, sheets in `_sheet.dart`.
8. **No secrets in code.** Config comes from `.env`; keep `.env.example` current.
9. Run `flutter analyze` and `flutter test` before calling work done.
10. **Category visuals** (icon + colour) go through `lib/core/ui/category_style.dart`; never hard-code per-screen category icons.
11. **Motion** goes through `lib/core/ui/motion.dart` (`Motion.*`, `AnimatedMoney`, `Motion.reduced`); never animate scrolled-in list rows.

## Known-debt checklist (check, don't assume fixed)
- [ ] `test/` is nearly empty — money and sync paths lack tests.
- [ ] `.core_backup/` holds a removed template core; do not import from it.
- [ ] README is still the Flutter template text.
