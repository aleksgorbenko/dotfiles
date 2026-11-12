DRY_RUN="${DRY_RUN:-0}"
TAG="v$VERSION"
RELEASES_REPO="$RELEASES_OWNER/$APP_SLUG-releases"
FEED_URL="https://$FEED_HOST/apps/$APP_SLUG/appcast.xml"
APPCAST_PATH="appcast.xml"
RELEASE_NOTES_PAGE="content/apps/$APP_SLUG/release-notes.md"
FEED_DIR="build.noindex/release/feed-repo"
RELEASES_DIR="build.noindex/release/releases-repo"
TAP_REPO="$RELEASES_OWNER/homebrew-tap"
TAP_DIR="build.noindex/release/tap-repo"
CASK_PATH="Casks/$APP_SLUG.rb"
DMG_NAME="$(basename "$DMG")"

log() { printf '== %s\n' "$*"; }
fail() { echo "error: $*" >&2; exit 1; }
run() {
  if [ "$DRY_RUN" = 1 ]; then printf '[dry-run] %s\n' "$*"; else "$@"; fi
}

gumroad_make() {
  make -C "$GUMROAD_DIR" DRY_RUN="$DRY_RUN" SLUG="$GUMROAD_SLUG" "$@"
}

clone_repo() {
  rm -rf "$2"
  git -c credential.helper='!gh auth git-credential' clone --quiet --depth 1 "https://github.com/$1.git" "$2"
  git -C "$2" config credential.helper '!gh auth git-credential'
}

clone_feed() {
  clone_repo "$RELEASES_OWNER/$FEED_REPO" "$FEED_DIR"
}

clone_releases() {
  clone_repo "$RELEASES_REPO" "$RELEASES_DIR"
}

push_repo() {
  git -C "$1" --no-pager diff --stat
  git -C "$1" --no-pager diff | head -40
  run git -C "$1" add "$2"
  run git -C "$1" commit -m "$3"
  run git -C "$1" push
}

gumroad_refresh_page() {
  [ -d "$FEED_DIR/.git" ] || fail "missing $FEED_DIR - run the blog step first"
  [ -z "$(git -C "$GUMROAD_DIR" status --porcelain -- products)" ] || fail "$GUMROAD_DIR/products has uncommitted changes"
  gumroad_make generate BLOG_DIR="$PWD/$FEED_DIR"
  git -C "$GUMROAD_DIR" --no-pager diff --stat -- products
  gumroad_make publish
  if [ "$DRY_RUN" = 1 ]; then
    git -C "$GUMROAD_DIR" checkout -- products
  elif [ -n "$(git -C "$GUMROAD_DIR" status --porcelain -- products)" ]; then
    git -C "$GUMROAD_DIR" add products
    git -C "$GUMROAD_DIR" commit -m "$1"
  fi
}
