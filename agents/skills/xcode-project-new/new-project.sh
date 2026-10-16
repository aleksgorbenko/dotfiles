#!/bin/bash
set -euo pipefail

usage() { echo "usage: new-project.sh <dir> <AppName> <slug> <bundle-id> <team-id> <owner> [macos-version]" >&2; exit 1; }
[ $# -ge 6 ] || usage

dir=$1 app=$2 slug=$3 bundle=$4 team=$5 owner=$6 macos=${7:-15.0}
template="$(cd "$(dirname "$0")" && pwd)/template"
[ ! -e "$dir/project.yml" ] || { echo "error: $dir/project.yml already exists" >&2; exit 1; }

fill() {
  sed -e "s|__APP__|$app|g" -e "s|__SLUG__|$slug|g" -e "s|__BUNDLE_ID__|$bundle|g" \
    -e "s|__TEAM_ID__|$team|g" -e "s|__OWNER__|$owner|g" -e "s|__MACOS__|$macos|g" \
    -e "s|__YEAR__|$(date +%Y)|g" "$1" > "$2"
}

mkdir -p "$dir/$slug/Assets.xcassets/AppIcon.appiconset" "$dir/${slug}Tests" "$dir/$app.xcworkspace"
fill "$template/project.yml" "$dir/project.yml"
fill "$template/Config.xcconfig" "$dir/Config.xcconfig"
fill "$template/Makefile" "$dir/Makefile"
fill "$template/workspace.xcworkspacedata" "$dir/$app.xcworkspace/contents.xcworkspacedata"

cat > "$dir/$slug/${app}App.swift" <<EOF
import SwiftUI

@main
struct ${app}App: App {
    var body: some Scene {
        WindowGroup {
            Text("$app")
                .padding()
        }
    }
}
EOF

cat > "$dir/${slug}Tests/${app}Tests.swift" <<EOF
import Testing

@testable import $app

@Suite internal struct ${app}Tests {
    @Test func launches() {
        #expect(Bool(true))
    }
}
EOF

cat > "$dir/$slug/$slug.entitlements" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
</dict>
</plist>
EOF

printf '{\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n' > "$dir/$slug/Assets.xcassets/Contents.json"
printf '{\n  "images" : [],\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n' > "$dir/$slug/Assets.xcassets/AppIcon.appiconset/Contents.json"

(cd "$dir" && xcodegen generate --spec project.yml --quiet)
echo "created $dir/$slug.xcodeproj; open $dir/$app.xcworkspace"
