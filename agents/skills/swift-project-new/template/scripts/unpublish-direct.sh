#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/publish-direct-common.sh"

tag() {
  log "tag v$VERSION"
  if git rev-parse -q --verify "refs/tags/v$VERSION" >/dev/null; then
    run git tag -d "v$VERSION"
  else
    echo "no local tag v$VERSION"
  fi
  app_repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
  if gh api "repos/$app_repo/git/matching-refs/tags/v$VERSION" --jq '.[].ref' | grep -qx "refs/tags/v$VERSION"; then
    run git push origin ":refs/tags/v$VERSION"
  else
    echo "no tag v$VERSION on $app_repo"
  fi
}

gumroad_file() {
  log "Gumroad $GUMROAD_SLUG: detach $DMG_NAME"
  gumroad_make detach FILE_NAME="$DMG_NAME"
  log "Gumroad $GUMROAD_SLUG: release notes"
  gumroad_refresh_page "Remove release notes for $APP_NAME $VERSION"
}

appcast() {
  log "appcast item for $VERSION in $RELEASES_REPO"
  clone_releases
  python3 scripts/appcast-remove-item.py --appcast "$RELEASES_DIR/$APPCAST_PATH" --version "$VERSION"
  if git -C "$RELEASES_DIR" diff --quiet; then
    return
  fi
  push_repo "$RELEASES_DIR" "$APPCAST_PATH" "Remove $APP_NAME $VERSION"
}

blog() {
  log "release notes for $VERSION on the blog"
  clone_feed
  python3 scripts/release-notes.py blog-remove --page "$FEED_DIR/$RELEASE_NOTES_PAGE" --version "$VERSION"
  if git -C "$FEED_DIR" diff --quiet; then
    return
  fi
  push_repo "$FEED_DIR" "$RELEASE_NOTES_PAGE" "Remove $APP_NAME $VERSION"
}

github_release() {
  log "GitHub release $TAG on $RELEASES_REPO"
  if gh release view "$TAG" --repo "$RELEASES_REPO" >/dev/null 2>&1; then
    run gh release delete "$TAG" --repo "$RELEASES_REPO" --cleanup-tag --yes
  else
    echo "no GitHub release $TAG"
  fi
}

case "${1:-}" in
  tag) tag ;;
  gumroad) gumroad_file ;;
  appcast) appcast ;;
  blog) blog ;;
  github-release) github_release ;;
  *) fail "usage: $0 tag|gumroad|appcast|blog|github-release" ;;
esac
