# App Store release

App Store and TestFlight via [`asc`](https://asccli.sh) (`brew install asc`). No Ruby.

## Commands

Both channels: **setup** (app / version information) -> **publish** (upload the build) -> **submit** (Apple review, a separate deliberate step).

| Command | Does |
|---|---|
| `make preflight-appstore` | Tools, semver, release notes format, App Store Connect access |
| `make create-appstore` | New app only: registers the bundle ID, applies capabilities from the entitlements, creates the App Store app record (Apple web session), writes `APP_STORE_APP_ID`; prints the command that opens the project in Xcode |
| `make setup-xcode-cloud` | Creates or updates the Xcode Cloud workflows in `xcode-cloud.json` (`{app}`, `{container}` filled from the Makefile); needs the Xcode Cloud product Xcode creates |
| `make generate-appstore` | `description` + `promotionalText` in `appstore/metadata/version/<version>/__LOCALE__.json` from the blog page (blog is the source of truth; features marked † are Direct-only and left out); `whatsNew` from `release-notes/<version>.md` |
| `make package-appstore` | `archive-appstore` + `export-appstore` to `build.noindex/appstore/export/__APP__.pkg`, no upload |
| `make setup-appstore` | Everything in this folder: version, listing, `app.json` settings, review notes, in-app purchases and prices, screenshots; each step reads App Store Connect first and sends only what differs; stops on a live version |
| `make setup-appstore-promotional-text` | Only `promotionalText`, the one field Apple accepts on a live version |
| `make generate-storekit` | `__APP__.storekit` for local purchases, from `in-app-purchases.json` and `app.json` |
| `make publish-appstore` | Preflight, setup-appstore, package, upload, attach the build to the version |
| `make submit-appstore` | Submit the attached build for App Review |
| `make setup-testflight` | Once per app: TestFlight test information + review contact from `appstore/metadata`, external group `Public Beta` with public link and feedback |
| `make publish-testflight` | Preflight, package, upload, What to Test (release notes + WHAT TO TRY from `review_information/notes.txt`), add to `Public Beta`; skips the upload if the build exists |
| `make submit-testflight` | Submit the build for Beta App Review |
| `gh workflow run release.yml` | `make publish-appstore` + `make submit-appstore` on the `xcode-27` runner |

Same pattern as the Direct build: `package-direct` / `preflight-direct` / `publish-direct`.

- `DRY_RUN=1` prints every mutating asc call; `asc migrate import` runs as a real dry run.
- `SKIP_BUILD=1` reuses `build.noindex/appstore`, like `publish-direct`.
- `scripts/publish-appstore.sh` holds only the asc calls (Keychain auth, version lookup, staging metadata with generated What's New); builds stay in the Makefile.
- Build number: `asc builds next-build-number` (App Store numbering, separate from the Direct build's `CURRENT_PROJECT_VERSION`).
- Tags never trigger it: `vX.Y.Z` belongs to `make publish-direct`.
- Telemetry is off (`ASC_TELEMETRY_DISABLED=1` in `scripts/publish-appstore.sh`).

## Sources

| Field | Source |
|---|---|
| Name, subtitle, description, keywords, URLs, promotional text | `appstore/metadata/__LOCALE__/*.txt` |
| Review contact + notes | `appstore/metadata/review_information/*.txt` |
| Copyright, primary category | `appstore/metadata/copyright.txt`, `primary_category.txt` |
| What's New, What to Test | `release-notes/X.Y.Z.md` via `scripts/release-notes.py appstore`; none for 1.0.0 |
| App ID, team, version | `xcconfigs/Config.xcconfig` (`APP_STORE_APP_ID`, `DEVELOPMENT_TEAM`, `MARKETING_VERSION`) |
| Screenshots | `appstore/screenshots/__LOCALE__/*.png` (untracked; skipped when absent) |

Pull the live listing into `appstore/`:

```bash
asc migrate export --app <APP_STORE_APP_ID> --version-id <VERSION_ID> --output-dir appstore
```

## Auth

- Local: login Keychain items `asc:key-id`, `asc:issuer-id`, `asc:key-p8` (base64 of the `.p8`).
- CI: GitHub secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8` (`base64 -i AuthKey_XXX.p8 | pbcopy`).
- Signing: `-allowProvisioningUpdates` lets Xcode fetch or create certificates and profiles. Locally it uses the Xcode account; CI passes the API key via `XCODE_AUTH` (needs the Admin role).

## Still manual

- Tax, banking, agreements in App Store Connect.
- Apple's review decision.

## Files

| Path | Holds | Format |
|---|---|---|
| `metadata/app-info/<locale>.json` | Name, subtitle, privacy policy URL | `asc metadata` |
| `metadata/version/<version>/<locale>.json` | Description, keywords, URLs, promotional text, What's New; `git mv` the folder for a new version | `asc metadata` |
| `metadata/categories.json` | Primary and secondary category | `asc metadata` |
| `metadata/age-rating.json` | Age rating answers | `asc metadata` |
| `metadata/review-information.json` | App Review and TestFlight contact and notes | `asc metadata` |
| `in-app-purchases.json` | In-app purchases and their names | `asc iap import` |
| `privacy.json` | App Privacy answers, published by `make setup-appstore` | `asc web privacy` |
| `app.json` | Copyright, content rights, app price and territories, in-app purchase prices and offer codes, accessibility, screenshot order, App Sandbox Information | ours, read by `scripts/publish-appstore.sh` |
