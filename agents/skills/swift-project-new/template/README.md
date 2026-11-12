# __APP__

## Setup

- `make install-hooks`: pre-commit lint, format check, project check, staged-secret scan.
- App Store Connect API key in the Keychain (`asc:key-id`, `asc:issuer-id`, `asc:key-p8`).
- Notarisation: `xcrun notarytool store-credentials notary --key AuthKey_XXXX.p8 --key-id <id> --issuer <issuer>`.
- Sparkle: build `__APP__-Direct` once, run Sparkle's `generate_keys -p`, put the key in `SPARKLE_PUBLIC_ED_KEY`.
- `make run` builds and opens the app; `make help` lists every target.

## Checks

| Check | Command | State |
|---|---|---|
| Release gate | `make check-release` | Before every package |
| Coverage floor 80% (views excluded) | `make test-coverage` | Xcode Cloud, release gate |
| Keychain tests | `make test-keychain` | Release gate, local only |
| No warnings | `make check-warnings XCODEBUILD_LOG=…` | Release gate |
| Analyzer rules | `make lint-analyze` | Release gate |
| Lint, prose, spelling, vocabulary | `make lint` | Pre-commit |
| Secret and dependency scans | `make scan-secrets`, `make scan-dependencies` | Every pull request (Linux) |
| Thread Sanitizer | `make test-unit-tsan` | Pull requests on macOS CI |
| Memory, CPU, launch profiles | `make profile-memory`, `make profile-cpu`, `make profile-launch` | Manual |
| macOS CI on GitHub | `gh variable set MACOS_CI --body true` | Off |

## Release

| Step | Direct | App Store | TestFlight |
|---|---|---|---|
| version | `make bump NEW_VERSION=X.Y.Z` | | |
| setup | | `make setup-appstore` | `make setup-testflight` |
| publish | `make publish-direct` | `make publish-appstore` | `make publish-testflight` |
| submit | | `make submit-appstore` | `make submit-testflight` |
| rollback | `make unpublish-direct` | | |
| check | `make status-distribution` | `make validate-appstore` | `make status-appstore` |

- Every step takes `DRY_RUN=1`; publish steps take `SKIP_BUILD=1`.
- Release notes: `release-notes/X.Y.Z.md`.
- Each `publish-direct` step is its own target (`make publish-lemonsqueezy`); Gumroad runs only with `make publish-gumroad`.
- Homebrew, first release: `make prepare-homebrew`, `make check-homebrew` once the DMG is online, then a pull request to `Homebrew/homebrew-cask` with `homebrew/PULL_REQUEST.md`.
