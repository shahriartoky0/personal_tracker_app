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
