#!/usr/bin/env bash
# extract-app-icons.sh — extract installed apps' icons by bundle ID.
set -euo pipefail

usage() {
  cat <<EOF
Usage:
  extract-app-icons.sh [--size N] <output-dir> <bundle-id>...

  <output-dir>      *.xcassets -> <bundle-id>.imageset/icon.png + Contents.json
                    any other  -> <bundle-id>.png
  --size N          longest side in pixels (default 512)

Example:
  extract-app-icons.sh Resources/BrowserIcons.xcassets com.apple.Safari com.google.Chrome
EOF
}

size=512
while [[ $# -gt 0 && "$1" == --* ]]; do
  case "$1" in
    --size) size="$2"; shift 2 ;;
    --help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
[[ $# -ge 2 ]] || { usage >&2; exit 2; }

output="$1"
shift
mkdir -p "$output"

find_app() {
  mdfind "kMDItemCFBundleIdentifier == '$1'" | grep '\.app$' | head -1 || true
}

write_imageset() {
  cat > "$1/Contents.json" <<EOF
{
  "images" : [
    {
      "filename" : "icon.png",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
}

status=0
for bundle_id in "$@"; do
  app_path="$(find_app "$bundle_id")"
  if [[ -z "$app_path" ]]; then
    echo "$bundle_id is not installed, skipping" >&2
    continue
  fi

  icon_file="$(/usr/libexec/PlistBuddy -c "Print :CFBundleIconFile" "$app_path/Contents/Info.plist" 2>/dev/null || true)"
  [[ -z "$icon_file" || "$icon_file" == *.icns ]] || icon_file="$icon_file.icns"
  icns_path="$app_path/Contents/Resources/$icon_file"
  if [[ -z "$icon_file" || ! -f "$icns_path" ]]; then
    echo "warning: $bundle_id has no .icns icon ($app_path), skipping" >&2
    status=1
    continue
  fi

  if [[ "$output" == *.xcassets ]]; then
    destination="$output/$bundle_id.imageset/icon.png"
    mkdir -p "$(dirname "$destination")"
    write_imageset "$(dirname "$destination")"
  else
    destination="$output/$bundle_id.png"
  fi
  sips -s format png -Z "$size" "$icns_path" --out "$destination" >/dev/null
  echo "$bundle_id -> $destination"
done
exit "$status"
