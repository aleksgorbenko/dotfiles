#!/usr/bin/env bash
# icon-iconify.sh - search and render icons from 200+ open-source sets via Iconify
# Sets include Lucide, Material, Tabler, Phosphor, Font Awesome and Simple Icons (brands).
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  icon-iconify.sh <set:name> <output.png> [options]
  icon-iconify.sh --batch <file.txt> [--outdir DIR] [options]
  icon-iconify.sh --search <query> [--set NAME] [--limit N]

Batch file: one "<name> <set:icon>" pair per line; writes DIR/<name>.png (default DIR: ./icons).
Search prints every matching "set:name" (the API caps at 999) unless --limit is given;
--set narrows it to one or more comma-separated sets (e.g. lucide,tabler).
Browse sets visually at https://icon-sets.iconify.design

Options:
  --size N        output width/height in px (default: 1024)
  --bg COLOUR     background #RRGGBB, or "none" (default: #FF0033)
  --fg COLOUR     monochrome icon #RRGGBB, or "original" to keep the set's colours (default: #1C1C1E)
  --radius, --inset, --glyph   passed to icon-compose.sh

Examples:
  icon-iconify.sh --search music --limit 20
  icon-iconify.sh --search music --set lucide
  icon-iconify.sh lucide:music music.png
  icon-iconify.sh simple-icons:github github.png --bg "#FFFFFF" --fg "#181717"
  icon-iconify.sh logos:youtube-icon yt.png --fg original --bg none
USAGE
  exit 1
}

[[ $# -eq 0 ]] && usage

API="https://api.iconify.design"
BG="#FF0033"
FG="#1C1C1E"
BATCH=""
OUTDIR="./icons"
SEARCH=""
SETS=""
LIMIT=""
COMPOSE=()
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="$2"; shift 2 ;;
    --outdir) OUTDIR="$2"; shift 2 ;;
    --search) SEARCH="$2"; shift 2 ;;
    --set) SETS="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --bg) BG="$2"; shift 2 ;;
    --fg) FG="$2"; shift 2 ;;
    --size|--radius|--inset|--glyph) COMPOSE+=("$1" "$2"); shift 2 ;;
    -h|--help) usage ;;
    -*) echo "Unknown arg: $1"; usage ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

if [[ -n "$SEARCH" ]]; then
  query=(--data-urlencode "query=$SEARCH" --data "limit=999")
  [[ -z "$SETS" ]] || query+=(--data-urlencode "prefixes=$SETS")
  curl -fsSL --get "${query[@]}" "$API/search" |
    python3 -c 'import json, sys; print("\n".join(json.load(sys.stdin)["icons"]))' |
    if [[ -n "$LIMIT" ]]; then head -n "$LIMIT"; else cat; fi
  exit 0
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

render() {
  local icon="$1" output="$2"
  [[ "$icon" == *:* ]] || { echo "Icon must be set:name, got $icon"; exit 1; }
  local query=(--data "height=512")
  [[ "$FG" == original ]] || query+=(--data-urlencode "color=$FG")
  curl -fsSL --get "${query[@]}" "$API/${icon%%:*}/${icon#*:}.svg" -o "$WORK/icon.svg" ||
    { echo "Iconify has no icon $icon"; exit 1; }
  grep -q '<svg' "$WORK/icon.svg" || { echo "Iconify has no icon $icon"; exit 1; }
  icon-compose.sh "$WORK/icon.svg" "$output" --bg "$BG" ${COMPOSE[@]+"${COMPOSE[@]}"}
}

if [[ -n "$BATCH" ]]; then
  [[ -f "$BATCH" ]] || { echo "Batch file not found: $BATCH"; exit 1; }
  while read -r name icon _; do
    [[ -z "${name:-}" || "$name" == \#* ]] && continue
    render "$icon" "$OUTDIR/$name.png"
  done < "$BATCH"
else
  [[ ${#POSITIONAL[@]} -eq 2 ]] || usage
  render "${POSITIONAL[0]}" "${POSITIONAL[1]}"
fi
