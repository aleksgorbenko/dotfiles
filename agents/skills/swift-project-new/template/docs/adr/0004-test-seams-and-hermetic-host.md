# 0004. Test seams are injected protocols; tests never read real data

- Status: Accepted __DATE__

## Decision
- Every system call sits behind a narrow protocol with one live implementation and one `Fake…` double, injected through initialisers.
- The test host app starts in a demo or hermetic mode, set by an environment variable in every test plan, so tests never read the developer's real data.
- Logging uses an inline `Logger(category:)`; logs are never asserted on or injected.

## Consequences
- Local and CI coverage measure the same code.
- Integration tests use temporary fake files and databases only.

## Rejected
- `#if DEBUG` hooks: tests then exercise different code from what ships.
