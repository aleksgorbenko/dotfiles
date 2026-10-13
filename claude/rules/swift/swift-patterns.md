---
paths:
  - "**/*.swift"
  - "**/Package.swift"
---
# Swift Patterns

> This file extends [common/patterns.md](../common/patterns.md) with Swift specific content.

## Protocol-Oriented Design

Define small, focused protocols. Use protocol extensions for shared defaults:

```swift
protocol Repository: Sendable {
    associatedtype Item: Identifiable & Sendable
    func find(by id: Item.ID) async throws -> Item?
    func save(_ item: Item) async throws
}
```

- Any access to a system/external resource (filesystem, network, pasteboard, system APIs) goes behind a protocol, never called directly from business logic.
- One protocol per capability — don't fold unrelated operations into one wide interface.
- Never depend on a concrete owner/parent type when only one of its narrow capabilities is needed — depend on the protocol for that capability instead.
- Never depend on a concrete type at all when a protocol seam is possible — concrete types are for the live implementation, not the dependency's declared type.
- A type with zero protocol seams around its external calls is a test-coverage dead end — if it can't be faked, it can't be tested in isolation.
- A data model never gets a method that makes a system call — extract that call into its own protocol plus a live implementation, and inject it.
- Separate read-path and write-path protocols on the same store when callers only need one side — smaller interfaces over one wide interface.
- Delete a test double or protocol implementation once nothing in production or tests calls it anymore.

## Value Types

- Use structs for data transfer objects and models
- Use enums with associated values to model distinct states:

```swift
enum LoadState<T: Sendable>: Sendable {
    case idle
    case loading
    case loaded(T)
    case failed(Error)
}
```

## Actor Pattern

Use actors for shared mutable state instead of locks or dispatch queues:

```swift
actor Cache<Key: Hashable & Sendable, Value: Sendable> {
    private var storage: [Key: Value] = [:]

    func get(_ key: Key) -> Value? { storage[key] }
    func set(_ key: Key, value: Value) { storage[key] = value }
}
```

## Concurrency Gotchas

- `nonisolated` on a protocol declaration does not carry into that protocol's extension — mark a default-implementation member `nonisolated` explicitly if it must run off the main actor.
- Never mark a protocol `nonisolated` when it already declares an explicit `@MainActor` requirement — contradictory, pick one.
- An actor conforming to a protocol that's called from both actor and `@MainActor` context needs that protocol's members marked `nonisolated`, or every caller pays an actor hop.

## Dependency Injection

Inject protocols with default parameters — production uses defaults, tests inject mocks:

```swift
struct UserService {
    private let repository: any UserRepository

    init(repository: any UserRepository = DefaultUserRepository()) {
        self.repository = repository
    }
}
```

- Default parameter value is the live implementation; the test double is passed explicitly by the caller, never picked via `#if DEBUG` or a runtime flag.
- Never add a parameter to production code that exists only to be a test seam — if it's not a real capability the type uses in production, it doesn't belong in the initializer.
- Prefer constructor injection over property injection or setter injection.

## SwiftUI View Organization

- Order a View file: stored state/inputs, derived/computed properties, `body`, sub-view builders, then action methods — don't interleave them.
- Don't name a stored closure property like it's a function call site is reading a method — keep callback properties and methods visually and semantically distinct.
- Derive UI sizing (spacing, frame dimensions, font sizes) from a small set of base values in one config, not independent hand-picked literals scattered per view.
- Preview code uses the same config/values as production — no separate hardcoded numbers for previews.
- Each visual element (icon, label, badge) appears in exactly one place per row — don't duplicate the same piece of information in two subviews of the same row.
- Represent a multi-key/multi-action hint as a list of discrete items, not one formatted string blob, so more can be added without string parsing.
- Give fixed-size UI regions their own explicit fixed size top-down — don't rely on ad hoc padding to compensate for size drift between them; no unexplained layout shift when content changes.
- Remove a modifier from a previous attempt fully before applying its replacement — don't leave dead layout modifiers stacked under a new one.

## Global Keyboard Shortcuts (macOS)

For user-customizable global keyboard shortcuts, use `sindresorhus/KeyboardShortcuts`
(the de-facto standard, used in thousands of apps) rather than hand-rolling on a raw
hotkey library or a custom recorder. It bundles recording, registration, conflict
handling, and persistence.

```swift
extension KeyboardShortcuts.Name {
    static let toggleApp = Self("toggleApp",
        initial: .init(.space, modifiers: [.command, .option]))
}

KeyboardShortcuts.Recorder(for: .toggleApp)

KeyboardShortcuts.onKeyDown(for: .toggleApp) { [weak self] in … }
```

- The library owns persistence (its own `UserDefaults` key) — do not duplicate the
  shortcut into a separate settings/config type.
- Don't add manual wake/active re-registration observers; the library handles the
  registration lifecycle.

## macOS App Projects

- Give each distribution channel its own positive compilation condition (`APPSTORE`, `DIRECT`); never test the negation of another channel's flag.
- Resolve the channel flag into a runtime value once at the composition root, guarded by `#error` unless exactly one flag is set; everything else reads that value.
- Use `#if <CHANNEL>` only where code cannot exist in the other build (linking a framework, a process entry point).
- Give Debug builds a bundle identifier suffix (`.debug`) and a display name suffix via the xcconfig.
- Keep build, archive and export output in a `build.noindex/` folder and exclude it from SwiftLint.
- Provide a `make unregister` target that removes every LaunchServices registration of the bundle ID outside `/Applications`, and run it after every install target.
- Test App Intents and Shortcuts only against the copy installed in `/Applications`.
- Decide CLI-versus-app launch by the invoked executable name (a lowercase CLI symlink), never by inspecting launch flags.
- Declare every module a package target uses, including modules referenced only through another module's default arguments.
- Inject any call that ends the process (`NSApplication.terminate`) through a protocol.
- In CI, run on a pinned Xcode runner image, assert the Swift version before building, and pass `-skipPackagePluginValidation` to `xcodebuild`.

## References

See skill: `swift-actor-persistence` for actor-based persistence patterns.
See skill: `swift-protocol-di-testing` for protocol-based DI and testing.
