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
- Package each customised Alfred canvas node icon as a root-level PNG named exactly `<node UID>.png`; `config.icon` controls result or placeholder icons, not the canvas node icon.
- Run `plutil -lint` after editing info.plist, and diff before/after.
- `readlink` a live workflow dir before assuming it's stale — it's a symlink into the repo.
- Use Script Filter Argument "Optional" for live search-as-you-type.
- Navigate fixed sections with space-separated words (`<keyword> <section> [filter]`); drill into a picked item with ` > ` written by the row's `autocomplete`; never use `@` or another separator.
- Fetch network pages in a detached `--refresh <page>` process: show a `Loading <Page>…` row with `rerun` 0.5 while uncached, cached rows with `rerun` 1.0 while stale, and retry a cached error on the next open.
- Pass structured data via an item's `variables` dict, not `arg`/`{query}`.
- Return at least 1 item from a Script Filter for "nothing to show" states.
- Keep UI text (title/subtext/runningsubtext) in info.plist config or the Workflow Variables panel.
- Set up tooling before writing any workflow code: `pyproject.toml` from `templates/pyproject.toml`, `Makefile`, shell linter - then write tests.
- Copy `templates/` into every workflow repo: `github/` as `.github/`, `Brewfile`, `.markdownlint-cli2.yaml`, `.editorconfig`; use `ci-private.yml` as `.github/workflows/ci.yml` in a private repo, and drop the `uv` block of `dependabot.yml` when there is no `pyproject.toml`.
- Give the `Makefile` the target set of `templates/Makefile`: `setup test lint lint-* format format-check audit check ci clean build verify release sync-plist link-live`, plus project-specific ones (`vendor`, `icons`); drop `lint-*`/`audit` parts for file types the repo has none of.
- Keep every CI step a Make target: the workflow runs only `make setup` and `make ci`; releases run only from the terminal via `make release VERSION=vX.Y.Z`.
- Make `make setup` install dev tools from the repo `Brewfile` (`brew bundle`) and the Python environment (`uv sync --group dev`).
- Manage Python dev tools (`pytest`, `pytest-cov`, `ruff`, `pyright`, `pip-audit`) as a `uv` dev group: `make setup` runs `uv sync` once, every other target uses `uv run --no-sync`.
- Lint Python at the strictest level: ruff `select = ["ALL"]` (ignore only `COM812`, `CPY`, `D`; tests also `S101`, `S105`, `S106`) plus pyright `typeCheckingMode = "strict"`, both in `lint-python`; zero findings.
- Render every generated row and node icon (SF Symbols, emoji, glyphs, maintenance) on the same macOS grid as `icon.png`: `icon-symbol.sh --style macos` or `icon-polish.sh` after a generator; content images (cover art, thumbnails, avatars) and their colour placeholders stay full-bleed.
- Never polish an icon that is already on the macOS grid (a vendor app icon); it shrinks twice.
- Give every workflow a maintenance menu on `:<main keyword>` (variable-based when the keyword is configurable, e.g. `:{var:keyword}`): copy `templates/src/maintenance.sh`, `templates/icons/maintenance_*.png` and `templates/tests/test_maintenance.py`; rows are `Cache: <size>` (Enter reveals the folder) and `Empty Cache`, then workflow-specific rows; set `skipuniversalaction`; route the action through a Post Notification with `onlyshowifquerypopulated`.
- Never use `<keyword>:<command>` keywords; maintenance commands are rows under `:<keyword>`.
- Run tool-only dependencies (Pillow for icon generators) with `uv run --with <package>`; never add them to the dev group.
- Brace shell variables next to non-ASCII text (`${noun}・`); under a UTF-8 locale bash reads the bytes as part of the name.
- Write every cache and data file with mode 0600 in a 0700 folder, atomically (temp file, then rename); set `os.umask(0o077)` in the entry script so SQLite and other files are private too.
- Give every test fake the full protocol it stands in for (unused methods raise `AssertionError`); never pass `None` for a dependency.
- Run `ruff check --fix` only with safe fixes; never `--unsafe-fixes` without a `--select` list (it deletes `print` calls and comments).
- Close SQLite connections explicitly (`contextlib.closing` or a `@contextmanager` returning `Generator`); `with sqlite3.connect()` only commits.
- Lint every file type the repo has: `ruff` + `pyright` (Python), `shellcheck` (bash), `zsh -n` (zsh), `osacompile` (AppleScript, local only - CI lacks the target app), `plutil -lint` (plist), `jq empty` (JSON), `markdownlint-cli2` (Markdown), `actionlint` (workflows); set `--cov-fail-under=80` in pytest `addopts`.
- Run `make audit` (`pip-audit`) in CI for every repo with a `pyproject.toml`; pin third-party actions by commit SHA with the tag in a trailing comment.
- Render the workflow `icon.png` at 1024px with `icon-polish.sh` (brand logo) or `icon-symbol.sh --style macos` (glyph), so every workflow matches the app-icon grid in Alfred results.
- Capture README and embedded-readme screenshots with `screencapture -o -l <Alfred window id>` while driving Alfred via `tell application id "com.runningwithcrayons.Alfred" to search "<keyword> "`; one screenshot per main keyword, named `images/about/<keyword-role>.png`.
- Write action scripts in bash so `shellcheck` can lint them; lint any zsh script with `zsh -n` only - shellcheck rejects zsh (SC1071).
- Render workflow and result icons with `icon-symbol.sh` (skill `icons`) from a repo `tools/icons.txt` (`<name> <symbol>` lines) behind `make icons`.
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
- Open a workflow README with the `templates/README.md` header: centred 128px icon, `<h1>` "<Name> for Alfred", one-line tagline, badges (CI, release, licence, macOS minimum, Alfred 5 Powerpack), section links, main screenshot.
- Structure the rest of a workflow README as: `## Commands` (keyword as `### heading`, one line per row-shape/behavior), `## Install` (numbered: download release, double-click, Powerpack requirement), `## Setup` only if config/token needed, `## Development` (terse `make` targets with inline `#` comments), `## My Other Workflows` (bullet links to sibling repos).
- Link only already-public sibling repos in a "My Other Workflows" section — a link to a still-private repo 404s for outside viewers; add it once that repo is flipped public.
- List every public workflow in the `config` repo README (`~/src/proj/config`) under `## Alfred` and its category heading (`### Reference`, `### Utilities`, `### Media`), with its 32px icon; update the row whenever the workflow changes.
- Add a new small workflow to the blog homepage's `### projects` bullet list (`content/_index.md`, one line: emoji + `[Name](repo url)` - one-line description) — not a dedicated app landing page, that tier is reserved for full native apps.
- Grep every tracked file for other private-repo names/links before flipping a repo public — a README mentioning an internal/private project by name is a real leak even with no secrets involved.
- `make build` → `make verify` (bundle audit: no local paths, no baked-in token/secret defaults, no junk files, plist script refs resolve, modules import clean) → tag + push + `gh release create`, in that order.
- Re-tag and re-cut the GitHub release after any `git commit --amend` on a repo's history — the old tag stays pointed at the now-orphaned pre-amend commit.
- When wiping a repo to single-commit history: `rm -rf .git && git init`, one commit `feat: Add initial workflow files`, force-push, delete+recreate any existing release tags on the new commit.
- Use verbatim wording when the user dictates exact README text — no embellishing, no added justification/explanation sentences.
- Treat the repository README and Alfred's embedded `info.plist` `readme` as separate documents. The embedded readme follows the Gallery style guide and must not depend on repository-only content.
- Keep the repository README and the embedded readme at the same content, but format each for its renderer: tables in the repository README, `*` bullet lists (e.g. `* Name `code` - detail`) in the embedded readme.
- Store embedded-readme screenshots under `images/` in the workflow root, reference them with relative paths such as `![Description](images/about/main.png)`, and copy them into the exported bundle.
- Put a short explanatory sentence immediately before each embedded-readme screenshot. Captions must say what the screenshot demonstrates, especially for summary or dashboard views.
- Add `images/` to `link-live` and verify every referenced screenshot exists through the live workflow directory before claiming it is visible in Alfred.
- When adding screenshots to several workflows, use the same filenames and relative location only when the screenshots belong to the same documented role. Run each workflow's own `link-live` target from that workflow repository; never run one repository's target against another repository's live directory.
- Before release, inspect the exported archive with `unzip -l` and confirm every embedded-readme image path is present alongside the plist.
- For public workflows, expose the primary keyword in `userconfigurationconfig`, use `{var:VARIABLE}` in every related Keyword or Script Filter node, and include the default keyword and purpose in both READMEs.
- If a configurable primary keyword prefixes maintenance commands, derive those command keywords from the same variable so changing the keyword does not leave stale commands behind.
- Remove private bundle IDs, local paths, example workflow names, and personal setup details from public READMEs and embedded workflow metadata before forum or Gallery publication.
- Do not rewrite or clean a user-authored repository README when the request targets Alfred's embedded `info.plist` `readme`; preserve its wording and structure unless repository README changes are explicitly requested.
- Name every workflow variable (UI text, labels, config) with letters, digits and underscores only; a hyphen is not a valid environment variable name and breaks shell `export`.

