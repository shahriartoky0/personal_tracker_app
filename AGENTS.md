# AGENTS.md

Short, tool-agnostic rules for AI agents (Cursor, Copilot, etc.). The full contract is `CLAUDE.md`.

## Project
SpendWise: offline-first Flutter app (Riverpod, go_router, drift, Supabase). Code in `lib/app`,
`lib/core` (domain/data/error/ui) and `lib/features/<feature>`. Backend in `supabase/`.

## Before you change code
- Read `.claude/skills/project-conventions/SKILL.md`, `flutter-architecture` and `flutter-principles`.
- Read the relevant BRD in `docs/modules/`.
- Discuss non-trivial changes first; keep diffs small and reviewable.

## Hard rules
- Money is an `int` of minor units. Never use `double` for amounts (`lib/core/domain/money.dart`).
- Return `Result<T>`/`Failure`; don't leak raw exceptions to the UI.
- Dependencies point inward: UI → application → data → domain. Features don't import each other's internals.
- Never commit secrets; `.env` is gitignored, keep `.env.example` current.
- Test money and sync logic first.

## Definition of done
Run `flutter analyze` and `flutter test`. Update the module BRD, feature docs, ADR and skills affected by the
change. A change that makes a doc wrong must fix that doc.

## Logging (Claude Code)
Session logs are per person under `.claude/sessions/<slug>/`. Never write to another person's folder.

## Working agreements
Commit only when asked. Shared files change via PR. Machine-specific config goes in `*.local` files.
