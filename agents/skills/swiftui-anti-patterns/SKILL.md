---
name: swiftui-anti-patterns
description: SwiftUI-specific pitfalls to avoid — async work in body/init, misplaced @State ownership, styling drift, Sendable violations, and background-actor list resets. Companion to swiftui-patterns.
---

# SwiftUI Anti-Patterns

SwiftUI-specific mistakes and their fixes. For the language-level banned list (`ObservableObject`,
`@Published`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject`, `AnyView`, `DispatchQueue`,
…) see `rules/swift/swift-anti-patterns.md` — this skill covers view-layer traps that list doesn't.

## When to Activate

- Reviewing or writing SwiftUI views, view models, and state flow
- Diagnosing extra re-renders, lost list selection, or laggy scrolling
- Deciding where state lives and how styling is centralized

## State & lifecycle

- **Async work in `body` or `init`** → use `.task {}` (auto-cancels on disappear) or an explicit
  `load()`/`refresh()` method. `body` must be a pure function of state.
- **View models as `@State` in a child that doesn't own the data** → the child recreates the VM on
  each parent re-render, silently dropping state. Own it in the parent; pass it down as a plain
  `@Observable` reference (no wrapper) or `@Bindable`.
- **`@ObservedObject`-era ownership habits** → own with `@State`, read-only pass without a wrapper,
  two-way bind with `@Bindable`. Pick the smallest wrapper that fits the ownership.
- **Ignoring `Sendable` when passing data to/from actors** → data crossing an actor boundary must be
  `Sendable`; make the DTO a value type, don't smuggle reference types across.
- **ViewModel importing SwiftUI/AppKit** → a VM is `@Observable @MainActor` from `Observation` +
  concurrency, *not* SwiftUI. No `Color`/`NSImage`/`View` in a VM; expose plain data and let the
  View render it.

## Rendering & performance

- **Background actor reassigning an observed array mid-interaction** → retriggers `.onChange` and
  resets list selection / diffs. Prefer pull-based reads (compute on user action), or gate
  notifications on an actual change and use a deterministic order.
- **Array indices as `ForEach` id** → causes wrong-row reuse and animation glitches on
  insert/delete. Use `Identifiable` or a stable `id: \.stableID`.
- **Non-lazy containers for large collections** → wrap in `LazyVStack`/`LazyHStack` inside a
  `ScrollView` so views are built only when visible.
- **`.shadow()`/`.blur()`/`.mask()` in list rows** → offscreen rendering per row; minimize in
  scrolling content. Use `.geometryGroup()`/`.sensoryFeedback()` sparingly too.
- **Monolithic `body`** → extract small focused subviews so a state change re-renders only the
  subview that reads it, not the whole screen.

## Styling

- **Inline `.font(.system(size:…))` / hardcoded colors scattered across views** → drift (the same
  "size 13" copied 5+ places). Centralize as role-named `Font`/`Color` tokens backed by Apple
  semantic styles; never custom fixed sizes. See `swiftui-patterns` → *Styling: token → modifier →
  style → environment*.
- **Hand-rolled modifier for an interactive control** → loses press/focus/disabled state. Use a
  custom `ButtonStyle`/`ToggleStyle` instead.
- **Speculative modifiers/styles for font-only roles** → over-engineering; a token fully serves a
  single-property role. Promote to a `ViewModifier` only when the role needs font + color + spacing.
- **Threading design constants (padding, row width) through inits** → use an `@Entry` environment
  value so the subtree inherits it.

## References

See skill: `swiftui-patterns` for the positive patterns these mirror.
See rules: `rules/swift/swift-anti-patterns.md` for the forbidden APIs + structure conventions.
