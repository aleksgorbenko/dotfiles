#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/publish-direct-common.sh"

NOTES="release-notes/$VERSION.md"
DMG_URL="https://$FEED_HOST/apps/$APP_SLUG/download/$TAG/$DMG_NAME"

warn_or_fail() {
  if [ "$DRY_RUN" = 1 ]; then echo "warning: $*"; else fail "$*"; fi
}

preflight() {
  log "preflight $APP_NAME $VERSION (build $BUILD)"
  for tool in gh jq python3 git curl; do
    command -v "$tool" >/dev/null || fail "missing tool: $tool"
  done
  [ -x "$SPARKLE_BIN/sign_update" ] || fail "Sparkle tools not found - build __APP__-Direct once so SPM fetches them"
  [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "version $VERSION is not semver X.Y.Z"
  [ -f "$NOTES" ] || fail "missing release notes: $NOTES"
  python3 scripts/release-notes.py check "$NOTES"
  [ -z "$(git status --porcelain)" ] || warn_or_fail "working tree is not clean"
  [[ "$(git rev-parse --abbrev-ref HEAD)" =~ ^(main|release/.+)$ ]] || warn_or_fail "not on main or a release/ branch"
  git rev-parse -q --verify "refs/tags/v$VERSION" >/dev/null && fail "tag v$VERSION already exists locally"
  app_repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)" || fail "cannot reach GitHub with gh"
  remote_tags="$(gh api "repos/$app_repo/git/matching-refs/tags/v$VERSION" --jq '.[].ref')" || fail "cannot list tags of $app_repo"
  grep -qx "refs/tags/v$VERSION" <<<"$remote_tags" && fail "tag v$VERSION already exists on $app_repo"
  gh release view "$TAG" --repo "$RELEASES_REPO" >/dev/null 2>&1 && fail "GitHub release $TAG already exists"
  latest_build="$(curl -fsS "$FEED_URL" | grep -o '<sparkle:version>[0-9]*' | sed 's/.*>//' | sort -n | tail -1 || true)"
  latest_build="${latest_build:-0}"
  [ "$BUILD" -gt "$latest_build" ] || fail "build $BUILD must be greater than the appcast's latest ($latest_build) - run make bump"
  log "preflight ok (appcast latest build: $latest_build)"
}

verify_artifacts() {
  log "verify artifacts"
  [ -f "$DMG" ] || fail "missing $DMG - run make package-direct"
  xcrun stapler validate "$DMG" >/dev/null || fail "$DMG is not notarised and stapled"
  plist="$APP_PATH/Contents/Info.plist"
  [ "$(plutil -extract CFBundleShortVersionString raw "$plist")" = "$VERSION" ] || fail "built app version differs from $VERSION - rebuild"
  [ "$(plutil -extract CFBundleVersion raw "$plist")" = "$BUILD" ] || fail "built app build number differs from $BUILD - rebuild"
  [ "$(plutil -extract SUFeedURL raw "$plist")" = "$FEED_URL" ] || fail "built app SUFeedURL differs from $FEED_URL - rebuild"
  log "artifacts match $VERSION ($BUILD)"
}

github_release() {
  log "GitHub release $TAG on $RELEASES_REPO"
  run gh release create "$TAG" "$DMG" --repo "$RELEASES_REPO" --title "$APP_NAME $VERSION" --notes-file "$NOTES"
}

appcast() {
  log "appcast item for $VERSION in $RELEASES_REPO -> $FEED_URL"
  clone_releases
  signature_line="$("$SPARKLE_BIN/sign_update" "$DMG")"
  python3 scripts/appcast-add-item.py \
    --appcast "$RELEASES_DIR/$APPCAST_PATH" --title "$APP_NAME $VERSION" --build "$BUILD" --version "$VERSION" \
    --min-os "$MIN_OS" --url "$DMG_URL" --signature-line "$signature_line" --notes "$NOTES"
  push_repo "$RELEASES_DIR" "$APPCAST_PATH" "Release $APP_NAME $VERSION"
}

blog() {
  log "release notes for $VERSION on the blog"
  clone_feed
  python3 scripts/release-notes.py blog-add \
    --page "$FEED_DIR/$RELEASE_NOTES_PAGE" --version "$VERSION" --date "$(date +%F)" --notes "$NOTES"
  push_repo "$FEED_DIR" "$RELEASE_NOTES_PAGE" "Release $APP_NAME $VERSION"
}

gumroad_file() {
  command -v gumroad >/dev/null || fail "missing tool: gumroad"
  [ -z "$(git -C "$GUMROAD_DIR" status --porcelain -- products)" ] || warn_or_fail "$GUMROAD_DIR/products has uncommitted changes"
  gumroad_product="$GUMROAD_DIR/products/$GUMROAD_SLUG/product.json"
  [ -n "$(jq -r '.product_id // ""' "$gumroad_product" 2>/dev/null)" ] || fail "no published Gumroad product in $gumroad_product"
  log "Gumroad $GUMROAD_SLUG: attach $DMG_NAME"
  gumroad_make attach FILE="$PWD/$DMG" DESCRIPTION="$APP_NAME $VERSION for macOS $MIN_OS or later"
  log "Gumroad $GUMROAD_SLUG: release notes"
  gumroad_refresh_page "Release notes for $APP_NAME $VERSION"
}


tag() {
  log "tag v$VERSION"
  run git tag -a "v$VERSION" -m "$APP_NAME $VERSION"
  run git push origin "v$VERSION"
}

lemonsqueezy_file() {
  log "Lemon Squeezy $APP_SLUG: upload $DMG_NAME by hand"
  make -C "$LEMONSQUEEZY_DIR" file SLUG="$APP_SLUG" FILE="$PWD/$DMG"
}

case "${1:-}" in
  preflight) preflight ;;
  verify-artifacts) verify_artifacts ;;
  publish-github-release) github_release ;;
  publish-appcast) appcast ;;
  publish-blog) blog ;;
  publish-gumroad) gumroad_file ;;
  publish-lemonsqueezy) lemonsqueezy_file ;;
  publish-tag) tag ;;
  *) fail "usage: $0 preflight|verify-artifacts|publish-github-release|publish-appcast|publish-blog|publish-gumroad|publish-lemonsqueezy|publish-tag" ;;
esac
