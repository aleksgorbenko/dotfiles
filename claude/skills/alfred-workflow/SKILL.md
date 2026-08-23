---
name: alfred-workflow
description: >
  Use when editing an Alfred workflow's info.plist, wiring Script Filter nodes,
  or debugging chained Script Filter behavior (empty query, fallback search,
  argument passing, running placeholder text). Trigger on "Alfred workflow",
  "info.plist", "Script Filter", "Args and Vars", keyword chaining.
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
