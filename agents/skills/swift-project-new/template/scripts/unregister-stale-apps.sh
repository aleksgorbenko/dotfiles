#!/usr/bin/env bash
set -euo pipefail

LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister
DRY_RUN="${DRY_RUN:-0}"

[ $# -eq 1 ] || { echo "usage: $0 <bundle-id>" >&2; exit 2; }

stale_paths() {
  "$LSREGISTER" -dump 2>/dev/null | awk -v id="$1" '
    /^-+$/ { path = "" }
    /^path:/ { sub(/^path: +/, ""); sub(/ \(0x[0-9a-f]+\)$/, ""); path = $0 }
    /^identifier:/ {
      if (($2 == id || index($2, id ".") == 1) && path != "" && path !~ /^\/Applications\//) print path
    }
  ' | sort -u
}

found=0
while IFS= read -r path; do
  found=1
  if [ "$DRY_RUN" = 1 ]; then
    echo "[dry-run] unregister $path"
  else
    "$LSREGISTER" -u "$path" 2>/dev/null || true
    echo "unregistered $path"
  fi
done < <(stale_paths "$1")
[ "$found" = 1 ] || echo "no registered copies of $1 outside /Applications"
