# __APP__: Agent Rules

Read this first. Each rule links to the record that explains why.

## Never break

1. Edit `project.yml`, never `.pbxproj` or schemes; run `make generate-project`. [ADR 0001](docs/adr/0001-xcodegen-project.md)
2. Build, test, lint and package only through Make targets; packaging runs `make check-release` first. [ADR 0006](docs/adr/0006-release-gate.md)
3. Zero warnings and complete strict concurrency; no `DispatchQueue`, `Thread.isMainThread`, `ObservableObject` or `@Published`. [ADR 0002](docs/adr/0002-mainactor-default-isolation.md), [ADR 0003](docs/adr/0003-zero-warnings.md)
4. Every system call sits behind a narrow protocol injected through an initialiser; tests use `Fake…` doubles and never touch the developer's real data. [ADR 0004](docs/adr/0004-test-seams-and-hermetic-host.md)
5. New logic ships with tests; non-view coverage stays at or above 80%. [ADR 0005](docs/adr/0005-coverage-scope-and-floor.md)
6. Use the DOMAIN.md vocabulary and string-key shape; lint fails otherwise. [ADR 0007](docs/adr/0007-enforced-vocabulary.md)
7. Persisted `UserDefaults` keys and raw values never change once shipped.
8. User-facing changes are checked in the running app before they are committed.

## Where things are

| Need | Look in |
|---|---|
| What the app is, feature status | `APP.md` |
| Domain objects and vocabulary | `DOMAIN.md` |
| Feature designs | `docs/design/` |
| Decisions and their reasons | `docs/adr/` |
| Setup, checks, release steps | `README.md`, `make help` |

## Commits

- Conventional Commits with a scope: `feat(settings): …`, `fix(search): …`.
- One change per branch; never push or merge to main without the owner's go-ahead.
