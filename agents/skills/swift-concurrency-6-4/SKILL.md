---
name: swift-concurrency-6-4
description: Swift 6.4 concurrency for Xcode 27 apps and packages - MainActor by default, async stays on the caller, @concurrent for background work, isolated conformances and deinit, Task.immediate, task names, async defer, cancellation shields, ~Sendable. Use when writing or reviewing actor, Task, Sendable or isolation code, fixing data-race errors, or setting concurrency build settings.
---

# Swift 6.4 Concurrency

Code runs single-threaded on the main actor by default; concurrency is opt-in and explicit. Checked against Apple Swift 6.4.2 (Xcode 27).

## When to Activate

- Writing or reviewing code with `actor`, `Task`, `async`, `Sendable`, `nonisolated`
- Resolving data-race or isolation compiler errors
- Offloading CPU-heavy or blocking work off the main actor
- Setting concurrency settings in `project.yml` or `Package.swift`

## Settings

`project.yml` (app targets):

```yaml
SWIFT_VERSION: "6.0"
SWIFT_STRICT_CONCURRENCY: complete
SWIFT_APPROACHABLE_CONCURRENCY: YES
SWIFT_DEFAULT_ACTOR_ISOLATION: MainActor
```

`Package.swift` (every target):

```swift
let commonSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .treatAllWarnings(as: .error),
]
```

- A library target with no UI may drop `.defaultIsolation(MainActor.self)`; mark the off-main IO and data layer `nonisolated` instead.
- `NonisolatedNonsendingByDefault` (SE-0461) runs a `nonisolated async` function on the caller's actor; `@concurrent` is the way off it.

## Async Stays on the Caller

```swift
@MainActor
final class StickerModel {
    let photoProcessor = PhotoProcessor()

    func extractSticker(_ item: PhotosPickerItem) async throws -> Sticker? {
        guard let data = try await item.loadTransferable(type: Data.self) else { return nil }
        return await self.photoProcessor.extractSticker(data: data, with: item.itemIdentifier)
    }
}
```

- No "sending risks causing data races" error: the call never leaves the main actor.

## @concurrent for Background Work

```swift
nonisolated final class PhotoProcessor {
    private var cachedStickers: [String: Sticker] = [:]

    func extractSticker(data: Data, with id: String) async -> Sticker {
        if let sticker = self.cachedStickers[id] { return sticker }
        let sticker = await Self.extractSubject(from: data)
        self.cachedStickers[id] = sticker
        return sticker
    }

    @concurrent
    static func extractSubject(from data: Data) async -> Sticker { /* ... */ }
}
```

1. Mark the containing type `nonisolated`.
2. Add `@concurrent` and `async` to the function.
3. `await` at call sites.
4. Arguments and result must be `Sendable`.

## Isolated Conformances

```swift
protocol Exportable {
    func export()
}

extension StickerModel: @MainActor Exportable {
    func export() { self.photoProcessor.exportAsPNG() }
}
```

- The conformance is usable only on the main actor; a `nonisolated` context using it is an error.
- Write `@MainActor` on the conformance explicitly; packages do not enable `InferIsolatedConformances`.

## Global and Static State

```swift
final class StickerLibrary {
    static let shared = StickerLibrary()
}
```

- Implicitly `@MainActor` under default isolation.
- Static mutable state in a `nonisolated` type needs an actor or a `Mutex` from `Synchronization`.

## Actor Around a Blocking System API

```swift
actor AppleScriptRunner {
    func run(_ source: String) throws -> String {
        var error: NSDictionary?
        let output = NSAppleScript(source: source)?.executeAndReturnError(&error)
        return output?.stringValue ?? ""
    }
}
```

- Off the main actor and serialised: no `DispatchQueue`, no locks.

### Parallel task-group fan-out

```swift
actor Poller {
    private let readers: [any Reader]

    func refresh() async {
        await withTaskGroup(of: Result?.self) { group in
            for reader in self.readers {
                group.addTask { await self.read(reader) }
            }
        }
    }

    @concurrent
    private nonisolated func read(_ reader: any Reader) async -> Result? { /* ... */ }
}
```

- A `nonisolated` method reads only immutable `Sendable` `let`s, so child tasks do not queue on the actor.
- Under `NonisolatedNonsendingByDefault`, add `@concurrent` or the method runs on the caller's isolation.

## Tasks

| API | Use |
|---|---|
| `Task.immediate { }` | Runs synchronously on the current actor until the first suspension (SE-0472); work that must start before the next event |
| `Task(name: "load") { }` | Names the task in Instruments and the debugger (SE-0469) |
| `group.addTask(name:)` | Same for child tasks |
| `withTaskCancellationShield { }` | Cleanup that must finish after cancellation; `Task.isCancelled` reads `false` inside (SE-0504) |
| `defer { await cleanup() }` | Async cleanup, awaited before return (SE-0493) |

## Isolated deinit

```swift
final class LauncherController {
    private var monitor: Any?

    isolated deinit {
        if let monitor = self.monitor { NSEvent.removeMonitor(monitor) }
    }
}
```

- `isolated deinit` (SE-0371) runs on the class's actor; use it to release main-actor-only resources.

## Sendable

- Value types crossing an actor boundary are `Sendable`; keep boundary types immutable structs.
- `struct Handle: ~Sendable` stops `Sendable` inference for a type that must stay on one actor (SE-0518).
- `sending` parameters and results move a non-`Sendable` value across a boundary once.
- Never `@unchecked Sendable` to silence an error; use an actor or `Mutex`.

## Best Practices

- Start on the main actor; offload only what Instruments shows is slow.
- `@concurrent` only for CPU-heavy or blocking work.
- `Task.immediate` over `Task` when ordering against UI events matters.
- Name long-lived tasks.
- Isolated conformances over `nonisolated` workarounds.

## Anti-Patterns

> Banned APIs (`DispatchQueue`, `NSLock`, `Thread.isMainThread`, …) live in `rules/swift/swift-anti-patterns.md`.

- `@concurrent` on every async function.
- `nonisolated` or `@preconcurrency` to silence an error without understanding the isolation.
- `nonisolated(unsafe)` on mutable state.
- `MainActor.assumeIsolated` as a bridge; restructure the isolation instead.
- Assuming an `async` function runs in the background.
- Unstructured `Task { }` where `.task { }` or a task group gives cancellation for free.
