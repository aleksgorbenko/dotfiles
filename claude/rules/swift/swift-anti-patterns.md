---
paths:
  - "**/*.swift"
  - "**/Package.swift"
---
# Swift Anti-Patterns & Conventions

> Canonical single-source list for Swift work. Other Swift skills/rules reference this file
> instead of restate it — keep DRY.

## Forbidden in new code

Don't introduce these. Left = banned, right = use instead.

- `DispatchQueue`, `NSLock`, `OSAllocatedUnfairLock`, `DispatchSemaphore` → actors (serial,
  compiler-checked isolation). Blocking/non-thread-safe system API: wrap in actor.
- `Thread.isMainThread`, `DispatchQueue.main` → `@MainActor` / actor isolation.
- `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject` →
  `@Observable` + `@State` / `@Bindable` / `@Environment`.
- `AnyView` / type erasure for conditionals → `@ViewBuilder` or `Group`.
- Inline/anonymous tuples anywhere — function boundaries, declared property/return types,
  AND local tuple-typed vars (e.g. `let x: (Int, String)`, `let x = (1, "a")`) →
  named `struct` in `Models/`. Exception: destructuring pattern bindings with no tuple-typed
  variable in between, like `for (k, v) in dict`, are fine.
- Search/filter/query logic on data model (e.g. `static func filter` on DTO) → put on
  owning store/service; models stay dumb data.
- `Bool` or closure param that steers runtime behavior (sync-vs-async, prompt-vs-silent)
  or exists only as test seam → model seam as protocol/actor with live implementation
  and test double. Isolation expressed by type, not flag.
- `#if DEBUG` to swap in test behavior → protocol-based DI with injected defaults.
- Force-unwrap data from external sources (files, network, pasteboard, deep links) →
  validate / guard.
- Copy whole external resource (file, database) to scratch location to dodge lock
  or concurrency issue → open resource live, read-only, in place.
- Inject parent/owner object into type that only needs one narrow capability of it →
  inject narrowest protocol type actually uses, typed as `any SomeProtocol`.
- Custom low-level system/library hook or hand-rolled platform extension → native/
  first-party API for same job. Consult current docs for native API before hand-roll.
- Clever/arcane concurrency bridge when plain standard idiom already works → keep
  standard idiom; don't gold-plate working code.
- `Binding` over an `@Observable` property (computed `Binding`, or `@Bindable`)
  passed to `MenuBarExtra(isInserted:)` or other `Scene`-level controls →
  `@AppStorage` on the same raw `UserDefaults` key instead. Confirmed both
  forms loop in a `Scene`: the control's own observer setup writes back
  through the binding, which re-triggers Observation, forever — `@Bindable`
  does not fix this in `Scene.body` the way it does in `View.body`.
- Runtime type check (`as?`, `is`) used to decide what to do next → dispatch through
  protocol method, or single factory/router lookup, instead.
- Production-only fake/dummy implementation of protocol that exists just to satisfy
  default param with no real behavior → seam has exactly one real implementation and
  one test double, never synthetic stand-in shipped in production code.
- Large multi-purpose "context"/"bag" object threaded through many layers → pass only
  specific narrow dependencies function actually uses.
- Speculative fields, cases, params added "for future use" with no current caller →
  add only when real caller needs them.
- Probe or permission-check system entity before confirming it's installed/running →
  gate probe on installed/running state first; don't call into absent target.
- Two types (enums/structs) covering overlapping sets of same real-world cases →
  merge into one type with helper methods; don't duplicate same identifiers across
  multiple files/switch statements.
- Same per-case dispatch (switch over same set of cases) reimplemented in more than
  one file → put in exactly one place, call from everywhere else.
- Dedicated type invented only so one function can switch over its cases → prefer
  plain params or protocol dispatch; remove type if only purpose is routing.

## Project structure conventions

- Feature-first folders, not type-first layers.
- One protocol per file, named `…Protocol.swift` (protocol type keeps clean name).
- One extension per file, named `Type+Extensions.swift`, under `Extensions/` folder.
  No stray/inline extensions living in unrelated feature files — extract out.
- One SwiftUI `View`/`ViewModifier` per file, in owning feature folder (or
  `Modifiers/` subfolder if they proliferate). `View` types take `…View` suffix;
  `ViewModifier` types take `…Modifier` suffix so they read distinct from data types.
  Apply single-use modifier via `.modifier(SomeModifier())` rather than adding stray
  `extension View` convenience; only add `.someModifier()` sugar as proper
  `Type+Extensions.swift` file if reused widely.
- Pure data types go in `Models/`, grouped into feature subfolders; error types go in `Errors/`.
  New pure `struct`/`enum` goes in `Models/` from start, never in feature folder.
- Group cross-cutting concerns under `Core/` (extensions, shared models, keyboard, etc).
  Consolidate single concern in one folder rather than scatter across features.
  No grab-bag "bridge"/"helpers" files holding multiple unrelated types — one type per file.
- Concrete implementation of protocol seam → `Default…` prefix, or `Live…` for real/
  system-backed one paired with test double.

## Databases

- Never add stored functions for SQL databases.