---
paths:
  - "**/project.yml"
  - "**/*.xcodeproj/**"
  - "**/*.xcworkspace/**"
  - "**/*.xcscheme"
  - "**/*.xctestplan"
  - "**/*.xcconfig"
  - "**/Package.swift"
  - "**/Package.resolved"
  - "**/Makefile"
  - "**/ci_scripts/**"
---
# Xcode

## Project

- Generate every Xcode project from `project.yml` with XcodeGen; never edit `.pbxproj` or `.xcscheme` files by hand.
- Start a new project from the `swift-project-new` skill.
- Set `settingPresets: none` and declare every build setting in `project.yml`: project-wide under `settings`, shared target settings in `settingGroups`.
- Nest a setting group's keys under `base:` whenever the group also lists `groups:`.
- Keep xcconfig files in an `xcconfigs/` folder, point every configuration at them through `configFiles`, and keep values the Makefile or scripts read there.
- Use `syncedFolder` sources and exclude any `INFOPLIST_FILE` from the folder's membership.
- Give local packages that the workspace already lists `excludeFromProject: true`.
- Commit the generated `.xcodeproj` and provide `make generate-project` and `make check-project`, which fails when `.pbxproj` differs from `project.yml`; run `check-project` in CI.
- Commit scheme files in the form Xcode re-saves them and leave them out of `check-project`.
- Diff `xcodebuild -showBuildSettings` for every target and configuration before and after moving a project to XcodeGen.

## Checks

- Make every `package-*` target depend on `make check-release`: project check, lint, analyzer, format, script tests, secret and dependency scans, full tests with coverage, and the warnings check.
- Fail on any warning in project sources by scanning the raw xcodebuild log (`make check-warnings`), on top of `SWIFT_TREAT_WARNINGS_AS_ERRORS`.
- Verify the signed app's entitlements against the source entitlements file after every export.
- Build local packages in parallel for `make lint-analyze` locally, and analyze the test build's raw log in CI.
- Pipe xcodebuild through xcbeautify only through an opt-in Makefile variable, with `set -o pipefail` and the raw log kept by `tee`.
- Provide `make profile-memory`: the Release build recorded with Instruments' Leaks template, printing peak and final memory, the leak count, the largest classes, growth since launch, the `.trace` and the `.memgraph`; `PROFILE_STACKS=1` names allocations by function.
- Provide `make profile-cpu`: the Release build recorded with Time Profiler, printing the top functions by self and total CPU.
- Provide `make profile-launch`: the Release build launched several times under the App Launch template, failing when the median launch exceeds the budget.
- Provide `make status-appstore`: App Store versions, latest builds, Beta App Review state, groups and the public link from `asc`.
- Keep `.github/dependabot.yml` with `open-pull-requests-limit: 0` until the repository is public.

## Workspace

- Give the workspace one `FileRef` per git-tracked top-level file and folder that no project or package already shows, so the navigator lists every non-generated file.
- Never reference the repo root or a folder holding ignored output (build folders, `.build`, worktrees); Xcode ignores `.gitignore` and lists everything inside.

## Build

- Give Debug builds a bundle identifier suffix (`.debug`) and a display name suffix via the xcconfig.
- Keep build, archive and export output in a `build.noindex/` folder and exclude it from SwiftLint.
- Declare every module a package target uses, including modules referenced only through another module's default arguments.
- Commit every `Package.resolved`, including `<Workspace>.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
- Never link a package product into a test target that does not import it.

## Install

- Provide a `make unregister` target that removes every LaunchServices registration of the bundle ID outside `/Applications`, and run it after every install target.
- Test App Intents and Shortcuts only against the copy installed in `/Applications`.

## Test Plans and Schemes

- Select or skip tagged tests through a test plan's Include/Exclude Tags (`selectedTags`/`skippedTags`), never by listing suite names in a Makefile or script.
- Put a narrower run (unit only) in its own test plan referenced by the scheme, and pick it with `-testPlan`.
- Check in a script that every test plan lists the same test targets.
- Never pass `-skip-testing:<Target>/<Suite>` to exclude a category; a stale identifier silently skips nothing.
- Set an environment variable in every test plan that starts the test host app in a demo or hermetic mode.
- Keep UI tests in their own test plan run by `make test-ui`, not in the plans CI runs.
- Pin the xcodebuild test destination to one architecture (`platform=macOS,arch=arm64`) so it never warns about multiple matching destinations.

## CI

- Run macOS CI on Xcode Cloud while the repository is private; keep GitHub's macOS jobs in the workflow behind `if: vars.MACOS_CI == 'true' || github.event_name == 'workflow_dispatch'`.
- Trigger GitHub CI on `pull_request` and `workflow_dispatch` only, never also on branch `push`.
- Run secret and dependency scans in an `ubuntu-latest` job.
- Diagnose Xcode Cloud failures with `asc xcode-cloud build-runs` and `asc xcode-cloud doctor --run-id`.

- Run on a pinned Xcode runner image, assert the Swift version before building, and pass `-skipPackagePluginValidation` to `xcodebuild`.
- Pass ad-hoc signing overrides (`CODE_SIGN_IDENTITY=-`) only on CI runners, never on a developer's Mac.
