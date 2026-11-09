#!/usr/bin/env bash
set -uo pipefail

LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister
: "${APP_NAME:?APP_NAME is required}"
: "${INSTALLED_APP:?INSTALLED_APP is required}"

pkill -f "MacOS/${APP_NAME}$" || true
for app in "$INSTALLED_APP" "$HOME"/Library/Developer/Xcode/DerivedData/[Bb]ukku-*/Build/Products/*/*.app; do
  [ -e "$app" ] && "$LSREGISTER" -u "$app"
done
rm -rf "$INSTALLED_APP" "$HOME"/Library/Developer/Xcode/DerivedData/[Bb]ukku-*
killall Shortcuts linkd duetexpertd 2>/dev/null || true
