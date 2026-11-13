#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="${DRY_RUN:-0}"
NOTES="release-notes/$VERSION.md"
APP_CONFIG="appstore/app.json"
LISTING_DIR="appstore/metadata"
REVIEW_INFORMATION="appstore/metadata/review-information.json"
PURCHASES="appstore/in-app-purchases.json"
XCCONFIG="xcconfigs/Config.xcconfig"
ENTITLEMENTS="$APP_NAME/$APP_NAME.entitlements"
XCODE_CLOUD="appstore/xcode-cloud.json"
PRIVACY="appstore/privacy.json"
SCREENSHOT_SOURCE="marketing/output/appstore-mac"
REVIEW_SCREENSHOT_SOURCE="marketing/output/appstore-iap-review"
STAGED_SCREENSHOTS="build.noindex/appstore/screenshots"
TESTFLIGHT_GROUP="Public Beta"
INTERNAL_GROUP="Team"

config() { jq -r "$@" "$APP_CONFIG"; }
same_json() { [ "$(jq -S . <<<"$1")" = "$(jq -S . <<<"$2")" ]; }
unchanged() { log "$1 unchanged"; }
log() { printf '== %s\n' "$*" >&2; }
fail() { echo "error: $*" >&2; exit 1; }
run() {
  if [ "$DRY_RUN" = 1 ]; then printf '[dry-run] %s\n' "$*"; else "$@"; fi
}
run_quiet() {
  if [ "$DRY_RUN" = 1 ]; then printf '[dry-run] %s\n' "$*"; else "$@" >/dev/null; fi
}

secret() {
  if [ -n "${!1:-}" ]; then printf '%s' "${!1}"; else security find-generic-password -a "$USER" -s "$2" -w; fi
}

export ASC_TELEMETRY_DISABLED=1 ASC_BYPASS_KEYCHAIN=1 ASC_APP_ID="$APP_STORE_APP_ID"
ASC_KEY_ID="$(secret ASC_KEY_ID asc:key-id)"
ASC_ISSUER_ID="$(secret ASC_ISSUER_ID asc:issuer-id)"
ASC_PRIVATE_KEY_B64="$(secret ASC_KEY_P8 asc:key-p8)"
export ASC_KEY_ID ASC_ISSUER_ID ASC_PRIVATE_KEY_B64

