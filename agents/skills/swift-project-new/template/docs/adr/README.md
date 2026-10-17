# Architecture Decision Records

One page per decision: context, decision, consequences, rejected options. Add a new number for a new decision; supersede, never rewrite.

| # | Decision |
|---|---|
| [0001](0001-xcodegen-project.md) | Generate the Xcode project with XcodeGen |
| [0002](0002-mainactor-default-isolation.md) | MainActor by default; the data layer opts out |
| [0003](0003-zero-warnings.md) | Zero warnings |
| [0004](0004-test-seams-and-hermetic-host.md) | Test seams are injected protocols; tests never read real data |
| [0005](0005-coverage-scope-and-floor.md) | Coverage counts non-view code, with an 80% floor |
| [0006](0006-release-gate.md) | Packaging is gated by the full check suite |
| [0007](0007-enforced-vocabulary.md) | One word per concept, enforced by lint |
| [0008](0008-ci-providers.md) | Xcode Cloud runs macOS CI; GitHub runs Linux scans |
