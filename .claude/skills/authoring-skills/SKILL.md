---
name: authoring-skills
description: How to write, review and maintain Claude skills in .claude/skills. Use when creating a new SKILL.md, editing a skill's description or body, deciding whether knowledge belongs in a skill, CLAUDE.md or docs/, or reviewing skills for staleness.
---

# Authoring skills

A skill is `.claude/skills/<name>/SKILL.md`: YAML frontmatter plus a Markdown body.

## Frontmatter
- `name` must match the folder name (kebab-case).
- `description` is how Claude decides to load the skill. Say **what it covers** and **when to use it**, and
  pack it with trigger words (file names, concepts, verbs a prompt would contain). One or two sentences.

## Body
- Hold durable method and rules: conventions, architecture, principles, checklists.
- Never hold status ("we are migrating X"), secrets, or pasted copies of code. Link to paths instead.
- **Three-month test:** will each statement still be true in three months? If not, it belongs in a session
  log, a feature doc or an ADR.
- Prefer short imperative rules with a one-line reason over prose. Keep one skill to one topic.

## Where things go
| Knowledge | Home |
| --- | --- |
| How we build here (rules) | skill |
| Why we chose X over Y | ADR in `docs/decisions/` |
| What a module/feature does | `docs/modules/`, `docs/features/` |
| What happened in a session | `.claude/sessions/<slug>/` |

## Review checklist
- [ ] `name` equals folder name; `description` has trigger words
- [ ] No status, secrets or code copies
- [ ] Every path mentioned still exists
- [ ] Does not contradict `CLAUDE.md` or another skill
