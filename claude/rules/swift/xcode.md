---
paths:
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
- Pin the xcodebuild test destination to one architecture (`platform=macOS,arch=arm64`) so it never warns about multiple matching destinations.

## CI

- Run on a pinned Xcode runner image, assert the Swift version before building, and pass `-skipPackagePluginValidation` to `xcodebuild`.
- Pass ad-hoc signing overrides (`CODE_SIGN_IDENTITY=-`) only on CI runners, never on a developer's Mac.
