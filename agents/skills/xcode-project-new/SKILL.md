---
name: xcode-project-new
description: Create a new macOS app Xcode project from an XcodeGen project.yml template. Use when the user says "new Xcode project", "start a new macOS app", "scaffold an app", "create project.yml", or "set up XcodeGen for a new app". Not for migrating an existing project (follow rules/swift/xcode.md) or for APP.md/DOMAIN.md docs (use swift-project-init-docs).
---

# New Xcode project

1. Ask for app name, slug, bundle ID, team ID, owner and minimum macOS version.
2. Run `~/.claude/skills/xcode-project-new/new-project.sh <dir> <AppName> <slug> <bundle-id> <team-id> "<owner>" [macos]`.
3. Run `git init`, then `make build` and `make test` in `<dir>`.
4. Commit `project.yml`, `Config.xcconfig`, `Makefile`, the workspace, sources and the generated `.xcodeproj`.

## Template

| File | Holds |
|---|---|
| `template/project.yml` | targets, configs, settings, schemes |
| `template/Config.xcconfig` | name, bundle ID, version, team, deployment target |
| `template/Makefile` | `generate-project`, `check-project`, `build`, `test` |
| `template/workspace.xcworkspacedata` | workspace with project and top-level files |

- Add targets, packages and release configurations by editing `project.yml`, then `make generate-project`.
- Copy release channel configs (`Release-AppStore`, `Release-Direct`), settings groups and schemes from Bukku's `project.yml` when the app ships both channels.
