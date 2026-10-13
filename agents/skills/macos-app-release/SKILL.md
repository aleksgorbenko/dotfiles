---
name: macos-app-release
description: Release a macOS app to TestFlight, the App Store and direct download (Gumroad + Sparkle) with Make targets, asc and one copy source. Use for "publish to TestFlight", "upload a new build", "submit for App Store review", "submit for Beta App Review", "TestFlight public link", "set up the release pipeline for a new app", "roll back a release", "write release notes", "App Store description from the blog". Not for single asc commands (use the asc-* skills) or app code patterns (rules/swift).
---

# macOS App Release

## Targets (`<verb>-<channel>`)

| Step | Direct | App Store | TestFlight |
|---|---|---|---|
| build artefact | `package-direct` | `package-appstore` | (same as App Store) |
| checks | `preflight-direct` | `preflight-appstore` | |
| app / version info | | `setup-appstore` | `setup-testflight` |
| ship build | `publish-direct` | `publish-appstore` (upload + attach, no submit) | `publish-testflight` (upload, What to Test, add to group) |
| Apple review | | `submit-appstore` | `submit-testflight` |
| rollback | `unpublish-direct` | | |

- Every target supports `DRY_RUN=1`; publish targets support `SKIP_BUILD=1`.
- Script steps carry the exact name of the target that calls them.
- Builds go through Make (`archive-*`, `export-*`), never raw `xcodebuild` in scripts.
- Submission is always a separate, deliberate run.
- CI release workflow: `workflow_dispatch` only; `vX.Y.Z` tags belong to the direct release.

## Order for a new version

1. `make bump NEW_VERSION=X.Y.Z`, write `release-notes/X.Y.Z.md`.
2. `make setup-appstore`, `make setup-testflight` (idempotent).
3. `make publish-testflight`; check the build in App Store Connect.
4. `make submit-testflight` when external testers need it.
5. `make publish-appstore`, then `make submit-appstore`.
6. `make publish-direct` for the Gumroad/Sparkle build.

## Release notes

- One source: `release-notes/X.Y.Z.md`; sections `### New`, `### Improved`, `### Fixed` in that order, bullets only; first release is the single line `Initial release.`.
- Rendered per channel: GitHub as-is, Sparkle `<h3>`+`<ul>`, blog `## X.Y.Z` + italic date, App Store plain text with `•`.
- Versions are semver `X.Y.Z` everywhere.
- The App Store shows no What's New for a first version; skip it for 1.0.0.

## Copy

- Blog page is the source of truth; generate Gumroad and App Store copy from it.
- Mark direct-only features with `†` plus an italic note; the App Store generator drops them.
- App Store limits: subtitle 30 chars, promotional text 170, description 4000; no `␣` glyph (spell "+ space").
- Use capitalised headings and `•` bullets in App Store text, not Markdown `#`.

## App Store Connect (asc) lessons

- Metadata locale must match the app record's primary locale (check `asc apps view`); a second locale clashes on the app name.
- `asc migrate import` fails creating review details; create them with `asc review details-create --if-exists update`.
- Always pass `--demo-account-required=false` for App Store and TestFlight review details; asc stores `true` otherwise.
- Export options: `method app-store-connect`, `manageAppVersionAndBuildNumber false`, or Xcode reserves empty upload slots that consume build numbers.
- Delete stale `AWAITING_UPLOAD` slots with `asc builds uploads delete`.
- Builds are immutable: upload a new build number, expire the old one; the version string stays.
- Take the next build number from `asc builds next-build-number`; App Store numbering is separate from Sparkle's.
- Set `ASC_TELEMETRY_DISABLED=1`; read the API key from Keychain locally, from secrets on CI.

## TestFlight

- Internal group `Team`: internal, access to all builds, every App Store Connect user; no review.
- External group `Public Beta`: public link + feedback; first build per version needs Beta App Review.
- What to Test per build = release notes + the WHAT TO TRY section of the review notes + feedback line.
- Review notes sections: ABOUT, WHAT TO TRY (first launch, each permission with the real button labels, shortcut, core actions), ACCOUNT, ENTITLEMENTS, CONTACT.
- Visual assets are not needed for Beta App Review; they are for App Store submission.

## Direct (Gumroad + Sparkle)

- `publish-direct`: GitHub Release, appcast + blog release notes, Gumroad file + page, tag; `unpublish-direct` reverses it in that order.
- Gumroad cannot delete files; on detach restore only an older version, never a later hidden one.
- Sparkle compares build numbers: never reuse or go below a build number testers have installed.
