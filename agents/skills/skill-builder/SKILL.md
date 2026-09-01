---
name: skill-builder
description: >
  Use when the user wants to create, edit, or improve a Claude Code skill —
  asks "make a skill for X", "add this as a skill", "how do skills work", or
  wants to turn a repeated workaround/lesson into something reusable across
  sessions. Not for always-on rule files (see rule-builder).
---

# Building Claude Code Skills

ALWAYS:
- Put public shared skills at `agents/skills/<name>/SKILL.md`.
- When the user asks for a private skill, put it at
  `~/.agents/skills/<name>/SKILL.md`, outside Git. After creating it, run
  `script/install --agents` so it is available to both Claude and Codex.
- Make `<name>` kebab-case and match the directory name exactly.
- Include YAML frontmatter with `name` and `description`.
- Write `description` as concrete trigger phrases the user would actually say.
- State what the skill is NOT for when a similar skill exists.
- Write reference/lessons-learned skills as flat terse bullets.
- Write procedural/workflow skills as short imperative steps or tables.
- Test by describing the task naturally, not by invoking the skill by name.
- Use `path:skill` naming for a project-scoped skill that collides with a personal skill name.
- If the request is ambiguous (personal vs project-scoped, which style, skill vs rule) — ask the user before writing.

NEVER:
- Add a private skill or its name to the repository, `.gitignore`, or tracked
  documentation.
- Write a vague one-line summary as `description`.
- Use prose paragraphs in a reference/lessons-learned skill.
- Restate the description inside the body.
- Add filler, "why this matters" text, or narrated reasoning.
- Assume a restart is needed — edits apply live within the session.
- Hand-edit a plugin skill (`plugin:skill` namespace).
