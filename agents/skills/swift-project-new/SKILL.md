---
name: swift-project-new
description: Create a new macOS app from an XcodeGen project.yml template with the full day-1 toolchain (Make targets, release gate, lint and vocabulary rules, scans, CI, ADRs, AGENTS.md). Use when the user says "new Xcode project", "start a new macOS app", "scaffold an app", "bootstrap an app", "create project.yml", or "set up XcodeGen for a new app". Not for migrating an existing project (follow rules/swift/xcode.md) or for APP.md/DOMAIN.md docs (use swift-project-docs).
---

# New Xcode project

1. Ask for app name, slug, bundle ID, team ID, owner and minimum macOS version.
2. Run `~/.claude/skills/swift-project-new/new-project.sh <dir> <AppName> <slug> <bundle-id> <team-id> "<owner>" [macos]`.
3. In `<dir>`: `git init`, `make install-hooks`, then `make check-release`; it must pass before the first commit.
4. Commit everything, including the generated `.xcodeproj`.
5. Run `swift-project-docs` for APP.md and DOMAIN.md; add each enforced word to `.swiftlint.yml` `custom_rules` and `scripts/check_strings.py` `BANNED`.
6. Create the Xcode Cloud workflow (test action on `main`) in Xcode; leave GitHub's macOS jobs off (`MACOS_CI` unset).
7. Give the test host a demo or hermetic mode and set its environment variable in every test plan before the first test that touches app services.

## Template

| File | Holds |
|---|---|
| `project.yml`, `xcconfigs/Config.xcconfig` | targets, settings (warnings as errors, MainActor default), name, bundle ID, version, team, `APP_STORE_APP_ID` |
| `Makefile` | build, run, test, coverage, TSan, flaky hunting, warnings check, release gate, lint, analyzer, format, scans, hooks, licences, memory, CPU and launch profiles, App Store status |
| `scripts/` | `check_coverage.py`, `check_warnings.py`, `check_entitlements.py`, `check_strings.py`, `lint-analyze.sh`, `profile-*.sh`, `cpu_profile_top.py`, `launch_time.py`, `appstore_status.py`, `asc.sh`, with tests |
| `.swiftlint.yml`, `.swift-format` | lint rules and vocabulary rules (Fake, Service, read, configuration, British spelling) |
| `lefthook.yml`, `.gitleaks.toml` | pre-commit lint, format, project and secret checks |
| `.github/workflows/ci.yml` | Linux scans on every pull request; macOS jobs behind `vars.MACOS_CI` |
| `.github/dependabot.yml` | configured, off (`open-pull-requests-limit: 0`) |
| `AGENTS.md`, `CLAUDE.md` | never-break rules linking to ADRs; `CLAUDE.md` is `@AGENTS.md` |
| `docs/adr/` | ADRs 0001–0008 for the decisions above |
| `README.md` | setup and the checks table |
| `<slug>/PrivacyInfo.xcprivacy` | no tracking; UserDefaults reason `CA92.1` |

- Add targets, packages and release configurations by editing `project.yml`, then `make generate-project`.
- Copy release channel configs (`Release-AppStore`, `Release-Direct`), entitlement checks and the release scripts from Bukku when the app ships; follow `swift-app-release`.
- Set `ANALYZE_PACKAGES` in the Makefile once local packages exist.
