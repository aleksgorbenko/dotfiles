# 0006. Packaging is gated by the full check suite

- Status: Accepted __DATE__

## Decision
- `make check-release` runs project, lint, analyzer, format, script tests, secret and dependency scans, the full tests with coverage, and the warnings check.
- Every `package-*` target depends on it and verifies signed entitlements against the source file afterwards.

## Rejected
- An opt-out flag: a gate that can be skipped is not a gate.
