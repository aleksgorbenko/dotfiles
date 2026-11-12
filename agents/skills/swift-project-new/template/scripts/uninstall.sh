#!/usr/bin/env bash
set -euo pipefail

LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister
: "${APP_NAME:?APP_NAME is required}"
: "${INSTALLED_APP:?INSTALLED_APP is required}"
: "${APP_BUNDLE_ID:?APP_BUNDLE_ID is required}"
PURGE="${PURGE:-}"
DRY_RUN="${DRY_RUN:-}"

run() {
  if [ "$DRY_RUN" = 1 ]; then echo "[dry-run] $*"; else "$@"; fi
}

if [ -e "$INSTALLED_APP" ] && [ ! -w "$INSTALLED_APP" ]; then
  echo "error: ${INSTALLED_APP} belongs to root (an App Store or TestFlight install); move it to the Bin in Finder, then run this again" >&2
  exit 1
fi

echo "== Quit ${APP_NAME}"
run pkill -f "MacOS/${APP_NAME}$" && echo "quit running ${APP_NAME}" || echo "${APP_NAME} was not running"

echo "== Remove ${INSTALLED_APP}"
if [ -e "$INSTALLED_APP" ]; then
  run "$LSREGISTER" -u "$INSTALLED_APP"
  echo "unregistered ${INSTALLED_APP}"
  run rm -rf "$INSTALLED_APP"
  echo "deleted ${INSTALLED_APP}"
else
  echo "${INSTALLED_APP} is not installed"
fi

echo "== Unregister stale copies"
DRY_RUN="$DRY_RUN" "$(dirname "$0")/unregister-stale-apps.sh" "$APP_BUNDLE_ID"

if [ "$PURGE" = 1 ]; then
  echo "== Delete ${APP_NAME} data (PURGE=1)"
  DRY_RUN="$DRY_RUN" "$(dirname "$0")/purge-app-data.sh" "$APP_BUNDLE_ID"
else
  echo "== Keep ${APP_NAME} data (PURGE=1 deletes it)"
fi

echo "== Restart Shortcuts, linkd and duetexpertd"
for process in Shortcuts linkd duetexpertd; do
  run killall "$process" 2>/dev/null && echo "restarted ${process}" || echo "${process} was not running"
done
