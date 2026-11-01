# Session logs

Per-person history of the work Claude Code did in this repo. Each developer writes only to their own
folder, so git never merges logs and the folder name is the attribution.

```
.claude/sessions/
  README.md
  <dev-slug>/
    01-Nov-2026.md      # one file per day, DD-Mon-YYYY
```

## What to log

One question: **did this prompt change the repo?** If yes, log it. If no (questions, status checks, chat), skip it.

## Rules

- Logs are append-only. Never rewrite past entries.
- Never write to another developer's folder.
- If identity is unknown, resolve it first (see `.claude/identity.local.example`). Do not log as `unknown`.
- At session start Claude reads the last 2–3 files in its own folder to restore context.

## Entry format

The file starts with `# Session log — <date> — <DEV_NAME>` once, then one block per prompt:

```markdown
---

### 14:32
**Prompt:** Add retry/backoff to the sync push engine

**Done:**
- Added exponential backoff to lib/core/data/sync/push_engine.dart
- New ADR docs/decisions/0001-sync-retry-policy.md
- Follow-up: add a jitter cap (TODO)
```
