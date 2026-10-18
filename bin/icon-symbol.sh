#!/usr/bin/env bash
# icon-symbol.sh - render SF Symbols as icons on a rounded background
# Requires macOS with SF Symbols.app. Find names with: sfsymbols search <term>
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  icon-symbol.sh <symbol> <output.png> [options]
  icon-symbol.sh --batch <file.txt> [--outdir DIR] [options]

Batch file: one "<name> <symbol> [#RRGGBB]" line per icon; writes DIR/<name>.png (default DIR: ./icons).
             The optional colour overrides --bg for that icon.
Blank lines and lines starting with # are skipped.

Options:
  --size N        output width/height in px (default: 1024)
  --bg COLOUR     background #RRGGBB, or "none" (default: #FF0033)
  --fg COLOUR     symbol #RRGGBB (default: #1C1C1E)
  --weight NAME   ultralight ... black (default: semibold)
  --radius, --inset, --glyph   passed to icon-compose.sh

Examples:
  icon-symbol.sh bell bell.png
  icon-symbol.sh play.rectangle.fill icon.png --bg "#FF0033" --fg "#FFFFFF"
  icon-symbol.sh --batch icons.txt --outdir icons --size 256
USAGE
  exit 1
}

[[ $# -eq 0 ]] && usage

SFSYMBOLS="/Applications/SF Symbols.app/Contents/Executables/sfsymbols"
BG="#FF0033"
FG="#1C1C1E"
WEIGHT=semibold
BATCH=""
OUTDIR="./icons"
COMPOSE=()
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --batch) BATCH="$2"; shift 2 ;;
    --outdir) OUTDIR="$2"; shift 2 ;;
    --bg) BG="$2"; shift 2 ;;
    --fg) FG="$2"; shift 2 ;;
    --weight) WEIGHT="$2"; shift 2 ;;
    --size|--radius|--inset|--glyph) COMPOSE+=("$1" "$2"); shift 2 ;;
    -h|--help) usage ;;
    -*) echo "Unknown arg: $1"; usage ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

[[ -x "$SFSYMBOLS" ]] || { echo "SF Symbols.app not found"; exit 1; }
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

render() {
  local symbol="$1" output="$2" background="${3:-$BG}"
  "$SFSYMBOLS" export "$symbol" --format png --output "$WORK/glyph.png" \
    --point-size 512 --weight "$WEIGHT" --rendering-mode monochrome --color "$FG" \
    >/dev/null 2>"$WORK/error.log" || { cat "$WORK/error.log" >&2; exit 1; }
  icon-compose.sh "$WORK/glyph.png" "$output" --bg "$background" ${COMPOSE[@]+"${COMPOSE[@]}"}
}

if [[ -n "$BATCH" ]]; then
  [[ -f "$BATCH" ]] || { echo "Batch file not found: $BATCH"; exit 1; }
  while read -r name symbol background _; do
    [[ -z "${name:-}" || "$name" == \#* ]] && continue
    render "$symbol" "$OUTDIR/$name.png" "${background:-}"
  done < "$BATCH"
else
  [[ ${#POSITIONAL[@]} -eq 2 ]] || usage
  render "${POSITIONAL[0]}" "${POSITIONAL[1]}"
fi
