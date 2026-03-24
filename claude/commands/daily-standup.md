---
allowed-tools: Bash(git:*)
description: Summarize yesterday's work and suggest today's priorities
---

## Context

- Today's date: !`date "+%d %b %Y"`
- Yesterday's commits (all branches): !`git log --all --since="2 days ago" --until="today" --oneline --author="$(git config user.name)" 2>/dev/null || git log --since="2 days ago" --until="today" --oneline`
- Recent commits with details: !`git log --since="2 days ago" --format="%h %s%n%b" 2>/dev/null | head -60`
- Current branch: !`git branch --show-current`
- Uncommitted changes: !`git status --short`
- Open TODOs touched recently: !`git diff HEAD~5 HEAD 2>/dev/null | grep "^+.*TODO\|^+.*FIXME" | head -10`

## Your task

Generate a daily standup report. Output it directly to the terminal (stdout). Use the date format "27 Jan 2026".

Structure the output exactly like this:

---

# Standup — {today's date in "27 Jan 2026" format}

## 🗓 Yesterday

Summarize what was actually done based on the commits above. Group related commits into 1–3 concise bullet points. Focus on outcomes, not just file names.

## 🚧 Blockers

Based on the commits, uncommitted changes, and open TODOs, identify anything that looks stuck or incomplete:
- Uncommitted work that may indicate an unfinished task
- TODO/FIXME comments added but not resolved
- If nothing looks blocked, write "None identified."

## 🎯 Today's Priorities

Based on what was in progress (uncommitted changes, recent work direction), suggest 2–4 concrete tasks to focus on today. Be specific — reference actual files, features, or issues where possible.

---

Keep the entire output concise. The standup should be readable in under 30 seconds.