NEVER:
- Use Snapline for Alfred screenshots - opening it hides Alfred's window.
- Run anything in CI except Make targets, or trigger a release from CI.
- Run `uv run` without `--no-sync` in `Makefile` targets - it re-syncs the environment on every call.
- Assume older sibling workflows are the tooling reference - they predate `uv`/`shellcheck` (global `ruff`, `python3 -m pytest`); keep their target names, not their tool invocation.
- Put Markdown tables in Alfred's embedded `info.plist` `readme` - Alfred's About view does not render them.
- Use Script Filter Argument "Required" when the next chained stage forwards an empty `arg`.
- Use Script Filter Argument "No Argument" for a list needing live search-as-you-type.
- Assume a chained Script Filter's `alfredfiltersresults=true` fuzzy match will hit — the forwarded box text can hide results.
- Word `runningsubtext` as fetch-specific — it shows on every invocation, even instant/no-network paths.
- Hardcode UI text inside .py scripts.
- Treat plistlib's int→float canvas `<real>` diffs (235 → 235.0) as a real change.
- Use literal `{query}` inside a Script Filter's `script` field in argv mode.
- Assume a workflow icon or a Script Filter result icon supplies a canvas node icon; verify the UID-named PNG exists for every customised node.
- Assume `{query}` fails everywhere — it substitutes fine in non-script fields (Open URL `url`, Conditional `inputstring`).
- Rely on `alfred_workflow_cache` being present when running scripts outside Alfred.
- Conflate "local personal tool over data you already have legitimate access to" with "redistributing a third party's proprietary content as a product" — the licensing caution from one doesn't automatically apply to the other.
- Force-push a history reset over an already-public repo without a fresh explicit confirmation, even right after doing the same reset on a sibling repo.
- Put the user's personal or business data (bundle IDs, company names, app IDs, real commit SHAs, branch names) in tests, fixtures or docs of a public workflow - use neutral examples such as `com.example.Sample`, and grep tracked files before the first commit.
