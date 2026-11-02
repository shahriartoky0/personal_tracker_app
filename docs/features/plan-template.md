# Plan template

One reusable daily plan per user: a total limit plus per-category amounts, with no date.

## Behaviour
- **Save as template** (Plan page) saves the current form as the template. Saving again overwrites it; there is only one template, no named ones.
- **Use template** loads the template into the form for whichever day is showing. It only fills the form: press **Save plan** to keep it. Categories that no longer exist are ignored and categories the template doesn't mention are cleared. The button is disabled until a template exists.
- **Manual**: nothing copies the template into new days automatically.
- **Independent**: loading it never changes days already saved, and editing or saving a day's plan never changes the template.
- Same validation as a day's plan: no negative amounts, allocations cannot exceed the limit. Amounts are integer minor units.

## Code
- Repository: `LedgerRepository.saveTemplate` / `watchTemplate` in `lib/core/data/ledger_repository.dart` (one row in `budget_templates`; the row's id is reused when overwriting).
- Controller: `PlanController.saveAsTemplate` / `useTemplate` in `lib/features/budgets/application/plan_controller.dart`; provider `budgetTemplateProvider` in `lib/app/providers.dart`.
- UI: buttons in `lib/features/budgets/plan_screen.dart`.
- Tests: `test/plan_template_test.dart`.

## Sync
Pushed as `budget_templates` (conflict key `user_id`, so the server also keeps one row per user). Payload: `{id, user_id, total_limit, allocations: [{category_id, amount}]}`, read back by `BudgetTemplatesSync.applyServerRow` in `lib/core/data/sync/sync_tables.dart`.

**Open check:** the `budget_templates` DDL is not in this repo's migrations (only `supabase/migrations/20261101000000_sync_support.sql` touches it), so the `allocations` column type and shape have not been verified against the live Supabase schema. Confirm before relying on sync for templates.

## Button states (Plan tab)
- **Save plan** (no icon) is disabled while the form is empty (no limit and no amounts) and while saving (label shows "Saving…").
- **Save as template** is disabled until the form is valid: limit above zero and allocations within the limit.
- Both follow the fields live as you type and re-evaluate when you change day. The rules live in `PlanController.canSavePlan` / `canSaveTemplate`.