preflight() {
  log "App Store preflight $APP_NAME $VERSION"
  command -v asc >/dev/null || fail "missing tool: asc (brew install asc)"
  [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "version $VERSION is not semver X.Y.Z"
  [ -f "$NOTES" ] || fail "missing release notes: $NOTES"
  python3 scripts/release-notes.py check "$NOTES"
  asc apps view --id "$APP_STORE_APP_ID" --output json >/dev/null || fail "cannot reach App Store Connect app $APP_STORE_APP_ID"
}

next_build_number() {
  build_number="$(asc builds next-build-number --app "$APP_STORE_APP_ID" --platform MAC_OS --output json | jq -r '.nextBuildNumber')"
  [ -n "$build_number" ] && [ "$build_number" != null ] || fail "cannot read the next App Store build number"
  echo "$build_number"
}

archive_build_number() {
  [ -f "$PKG" ] || fail "missing $PKG - run without SKIP_BUILD=1"
  plutil -extract CFBundleVersion raw "$ARCHIVE/Products/Applications/$APP_NAME.app/Contents/Info.plist"
}

version_id() {
  asc versions list --app "$APP_STORE_APP_ID" --platform MAC_OS --paginate --output json \
    | jq -r --arg version "$VERSION" '.data[] | select(.attributes.versionString == $version) | .id'
}

version_state() {
  asc versions list --app "$APP_STORE_APP_ID" --platform MAC_OS --paginate --output json \
    | jq -r --arg version "$VERSION" '.data[] | select(.attributes.versionString == $version) | .attributes.appStoreState'
}

bundle_resource_id() {
  asc bundle-ids list --identifier "$APP_BUNDLE_ID" --platform MAC_OS --output json \
    | jq -r --arg identifier "$APP_BUNDLE_ID" '.data[] | select(.attributes.identifier == $identifier) | .id'
}

app_id_for_bundle() {
  asc apps list --bundle-id "$APP_BUNDLE_ID" --output json | jq -r '.data[0].id // empty'
}

create_appstore() {
  log "App Store app $APP_NAME ($APP_BUNDLE_ID)"
  [ -f "$ENTITLEMENTS" ] || fail "missing $ENTITLEMENTS"
  local bundle app_id xcode
  bundle="$(bundle_resource_id)"
  if [ -n "$bundle" ]; then
    unchanged "bundle ID $APP_BUNDLE_ID"
  else
    log "bundle ID $APP_BUNDLE_ID"
    run_quiet asc bundle-ids create --identifier "$APP_BUNDLE_ID" --name "$APP_NAME" --platform MAC_OS --output json
    bundle="$(bundle_resource_id)"
  fi
  if [ -n "$bundle" ]; then
    log "capabilities from $ENTITLEMENTS"
    asc bundle-ids capabilities reconcile plan --bundle "$bundle" --entitlements "$ENTITLEMENTS" --ignore-unknown --output table
    run_quiet asc bundle-ids capabilities reconcile apply --bundle "$bundle" --entitlements "$ENTITLEMENTS" --ignore-unknown --confirm --output json
  fi
  app_id="$(app_id_for_bundle)"
  if [ -n "$app_id" ]; then
    unchanged "App Store app $app_id"
  else
    web_session || fail "creating the app needs the Apple web session: run asc web auth login --apple-id EMAIL"
    log "App Store app record"
    run_quiet asc web apps create --name "$APP_NAME" --bundle-id "$APP_BUNDLE_ID" --sku "$APP_SLUG" --platform MAC_OS \
      --primary-locale "$LOCALE" --if-exists skip --auto-rename=false --output json
    app_id="$(app_id_for_bundle)"
  fi
  if [ -n "$app_id" ] && [ "$APP_STORE_APP_ID" != "$app_id" ]; then
    log "APP_STORE_APP_ID = $app_id in $XCCONFIG"
    run sed -i '' "s/^APP_STORE_APP_ID *=.*/APP_STORE_APP_ID = $app_id/" "$XCCONFIG"
  fi
  xcode="$(xcode-select -p)"
  xcode="${xcode%/Contents/Developer}"
  if [ -n "$app_id" ] && [ "$(asc xcode-cloud products list --app "$app_id" --output json | jq '.data | length')" != 0 ]; then
    printf '\nXcode Cloud is connected: run make setup-xcode-cloud to apply %s.\n\n' "$XCODE_CLOUD"
  else
    printf '\nNext: in Xcode choose Integrate > Create Workflow to connect %s to Xcode Cloud, commit the manifest it writes, then run make setup-xcode-cloud.\n\n' "$APP_NAME"
  fi
  printf 'open -a %q %q\n' "$xcode" "$PWD/$XCODE_CLOUD_CONTAINER"
}

setup_xcode_cloud() {
  [ -n "$APP_STORE_APP_ID" ] || fail "no APP_STORE_APP_ID in $XCCONFIG: run make create-appstore"
  local flags=()
  [ "$DRY_RUN" = 1 ] && flags=(--dry-run)
  python3 scripts/xcode_cloud.py setup --app-id "$APP_STORE_APP_ID" --app "$APP_NAME" --container "$XCODE_CLOUD_CONTAINER" \
    --config "$XCODE_CLOUD" "${flags[@]}"
}

setup_appstore_promotional_text() {
  log "App Store $VERSION promotional text"
  local listing dir push_flags=(--confirm)
  listing="$(listing_path)"
  [ -n "$(version_id)" ] || fail "no App Store version $VERSION: run make setup-appstore"
  [ "$DRY_RUN" = 1 ] && push_flags=(--dry-run)
  dir="$(mktemp -d)"
  mkdir -p "$dir/version/$VERSION"
  jq '{promotionalText}' "$listing" > "$dir/version/$VERSION/$LOCALE.json"
  asc metadata push --app "$APP_STORE_APP_ID" --version "$VERSION" --platform MAC_OS --dir "$dir" \
    --include localizations "${push_flags[@]}" --output table
  rm -rf "$dir"
}

listing_path() {
  local listing="$LISTING_DIR/version/$VERSION/$LOCALE.json"
  [ -f "$listing" ] || fail "missing $listing: git mv the previous version folder, then make generate-appstore"
  echo "$listing"
}

setup_appstore() {
  log "App Store $VERSION from appstore/"
  [ "$(version_state)" != READY_FOR_SALE ] \
    || fail "$VERSION is live: Apple accepts only promotional text until the next version; run make setup-appstore-promotional-text"
  local copyright listing
  copyright="$(config .copyright)"
  if [ "$(version_copyright)" = "$copyright" ]; then
    unchanged "version and copyright"
  else
    run_quiet asc versions create --app "$APP_STORE_APP_ID" --platform MAC_OS --version "$VERSION" \
      --copyright "$copyright" --if-exists update --output json
  fi
  version="$(version_id)"
  [ -n "$version" ] || [ "$DRY_RUN" = 1 ] || fail "App Store version $VERSION was not created"
  listing="$(listing_path)"
  if [ "$VERSION" != 1.0.0 ] && [ "$(jq -r '.whatsNew // empty' "$listing")" = "" ]; then
    fail "$listing has no whatsNew: run make generate-appstore"
  fi
  if [ -z "$version" ]; then
    echo "[dry-run] asc metadata push --version $VERSION --dir $LISTING_DIR"
  else
    local push_flags=(--confirm)
    [ "$DRY_RUN" = 1 ] && push_flags=(--dry-run)
    asc metadata push --app "$APP_STORE_APP_ID" --version "$VERSION" --platform MAC_OS --dir "$LISTING_DIR" \
      --include localizations,categories,age-rating,review-information "${push_flags[@]}" --output table
    setup_sandbox_entitlements
  fi
  setup_content_rights
  setup_privacy
  setup_pricing
  setup_accessibility
  setup_purchases
  setup_purchase_review_screenshots
  setup_screenshots
}

version_copyright() {
  asc versions list --app "$APP_STORE_APP_ID" --platform MAC_OS --paginate --output json \
    | jq -r --arg version "$VERSION" '.data[] | select(.attributes.versionString == $version) | .attributes.copyright // empty'
}

review_information() {
  jq -r ".$1" "$REVIEW_INFORMATION"
}

review_contact() {
  jq -c '{contactFirstName, contactLastName, contactEmail, contactPhone, notes, demoAccountRequired}' "$REVIEW_INFORMATION"
}

remote_review_contact() {
  jq -c '(.data | if type == "array" then .[0] else . end).attributes // {}
    | {contactFirstName, contactLastName, contactEmail, contactPhone, notes, demoAccountRequired}'
}

setup_content_rights() {
  local wanted
  wanted="$(config .contentRights)"
  if [ "$(asc apps view --id "$APP_STORE_APP_ID" --output json | jq -r '.data.attributes.contentRightsDeclaration // empty')" = "$wanted" ]; then
    unchanged "content rights"
    return
  fi
  log "content rights"
  run_quiet asc apps update --id "$APP_STORE_APP_ID" --content-rights "$wanted" --output json
}

web_session() {
  [ "$(asc web auth status --output json | jq -r .authenticated)" = true ]
}

setup_privacy() {
  local remote
  if ! web_session; then
    log "WARNING: App Privacy not set: no Apple web session. Run asc web auth login --apple-id EMAIL, then make setup-appstore"
    return
  fi
  remote="$(asc web privacy pull --app "$APP_STORE_APP_ID" --output json)"
  if ! same_json "$(jq -c .declaration <<<"$remote")" "$(jq -c . "$PRIVACY")"; then
    log "App Privacy answers"
    run_quiet asc web privacy apply --app "$APP_STORE_APP_ID" --file "$PRIVACY" --output json
  fi
  if [ "$(jq -r .publishState.published <<<"$remote")" = true ] && same_json "$(jq -c .declaration <<<"$remote")" "$(jq -c . "$PRIVACY")"; then
    unchanged "App Privacy"
    return
  fi
  log "App Privacy: publish"
  run_quiet asc web privacy publish --app "$APP_STORE_APP_ID" --confirm --output json
}

setup_sandbox_entitlements() {
  local entitlement remote
  if ! web_session; then
    log "WARNING: App Sandbox Information not set: no Apple web session. Run asc web auth login --apple-id EMAIL, then make setup-appstore"
    return
  fi
  remote="$(asc web review sandbox-entitlements list --version-id "$version" --output json)"
  while IFS= read -r entitlement; do
    if [ "$(jq -r --arg key "$entitlement" '.data[] | select(.relationships.appSandboxEntitlement.data.id == $key) | .attributes.justification' <<<"$remote")" \
      = "$(config --arg key "$entitlement" '.sandboxEntitlements[$key]')" ]; then
      unchanged "App Sandbox Information for $entitlement"
      continue
    fi
    log "App Sandbox Information for $entitlement"
    run_quiet asc web review sandbox-entitlements set --version-id "$version" --entitlement "$entitlement" \
      --justification "$(config --arg key "$entitlement" '.sandboxEntitlements[$key]')" --confirm --output json
  done < <(config '.sandboxEntitlements | keys[]')
}

setup_testflight() {
  local localizations localization wanted remote_review groups group
  log "TestFlight test information and $TESTFLIGHT_GROUP group"
  wanted="$(jq -n --arg description "$(jq -r '.description' "$LISTING_DIR/version/$VERSION/$LOCALE.json")" \
    --arg feedback "$(review_information contactEmail)" \
    --arg marketing "$(jq -r '.marketingUrl' "$LISTING_DIR/version/$VERSION/$LOCALE.json")" \
    --arg privacy "$(jq -r '.privacyPolicyUrl' "$LISTING_DIR/app-info/$LOCALE.json")" \
    '{description: $description, feedbackEmail: $feedback, marketingUrl: $marketing, privacyPolicyUrl: $privacy}')"
  localizations="$(asc testflight app-localizations list --app "$APP_STORE_APP_ID" --output json)"
  localization="$(jq -r --arg locale "$LOCALE" '.data[] | select(.attributes.locale == $locale) | .id' <<<"$localizations")"
  localization_fields=(--description "$(jq -r .description <<<"$wanted")" --feedback-email "$(jq -r .feedbackEmail <<<"$wanted")"
    --marketing-url "$(jq -r .marketingUrl <<<"$wanted")" --privacy-policy-url "$(jq -r .privacyPolicyUrl <<<"$wanted")")
  if [ -z "$localization" ]; then
    run_quiet asc testflight app-localizations create --app "$APP_STORE_APP_ID" --locale "$LOCALE" "${localization_fields[@]}" --output json
  elif same_json "$(jq -c --arg locale "$LOCALE" '.data[] | select(.attributes.locale == $locale) | .attributes
      | {description, feedbackEmail, marketingUrl, privacyPolicyUrl}' <<<"$localizations")" "$wanted"; then
    unchanged "TestFlight test information"
  else
    run_quiet asc testflight app-localizations update --id "$localization" "${localization_fields[@]}" --output json
  fi
  remote_review="$(asc testflight review view --app "$APP_STORE_APP_ID" --output json | remote_review_contact)"
  if same_json "$remote_review" "$(review_contact)"; then
    unchanged "TestFlight review contact and notes"
  else
    run_quiet asc testflight review edit --id "$APP_STORE_APP_ID" \
      --contact-first-name "$(review_information contactFirstName)" \
      --contact-last-name "$(review_information contactLastName)" \
      --contact-email "$(review_information contactEmail)" \
      --contact-phone "$(review_information contactPhone)" \
      --notes "$(review_information notes)" --demo-account-required=false --output json
  fi
  groups="$(asc testflight groups list --app "$APP_STORE_APP_ID" --paginate --output json)"
  group="$(jq -c --arg name "$TESTFLIGHT_GROUP" '.data[] | select(.attributes.name == $name)' <<<"$groups")"
  if [ -z "$group" ]; then
    run_quiet asc testflight groups create --app "$APP_STORE_APP_ID" --name "$TESTFLIGHT_GROUP" \
      --public-link-enabled --feedback-enabled --output json
  elif [ "$(jq -r '.attributes.publicLinkEnabled and .attributes.feedbackEnabled' <<<"$group")" = true ]; then
    unchanged "$TESTFLIGHT_GROUP group"
  else
    run_quiet asc testflight groups edit --id "$(jq -r .id <<<"$group")" --public-link-enabled --feedback-enabled --output json
  fi
  setup_internal_group
}

setup_internal_group() {
  log "TestFlight $INTERNAL_GROUP group: every App Store Connect user, every build"
  internal="$(asc testflight groups list --app "$APP_STORE_APP_ID" --paginate --output json \
    | jq -r --arg name "$INTERNAL_GROUP" '.data[] | select(.attributes.name == $name) | .id')"
  if [ -z "$internal" ]; then
    run_quiet asc testflight groups create --app "$APP_STORE_APP_ID" --name "$INTERNAL_GROUP" \
      --internal --access-all-builds --feedback-enabled --output json
    [ "$DRY_RUN" = 1 ] && return
    internal="$(asc testflight groups list --app "$APP_STORE_APP_ID" --paginate --output json \
      | jq -r --arg name "$INTERNAL_GROUP" '.data[] | select(.attributes.name == $name) | .id')"
  fi
  members="$(asc testflight testers list --app "$APP_STORE_APP_ID" --group "$internal" --paginate --output json \
    | jq -r '.data[].attributes.email')"
  for email in $(asc users list --paginate --output json | jq -r '.data[].attributes.username'); do
    grep -qxF "$email" <<<"$members" || run_quiet asc testflight testers add --app "$APP_STORE_APP_ID" \
      --email "$email" --group "$internal" --output json
  done
}

test_notes() {
  build_number="$(archive_build_number)"
  log "What to Test for $VERSION ($build_number)"
  build=(--app "$APP_STORE_APP_ID" --platform MAC_OS --version "$VERSION" --build-number "$build_number" --locale "$LOCALE")
  what_to_test="$(python3 scripts/release-notes.py what-to-test "$NOTES" \
    --review-information "$REVIEW_INFORMATION" \
    --feedback-email "$(review_information contactEmail)")"
  existing="$(asc builds test-notes list --app "$APP_STORE_APP_ID" --platform MAC_OS --version "$VERSION" \
    --build-number "$build_number" --locale "$LOCALE" --output json | jq -r '.data | length')"
  if [ "$existing" -gt 0 ]; then
    run_quiet asc builds test-notes update "${build[@]}" --whats-new "$what_to_test" --output json
  else
    run_quiet asc builds test-notes create "${build[@]}" --whats-new "$what_to_test" --output json
  fi
}

build_id() {
  asc builds list --app "$APP_STORE_APP_ID" --output json \
    | jq -r --arg build "$1" '.data[] | select(.attributes.version == $build) | .id' | head -1
}

build_uploaded() {
  [ -n "$(build_id "$1")" ]
}

publish_testflight() {
  build_number="$(archive_build_number)"
  if build_uploaded "$build_number"; then
    log "TestFlight build $VERSION ($build_number) is already uploaded"
  else
    log "TestFlight upload of $VERSION ($build_number)"
    run asc publish testflight --app "$APP_STORE_APP_ID" --platform MAC_OS --pkg "$PKG" \
      --version "$VERSION" --build-number "$build_number" --upload-only --wait --output json
  fi
  test_notes
  log "$TESTFLIGHT_GROUP: add $VERSION ($build_number)"
  run_quiet asc builds add-groups --app "$APP_STORE_APP_ID" --platform MAC_OS --version "$VERSION" \
    --build-number "$build_number" --group "$TESTFLIGHT_GROUP" --output json
  [ "$DRY_RUN" = 1 ] || verify_build_groups "$build_number"
}

verify_build_groups() {
  groups="$(asc testflight groups list --build-id "$(build_id "$1")" --output json | jq -r '.groups[].name')"
  grep -qxF "$TESTFLIGHT_GROUP" <<<"$groups" || fail "$VERSION ($1) is not in $TESTFLIGHT_GROUP"
  log "$VERSION ($1) groups: $(paste -sd ',' - <<<"$groups" | sed 's/,/, /g')"
}

submit_testflight() {
  build_number="$(archive_build_number)"
  build="$(build_id "$build_number")"
  [ -n "$build" ] || fail "build $VERSION ($build_number) is not uploaded - run make publish-testflight"
  log "Beta App Review submission of $VERSION ($build_number)"
  run asc testflight review submit --build-id "$build" --confirm --output json
}

publish_appstore() {
  build_number="$(archive_build_number)"
  if build_uploaded "$build_number"; then
    log "App Store $VERSION: attach the uploaded build $build_number"
    run asc versions attach-build --app "$APP_STORE_APP_ID" --platform MAC_OS --version "$VERSION" \
      --build-number "$build_number" --wait --output json
    return
  fi
  log "App Store upload of $VERSION ($build_number), attached to the version"
  run asc publish appstore --app "$APP_STORE_APP_ID" --platform MAC_OS --pkg "$PKG" \
    --version "$VERSION" --build-number "$build_number" --wait --output json
}

setup_pricing() {
  local current availability
  [ "$(config .pricing.free)" = true ] || fail "$APP_CONFIG: only a free app price is supported"
  current="$(asc pricing current --app "$APP_STORE_APP_ID" --output json | jq -c '{free: .isFree, baseTerritory}')"
  if same_json "$current" "$(config -c '{free: .pricing.free, baseTerritory: .pricing.baseTerritory}')"; then
    unchanged "app price"
  else
    log "app price"
    run_quiet asc pricing schedule create --app "$APP_STORE_APP_ID" --base-territory "$(config .pricing.baseTerritory)" \
      --free --output json
  fi
  availability="$(asc pricing availability territory-availabilities --app "$APP_STORE_APP_ID" --paginate --output json \
    | jq '[.data[] | select(.attributes.available | not)] | length == 0')"
  if [ "$availability" = "$(config .pricing.availableInAllTerritories)" ]; then
    unchanged "app availability"
    return
  fi
  log "app availability"
  run_quiet asc pricing availability edit --app "$APP_STORE_APP_ID" --all-territories \
    --available "$(config .pricing.availableInAllTerritories)" --output json
}

setup_accessibility() {
  local family declaration remote wanted flags=()
  family="$(config .accessibility.deviceFamily)"
  wanted="$(config -c '.accessibility | (.supports | with_entries(.key |= "supports" + (.[:1] | ascii_upcase) + .[1:]))
    + {state: (if .publish then "PUBLISHED" else "DRAFT" end)}')"
  declaration="$(asc accessibility list --app "$APP_STORE_APP_ID" --output json \
    | jq -c --arg family "$family" '[.data[] | select(.attributes.deviceFamily == $family)][0] // empty')"
  remote="$(jq -c --argjson wanted "$wanted" '.attributes | with_entries(select(.key as $key | $wanted | has($key)))' <<<"${declaration:-{\}}")"
  if [ -n "$declaration" ] && same_json "$remote" "$wanted"; then
    unchanged "accessibility declaration"
    return
  fi
  log "accessibility declaration"
  while IFS='|' read -r flag value; do
    flags+=("--$flag" "$value")
  done < <(config '.accessibility.supports | to_entries[] | [(.key | gsub("(?<c>[A-Z])"; "-\(.c | ascii_downcase)") | "supports-" + .), .value] | join("|")')
  if [ -z "$declaration" ]; then
    run_quiet asc accessibility create --app "$APP_STORE_APP_ID" --device-family "$family" "${flags[@]}" --output json
    [ "$DRY_RUN" = 1 ] && return
    declaration="$(asc accessibility list --app "$APP_STORE_APP_ID" --output json \
      | jq -c --arg family "$family" '[.data[] | select(.attributes.deviceFamily == $family)][0] // empty')"
  fi
  run_quiet asc accessibility update --id "$(jq -r .id <<<"$declaration")" "${flags[@]}" \
    --publish "$(config .accessibility.publish)" --output json
}

setup_screenshots() {
  local index=0 name source local_checksums remote_checksums
  rm -rf "$STAGED_SCREENSHOTS"
  mkdir -p "$STAGED_SCREENSHOTS"
  while read -r name; do
    index=$((index + 1))
    source="$SCREENSHOT_SOURCE/appstore-${name}_2880x1800.png"
    [ -f "$source" ] || fail "missing $source - run make assets in the brand assets kit"
    cp "$source" "$STAGED_SCREENSHOTS/$(printf '%02d' "$index")-$name.png"
  done < <(config '.screenshots[]')
  local_checksums="$(for file in "$STAGED_SCREENSHOTS"/*.png; do md5 -q "$file"; done | jq -R . | jq -sc .)"
  remote_checksums="$(asc screenshots list --app "$APP_STORE_APP_ID" --version "$VERSION" --platform MAC_OS --locale "$LOCALE" \
    --output json 2>/dev/null | jq -c '[.sets[]? | select(.set.attributes.screenshotDisplayType == "APP_DESKTOP")
      | .screenshots[].attributes.sourceFileChecksum]' || echo '[]')"
  if same_json "$remote_checksums" "$local_checksums"; then
    unchanged "screenshots ($index)"
    return
  fi
  log "screenshots ($index) from $APP_CONFIG"
  local upload_flags=(--replace --confirm)
  [ "$DRY_RUN" = 1 ] && upload_flags+=(--dry-run)
  asc screenshots upload --app "$APP_STORE_APP_ID" --version "$VERSION" --platform MAC_OS --locale "$LOCALE" \
    --device-type APP_DESKTOP --path "$STAGED_SCREENSHOTS" "${upload_flags[@]}" --output table
}

