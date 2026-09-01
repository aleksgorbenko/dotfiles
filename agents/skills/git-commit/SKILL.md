---
name: git-commit
description: >
  Use this skill whenever the user wants to work with git in the terminal — committing files,
  checking status, viewing history, or initializing a repository. Trigger on any mention of
  "git", "commit", "version control", "repo", "repository", "save my changes", "track changes",
  or when the user has been working on files and wants to preserve their progress. Also trigger
  when the user asks to see what changed, check git status, or view commit history. Even if
  the user doesn't say "git" explicitly, use this skill when they want to save or track file
  changes in a project.
---

# Git Skill

Help users manage their code and files with git — focusing on the everyday basics:
initializing repos, staging files, committing with clear messages, checking status,
and viewing history.

## Core Principles

1. **Always check context first.** Before running any git command, understand the current
   state: Is this directory a git repo? Are there uncommitted changes? What branch are we on?
   Run `git status` as a starting point.

2. **Use Conventional Commits.** All commit messages follow the
   [Conventional Commits](https://www.conventionalcommits.org/) format. This matters because
   it creates a machine-readable, human-scannable history that makes projects easier to
   maintain over time.

3. Use emojis at the end of commit message from [gitmoji](https://gitmoji.dev/) if the user seems open to it and it fits the commit type. For
   example, `feat` could use ✨, `fix` could use 🐛, `docs` could use 📚, etc. This is optional
   but can make the commit history more visually engaging.

4. **Explain what you're doing.** Git can feel opaque. Briefly tell the user what each
   command does and why, especially if they seem new to git.

## Conventional Commits Format

Every commit message follows this structure:

```
<type>(<optional scope>): <short description>
```

**Types and when to use them:**

| Type       | When to use                                      | Example                                        |
|------------|--------------------------------------------------|------------------------------------------------|
| `feat`     | Adding new functionality                         | `feat(auth): add login form validation`        |
| `fix`      | Fixing a bug                                     | `fix(api): handle null response from endpoint` |
| `docs`     | Documentation changes only                       | `docs: update README with setup instructions`  |
| `style`    | Formatting, whitespace, semicolons (no logic)    | `style: fix indentation in config file`        |
| `refactor` | Code restructuring without changing behavior     | `refactor(utils): simplify date parsing logic` |
| `test`     | Adding or updating tests                         | `test(auth): add unit tests for login flow`    |
| `chore`    | Build scripts, dependencies, config, maintenance | `chore: update eslint config`                  |

**Guidelines for the description:**
- Use the imperative mood ("add feature" not "added feature")
- Keep it under 72 characters
- Lowercase first letter after the colon
- No period at the end
- Scope is optional — use it when it clarifies which part of the project is affected

**Example 1:**
The user created a new Python script for data processing.
→ `feat(data): add CSV parsing script`

**Example 2:**
The user fixed a typo in their README.
→ `docs: fix typo in installation section`

**Example 3:**
The user refactored a helper function.
→ `refactor(utils): simplify error handling logic`

## Workflow

### Initializing a Repo

If the directory is not a git repo and the user wants to start tracking:

```bash
git init
git add .
git commit -m "chore: initial commit"
```

Before the initial commit, check what's in the directory. If there are files that shouldn't
be tracked (node_modules, .env, __pycache__, .DS_Store, etc.), create or update a `.gitignore`
first. Use common sense about what belongs in `.gitignore` based on the project type.

### Checking Status

When the user wants to know the state of things:

```bash
git status
```

Summarize the output in plain language: which files are new, modified, or staged.
If there's nothing to commit, say so clearly.

### Staging and Committing

When the user wants to commit changes:

1. Run `git status` to see what's changed
2. Run `git diff --stat` for a quick summary of changes (helps craft a good commit message)
3. Look at the actual changes with `git diff` if needed to understand what was modified
4. Stage the appropriate files:
   - `git add .` if all changes should be committed
   - `git add <specific files>` if only some changes should go in
5. Craft a Conventional Commit message based on what actually changed
6. Commit: `git commit -m "<type>(<scope>): <description>"`
7. Never commit your name, always commit using the credentials of the user.

If the changes span multiple types (e.g., a bug fix AND a new feature), prefer separate
commits for each logical change. Ask the user if they'd like to split them up.

### Viewing History

When the user wants to see past commits:

```bash
git log --oneline -10
```

This gives a clean, compact view of recent history. Offer to show more detail
(`git log -p`) or a specific commit if they want to dig deeper.

### Quick Reference

| User says...                        | What to do                                     |
|-------------------------------------|-------------------------------------------------|
| "commit my changes"                 | Status → diff → stage → commit                 |
| "what changed?"                     | `git status` + `git diff --stat`               |
| "start tracking this project"       | Init → gitignore → add → initial commit        |
| "show me the history"               | `git log --oneline -10`                         |
| "save my work" / "save my progress" | Treat as commit request                         |
| "undo my last commit"               | `git reset --soft HEAD~1` (keeps changes staged)|

## Edge Cases

- **Not a git repo:** If `git status` fails, ask if the user wants to initialize one.
- **Nothing to commit:** Let the user know the working tree is clean.
- **Large number of changes:** Summarize the diff stats and suggest grouping related
  changes into separate commits if appropriate.
- **Sensitive files:** Watch for files that look like they contain secrets (.env, credentials,
  API keys). Flag them and suggest adding to `.gitignore` before committing.
- **Merge conflicts:** If encountered, explain the conflict clearly and help resolve it,
  but this skill focuses on basics — don't overcomplicate things.
