---
paths:
  - "**/*.applescript"
  - "**/*.scpt"
  - "**/info.plist"
  - "**/*.swift"
---

# AppleScript Patterns

> This file extends [common/patterns.md](../common/patterns.md) with AppleScript specific content.

## Apple Events

- Read a property for every element in one Apple Event (`URL of every tab of every window`); never loop to read it element by element.
- Fetch each needed property with its own `every` query and pair the lists by index; skip any index beyond the shorter list.
- Read window-level filters (`mode of every window`) in one query inside `try`; treat a failed read as unfiltered.
- Target apps by bundle ID (`tell application id "com.google.Chrome"`), never by name.
- Check that the target app is running before scripting it; `tell application` launches a stopped app.

## Values and Output

- Replace `missing value` with `""` before joining any app-supplied value into text.
- Collect output in a list and join it once with `AppleScript's text item delimiters`; reset the delimiters to `""` afterwards.
- Never build output with repeated `set output to output & …`.
- Separate records with `character id 30` and fields with `character id 31`; never use tabs, commas or newlines.
- Strip only `\r\n ` from script output in Python; plain `str.strip()` also removes the `\x1e`/`\x1f` separators and drops empty trailing fields.

## Output Pitfalls

- Coerce every returned value with `as text` before `return`; a non-text result gives a nil string in `NSAppleScript`.
- Return integers with `as text` and anything else (dates, decimals) as an epoch number or a hand-built string; `as text` follows the user's locale.
- Wrap `count of`, `item n of` and every property read of an app object in `try`; a closed window or a blank tab makes them fail mid-script.
- Never return one value per line; app-supplied titles can contain newlines, tabs and the delimiter itself, so strip `RS`/`US` from titles inside the script when they might appear.

## Compilation

- Keep a polled script's source constant per target; never interpolate per-call data into it.
- Compile each script once and reuse the compiled object: an `NSAppleScript` cache keyed by source in apps, an `osacompile`d `.scpt` in Alfred workflows.

## Errors

- Catch error `-128` (user cancelled) inside the script and return a sentinel; never surface it as a failure.
- Map errors `-1743` and `-1744` to an automation-not-permitted state, never a generic failure.

## Shell

- Pass every interpolated path through `quoted form of` in `do shell script`.
- Escape `\` and `"` in any value written into an AppleScript string literal.
- Run `do shell script … with administrator privileges` only from an explicit user action, never from a background poll.

## Native Apps

- Run AppleScript off the main thread, serialised through one actor-owned executor.
- Call `AEDeterminePermissionToAutomateTarget` only through one shared actor instance; it blocks while a consent prompt is open, and parallel detached calls exhaust the cooperative pool and freeze `NSOpenPanel`.
- In a headless CLI process, run one neutral script on the main thread before any off-main execution.
