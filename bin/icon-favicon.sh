#!/usr/bin/env bash
# icon-favicon.sh - fetch a website's icon at the best available resolution
# Tries apple-touch-icon, Google's favicon service and DuckDuckGo's; the largest wins.
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  icon-favicon.sh <domain> <output.png> [options]

Options:
  --size N        output width/height in px (default: 256)
  --bg COLOUR     background #RRGGBB, or "none" (default: none)
  --radius, --inset, --glyph   passed to icon-compose.sh

Examples:
  icon-favicon.sh github.com github.png
  icon-favicon.sh bandcamp.com bc.png --size 512 --bg "#FFFFFF"
USAGE
  exit 1
}

[[ $# -eq 0 ]] && usage

SIZE=256
BG=none
COMPOSE=()
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --size) SIZE="$2"; shift 2 ;;
    --bg) BG="$2"; shift 2 ;;
    --radius|--inset|--glyph) COMPOSE+=("$1" "$2"); shift 2 ;;
    -h|--help) usage ;;
    -*) echo "Unknown arg: $1"; usage ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

[[ ${#POSITIONAL[@]} -eq 2 ]] || usage
DOMAIN="${POSITIONAL[0]#*://}"
DOMAIN="${DOMAIN%%/*}"
OUTPUT="${POSITIONAL[1]}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

SOURCES=(
  "https://$DOMAIN/apple-touch-icon.png"
  "https://www.google.com/s2/favicons?domain=$DOMAIN&sz=256"
  "https://icons.duckduckgo.com/ip3/$DOMAIN.ico"
)

best=""
best_width=0
for index in "${!SOURCES[@]}"; do
  raw="$WORK/raw-$index"
  png="$WORK/source-$index.png"
  curl -fsSL --max-time 10 -o "$raw" "${SOURCES[$index]}" 2>/dev/null || continue
  sips -s format png "$raw" --out "$png" >/dev/null 2>&1 || continue
  width="$(sips -g pixelWidth "$png" 2>/dev/null | awk '/pixelWidth/ { print $2 }')"
  [[ -n "$width" && "$width" -gt "$best_width" ]] || continue
  best="$png"
  best_width="$width"
  best_source="${SOURCES[$index]}"
done

[[ -n "$best" ]] || { echo "No icon found for $DOMAIN"; exit 1; }
echo "source: $best_source (${best_width}px)" >&2
[[ "$best_width" -ge "$SIZE" ]] || echo "warning: upscaling ${best_width}px source to ${SIZE}px" >&2

icon-compose.sh "$best" "$OUTPUT" --size "$SIZE" --bg "$BG" ${COMPOSE[@]+"${COMPOSE[@]}"}