setup_purchases() {
  local import_flags=(--confirm) existing missing territories total product_id iap_id plan scratch
  [ "$DRY_RUN" = 1 ] && import_flags=(--dry-run)
  existing="$(asc iap list --app "$APP_STORE_APP_ID" --paginate --output json | jq -c '[.data[].attributes.productId]')"
  missing="$(jq -r --argjson existing "$existing" '[.products[].productId | select(. as $id | $existing | index($id) | not)] | length' "$PURCHASES")"
  if [ "$missing" = 0 ]; then
    unchanged "in-app purchases"
  else
    log "in-app purchases: $missing new"
    asc iap import --app "$APP_STORE_APP_ID" --file "$PURCHASES" --skip-existing "${import_flags[@]}" --output json >/dev/null
  fi
  territories="$(asc pricing territories list --paginate --output json | jq -r '[.data[].id] | join(",")')"
  total="$(tr ',' '\n' <<<"$territories" | wc -l | tr -d ' ')"
  scratch="$(mktemp -d)"
  while read -r product_id; do
    iap_id="$(asc iap list --app "$APP_STORE_APP_ID" --paginate --output json \
      | jq -r --arg id "$product_id" '.data[] | select(.attributes.productId == $id) | .id')"
    [ -n "$iap_id" ] || { [ "$DRY_RUN" = 1 ] && continue; fail "in-app purchase $product_id was not created"; }
    if [ "$(asc iap pricing availabilities available-territories --id "$iap_id" --paginate --output json | jq '.data | length')" = "$total" ]; then
      unchanged "$product_id availability"
    else
      log "$product_id availability in every territory"
      run_quiet asc iap pricing availability set --app "$APP_STORE_APP_ID" --iap-id "$product_id" \
        --territories "$territories" --available-in-new-territories --output json
    fi
    asc iap pricing price-points list --app "$APP_STORE_APP_ID" --iap-id "$product_id" \
      --territory "$(config .inAppPurchasePrices.baseTerritory)" --paginate --output json > "$scratch/points.json"
    asc iap pricing summary --app "$APP_STORE_APP_ID" --iap-id "$product_id" --output json > "$scratch/summary.json"
    plan="$(python3 scripts/iap_price_schedule.py --app-config "$APP_CONFIG" --product-id "$product_id" \
      --price-points "$scratch/points.json" --summary "$scratch/summary.json")"
    if [ "$(jq -r .unchanged <<<"$plan")" = true ]; then
      unchanged "$product_id prices"
      continue
    fi
    log "$product_id prices"
    run_quiet asc iap pricing schedules create --app "$APP_STORE_APP_ID" --iap-id "$product_id" \
      --base-territory "$(config .inAppPurchasePrices.baseTerritory)" --prices "$(jq -r .prices <<<"$plan")" --output json
  done < <(config '.inAppPurchasePrices.prices | keys[]')
  rm -rf "$scratch"
}

