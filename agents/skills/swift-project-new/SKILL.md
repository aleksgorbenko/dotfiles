---
name: swift-project-new
description: Create a new macOS app from an XcodeGen project.yml template with the full day-1 toolchain (Make targets, App Store and Direct release pipelines, release gate, lint and vocabulary rules, scans, CI, AGENTS.md) and its storefront, brand-assets, website and GitHub entries. Use when the user says "new Xcode project", "start a new macOS app", "scaffold an app", "bootstrap an app", "create project.yml", or "set up XcodeGen for a new app". Not for migrating an existing project (follow rules/swift/xcode.md) or for APP.md/DOMAIN.md docs (use swift-project-docs).
---

# New Xcode project

1. Ask for the app name (UpperCamelCase) and minimum macOS version.
2. First time on this Mac: copy `owner.env.example` to `~/.config/swift-project-new/owner.env` (0600) and fill it; it never goes into a repo.
3. Run `~/.claude/skills/swift-project-new/new-project.sh <dir> <AppName> [macos]`.
4. Run every `todo:` line it prints once that repo has the target.
5. In `<dir>`: `git init`, `make install-hooks`, `make check-release`; it must pass before the first commit.
6. Commit everything, including the generated `.xcodeproj` and test plans.
7. Run `swift-project-docs` for APP.md and DOMAIN.md; add each enforced word to `.swiftlint.yml` `custom_rules` and `scripts/check_strings.py` `BANNED`.
8. Propose ADRs for the project's decisions; write each only after the owner agrees.
9. Create the Xcode Cloud workflow (test action on `main`) in Xcode and grant it the private SwiftKit repo in App Store Connect; leave GitHub's macOS jobs off (`MACOS_CI` unset).

## What the script makes

| Part | Holds |
|---|---|
| `project.yml`, `xcconfigs/Config.xcconfig` | App Store and Direct targets (`APPSTORE`/`DIRECT` flags), SwiftKit products per channel (Sparkle in Direct only), unit and UI test targets, settings from the owner profile |
| Test plans | full, unit, UI and Keychain plans written from the generated target IDs; demo variable `<APP>_DEMO=1` |
| `Makefile`, `scripts/` | build, run, install, tests, coverage, TSan, profiles, release gate, lint, scans, and every `package-*`, `preflight-*`, `setup-*`, `publish-*`, `submit-*` and `unpublish-direct` step, with script tests |
| `homebrew/` | cask source; `make publish-direct` renders it into the owner's `homebrew-tap` repo |
| `appstore/` | asc metadata, `app.json`, trial and activation in-app purchases, privacy answers |
| `.github/`, `ci_scripts/` | Linux scans, macOS jobs behind `MACOS_CI`, release workflow, CodeQL, Xcode Cloud scripts |
| `AGENTS.md`, `CLAUDE.md` | start-of-session steps and never-break rules; `CLAUDE.md` is `@AGENTS.md` |
| `docs/adr/README.md` | empty index; no template ADRs |
| Other repos | `storefronts` `new-product`, `brand-assets-kit` `new-product`, website `new-app`, `infra-github` `new-repo` |

- Set `SPARKLE_PUBLIC_ED_KEY`, `APP_STORE_APP_ID`, `LEMON_SQUEEZY_PRODUCT_ID` and `LEMON_SQUEEZY_CHECKOUT_URL` once they exist.
- Add packages and targets by editing `project.yml`, then `make generate-project`; set `ANALYZE_PACKAGES` once local packages exist.
- Reusable code lives in SwiftKit (`https://github.com/aleksgorbenko/SwiftKit`): `SystemKit`, `FuzzyRank`, `UpdaterInterface`, `SparkleUpdater`, `LicenceKit`, `LicenceKitAppStore`, `LicenceKitDirect`, `LicenceKitUI`, `SettingsKit` (Settings tabs, sections, rows, pickers, badges; `LicenceSettingsTabView` lives in `LicenceKitUI`).
