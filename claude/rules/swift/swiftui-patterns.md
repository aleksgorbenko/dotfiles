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

## Navigation

`NavigationStack` + `NavigationPath`, `Destination: Hashable` enum, `.navigationDestination(for:)`.

## Performance

`LazyVStack`/`LazyHStack` for large collections. Stable `id` in `ForEach`, never array index.
No I/O/network/heavy compute in `body` — use `.task {}`. `Equatable` conformance for
expensive-body views to skip re-renders.

## AppKit hosting

SwiftUI in manually-managed window (hotkey panel, custom `NSWindow`, status-bar popover) →
AppKit coordinator (`NSWindowController`-style) owns window + `NSHostingView`, constructs
and injects ViewModel. Not part of MVVM — hosts the stack.
