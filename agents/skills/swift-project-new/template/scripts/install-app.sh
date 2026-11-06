#!/usr/bin/env bash
set -euo pipefail

LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister

[ $# -eq 2 ] || { echo "usage: APP_NAME=<name> $0 <built app> <installed app>" >&2; exit 2; }
: "${APP_NAME:?APP_NAME is required}"

pkill -f "MacOS/${APP_NAME}$" || true
killall Shortcuts linkd duetexpertd 2>/dev/null || true
rm -rf "$2"
cp -R "$1" "$2"
"$LSREGISTER" -f "$2"
