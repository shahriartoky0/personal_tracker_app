# Setting up the .claude Team Kit in a new project

The "Claude Team Kit" is a committed set of files that makes Claude Code behave the same way for every
developer: it knows who is working, logs its work per person, follows shared skills, and keeps docs in
sync with code. It has five parts:

- **`CLAUDE.md`** is the full working agreement Claude Code reads at session start. `AGENTS.md` is the
  short, tool-agnostic copy for other agents.
- **A SessionStart hook** (`.claude/settings.json` + `.claude/scripts/`) injects the developer's identity
  and logging rules into every session.
- **Per-person session logs** in `.claude/sessions/<slug>/` give a shared history with no merge conflicts.
- **Skills** in `.claude/skills/` hold durable project knowledge (conventions, architecture, principles).
- **`docs/`** holds module BRDs, ADRs and feature docs that Claude must update as part of finishing a task.

## Layout

| Path | Purpose | Committed? |
| --- | --- | --- |
| `CLAUDE.md` | Full contract: identity, session start, operating principles, definition of done, logging, docs, skills | Yes |
| `AGENTS.md` | Short version for Cursor, Copilot and other agents | Yes |
| `.claude/settings.json` | Shared config; holds the SessionStart hook | Yes |
| `.claude/settings.local.json` | Per-developer overrides and permissions | No (gitignored) |
| `.claude/scripts/whoami.sh` | Resolves developer identity | Yes |
| `.claude/scripts/session-start.sh` | Hook that prints identity and logging rules into the session | Yes |
| `.claude/identity.local.example` | Template for each developer's identity | Yes |
| `.claude/identity.local` | The real identity of this machine | No (gitignored) |
| `.claude/sessions/README.md` | Explains the log layout and entry format | Yes |
| `.claude/sessions/<slug>/<DD-Mon-YYYY>.md` | One log file per person per day | Yes |
| `.claude/skills/<name>/SKILL.md` | One folder per skill | Yes |
| `docs/README.md`, `docs/modules/`, `docs/decisions/`, `docs/features/` | Living documentation | Yes |

`.claude/scheduled_tasks.lock` also appears in this repo. Claude Code creates it at runtime, so do not
copy it.

## Identity hook and scripts

Identity resolves in this order: `.claude/identity.local` first, then `git config user.name` and
`user.email`. The slug is the email's local part, lowercased. The hook runs at every session start and
prints a `[TEAM KIT — SESSION IDENTITY]` block, so Claude knows which folder it may write to. If git
identity is used, the hook also offers to create `identity.local`. If nothing resolves, it tells Claude
not to log until identity is set.

**`.claude/settings.json`**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "bash .claude/scripts/session-start.sh" }
        ]
      }
    ]
  }
}
```

If the target project already has a `hooks` block, merge this entry in rather than overwriting.

**`.claude/scripts/whoami.sh`**

```bash
#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CLAUDE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCAL_FILE="$CLAUDE_DIR/identity.local"

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

DEV_SLUG=""; DEV_NAME=""; DEV_EMAIL=""; IDENTITY_SOURCE="none"

if [ -f "$LOCAL_FILE" ]; then
  . "$LOCAL_FILE" 2>/dev/null || true
  IDENTITY_SOURCE="file"
fi

[ -z "${DEV_EMAIL:-}" ] && DEV_EMAIL="$(git config user.email 2>/dev/null || true)"
[ -z "${DEV_NAME:-}" ]  && DEV_NAME="$(git config user.name 2>/dev/null || true)"
if [ -z "${DEV_SLUG:-}" ] && [ -n "${DEV_EMAIL:-}" ]; then
  DEV_SLUG="$(slugify "${DEV_EMAIL%@*}")"
fi
if [ "$IDENTITY_SOURCE" = "none" ] && [ -n "${DEV_EMAIL:-}${DEV_NAME:-}" ]; then
  IDENTITY_SOURCE="git"
fi

printf 'DEV_SLUG=%q\n'        "${DEV_SLUG:-}"
printf 'DEV_NAME=%q\n'        "${DEV_NAME:-}"
printf 'DEV_EMAIL=%q\n'       "${DEV_EMAIL:-}"
printf 'IDENTITY_SOURCE=%q\n' "${IDENTITY_SOURCE}"
```

**`.claude/scripts/session-start.sh`**

```bash
#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
eval "$(bash "$SCRIPT_DIR/whoami.sh" 2>/dev/null || true)"

