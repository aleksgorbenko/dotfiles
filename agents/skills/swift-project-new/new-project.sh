#!/bin/bash
set -euo pipefail

usage() { echo "usage: new-project.sh <dir> <AppName> [macos-version]" >&2; exit 1; }
[ $# -ge 2 ] || usage

profile="${SWIFT_PROJECT_OWNER:-$HOME/.config/swift-project-new/owner.env}"
[ -f "$profile" ] || { echo "error: missing $profile (copy owner.env.example from this skill)" >&2; exit 1; }
# shellcheck source=/dev/null
. "$profile"

dir=$1 app=$2 macos=${3:-15.5}
slug=$(printf '%s' "$app" | tr '[:upper:]' '[:lower:]')
bundle="$BUNDLE_ID_PREFIX.$app"
demo_variable="$(printf '%s' "$app" | tr '[:lower:]' '[:upper:]')_DEMO"
skill="$(cd "$(dirname "$0")" && pwd)"
template="$skill/template"
[[ "$app" =~ ^[A-Z][A-Za-z0-9]+$ ]] || { echo "error: AppName must be UpperCamelCase letters and digits" >&2; exit 1; }
[ ! -e "$dir/project.yml" ] || { echo "error: $dir/project.yml already exists" >&2; exit 1; }

fill() {
  sed -e "s|__APP__|$app|g" -e "s|__SLUG__|$slug|g" -e "s|__BUNDLE_ID__|$bundle|g" \
    -e "s|__TEAM_ID__|$TEAM_ID|g" -e "s|__OWNER__|$OWNER|g" -e "s|__MACOS__|$macos|g" \
    -e "s|__DEVELOPER_ID_CERTIFICATE__|$DEVELOPER_ID_CERTIFICATE|g" \
    -e "s|__RELEASES_OWNER__|$RELEASES_OWNER|g" -e "s|__FEED_HOST__|$FEED_HOST|g" -e "s|__FEED_REPO__|$FEED_REPO|g" \
    -e "s|__LEMON_SQUEEZY_STORE_ID__|$LEMON_SQUEEZY_STORE_ID|g" -e "s|__BASE_TERRITORY__|$BASE_TERRITORY|g" \
    -e "s|__LOCALE__|$LOCALE|g" -e "s|__CONTACT_EMAIL__|$CONTACT_EMAIL|g" \
    -e "s|__CONTACT_FIRST_NAME__|$CONTACT_FIRST_NAME|g" -e "s|__CONTACT_LAST_NAME__|$CONTACT_LAST_NAME|g" \
    -e "s|__CONTACT_PHONE__|$CONTACT_PHONE|g" -e "s|__YEAR__|$(date +%Y)|g" "$1" > "$2"
}

destination() {
  case "$1" in
    gitignore) echo .gitignore ;;
    vale.ini) echo .vale.ini ;;
    yamllint.yaml) echo .yamllint.yaml ;;
    vale/*) echo ".$1" ;;
    PrivacyInfo.xcprivacy) echo "$app/PrivacyInfo.xcprivacy" ;;
    app/app.entitlements) echo "$app/$app.entitlements" ;;
    app/app-Debug.entitlements) echo "$app/$app-Debug.entitlements" ;;
    app/app-Direct.entitlements) echo "$app/$app-Direct.entitlements" ;;
    app/Direct-Info.plist) echo "$app/$app-Direct-Info.plist" ;;
    *) printf '%s' "$1" | sed "s|__LOCALE__|$LOCALE|g" ;;
  esac
}

mkdir -p "$dir"
(cd "$template" && find . -type f ! -name .DS_Store ! -path '*/__pycache__/*' | sed 's|^\./||') | while read -r relative; do
  target="$dir/$(destination "$relative")"
  mkdir -p "$(dirname "$target")"
  fill "$template/$relative" "$target"
done
chmod +x "$dir"/scripts/*.py "$dir"/scripts/*.sh "$dir"/ci_scripts/*.sh

mkdir -p "$dir/$app/Assets.xcassets/AppIcon.appiconset" "$dir/$app/Assets.xcassets/AccentColor.colorset" \
  "$dir/${app}Tests" "$dir/${app}UITests"
printf '{\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n' > "$dir/$app/Assets.xcassets/Contents.json"
printf '{\n  "images" : [],\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n' > "$dir/$app/Assets.xcassets/AppIcon.appiconset/Contents.json"
printf '{\n  "colors" : [],\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n' > "$dir/$app/Assets.xcassets/AccentColor.colorset/Contents.json"

cat > "$dir/$app/${app}App.swift" <<EOF
import SwiftUI

@main
internal struct ${app}App: App {
    var body: some Scene {
        WindowGroup {
            Text("$app")
                .padding()
        }
    }
}
EOF

cat > "$dir/${app}Tests/${app}Tests.swift" <<EOF
import Testing

@testable import $app

@Suite internal struct ${app}Tests {
    @Test func launches() {
        #expect(Bool(true))
    }
}
EOF

cat > "$dir/${app}UITests/${app}UITests.swift" <<EOF
import XCTest

internal nonisolated final class ${app}UITests: XCTestCase {
    @MainActor
    func testLaunches() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertEqual(app.state, .runningForeground)
    }
}
EOF

for plan in "$app" "$app-Unit" "$app-UI" "$app-Keychain"; do echo "{}" > "$dir/$plan.xctestplan"; done
(cd "$dir" && xcodegen generate --spec project.yml --quiet)
python3 "$skill/write-test-plans.py" "$dir" "$app" "$demo_variable"
(cd "$dir" && xcodegen generate --spec project.yml --quiet)

mkdir -p "$dir/$app.xcworkspace"
{
  printf '<?xml version="1.0" encoding="UTF-8"?>\n<Workspace\n   version = "1.0">\n'
  printf '   <FileRef\n      location = "group:%s.xcodeproj">\n   </FileRef>\n' "$app"
  (cd "$dir" && ls -A) | grep -vxE "\.git|\.DS_Store|$app\.xcodeproj|$app\.xcworkspace|$app|${app}Tests|${app}UITests|build\.noindex" |
    while read -r entry; do printf '   <FileRef\n      location = "group:%s">\n   </FileRef>\n' "$entry"; done
  printf '</Workspace>\n'
} > "$dir/$app.xcworkspace/contents.xcworkspacedata"

scaffold() {
  local repo=$1 target=$2
  shift 2
  if [ -d "$repo" ] && make -C "$repo" -n "$target" "$@" > /dev/null 2>&1; then
    make -C "$repo" "$target" "$@"
  else
    echo "todo: make -C $repo $target $*"
  fi
}
scaffold "$STOREFRONTS_DIR" new-product APP="$app" SLUG="$slug"
scaffold "$BRAND_ASSETS_DIR" new-product PRODUCT="$(cd "$dir" && pwd)" APP="$app" BUNDLE_ID="$bundle"
scaffold "$SITE_DIR" new-app APP="$app" SLUG="$slug"
scaffold "$INFRA_GITHUB_DIR" new-repo NAME="$app" DESCRIPTION="$app for macOS"

echo "created $dir; open $dir/$app.xcworkspace"
