---
name: snapline
description: See and read this Mac's screen with the Snapline MCP, and capture app windows for UI checks and README shots. Trigger on "look at the app", "screenshot the app", "capture the launcher", "the screenshot I just took", "read the error on screen", "check how the window looks", "capture without shadow". Not for marketing images (use brand-assets), screen recordings (ScreenKite) or icons (use icons).
---

# Snapline

## Habits

- Look before asking: capture or read the screen yourself instead of asking for a screenshot.
- Text question (error, log, terminal, version, URL, table): `capture_text` or `get_capture_text`, not an image.
- Spatial question (layout, colour, spacing, overlap): image.
- Unsure: read text first.
- One window, not the display: `capture_window` with `app` (bundle ID when known) and `title`.

## Tools

| Tool | Use |
|---|---|
| `capture_window` | One window; `app`, `title`, `window_id`, `shadow` (default true) |
| `capture_region` / `capture_display` | A rectangle in points / the whole screen |
| `capture_text` | Recognised text, no file in History |
| `list_captures` | "The screenshot I just took"; `since` (`15m`, `today`), `medium` |
| `search_captures` | Text inside captures, names, dates; cheap |
| `get_capture` | Size and kind before fetching pixels |
| `get_capture_image` | Pixels; `max_pixel`, `format` |
| `get_capture_text` | Text of an existing capture; `layout` `plain`, `table`, `code` |
| `list_collections` | Named groups; id into `list_captures` |
| `export_capture` | Copy to the user's export folder; only when they want a file |
| `capture_scrolling` / `capture_interactive` | Need the user's hands; never unattended |

## Pixels

| Question | `max_pixel` |
|---|---|
| Did it move, rough layout | 800-1000 |
| General look | 1400 (default) |
| Pixel-exact, borders, artefacts | 2000+, `format: png` |

- Never raise `max_pixel` to read text; use the text tools.
- Never go below about 800.
- Tall Captures are constrained on width.

## Several candidates

1. Call again with `title`, or `window_id` when titles match.
2. Pick from context when one title fits the task.
3. Ask the user, naming the candidates.
4. `capture_interactive` as the last resort.

- Never capture every candidate, never fall back to `capture_display`.

## Refusals

- Named toggle: a Snapline Settings > MCP switch is off; tell the user once.
- Denied: the user said no; report and stop.
- Busy with "Nothing was declined": another permission question is up; retry once after it.
- Named activity (recording, Scrolling Capture): wait or ask; no loop.
- Named activation: trial ended; reading still works.
- First capture of a session may wait up to about 45 s for the user's approval; not a hang.

## Build-run-look

1. Change, build, launch; wait for it to render.
2. `capture_window` at `max_pixel` 800-1000 while iterating; full size for the final look.
3. Text results (banner, console): `capture_text`.
4. Every capture lands in History; report roughly how many were taken.

## Window captures

1. Pass the bundle ID to `capture_window`; a debug build has its own name and bundle ID.
2. Open a transient window through the app's own launch command (never keystrokes), then capture in the next call.
3. Check alpha at the corners before calling a capture clean (script below).

| `shadow` | Result |
|---|---|
| `true` | System shadow on a transparent margin |
| `false` | Window edge to edge; corners outside the radius transparent |

- Captures are at backing scale: points × 2 on Retina.
- Square shadow corners mean a stale or unclipped window shadow in the app.
- A black band around an export is the shadow margin flattened without alpha.

```swift
import AppKit
for path in CommandLine.arguments.dropFirst() {
    guard let rep = NSBitmapImageRep(data: try! Data(contentsOf: URL(fileURLWithPath: path))) else { continue }
    let w = rep.pixelsWide, h = rep.pixelsHigh
    func a(_ x: Int, _ y: Int) -> String { String(format: "%.2f", rep.colorAt(x: x, y: y)?.alphaComponent ?? -1) }
    print(path, "\(w)x\(h)", "corners:", a(0, 0), a(w - 1, 0), a(0, h - 1), a(w - 1, h - 1), "centre:", a(w / 2, h / 2))
}
```

- Run `swift alpha.swift <png>…` from the scratchpad; expect 0.00 at the corners, 1.00 at the centre.

## Never

- Snapline Settings "Install skill": it overwrites this file through the symlink.
