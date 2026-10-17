# 0001. Generate the Xcode project with XcodeGen

- Status: Accepted __DATE__

## Decision
- `project.yml` is the source of truth; `make generate-project` writes the `.xcodeproj`; shared settings live in `xcconfigs/Config.xcconfig`.
- Schemes are committed in Xcode's own format; `make check-project` diffs only `.pbxproj`.

## Consequences
- Never edit `.pbxproj` or schemes by hand.
- A setting group with both `groups:` and plain keys drops the plain keys; nest them under `base:`.

## Rejected
- Tuist: heavier, its own manifest language and cache.
- A hand-edited Xcode project: merge conflicts on every branch.
