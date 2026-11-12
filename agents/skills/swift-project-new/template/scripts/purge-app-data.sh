#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="${DRY_RUN:-0}"

[ $# -eq 1 ] || { echo "usage: $0 <bundle-id>" >&2; exit 2; }
bundle_id="$1"

paths=(
  "$HOME/Library/Containers/$bundle_id"
  "$HOME/Library/Application Scripts/$bundle_id"
  "$HOME/Library/Application Support/$bundle_id"
  "$HOME/Library/Preferences/$bundle_id.plist"
  "$HOME/Library/Caches/$bundle_id"
  "$HOME/Library/HTTPStorages/$bundle_id"
  "$HOME/Library/Saved Application State/$bundle_id.savedState"
)

if [ "$DRY_RUN" = 1 ]; then
  echo "[dry-run] defaults delete $bundle_id"
elif defaults delete "$bundle_id" 2>/dev/null; then
  echo "deleted defaults for $bundle_id"
else
  echo "no defaults for $bundle_id"
fi

for path in "${paths[@]}"; do
  if [ ! -e "$path" ]; then
    echo "not found $path"
  elif [ "$DRY_RUN" = 1 ]; then
    echo "[dry-run] delete $path"
  else
    rm -rf "$path"
    echo "deleted $path"
  fi
done

if [ "$DRY_RUN" = 1 ]; then
  echo "[dry-run] tccutil reset All $bundle_id"
elif tccutil reset All "$bundle_id" >/dev/null 2>&1; then
  echo "reset every privacy permission for $bundle_id"
else
  echo "no privacy permission to reset for $bundle_id"
fi
