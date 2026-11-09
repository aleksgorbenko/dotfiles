#!/bin/sh
set -eu

[ "${CI_XCODEBUILD_ACTION:-}" = "build-for-testing" ] || exit 0

entitlements="$(cd "$(dirname "$0")/.." && pwd)/__APP__/__APP__-Debug.entitlements"
if /usr/libexec/PlistBuddy -c "Print :keychain-access-groups" "$entitlements" >/dev/null 2>&1; then
  echo "Removing keychain-access-groups from __APP__-Debug.entitlements: Xcode Cloud signs ad hoc, and macOS refuses to launch an ad hoc app with that entitlement."
  /usr/libexec/PlistBuddy -c "Delete :keychain-access-groups" "$entitlements"
fi
