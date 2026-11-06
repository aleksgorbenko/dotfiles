# Workflow standards

Apply to every `alfred-workflow-*` repo.

## Modifier keys

| Key | Meaning | How |
|---|---|---|
| `↩` | Default: open, drill in, open URL | Main connection |
| `⌘↩` | Act or change state (download, deploy, complete) | Modifier connection |
| `⌃↩` | Secondary or destructive act (audio download, cancel, delete) | Modifier connection |
| `⌘C` | Copy the main value (URL, ID, path, text) | `text.copy`, no node |
| `⌘L` | Large type of the same value | `text.largetype` |
| `⌥↩` | Open elsewhere (browser, Finder, live site) | Modifier connection |
| `⌃⌥↩` | Second open-elsewhere target (Terminal, live site) | Modifier connection |
| `⌘⌥↩` | Copy an alternate form (Markdown link, reading) | Modifier connection |
| `⌘⌃↩` | Copy a second alternate form (word with reading) | Modifier connection |
| `⇧` | Preview | `quicklookurl` |
| `⇥` | Autocomplete into the next level | `autocomplete` |

- Destructive actions use `⌃↩`, never `⌘↩` or `↩`.
- Script Filter JSON keys: `cmd`, `alt`, `ctrl`, `shift`, joined with `+` for combinations (`cmd+alt`).
- Modifier connection masks: `⌘` 1048576, `⌥` 524288, `⌃` 262144, `⇧` 131072, `⌘⌥` 1572864, `⌃⌥` 786432, `⌘⌃` 1310720.

## Subtitle hints

- Format: `<info>・<info> · <symbol> <Capitalised phrase>`, e.g. `⌘↩ Download · ⌘C Copy URL`.
- Info parts join with `・`; hints join with ` · `.
- Symbols only: `↩ ⌘↩ ⌃↩ ⌥↩ ⌘⌥↩ ⇥ ⇧ ⌘C`; never write "Enter", "Return", "Cmd", `↵`.
- Phrases are short imperative verb phrases, no articles or sentences: `⌘↩ Download · ⌘C Copy URL`.
- Show at most two hints; show `↩` only when the default is not obvious.
- Keep hint text in `info.plist` `hint_*` variables or one constant per workflow.

## Navigation

- Non-leaf rows set `autocomplete` with a trailing space.
- Path levels join with ` > `; delete the last segment to go back.
- The first row of a page is the page itself.
- Do not chain Script Filters for navigation: one Script Filter reads the whole path and a `router.py` parses it.
- Path segments are readable names, never ids or hosts: a name-to-id map is remembered in the cache and rebuilt by search or by listing the parent page when missing. Repeated names get a qualifier, e.g. `Nevermind (1991, US)`.

## Loading

- Every Script Filter that can wait on a network call or a slow scan returns a `Loading…` row with `rerun: 0.3` instead of blocking; fast cached answers never show it.
- Copy `templates/async_view.py` (and its test) into the workflow: `serve()` runs the view as a detached `--job`, waits 0.35s for the result, and otherwise returns the loading row; the job stores its payload with `finish()`.
- Exceptions in the job become an error row, so the lock never sticks; jobs call `settle()` first so superseded keystrokes do no work.
- Name the wait: `Searching <Service> for '<query>'…` for searches, `Loading <what>…` for pages (Builds, releases, tracks).
- Cache deterministic results on disk (conjugations, search hits); never cache an empty or failed result.

## Icons

- Every workflow renders icons with `icon-symbol.sh --batch <icons.txt> --outdir icons --size 256 --fg "#FFFFFF" --style macos` and `icon.png` at 1024; no per-workflow drawing scripts.

## Makefile

- Every workflow has the same targets with the same shape: `setup` (only `uv sync`), `icons`, `test`, `lint`, `format`, `format-check`, `audit`, `check` (`lint format-check test`), `ci` (`check audit`), `clean`, `build: check`, `verify` (standalone, runs `tools/verify_bundle.py`), `release: build verify`, `sync-plist`, `link-live`.
- Missing a target that a sibling has is a bug; compare the target lists of all workflows after any Makefile change.
- Never add a Brewfile or `brew bundle`.
- Canvas node icons live in `icons/nodes/`; `build` moves them to the bundle root and `link-live` symlinks them into the workflow folder. Never keep UID PNGs in the repo root.
- Nihongo keeps its Makefile, `tools/` and `.github/` untracked on purpose; never commit them.

## Repository README

- Order: header block, `## Commands`, `## Install`, `## Setup` (only if needed), `## Development`, `## My Other Workflows`.
- Layout comes from `templates/README.md`; tables allowed.
- Write each modifier as `⌘↩`, matching the table above.

## Embedded readme (`info.plist` `readme`)

- Follows the Alfred Gallery style guide: `## Setup` (optional), `## Usage`, `## Workflow Configuration` (optional).
- No tables, no other headings.
- Usage: one or two sentences starting with a verb and ending `via the \`keyword\` keyword`, screenshot right below.
- Modifiers: `* <kbd>⌘</kbd><kbd>↩</kbd> Action`.
- Maintenance, navigation and row notes go in Usage as bullets.
- Exclude app installs, API-key steps and required configuration.
- The same text is the template for the Gallery and forum post.

## CLAUDE.md

- One per repo, from `templates/CLAUDE.md`.
- Lists the real `make` targets, code locations and the rules above.
