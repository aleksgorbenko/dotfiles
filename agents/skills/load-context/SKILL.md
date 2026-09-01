---
name: load-context
description: >
  Use this skill when the user wants to load or resume a previously saved feature context.
  Trigger on phrases like "load context", "resume feature", "pick up where we left off",
  "load my notes", "continue working on", or "restore context".
---

# Load Context Skill

Load a previously saved feature context from the project's `claude/` directory so work can continue seamlessly.

## Steps

1. **Find the project root** — use `git rev-parse --show-toplevel`.

2. **Determine which context file to load:**
   - If the user specified a feature/branch name, look for `claude/<name>.md`
   - Otherwise, default to the current branch: `git rev-parse --abbrev-ref HEAD`
   - List available files with `ls <project-root>/claude/` if the target file doesn't exist

3. **If no matching file exists:**
   - List all `.md` files in `claude/` and ask the user which one to load
   - If the directory is empty or missing, inform the user that no saved context was found

4. **Read the context file** using the Read tool.

5. **Present a concise summary** to the user:
   - Restate the feature goal
   - Current status and what has been done
   - What remains / next steps
   - Any open questions

6. **Confirm readiness** — tell the user you have loaded the context and are ready to continue,
   then ask if they want to pick up at the next step or if anything has changed since last time.

## Guidelines

- Do not just dump the raw file — synthesize and present it clearly.
- After loading, proactively suggest the most logical next action based on the "Next Steps" section.
- If the context file seems outdated (e.g., tasks marked as remaining that are now done), offer to update it.
