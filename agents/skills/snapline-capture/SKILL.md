---
name: snapline-capture
description: Capture clean screenshots of a running macOS app window with the Snapline MCP, for demos, App Store or marketing images, README shots, or checking UI in the real app. Trigger on "screenshot the app", "capture the launcher", "take a demo shot", "grab the window with Snapline", "make demo materials", "check how the window looks", "capture without shadow". Not for screen recordings (Snapline app or ScreenKite) or for making icons (use icons).
---

# Snapline Capture

## Product marketing views (brand-assets-kit)

- Capture every marketing view yourself; never ask the user to change a setting or open a window.
- Capture Liquid Glass only, dark and light; the kit turns Reduce Transparency off with `defaults` and restores it.
- `bun src/cli.ts launch <product>/marketing <view> <light|dark>` opens the backdrop and the view, prints bounds.
- Call `capture_region` (bounds) and `capture_window` (`title`, `shadow: false`) in the same turn.
- `bun src/cli.ts store <product>/marketing <view> <appearance> <region png> <window png>` masks the glass to the window shape.
- Views with `"capture": "glass"` keep the backdrop: `capture_region` only, no window png.
- `bun src/cli.ts restore <product>/marketing` when done; then `make render PRODUCT=<absolute path>`.
- `capture_window` alone flattens Liquid Glass to an opaque fill; it is only the alpha mask.

## Tools

| Tool | Use |
|---|---|
| `capture_window` | One window now; `app` (display name or bundle ID), `title` to narrow, `window_id` from a candidate list, `shadow` (default true) |
| `capture_display` / `capture_region` | Whole screen or a rectangle |
| `get_capture` | Size and path without spending image tokens |
| `get_capture_image` | Pixels; `format: png` when edges or corners matter |
| `export_capture` | Copy into the export folder set in Snapline Settings |
| `capture_text` / `get_capture_text` | Text questions; far cheaper than images |
| `capture_scrolling` / `capture_interactive` | Need the user to act; never call unattended |

## Steps

1. Find the app's display name and bundle ID: `osascript -e 'tell application "System Events" to get {name, bundle identifier} of (every process whose name contains "<App>")'`.
2. Pass the bundle ID to `capture_window`; a debug build has a different display name (e.g. "<App> Debug") and bundle ID.
3. Show a transient window (launcher, popover, panel) through the app's own launch command (e.g. `BUKKU_DEMO_OPEN`), not keystrokes.
4. Capture immediately in the next tool call; any focus change back to the terminal hides a window that closes on deactivate.
5. Call `get_capture` first, then `get_capture_image` only when the pixels are needed.
6. Check transparency at the corners and margin before calling a capture clean (script below).

## Shadow

| `shadow` | Result | Snapline editor |
|---|---|---|
| `true` | System shadow on a transparent margin; follows the window shape | Turn Snapline's own shadow off |
| `false` | Window edge to edge; corners outside the radius transparent | Turn Snapline's shadow on; corner radius 0 or the app's radius |

- Snapline app setting "Include window shadow" matches the `shadow` parameter.
- Square shadow corners mean a stale or unclipped window shadow in the app, not a capture fault.
- A black band around an exported shot is the shadow margin flattened without alpha.
- Captures are at the backing scale: points × 2 on Retina.
- Ask before driving the app with System Events UI scripting; it makes macOS prompt the terminal for Accessibility, and a pending prompt can stall the app under test.

## Alpha check

```swift
import AppKit
for path in CommandLine.arguments.dropFirst() {
    guard let rep = NSBitmapImageRep(data: try! Data(contentsOf: URL(fileURLWithPath: path))) else { continue }
    let w = rep.pixelsWide, h = rep.pixelsHigh
    func a(_ x: Int, _ y: Int) -> String { String(format: "%.2f", rep.colorAt(x: x, y: y)?.alphaComponent ?? -1) }
    print(path, "\(w)x\(h)", "corners:", a(0, 0), a(w - 1, 0), a(0, h - 1), a(w - 1, h - 1), "centre:", a(w / 2, h / 2))
}
```

- Save to the scratchpad, run `swift alpha.swift <png>…`.
- Expect alpha 0.00 at the corners and 1.00 at the centre.
- Zoom a corner with `sips -c <h> <w> --cropOffset <y> <x>` then `sips -z 480 480` and read the result.