setup_purchase_review_screenshots() {
  local product_id scene source remote remote_id
  while read -r product_id; do
    scene="$(config --arg id "$product_id" '.inAppPurchaseReviewScreenshots[$id]')"
    source="$REVIEW_SCREENSHOT_SOURCE/${scene}_2880x1800.png"
    [ -f "$source" ] || fail "missing $source - run make assets in the brand assets kit"
    remote="$(asc iap review-screenshots view --app "$APP_STORE_APP_ID" --iap-id "$product_id" --output json)"
    if [ "$(jq -r '.data.attributes.sourceFileChecksum // ""' <<<"$remote")" = "$(md5 -q "$source")" ]; then
      unchanged "$product_id review screenshot"
      continue
    fi
    log "$product_id review screenshot from $scene"
    remote_id="$(jq -r '.data.id // empty' <<<"$remote")"
    [ -z "$remote_id" ] || run_quiet asc iap review-screenshots delete --screenshot-id "$remote_id" --confirm --output json
    run_quiet asc iap review-screenshots create --app "$APP_STORE_APP_ID" --iap-id "$product_id" --file "$source" --output json
  done < <(config '.inAppPurchaseReviewScreenshots | keys[]')
}

review_draft() {
  asc review submissions-list --app "$APP_STORE_APP_ID" --platform MAC_OS --include appStoreVersionForReview --output json \
    | jq -c '[.data[] | select(.attributes.state == "READY_FOR_REVIEW")
      | {id, version: .relationships.appStoreVersionForReview.data.id?}][0] // empty'
}

