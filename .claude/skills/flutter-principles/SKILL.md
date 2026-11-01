---
name: flutter-principles
description: Non-negotiable engineering principles for this finance app — money is never a raw double, immutability, typed errors, no secrets, test-first for money and sync paths. Use when touching amounts, balances, budgets, reports, sync, error handling, config or tests.
---

# Flutter principles

1. **Money is never a raw `double`.** Store and compute as `int` minor units; parse and format only via `lib/core/domain/money.dart`. Floating point corrupts ledgers.
2. **Immutability.** Entities and state are immutable (`final` fields, `const` constructors, copy-with). No mutating shared lists/maps.
3. **Typed errors.** Return `Result<T>`/`Failure` with a `FailureCode`; don't throw across layers or show raw exceptions to users.
4. **No secrets in the repo.** Keys live in `.env` (gitignored) or secure storage; keep `.env.example` current. Never log tokens or amounts tied to identity.
5. **Test-first for money and sync paths.** Write the failing test for calculators, parsing, reports, conflict resolvers and outbox logic before changing them.
6. **Dates are local dates.** Use `LocalDate`/timezone helpers for ledger days; avoid raw `DateTime.now()` in business logic.
7. **Fail visibly, recover quietly.** Surface a safe message to the user; send detail to `AppLog`.
