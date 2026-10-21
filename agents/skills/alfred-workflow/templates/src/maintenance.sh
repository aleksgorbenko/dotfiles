#!/bin/bash
set -euo pipefail

cache="${alfred_workflow_cache:?}"

case "${1:-}" in
  --clear)
    find "$cache" -mindepth 1 -delete 2>/dev/null || true
    printf 'Cache emptied\n'
    exit 0
    ;;
  --reveal)
    mkdir -p "$cache"
    chmod 700 "$cache"
    open "$cache"
    exit 0
    ;;
esac

files=0
kilobytes=0
if [[ -d "$cache" ]]; then
  files=$(find "$cache" -type f | wc -l | tr -d ' ')
  kilobytes=$(du -sk "$cache" | cut -f1)
fi

size=$(awk -v kb="$kilobytes" 'BEGIN {
  if (kb < 1024) printf "%d KB", kb
  else if (kb < 1048576) printf "%.1f MB", kb / 1024
  else printf "%.1f GB", kb / 1048576
}')
noun=$([[ "$files" == 1 ]] && printf 'file' || printf 'files')

cat <<JSON
{"items": [
  {"title": "Cache: $size", "subtitle": "${files} ${noun}・Enter reveals the folder in Finder", "arg": "--reveal", "icon": {"path": "icons/maintenance_cache.png"}},
  {"title": "Empty Cache", "subtitle": "Delete cached data; it is fetched again when needed", "arg": "--clear", "icon": {"path": "icons/maintenance_clear.png"}}
]}
JSON
