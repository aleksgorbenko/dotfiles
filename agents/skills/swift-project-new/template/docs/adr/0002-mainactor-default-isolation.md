# 0002. MainActor by default; the data layer opts out

- Status: Accepted __DATE__

## Decision
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `SWIFT_APPROACHABLE_CONCURRENCY = YES`, `SWIFT_STRICT_CONCURRENCY = complete` in every target.
- Readers, parsers, stores and their protocols are `nonisolated` or actors.

## Consequences
- A `nonisolated async` function runs on the caller's actor; heavy work runs in task-group children or actors.
- `nonisolated` on a protocol does not cover its extension.

## Rejected
- Nonisolated by default with `@MainActor` on UI types: noisier and easier to get wrong.
