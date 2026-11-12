# __APP__: Agent Rules

## Start of every session

1. `command git status`; never start on a dirty tree or on `main`; branch first.
2. `make help` lists every task; run nothing outside Make.
3. Read `APP.md`, `DOMAIN.md` and `PACKAGES.md` before changing behaviour, names or where code lives.
4. Propose an ADR in `docs/adr/` for each decision; write it only after the owner agrees.

## Never break

1. Edit `project.yml`, never `.pbxproj` or schemes; run `make generate-project`.
2. Build, test, lint and package only through Make targets; packaging runs `make check-release` first.
3. Zero warnings and complete strict concurrency; no `DispatchQueue`, `Thread.isMainThread`, `ObservableObject` or `@Published`.
4. Every system call sits behind a narrow protocol injected through an initialiser; tests use `Fake…` doubles and never touch real user data.
5. New logic ships with tests; non-view coverage stays at or above 80%.
6. Channel-specific code uses the `APPSTORE`/`DIRECT` flags; `#if` only where code cannot exist in the other build.
7. Persisted `UserDefaults` keys and raw values never change once shipped.
8. Use the `DOMAIN.md` vocabulary; lint fails on banned words.
9. User-facing changes are checked in the running app before they are committed.

## Where things are

| Need | Look in |
|---|---|
| What the app is, feature status | `APP.md` |
| Domain objects and vocabulary | `DOMAIN.md` |
| Packages, targets and where new code goes | `PACKAGES.md` |
| Decisions and their reasons | `docs/adr/` |
| App Store files | `appstore/README.md` |
| Setup, checks, release steps | `README.md`, `make help` |

## Commits

- Conventional Commits with a scope: `feat(settings): …`, `fix(search): …`.
- Never push or merge to `main` without the owner's go-ahead.
