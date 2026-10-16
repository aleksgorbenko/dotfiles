#!/usr/bin/env bash
# icon-emoji.sh - render emoji as icons, optionally on a rounded background
# Requires macOS (Apple Color Emoji).
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  icon-emoji.sh "<emoji>" <output.png> [options]
  icon-emoji.sh --batch <file.txt> [--outdir DIR] [options]

Batch file: one "<name> <emoji>" pair per line; writes DIR/<name>.png (default DIR: ./icons).
Blank lines and lines starting with # are skipped.

Options:
  --size N        output width/height in px (default: 1024)
  --bg COLOUR     background #RRGGBB, or "none" (default: #FF0033)
  --radius, --inset, --glyph   passed to icon-compose.sh

Examples:
  icon-emoji.sh "🎵" music.png
  icon-emoji.sh "🍣" sushi.png --bg none --size 256
USAGE
  exit 1
}

[[ $# -eq 0 ]] && usage

BG="#FF0033"
BATCH=""
OUTDIR="./icons"
COMPOSE=()
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="$2"; shift 2 ;;
    --outdir) OUTDIR="$2"; shift 2 ;;
    --bg) BG="$2"; shift 2 ;;
    --size|--radius|--inset|--glyph) COMPOSE+=("$1" "$2"); shift 2 ;;
    -h|--help) usage ;;
    -*) echo "Unknown arg: $1"; usage ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

render() {
  icon-compose.sh --text "$1" "$2" --bg "$BG" ${COMPOSE[@]+"${COMPOSE[@]}"}
}

if [[ -n "$BATCH" ]]; then
  [[ -f "$BATCH" ]] || { echo "Batch file not found: $BATCH"; exit 1; }
  while read -r name emoji _; do
    [[ -z "${name:-}" || "$name" == \#* ]] && continue
    render "$emoji" "$OUTDIR/$name.png"
  done < "$BATCH"
else
  [[ ${#POSITIONAL[@]} -eq 2 ]] || usage
  render "${POSITIONAL[0]}" "${POSITIONAL[1]}"
fi
