# 0003. Zero warnings

- Status: Accepted __DATE__

## Decision
- `SWIFT_TREAT_WARNINGS_AS_ERRORS` and `GCC_TREAT_WARNINGS_AS_ERRORS` in `project.yml`; `.treatAllWarnings(as: .error)` in every local package.
- `make check-warnings` fails on any warning in project sources in a raw build log.

## Consequences
- Concurrency warnings that come through `@preconcurrency` APIs (for example `RunLoop.main.perform`) are not promoted by warnings-as-errors; the log check catches them.

## Rejected
- A warnings budget: drifts upward.
