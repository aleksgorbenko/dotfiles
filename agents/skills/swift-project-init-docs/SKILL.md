---
name: swift-project-init-docs
description: Generate or refresh a project's APP.md, DOMAIN.md, and PACKAGES.md through guided clarification questions, and optionally scaffold SwiftLint, Config.xcconfig, and a fastlane App Store release pipeline
---

# Project Docs Init

Generate three foundational reference docs for a project by asking the user targeted questions, not by guessing from the codebase. Re-invocable: running again on a project that already has these files refreshes them instead of starting over.

## Scope

Three files only:
- **APP.md** — product identity: what the app is, philosophy/constraints, feature list + status.
- **DOMAIN.md** — core domain objects: nouns, their key attributes/relationships, terminology.
- **PACKAGES.md** — package/module split: responsibility per package, dependency direction, placement rules.

Optionally (macOS/SwiftPM projects, only if the user asks): scaffold project tooling — SwiftLint, `Config.xcconfig`, and a fastlane App Store release pipeline. See "Tooling scaffold" below.

Out of scope (do not attempt): interface/protocol definitions, method signatures, function-level API contracts between packages, relationship diagrams. That belongs to `architecture-design` — invoke it separately once real code exists, don't pull that thread here even if the user starts describing methods.

## Mode detection

Check whether APP.md, DOMAIN.md, PACKAGES.md exist in the project root.

- **None exist → init mode.** Ask all three question rounds below, then write fresh files.
- **Some/all exist → refresh mode.** Read the existing file(s) first. Show the user a short summary of current content per file, ask what changed (new features shipped, new domain objects, packages added/split/merged), then edit in place — preserve sections the user didn't say changed, don't regenerate wholesale.

## Question rounds

Ask in batches via clarifying questions, not all at once. Skip a round entirely in refresh mode if the user says that file is unchanged.

**1. App identity (→ APP.md)**
- App name, one-line purpose
- Platform/stack (e.g. macOS SwiftUI, web/Next.js, CLI)
- Philosophy/constraints (3-5 bullets: privacy, performance, footprint, distribution model, whatever is load-bearing for this app)
- Core features list with status (shipped / in progress / planned)

**2. Domain objects (→ DOMAIN.md)**
- Core nouns of the system (the things it models, not the UI screens)
- Key attributes and relationships between them
- Terminology to standardize (names that must be used consistently across code and docs)

**3. Package split (→ PACKAGES.md)**
- Proposed packages/modules
- One-line responsibility per package
- Dependency direction: which packages may import which (call out any that must stay leaf/no-dependents)
- Placement rules: for common new-code cases (new data model, new UI feature, new shared util), which package it goes in

## Output structure

**APP.md**
```
# <App Name>

<one-line purpose>

## Philosophy
- bullet per constraint/principle

## Core Features
| Feature | Status |
|---|---|
| ... | ✅ / 🟡 / planned |
```

**DOMAIN.md**
```
# Domain

## <Object Name>
- attributes
- relationships to other objects

(repeat per core object)

## Terminology
- term → definition, only where a name could be ambiguous or is enforced project-wide
```

**PACKAGES.md**
```
# Packages

| Package | Responsibility | Depends on |
|---|---|---|
| ... | ... | ... |

## Placement rules
- New <type of code> goes in `<Package>`, not `<other package>` — because <reason, if non-obvious>
(repeat per case worth calling out; skip cases with an obvious answer)
```

## Tooling scaffold (optional, macOS/SwiftPM)

Only when the user asks. Each piece is independent — offer them, don't force all three. Verify before committing: run the linter clean and the test suites green; never commit secrets.

### SwiftLint

Keep the config **lean** — adopting lint on an existing codebase with everything enabled just yields red CI.

- `.swiftlint.yml` at repo root. Lint production source only:
  - `excluded:` `**/.build`, `Packages/**/.build`, `**/worktrees`, `fastlane`, `scripts`, `Packages/*/Tests`, test target dirs, `**/PreviewData.swift`.
  - `disabled_rules:` opinionated size/complexity metrics (`file_length`, `type_body_length`, `function_body_length`, `function_parameter_count`, `cyclomatic_complexity`, `line_length`) and `todo` — turn on later per-file if wanted.
  - `opt_in_rules:` cheap safe ones (`empty_count`, `first_where`, `explicit_init`, `toggle_bool`, `closure_spacing`, `collection_alignment`, `fatal_error_message`, `prefer_self_in_static_references`, …).
  - Do **not** enable blanket `force_unwrapping` — it conflicts with the nuanced "external data only" rule; leave that to review.
- "Explicit self" and formatting are **SwiftFormat's** job, not SwiftLint — don't try to enforce them here.
- Run `swiftlint --fix` for mechanical cleanups, then fix/relax residuals until `swiftlint lint --strict` is clean.
- Wire into CI as its own job: `brew list swiftlint || brew install swiftlint`, then `swiftlint lint --strict --quiet`.

### Config.xcconfig

Central home for build settings that are duplicated across config blocks/targets.

- `Config.xcconfig` at repo root: `MACOSX_DEPLOYMENT_TARGET`, `SWIFT_VERSION`, `MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`, `DEVELOPMENT_TEAM`.
- Bundle IDs **stay per-target** in the project (they differ) — don't put them here.
- Wire it in Xcode (Project → Info → Configurations → "Based on Configuration File"), then delete the now-duplicated keys from target settings so the xcconfig wins. Do **not** hand-edit `project.pbxproj` fileRefs on a non-trivial project (multiple custom configs / app targets) — too easy to corrupt; the Xcode step is safe.

### fastlane (App Store, metadata-as-code)

- `Gemfile` (`gem "fastlane"`), `fastlane/Appfile` (`app_identifier`, `team_id`), `fastlane/Fastfile`.
- `fastlane/metadata/en-US/*.txt` — every store text field as a committed plain-text file. **`description.txt` is the canonical copy**: reuse it for the marketing site and Gumroad (paste — Gumroad has no API); `marketing_url`/`support_url` point back at the site. Edit once, reuse everywhere.
- Lanes: `metadata` (text/screenshots only, `skip_binary_upload: true`) and `release` (`build_app` → `upload_to_app_store submit_for_review: true`).
- Auth via **App Store Connect API key** (`.p8`) through env (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8` base64) — no password/2FA. Signing via `fastlane match` (private certs repo).
- Tag-triggered GitHub Actions (`on: push: tags: ["v*"]`) runs `bundle exec fastlane release`. Ship = `git tag vX.Y.Z && git push --tags`.
- **Secrets never in git**: `.p8`, signing keys, match password, demo-account passwords → CI secrets + `.gitignore`. Metadata text is public (it's on the store already) — commit it.
- Still manual (Apple-gated): tax/banking agreements, first app-record creation (or `fastlane produce`), review approval itself.

## Instructions

1. Detect mode (init vs refresh) by checking for existing files.
2. Run question round 1, write/update APP.md.
3. Run question round 2, write/update DOMAIN.md.
4. Run question round 3, write/update PACKAGES.md.
5. Confirm file paths written and summarize what changed, in one or two sentences — don't repeat the full file content back.
6. If the user starts describing package interfaces or method signatures during round 3, note that `architecture-design` handles that (invoke it if they want to go there now), and keep this round scoped to responsibility + dependency direction + placement.
7. If the user asked for tooling, scaffold the requested pieces per "Tooling scaffold": get the linter clean and tests green before committing, and never commit secrets.