TODAY="$(date +%d-%b-%Y 2>/dev/null || echo unknown-date)"
SESS_DIR=".claude/sessions/${DEV_SLUG:-unknown}"

if [ -n "${DEV_SLUG:-}" ]; then
  cat <<EOF
[TEAM KIT — SESSION IDENTITY]
You are assisting **${DEV_NAME:-$DEV_SLUG}** (slug: \`${DEV_SLUG}\`, ${DEV_EMAIL:-no-email}).
Identity source: ${IDENTITY_SOURCE:-unknown}. Today: ${TODAY}.

Session logging is PER-PERSON so multiple developers never touch the same file:
- This developer's log for today: \`${SESS_DIR}/${TODAY}.md\`
- On start: read the last 2–3 files in \`${SESS_DIR}/\` to restore recent context.
- Log ONLY prompts that CHANGE the repo (edits, new files, decisions, commits).
  Skip pure questions, status checks, and chat.
- NEVER write to another developer's folder under \`.claude/sessions/\`.
  You write only to \`${SESS_DIR}/\`.
- Follow \`CLAUDE.md\` for the full session / documentation / skills workflow.
EOF
  if [ "${IDENTITY_SOURCE:-}" = "git" ]; then
    cat <<EOF

NOTE: identity is git-derived — there is no \`.claude/identity.local\` yet.
If the slug \`${DEV_SLUG}\` is correct, offer to persist it by creating
\`.claude/identity.local\` from \`.claude/identity.local.example\` (it is gitignored).
EOF
  fi
else
  cat <<EOF
[TEAM KIT — IDENTITY NOT SET]
No identity could be resolved (no \`.claude/identity.local\`, and \`git config user.email\`
is empty). Do NOT write any session log yet. First, help the developer create
\`.claude/identity.local\` from \`.claude/identity.local.example\`.
EOF
fi
```

**`.claude/identity.local.example`**

```bash
# Copy to .claude/identity.local (gitignored) and fill in.
DEV_SLUG=yourname          # stable, lowercase; becomes the session folder name
DEV_NAME="Your Name"
DEV_EMAIL=you@example.com
```

Check who Claude thinks you are with `bash .claude/scripts/whoami.sh`. On Windows, `bash` must be on
PATH (Git Bash).

## Session logging

Each developer writes only to their own folder, so git never merges logs and the folder name is the
attribution. The rule is one question: did this prompt change the repo? If yes, log it. If no
(questions, status checks, chat), skip it.

```
.claude/sessions/
  README.md
  <dev-slug>/
    01-Nov-2026.md      # one file per day, DD-Mon-YYYY
```

Rules:

- Logs are append-only. Never rewrite past entries.
- Never write to another developer's folder.
- If identity is unknown, resolve it first. Do not log as `unknown`.
- At session start Claude reads the last 2–3 files in its own folder to restore context.

Entry format (the file starts with `# Session log — <date> — <DEV_NAME>` once):

```markdown
---

### 14:32
**Prompt:** Add retry/backoff to the health-check ping

**Done:**
- Added exponential backoff to <file path>
- New ADR docs/decisions/0002-health-check-retry-policy.md
- Follow-up: add a jitter cap (TODO)
```

Copy `.claude/sessions/README.md` as-is, then change the example paths.

## Skills

A skill is `.claude/skills/<name>/SKILL.md`: YAML frontmatter (`name` matching the folder, and a
`description` that says what it covers and when to use it) plus a Markdown body. The description is how
Claude decides to load it, so pack it with trigger words. Skills hold durable method and rules, never
status, secrets, or copies of code. The test is whether it will still be true in three months.

| Skill | Kind | Reuse in another project |
| --- | --- | --- |
| `authoring-skills` | How to write and review skills | Copy as-is |
| `project-conventions` | How this codebase is structured: folders, Bloc/get_it/dio, Money, errors, naming, known-debt checklist | Rewrite for the new codebase |
| `flutter-architecture` | Layering, dependency rule, module boundaries | Keep for Flutter; adapt otherwise |
| `flutter-principles` | Money is never a raw double, immutability, typed errors, no secrets, test-first for money paths | Keep what fits; edit the money rules to the new domain |

Start with `authoring-skills` and a fresh `project-conventions`. Add the others only if their rules are
true for the new project.

## CLAUDE.md, AGENTS.md and gitignore

`CLAUDE.md` is the contract. Its sections, in order:

1. **Project at a glance:** product, stack, where things live, which skill to read first.
2. **Identity:** trust the injected block; act for exactly one person.
3. **Session start:** read the last 2–3 own logs, `git log --oneline -10`, `git status`, and the relevant
   module BRD.
4. **Operating principles:** discuss first, offer a plan, ask clarifying questions, re-verify against
   guardrails, be precise, keep changes reviewable, close the loop.
5. **Definition of done:** update the session log, module BRD, feature docs, ADR, skills and indexes. A
   change that makes a doc wrong must fix that doc in the same change.
6. **Session logging:** the rule and entry format above.
7. **Documentation and skills:** where BRDs, ADRs and feature docs live, and which skills exist.
8. **Working agreements:** small commits only when asked, shared files change via PR, no secrets,
   machine-specific settings in `*.local` files.

`AGENTS.md` repeats this in about 45 lines for non-Claude agents and points back to `CLAUDE.md`.

Only section 1 (project at a glance) and the skill names are project-specific. Keep the rest, and change
the stack line, the guardrail examples (here: money as raw floating point) and the skill list.

Add these lines to `.gitignore`:

```
# Claude Team Kit — per-developer identity, never shared
.claude/identity.local
.claude/settings.local.json
```

Shared files (`CLAUDE.md`, `.claude/settings.json`, scripts, skills, `docs/*`) change through PR review.
Per-person session files need no review.

## Docs structure

```
docs/
  README.md
  modules/       # BRDs: 00-product-overview.md, NN-<module>.md, _TEMPLATE.md, README.md
  decisions/     # ADRs: 0000-adr-template.md, NNNN-short-title.md
  features/      # what a feature does and how it flows
```

- **Module BRDs** state business purpose, current state and what is still needed.
  `00-product-overview.md` holds the module map. Claude reads the BRD before building in a module and
  updates it in the same change.
- **ADRs** record non-obvious decisions, one per file, numbered. They are immutable once accepted. A
  reversal is a new ADR, and the old one is marked `Superseded by NNNN`.
- **Feature docs** describe what a feature does, its user flow, edge cases and code pointers.
- Principles: one source of truth, durable rather than status, link to code instead of pasting it.

Copy `docs/README.md`, `modules/_TEMPLATE.md`, `modules/README.md` and `decisions/0000-adr-template.md`.
Leave out this project's own BRDs and ADRs.

## Setup steps for a new project

1. Create `.claude/scripts/`, `.claude/sessions/` and `.claude/skills/` in the new repo.
2. Copy `whoami.sh` and `session-start.sh` exactly as shown above. They use no project-specific values.
3. Create `.claude/settings.json` with the SessionStart hook, merging into any existing `hooks` block.
4. Copy `identity.local.example` and `sessions/README.md`. Fix the example paths in the README.
5. Append the two identity lines to `.gitignore`.
6. Copy `CLAUDE.md` and `AGENTS.md`. Rewrite section 0 (product, stack, locations), the guardrail
   examples, and the skill list.
7. Copy `authoring-skills`. Write a new `project-conventions` for the new codebase, then add
   architecture or principles skills if they apply.
8. Create `docs/` from the templates: `README.md`, `modules/_TEMPLATE.md`, `modules/README.md`,
   `decisions/0000-adr-template.md`. Write `modules/00-product-overview.md`.
9. Each developer copies `identity.local.example` to `.claude/identity.local` and fills it in (or accepts
   the git-derived identity when Claude offers).
10. Start Claude Code and check that the first message shows the `[TEAM KIT — SESSION IDENTITY]` block.
    If it does not, run `bash .claude/scripts/whoami.sh` and check that `bash` is on PATH.
11. Commit the kit in one PR so the team gets it together.

**Checklist**

- [ ] Identity block appears at session start
- [ ] `.claude/identity.local` and `settings.local.json` are gitignored
- [ ] `CLAUDE.md` section 0 describes the new project, not this one
- [ ] No leftover references to this project's modules, Money type, or Flutter-only rules that do not apply
- [ ] A first prompt that edits a file produces a log entry under your own slug
- [ ] Skills have accurate `description` fields
