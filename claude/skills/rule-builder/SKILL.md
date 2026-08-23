---
name: rule-builder
description: >
  Use when the user wants to add, edit, or reorganize their personal always-on
  Claude instructions — asks to "add a rule", "always do X from now on",
  "update my Claude preferences", or wants a new language/topic rule file.
  Rules are always loaded every session; skills are loaded on demand (see
  skill-builder).
---

# Editing Personal Claude Rules

ALWAYS:
- Edit files under `~/.claude/rules` (symlink to `~/.dotfiles/claude/rules`).
- Put language-agnostic rules in `common/*.md`.
- Put language-specific rules in `<language>/<topic>.md`.
- Reuse existing topic names: coding-style, testing, patterns, hooks, security.
- Open a language file with `> This file extends [common/X.md](../common/X.md) with <language> specific content.`
- Write rules as single-line imperative instructions.
- Commit changes in `~/.dotfiles`.
- If the request is ambiguous (which file, common vs language-specific, new file vs edit existing) — ask the user before writing.

NEVER:
- Add a registration or include step for a new rule file.
- Duplicate a common rule inside a language file.
- Write prose paragraphs.
- Add rationale or "why" text.
- Expect a mid-session edit to apply to the current session.
- Put project-specific or task-specific instructions here.
