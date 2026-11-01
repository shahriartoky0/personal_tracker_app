# Documentation

Living docs for Personal Expense Tracker. Principles: one source of truth, durable rather than status,
link to code instead of pasting it.

| Folder | Contents |
| --- | --- |
| `modules/` | Module BRDs: business purpose, current state, what is still needed. Start at `00-product-overview.md`. |
| `decisions/` | ADRs: one non-obvious decision per file, numbered, immutable once accepted. |
| `features/` | What a feature does: user flow, edge cases, code pointers. |

Also here: `claude-team-kit-setup.md` — how the `.claude/` team kit works and how to reuse it.

Claude updates the relevant docs in the same change as the code (see `CLAUDE.md`, Definition of done).
