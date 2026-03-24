---
name: gh-pr
description: >
  Use this skill when the user wants to create a GitHub Pull Request. Trigger on phrases
  like "create a PR", "open a pull request", "make a PR", "submit PR", "raise a PR".
---

# GitHub Pull Request Skill

Create a draft GitHub Pull Request using the `gh` CLI and open it in the browser.

## Steps

1. **Gather state** — run these in parallel:
   - `git rev-parse --show-toplevel` — project root
   - `git rev-parse --abbrev-ref HEAD` — current branch
   - `git log main...HEAD --oneline` — commits since branching from main
   - `git diff main...HEAD --stat` — files changed

2. **Determine the base branch** — default to `main`. If the repo uses a different default branch, detect it with:
   ```bash
   gh repo view --json defaultBranchRef -q .defaultBranchRef.name
   ```

3. **Find the PR template:**
   - Check if `<project-root>/.github/pull_request_template.md` exists → use it
   - Otherwise fall back to `~/engbook/_template/pull_request_template.md`
   - Read the template file

4. **Draft the PR body** by filling in the template:
   - **Description / context**: summarize what the feature/fix does based on the commits and diff
   - **This PR contains the following changes**: bullet list from `git log` / `git diff --stat`
   - **Proof of Work**: keep the checklist as-is (do not pre-check anything)
   - **Related**: leave blank unless the user provided issue numbers or links

5. **Draft the PR title:**
   - Use Conventional Commits style: `<type>(<scope>): <short description>`
   - Derive from the branch name and commits
   - Keep under 72 characters

6. **Create the PR as a draft and open it in the browser:**
   ```bash
   gh pr create \
     --draft \
     --web \
     --title "<title>" \
     --body "$(cat <<'EOF'
   <filled-in body>
   EOF
   )"
   ```

7. **Return the PR URL** to the user.

## Guidelines

- Always create as `--draft`. Never create a ready-for-review PR unless the user explicitly asks.
- Always pass `--web` to open the browser.
- If the branch has no commits ahead of main, warn the user before proceeding.
- If the branch is not pushed to remote yet, push it first: `git push -u origin <branch>`.
- Do not include raw diff output in the PR body — use the stat summary instead.
- If the user provides a title or description, prefer their wording over the generated one.
