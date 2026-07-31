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

- Default: no comments
- Never explain WHAT the code does — clear naming already does that
- Only comment the WHY when non-obvious: a hidden constraint, an invariant, a workaround for a specific bug
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

## Concurrency

Enable Swift 6 strict concurrency checking. Prefer:

- `Sendable` value types for data crossing isolation boundaries
- Actors for shared mutable state
- Structured concurrency (`async let`, `TaskGroup`) over unstructured `Task {}`
