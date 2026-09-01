---
name: alfred-workflow
description: >
  Use when editing an Alfred workflow's info.plist, wiring Script Filter nodes,
  debugging chained Script Filter behavior (empty query, fallback search,
  argument passing, running placeholder text), writing/updating a workflow's
  README, or publishing a new Alfred workflow repo (GitHub release, visibility,
  cross-linking, blog homepage entry). Trigger on "Alfred workflow", "info.plist",
  "Script Filter", "Args and Vars", keyword chaining, "publish this workflow",
  "workflow README".
---

# Alfred Workflow

ALWAYS:
- Edit info.plist via python plistlib.
- Run `plutil -lint` after editing info.plist, and diff before/after.
- `readlink` a live workflow dir before assuming it's stale — it's a symlink into the repo.
- Use Script Filter Argument "Optional" for live search-as-you-type.
- Pass structured data via an item's `variables` dict, not `arg`/`{query}`.
- Return at least 1 item from a Script Filter for "nothing to show" states.
- Keep UI text (title/subtext/runningsubtext) in info.plist config or the Workflow Variables panel.
- Run scripts standalone (`python3 script.py "arg"`) to check JSON output.
- Have the user manually test real Alfred UI behavior (placeholders, fallback search, argument forwarding) in the app.
- Use `$1`, not literal `{query}`, inside a Script Filter's `script` field in argv mode.
- Grep other installed workflows' info.plist (`plutil -convert json -o -`) for real schema before hand-authoring an unfamiliar object type.
- Use an Argument utility (`argument=""`, `passthroughargument=false`) to clear the query before a downstream live-search Script Filter.
- Fill Script Filter `title`/`subtext` — shown as the loading placeholder row alongside `runningsubtext`.
- Re-save a Config Builder "secure" field in Alfred's UI after renaming its variable in info.plist.
- Isolate/fake `alfred_workflow_cache` per test run when testing outside Alfred.
- Encode List Filter `config.items` as a JSON string of `{title,arg,subtitle,imagefile}` objects.
- Give a Conditional branch's connection a `sourceoutputuid` matching that condition's `uid`; omit it only for the else/default branch.
- Use `{keyword, text, subtext, withspace, argumenttype}` for a Keyword input node.
- Put a native List Filter row's icon file inside a `List Filter Images/` subfolder in the workflow dir — `imagefile` does not resolve arbitrary relative paths or workflow-root files the way Script Filter JSON `icon.path` does.
- Set `scriptargtype: 0` (`{query}` substitution) on a Script Filter that must receive a value from an incoming connection (e.g. a Cmd-modifier jump) — `scriptargtype: 1` (`$1`/argv) does not reliably deliver connection-passed values, only typed/constant ones.
- Suspect prefix-keyword collision (e.g. `wk` vs `wks`) when an unrelated node's title/subtext leaks into a shorter keyword's results — Alfred matches every node whose keyword the typed text is a prefix of.
- Use `ln -sfn`, not `ln -sf`, when scripting live-workflow symlinks — plain `-sf` nests a new symlink inside an existing symlinked directory instead of replacing it, and is silently non-idempotent on rerun.
- Symlink the dev repo straight into Alfred's live workflow folder for hot-reload dev (`src/`, `icons/`, `icon.png`) — this is the documented community-standard pattern (deanishe/alfred-workflow, alfred-link, awf), not a shortcut.
- Suspect the repo's `info.plist` has drifted from the live workflow after any live-UI edit or debugging session — re-run `sync-plist` before trusting either copy.
- Structure a workflow README as: title+one-line description, `## Commands` (keyword as `### heading`, one line per row-shape/behavior), `## Install` (numbered: download release, double-click, Powerpack requirement), `## Setup` only if config/token needed, `## Development` (terse `make` targets with inline `#` comments), `## My Other Workflows` (bullet links to sibling repos).
- Link only already-public sibling repos in a "My Other Workflows" section — a link to a still-private repo 404s for outside viewers; add it once that repo is flipped public.
- Add a new small workflow to the blog homepage's `### projects` bullet list (`content/_index.md`, one line: emoji + `[Name](repo url)` - one-line description) — not a dedicated app landing page, that tier is reserved for full native apps.
- Grep every tracked file for other private-repo names/links before flipping a repo public — a README mentioning an internal/private project by name is a real leak even with no secrets involved.
- `make build` → `make verify` (bundle audit: no local paths, no baked-in token/secret defaults, no junk files, plist script refs resolve, modules import clean) → tag + push + `gh release create`, in that order.
- Re-tag and re-cut the GitHub release after any `git commit --amend` on a repo's history — the old tag stays pointed at the now-orphaned pre-amend commit.
- When wiping a repo to single-commit history: `rm -rf .git && git init`, one commit `feat: Add initial workflow files`, force-push, delete+recreate any existing release tags on the new commit.
- Use verbatim wording when the user dictates exact README text — no embellishing, no added justification/explanation sentences.

NEVER:
- Use Script Filter Argument "Required" when the next chained stage forwards an empty `arg`.
- Use Script Filter Argument "No Argument" for a list needing live search-as-you-type.
- Assume a chained Script Filter's `alfredfiltersresults=true` fuzzy match will hit — the forwarded box text can hide results.
- Word `runningsubtext` as fetch-specific — it shows on every invocation, even instant/no-network paths.
- Hardcode UI text inside .py scripts.
- Treat plistlib's int→float canvas `<real>` diffs (235 → 235.0) as a real change.
- Use literal `{query}` inside a Script Filter's `script` field in argv mode.
- Assume `{query}` fails everywhere — it substitutes fine in non-script fields (Open URL `url`, Conditional `inputstring`).
- Rely on `alfred_workflow_cache` being present when running scripts outside Alfred.
- Conflate "local personal tool over data you already have legitimate access to" with "redistributing a third party's proprietary content as a product" — the licensing caution from one doesn't automatically apply to the other.
- Force-push a history reset over an already-public repo without a fresh explicit confirmation, even right after doing the same reset on a sibling repo.
