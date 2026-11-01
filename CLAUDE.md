# CLAUDE.md — working agreement

This file is the contract for Claude Code in this repo. `AGENTS.md` is the short version for other tools.

## 1. Project at a glance
- **Product:** Personal Expense Tracker — an offline-first personal finance app (accounts, transactions,
  transfers, budgets/plan, reports) in BDT, with Supabase auth and sync.
- **Stack:** Flutter, Riverpod, go_router, drift (local SQLite), Supabase.
- **Where things live:** `lib/app` (wiring), `lib/core` (domain, data, error, ui), `lib/features/<f>`
  (screens + `application/`), `supabase/` (migrations, functions), `docs/` (BRDs, ADRs, feature docs).
- **Read first:** skill `project-conventions`, then `flutter-architecture` and `flutter-principles`.

## 2. Identity
Trust the `[TEAM KIT — SESSION IDENTITY]` block injected at session start. Act for exactly one person, and
write only to that person's folder under `.claude/sessions/`. If identity is not set, help create
`.claude/identity.local` before logging anything.

## 3. Session start
1. Read the last 2–3 files in your own `.claude/sessions/<slug>/`.
2. Run `git log --oneline -10` and `git status` (skip if the folder is not a git repo).
3. Read the BRD in `docs/modules/` for the module you are about to touch.

## 4. Operating principles
- **Discuss first** for anything non-trivial; offer a plan and ask clarifying questions before large edits.
- **Re-verify against guardrails** (skills, especially money rules) before and after changing code.
- **Be precise:** cite `path:line`, don't guess APIs, check that referenced files exist.
- **Keep changes reviewable:** small, focused diffs; no drive-by refactors.
- **Close the loop:** run `flutter analyze` / `flutter test` and report results honestly.

## 5. Definition of done
Update, in the same change: the session log, the module BRD, feature docs, an ADR (for non-obvious
decisions), affected skills and indexes. A change that makes a doc wrong must fix that doc.

## 6. Session logging
Log only prompts that **change the repo**; skip questions and chat. File: `.claude/sessions/<slug>/<DD-Mon-YYYY>.md`,
append-only, starting once with `# Session log — <date> — <DEV_NAME>`. Entry:

```markdown
---

### 14:32
**Prompt:** <what was asked>

**Done:**
- <change, with file paths>
- Follow-up: <TODO>
```
Details: `.claude/sessions/README.md`.

## 7. Documentation and skills
- `docs/modules/` BRDs (`00-product-overview.md` is the module map), `docs/decisions/` ADRs (immutable once
  accepted; reversal = new ADR), `docs/features/` feature docs. Link to code, don't paste it.
- Skills in `.claude/skills/`: `authoring-skills`, `project-conventions`, `flutter-architecture`, `flutter-principles`.

## 8. Working agreements
- Commit small, and only when asked. Shared files (`CLAUDE.md`, `.claude/settings.json`, scripts, skills,
  `docs/*`) change via PR review.
- No secrets in the repo; machine-specific settings go in `*.local` files (gitignored).
- Money is never a raw `double` — see `flutter-principles`.