validate_appstore() {
  python3 scripts/appstore_validate.py "$APP_STORE_APP_ID" "$VERSION"
}

submit_appstore() {
  local draft draft_version product_id
  build_number="$(archive_build_number)"
  web_session || fail "in-app purchases join the submission through the Apple web session: run asc web auth login --apple-id EMAIL"
  version="$(version_id)"
  draft="$(review_draft)"
  draft_version="$(jq -r '.version // empty' <<<"$draft")"
  draft="$(jq -r '.id // empty' <<<"$draft")"
  if [ -z "$draft" ]; then
    log "App Review draft for $VERSION"
    draft="$(asc review submissions-create --app "$APP_STORE_APP_ID" --platform MAC_OS --output json | jq -r .data.id)"
  fi
  if [ "$draft_version" = "$version" ]; then
    unchanged "$VERSION in the App Review draft"
  else
    log "App Review draft: add $VERSION ($build_number)"
    run_quiet asc review items add --submission "$draft" --item-type appStoreVersions --item-id "$version" --output json
  fi
  while read -r product_id; do
    log "App Review draft: add $product_id"
    run_quiet asc web review iaps attach --app "$APP_STORE_APP_ID" --iap-id "$product_id" --submission "$draft" --confirm --output json
  done < <(jq -r '.products[].productId' "$PURCHASES")
  log "App Store readiness of $VERSION"
  validate_appstore
  log "App Review submission of $VERSION ($build_number) with its in-app purchases"
  run asc review submissions-submit --id "$draft" --confirm --output json
}

case "${1:-}" in
  preflight) preflight ;;
  status) python3 scripts/appstore_status.py "$APP_STORE_APP_ID" "${STATUS_BUILDS:-5}" ;;
  status-xcode-cloud) python3 scripts/xcode_cloud_status.py "$APP_STORE_APP_ID" "${STATUS_BUILDS:-5}" ;;
  next-build-number) next_build_number ;;
  create-appstore) create_appstore ;;
  setup-appstore) setup_appstore ;;
  setup-xcode-cloud) setup_xcode_cloud ;;
  setup-appstore-promotional-text) setup_appstore_promotional_text ;;
  setup-testflight) setup_testflight ;;
  publish-testflight) publish_testflight ;;
  submit-testflight) submit_testflight ;;
  publish-appstore) publish_appstore ;;
  validate-appstore) validate_appstore ;;
  submit-appstore) submit_appstore ;;
  *) fail "usage: $0 preflight|status|status-xcode-cloud|next-build-number|create-appstore|setup-appstore|setup-xcode-cloud|setup-appstore-promotional-text|setup-testflight|publish-testflight|submit-testflight|publish-appstore|validate-appstore|submit-appstore" ;;
esac
