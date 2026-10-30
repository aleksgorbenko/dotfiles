---
paths:
  - "**/*.swift"
---
# SwiftUI Patterns (essentials)

> Short always-on core; full patterns/examples in skill `swiftui-patterns`. See
> `rules/swift/swift-anti-patterns.md` for forbidden list — DRY, don't restate here.

## MVVM boundaries

- Model: data + domain logic, unaware of View.
- View: dumb, renders state, forwards events, never reached into by VM.
- ViewModel: owns observable view state, translates Model → display, handles intent.
- ViewModel imports no UI framework (`Observation`/`Foundation` only) — no `import SwiftUI`/`AppKit`.

## Property wrapper choice

`@State` local value · `@Binding` two-way to parent `@State` · `@Observable` class + `@State`
owned model · `@Observable` class bare = read-only from parent · `@Bindable` two-way to
`@Observable` prop · `@Environment` shared dependency via `.environment()`.

## Styling: token → modifier → style → environment

Smallest tool that fully expresses the role. Semantic token (one property) → `ViewModifier`
(font+color+spacing bundle) → custom `*Style` (interactive control state) → `@Entry`
environment value (whole-subtree metric). Don't build modifiers/styles speculatively.

Token scope, promoted only on an actual second consumer (never speculatively): private to
one component (`*Style.swift`) → feature-shared (`*Palette.swift` colour, `*Metrics.swift`
sizing) → app-global (`Tokens/*Primitives.swift` / role-named `*Metrics.swift`, created only
once ≥2 features need the same value). `<Feature>UIConfiguration` is reserved for layout that
needs runtime computation (row-count-dependent height), not plain constants. Full table +
decision procedure: skill `swiftui-patterns`.

## Navigation

`NavigationStack` + `NavigationPath`, `Destination: Hashable` enum, `.navigationDestination(for:)`.

## Performance

`LazyVStack`/`LazyHStack` for large collections. Stable `id` in `ForEach`, never array index.
No I/O/network/heavy compute in `body` — use `.task {}`. `Equatable` conformance for
expensive-body views to skip re-renders.

## Fixed-row panels

- Give each row a fixed height constant and size a panel that shows N rows from it; never estimate from font metrics or measure rendered rows at runtime.
- Count N-1 gaps between N stacked rows.
- Arrow Up from the first row selects the query text with no row selected; Down returns to the first row and collapses the text selection.

## AppKit hosting

SwiftUI in manually-managed window (hotkey panel, custom `NSWindow`, status-bar popover) →
AppKit coordinator (`NSWindowController`-style) owns window + `NSHostingView`, constructs
and injects ViewModel. Not part of MVVM — hosts the stack.

## macOS windows and Liquid Glass

- Build every summoned surface of a background menu bar app (launcher, edge slide-out, HUD) as an `NSPanel` with `.nonactivatingPanel`, `canBecomeKey` true, `becomesKeyOnlyIfNeeded = false` and `hidesOnDeactivate = false`, the way Spotlight and Alfred work.
- Show a summoned panel with `orderFrontRegardless()` and `makeKey()` only; never call `NSApp.activate()` for it.
- Hide a summoned panel on `NSWindow.didResignKeyNotification`, never on `NSApplication.didResignActiveNotification`.
- Keep standard windows (Settings, About, onboarding, activation) for everything that is not summoned, and route every Settings entry point through one opener.
- Request `NSApp.activate()` synchronously inside the user action that opens a standard window; never defer it into a `Task` or a delay to fix focus, because since macOS 14 activation is cooperative and a late request can be refused.
- Query a non-activating panel in UI tests through `app.dialogs`, not `app.windows`.
- Give every window a title (hidden with `titleVisibility = .hidden` when the design has none) and mark decorative images `accessibilityHidden(true)`.
- Put Liquid Glass (`glassEffect`, `.glass`, `.glassProminent`) behind `#available(macOS 26, *)` with the pre-26 look as the fallback.
- Set `.buttonBorderShape(.capsule)` once at each window's root view, and give every primary action in every window (including reusable packages) the same style: `.glassProminent` on macOS 26, `.borderedProminent` before.
- Place panels at fractions of the screen's visible frame, never at fixed point offsets.
- Offer picture tiles for few-choice visual settings (theme, position) and top-align the row label with them.
- Preview a placement setting by showing the window there briefly without taking focus.
- Clip the content view of a transparent borderless window to its corner radius (`wantsLayer`, `layer.cornerRadius`, `cornerCurve = .continuous`, `masksToBounds`) so the system shadow follows the rounded shape.
- Call `invalidateShadow()` after every frame change of a transparent window that has `hasShadow`.
- Keep system Liquid Glass under Reduce Transparency and Increase Contrast; never replace it with a solid fill.
- Swap only custom materials, blurs and translucent fills for solid backgrounds when `accessibilityReduceTransparency` is on.
- Switch an accessory (LSUIElement) app to `.regular` while any standard window is open and back to `.accessory` when the last closes, from the one window opener.
- Activate the app in the next main-actor turn after changing the activation policy; an app already active as an accessory still lands last in Cmd-Tab, accept it.
- Use a button, not a link, in a macOS SwiftUI `.alert` message; alert text is never clickable.
- Give a tab that scrolls one inner list a non-scrolling container; a `ScrollView` nested in a scrolling container grows to full height.
- Reserve a 16 pt trailing gutter in a scrolling list whose trailing column holds controls, so the always-shown scroller never covers them.

