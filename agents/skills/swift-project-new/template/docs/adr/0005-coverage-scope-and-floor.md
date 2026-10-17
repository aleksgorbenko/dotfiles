# 0005. Coverage counts non-view code, with an 80% floor

- Status: Accepted __DATE__

## Decision
- `make test-coverage` runs the full test plan and fails below 80%; `scripts/check_coverage.py` excludes SwiftUI views, tests and dependencies.
- Views are covered by snapshot tests and an accessibility audit UI test.
- Snapshot tests skip where reference images are absent (Xcode Cloud runs tests without the source tree) and on CI via `TEST_RUNNER_SKIP_SNAPSHOTS=1`.

## Rejected
- Counting view bodies: rewards meaningless tests.
