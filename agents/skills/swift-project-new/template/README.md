# __APP__

## Setup

- `brew install xcodegen swiftlint gitleaks osv-scanner lefthook xcbeautify licenseplist`
- `make install-hooks` installs the pre-commit hook: lint, format check, project check, staged-secret scan.
- `make run` builds and opens the app; `make help` lists every target.

| Check | Command | State |
|---|---|---|
| Release gate (all checks + full tests) | `make check-release` | On, before every package |
| Coverage floor 80% (views excluded) | `make test-coverage` | On, macOS CI |
| No warnings in project sources | `make check-warnings XCODEBUILD_LOG=…` | On, macOS CI and release gate |
| Analyzer rules | `make lint-analyze` | On, macOS CI |
| Vocabulary and string keys | `make lint` | On, pre-commit and macOS CI |
| Secret and dependency scans | `make scan-secrets`, `make scan-dependencies` | On, every pull request (Linux) |
| Thread Sanitizer | `make test-tsan` | Manual |
| Memory profile (peak, final, leaks, top classes, growth, .trace, .memgraph) | `make profile-memory` | Manual |
| macOS CI on GitHub | `gh variable set MACOS_CI --body true` | Off ([ADR 0008](docs/adr/0008-ci-providers.md)) |
| Dependabot | remove `open-pull-requests-limit: 0` | Off |
