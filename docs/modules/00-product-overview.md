# 00 — Product overview

Personal Expense Tracker is an offline-first personal finance app (currency BDT, amounts in poisha) built with
Flutter. Data lives in a local drift database and syncs to Supabase; users sign in with Supabase auth.

## Module map

| Module | Code | Purpose |
| --- | --- | --- |
| Auth | `lib/features/auth/` | Sign-in, bootstrap, app lock |
| Transactions | `lib/features/transactions/` | Dashboard, transaction list, add sheet |
| Transfers | `lib/features/transfers/` | Moves between accounts |
| Budgets / Plan | `lib/features/budgets/` | Budget planning |
| Reports | `lib/features/reports/` | Summaries and charts |
| Settings | `lib/features/settings/` | Accounts, categories, reminders, diagnostics |
| Common UI | `lib/features/common/`, `lib/core/ui/` | Shared widgets and charts |
| Core domain | `lib/core/domain/` | Money, entities, calculators, Result/Failure |
| Core data and sync | `lib/core/data/` | drift DB, repository, outbox, push/pull sync |

Per-module BRDs are added as `NN-<module>.md` from `_TEMPLATE.md` when work begins in that module.
