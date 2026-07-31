---
paths:
  - "**/*.swift"
  - "**/Package.swift"
---
# Swift Testing

> This file extends [common/testing.md](../common/testing.md) with Swift specific content.

## Framework

Use Swift Testing (`import Testing`) for new tests. Use `@Test` and `#expect`:

```swift
@Test("User creation validates email")
func userCreationValidatesEmail() throws {
    #expect(throws: ValidationError.invalidEmail) {
        try User(email: "not-an-email")
    }
}
```

## Logging

- Never assert on log output — logs are not a behavioural contract
- Never inject a `Logger` into a type as a DI/test seam — create it inline as `private let logger = Logger(category: "…")`
- To verify behaviour, assert on return values or an injected protocol double, never on log lines

## Test Isolation

Each test gets a fresh instance — set up in `init`, tear down in `deinit`. No shared mutable state between tests.

- Tests never depend on the state of the machine running them (real files, real installed apps, real network) — inject protocol doubles so tests are hermetic and deterministic.
- Compare paths through the same resolution/canonicalization function on both sides, or inject a fake path resolver — raw string path equality is flaky across symlinked locations.
- Run the full test suite locally on every change until CI is in place, not just the changed subset.
- Delete a test-only protocol/double once nothing in the suite calls it anymore.

## Parameterized Tests

```swift
@Test("Validates formats", arguments: ["json", "xml", "csv"])
func validatesFormat(format: String) throws {
    let parser = try Parser(format: format)
    #expect(parser.isValid)
}
```

## Coverage

```bash
swift test --enable-code-coverage
```

## Reference

See skill: `swift-protocol-di-testing` for protocol-based dependency injection and mock patterns with Swift Testing.
