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
- Never call StoreKit `purchase()`, `AppStore.sync()` or `SKTestSession` purchases in automated tests; on macOS they reach the real App Store and show an Apple Account sign-in.
- Delete a test-only protocol/double once nothing in the suite calls it anymore.
- Pass an explicit UTC time zone (`TimeZone.gmt`) to date code under test; never rely on the machine's or the test plan's time zone.
- Build fixture dates from ISO 8601 strings (`try Date("2026-02-09T23:00:00Z", strategy: .iso8601)`), never from raw epoch numbers.

## Coverage and Flakiness

- Measure coverage on the full test plan, exclude SwiftUI view files, the `@main` App file and thin `Live…` system adapters, and fail below 80%.
- Cover views with swift-snapshot-testing in light appearance at `perceptualPrecision: 0.98`, and skip snapshot suites where the `__Snapshots__` folder is absent or `SKIP_SNAPSHOTS=1`.
- Repeat a suspect test with `make test-until-failure TESTS=<target/suite>` before calling it fixed.
- Run `performAccessibilityAudit()` in a UI test and ignore issues whose element lies outside the app's window.
- Re-post a notification inside the wait loop when the observer under test subscribes asynchronously.

## Tags

- Mark every integration suite with a tag trait (`@Suite(.tags(.integration))`); tag every suite named `*IntegrationTests`.

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
