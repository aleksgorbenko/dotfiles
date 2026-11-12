---
name: swift-app-release
description: Release a macOS app to TestFlight, the App Store and direct download (Lemon Squeezy, Gumroad and Sparkle) with Make targets, asc and one copy source. Use for "publish to TestFlight", "upload a new build", "submit for App Store review", "submit for Beta App Review", "TestFlight public link", "set up the release pipeline for a new app", "roll back a release", "write release notes", "App Store description from the blog". Not for single asc commands (use the asc-* skills) or app code patterns (rules/swift).
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
| check | `status-distribution` | `validate-appstore` | `status-appstore` |

- Every target supports `DRY_RUN=1`; publish targets support `SKIP_BUILD=1`.
- Script steps carry the exact name of the target that calls them.
- Builds go through Make (`archive-*`, `export-*`), never raw `xcodebuild` in scripts.
- Submission is always a separate, deliberate run.
- `package-*` depends on `make check-release`; packaging verifies signed entitlements against the source file.
- `make status-appstore` prints versions, builds, Beta App Review state, groups and the public link.
- `make validate-appstore` prints asc submission readiness as a short list; `submit-appstore` runs it first.
- `make status-distribution` checks every channel for `VERSION`: App Store state, GitHub release and DMG, website download link, appcast, website buy links, Lemon Squeezy product and file, Homebrew cask, `vX.Y.Z` tag.
- CI release workflow: `workflow_dispatch` only; `vX.Y.Z` tags belong to the direct release.

## Order for a new version

1. `make bump NEW_VERSION=X.Y.Z`, write `release-notes/X.Y.Z.md`.
2. `make setup-appstore`, `make setup-testflight` (idempotent).
3. `make publish-testflight`; check the build in App Store Connect.
4. `make submit-testflight` when external testers need it.
5. `make publish-appstore`, then `make submit-appstore`.
6. `make publish-direct` for the Direct build (GitHub Release, appcast, blog notes, Lemon Squeezy, tag).
7. `make status-distribution` until every channel is ok.

## Release notes

- One source: `release-notes/X.Y.Z.md`; sections `### New`, `### Improved`, `### Fixed` in that order, bullets only; first release is the single line `Initial release.`.
- Rendered per channel: GitHub as-is, Sparkle `<h3>`+`<ul>`, blog `## X.Y.Z` + italic date, App Store plain text with `•`.
- Versions are semver `X.Y.Z` everywhere.
- The App Store shows no What's New for a first version; skip it for 1.0.0.

## Copy

- Blog page is the source of truth; generate Gumroad, Lemon Squeezy and App Store copy from it.
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
- `make setup-appstore` is the one command for everything App Store: listing, prices, in-app purchases and their review screenshots; never add a second setup target.
- Keep in-app purchase prices in the app config as a schedule (`price`, optional `startDate`); a launch price is the first entry, the full price starts on its date.
- Give each in-app purchase review screenshot its own brand-assets channel and scene; `setup-appstore` stops when one is missing.
- Xcode Cloud compute usage has no App Store Connect API endpoint (checked API 4.5.1) and no `asc` command; it shows only in App Store Connect and the Apple Developer app.

## TestFlight

- Internal group `Team`: internal, access to all builds, every App Store Connect user; no review.
- External group `Public Beta`: public link + feedback; every build needs its own Beta App Review submission (`make submit-testflight`); later builds are approved within minutes.
- What to Test per build = release notes + the WHAT TO TRY section of the review notes + feedback line.
- Review notes sections: ABOUT, WHAT TO TRY (first launch, each permission with the real button labels, shortcut, core actions), ACCOUNT, ENTITLEMENTS, CONTACT.
- Visual assets are not needed for Beta App Review; they are for App Store submission.

## Direct (Sparkle, Homebrew, Gumroad)

- `publish-direct` runs `publish-github-release`, `publish-appcast`, `publish-blog`, `publish-lemonsqueezy`, `publish-tag`; each is also its own target. `unpublish-direct` reverses them.
- Gumroad is out of `publish-direct`; `make publish-gumroad` runs it on its own.
- A Direct release whose code must match an App Store build: branch `release/X.Y.Z` from the submitted commit and cherry-pick only config and tooling commits; publish from that branch.
- `export-direct` passes `-allowProvisioningUpdates`: a Keychain access group needs a Developer ID provisioning profile.
- Homebrew: an official cask in `Homebrew/homebrew-cask`, no own tap. First release: `make prepare-homebrew`, then `make check-homebrew` once the DMG is online, then open the pull request from `homebrew/PULL_REQUEST.md`; answer reviewers yourself. Later versions usually arrive through Homebrew's automatic bump from the appcast; otherwise `brew bump-cask-pr <token> --version X.Y.Z`.
- Clean-machine test: move a TestFlight or App Store copy to the Bin first (root owns it), then `make uninstall PURGE=1`; it does not clear Keychain trial records.
- Gumroad cannot delete files; on detach restore only an older version, never a later hidden one.
- Sparkle compares build numbers: never reuse or go below a build number testers have installed.

## Lemon Squeezy

- Targets use the live API key `LEMON_SQUEEZY_API_KEY`; add `MODE=test` for `LEMON_SQUEEZY_API_KEY_TEST`. `make check SLUG=` compares the product with the live store.
- Products live in `~/src/proj/storefronts/lemonsqueezy/products/<slug>/` (`product.json`, `description.html`, `media/`); every action is a Make target there, never the API, `curl` or a hand edit of the live store.
- New app: `make -C ~/src/proj/storefronts new-product APP= SLUG=`, then create the product in the dashboard (the API cannot create products) and put its IDs in `product.json`.
- Copy: `make generate SLUG=` from the blog page, `make copy-description SLUG=` pastes it as HTML; Lemon Squeezy strips `<code>` and `<pre>`.
- The product name is the SEO title; there are no separate SEO fields.
- `publish-direct` runs `make file SLUG= FILE=`: checks the DMG is notarised and reveals it; the upload itself is by hand.
- After the upload, `make check-file SLUG= FILE=` confirms every variant serves only the new DMG.
- App config: `LEMON_SQUEEZY_STORE_ID`, `LEMON_SQUEEZY_PRODUCT_ID`, `LEMON_SQUEEZY_CHECKOUT_URL` in `Config.xcconfig`; a live product has new IDs and a new checkout URL, and release builds reject test-mode keys.
- Price changes (launch offer end) are made by hand in the dashboard; `storefronts/pricing` compares net revenue per store.
