---
paths:
  - "**/*.swift"
  - "**/Package.swift"
---
# Swift Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) with Swift specific content.

## Formatting

- SwiftFormat for auto-formatting, SwiftLint for style enforcement
- `swift-format` is bundled with Xcode 16+ as an alternative
- Put each argument on its own line when a call wraps (`lineBreakBeforeEachArgument` in swift-format, `multiline_arguments` in SwiftLint)

## Immutability

- Prefer `let` over `var` — define everything as `let` and only change to `var` if the compiler requires it
- Use `struct` with value semantics by default; use `class` only when identity or reference semantics are needed

## Naming

Follow [Apple API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/):

- Clarity at the point of use — omit needless words
- Name methods and properties for their roles, not their types
- Use `static let` for constants over global constants
- Full descriptive names for dependencies/params, never shorthand or abbreviations
- Name a value for what it actually does, not a loose or vague synonym
- Same name for the same concept across every layer it crosses (config key, init param, call site)
- One name per concept — never introduce a second term for something already named
- A shared dependency/config instance uses the same short name at every reference site, decided once

## Self Reference

- Every type — `class`, `actor`, `struct`, `enum`, SwiftUI `View`/`ViewModifier` — uses explicit `self.property` / `self.method()` for its own members, no implicit self
- Applies inside `body`, `@ViewBuilder` blocks, enum methods — no exception for "declarative" code
- Exception: a local snapshot captured specifically to avoid capturing `self` in a `Task`/closure stays bare (that's the point of the snapshot)

## Comments

- Never reference the current task/fix/caller in a comment — that belongs in the commit message

## Defaults

- A tunable value has exactly one default, owned by the config type that supplies it
- Never repeat the same default in a consuming type's init parameter — inject the config's value, no fallback default at the call site

## Error Handling

Use typed throws (Swift 6+) and pattern matching:

```swift
func load(id: String) throws(LoadError) -> Item {
    guard let data = try? read(from: path) else {
        throw .fileNotFound(id)
    }
    return try decode(data)
}
```

- Convert every Apple API failure (thrown error, `OSStatus`, `Bool` result, AppleScript error number) to a typed error in its live adapter.
- Give each failure a caller handles differently its own case; send the rest to one `failed(reason:)` case that keeps the code and message.
- Log every error an adapter collapses or swallows with its code: `SecCopyErrorMessageString` for `OSStatus`, `URLError.code`, the AppleScript error number, `sqlite3_errmsg`.
- Check the `Bool` from `NSWorkspace.shared.open` and `startAccessingSecurityScopedResource()`; log a `false`.
- Keep a value that resolved when a follow-up step fails (a stale bookmark that can't be refreshed); log the follow-up failure, don't throw.
- Return a distinct failure result to the UI when saving a user's choice fails; never report it as cancelled.
- Show nothing for a user cancellation (StoreKit `userCancelled`, AppleScript `-128`, `URLError.cancelled`).
- Delete and recreate an app-owned SQLite cache (with its `-wal` and `-shm` files) that fails to open, once; crash only if the second open fails.
- Map every `StoreKitError` and `Product.PurchaseError` case to an app error with its own message, gating newer cases with `#available`.
- Check ownership before showing the StoreKit payment sheet, and re-read `Transaction.currentEntitlements` after a failed purchase before reporting the failure.
- Map AppleScript `-600`/`-609` to app not running, `-1728`/`-1719` to object not found and `-1712` to timed out; a tab reader returns no tabs when its browser quit mid-read.
- Never add an error code field or case that no caller branches on.

## Concurrency

Enable Swift 6 strict concurrency checking. Prefer:

- `Sendable` value types for data crossing isolation boundaries
- Actors for shared mutable state
- Structured concurrency (`async let`, `TaskGroup`) over unstructured `Task {}`
