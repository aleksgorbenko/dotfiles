---
name: save-context
description: >
  Use this skill when the user wants to save, preserve, or checkpoint the current
  feature-building context. Trigger on phrases like "save context", "save feature context",
  "checkpoint this", "preserve this context", "save progress notes", or "document what we're building".
---

# Save Context Skill

Save a summary of the current feature-building context to a markdown file in the project's `claude/` directory.

## Purpose

Capture enough context that a future Claude session can pick up exactly where this one left off,
without needing to re-explore the codebase or re-discuss decisions already made.

## Steps

1. **Identify the project root** — use `git rev-parse --show-toplevel` to find it.

2. **Create the `claude/` directory** if it doesn't exist: `mkdir -p <project-root>/claude`.

3. **Determine the filename** — use the feature or branch name as the filename:
   - Get branch: `git rev-parse --abbrev-ref HEAD`
   - Sanitize to lowercase-kebab-case
   - Example: `add-auth-flow` → `claude/add-auth-flow.md`
   - If the user provides a name, use that instead.

4. **Write the context file** with the following structure:

```markdown
# Feature Context: <feature name>

**Branch:** <branch name>
**Date:** <today's date>
**Status:** <in-progress / blocked / ready for review>

## Goal

<1-3 sentences describing what this feature is trying to accomplish>

## Key Files

<list of the most important files touched or relevant to this feature>

## Decisions Made

<bullet list of architectural or implementation decisions made in this session>

## Current State

<what has been implemented so far, and what remains to be done>

## Open Questions / Next Steps

<anything unresolved, blocked, or left for the next session>

## Relevant Context

<any other notes that would help a future session: API shapes, gotchas, constraints, etc.>
```

5. **Confirm** by telling the user the file path where the context was saved.

## Guidelines

- Be specific and concrete — vague summaries are useless.
- Focus on decisions and state, not on restating the code.
- If the user provides additional notes or corrections, incorporate them before writing.
- Do not include the full conversation — distill only what matters for continuity.
- If a context file for this branch already exists, update it rather than creating a new one.
