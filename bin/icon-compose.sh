#!/usr/bin/env bash
# icon-compose.sh - place any image or emoji, trimmed and centred, on a square canvas
# Requires macOS with the Swift toolchain. Engine shared by every icon-*.sh script.
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  icon-compose.sh <input.png|svg|icns|...> <output.png> [options]
  icon-compose.sh --text "<emoji>" <output.png> [options]

Options:
  --size N        output width/height in px (default: 1024)
  --bg COLOUR     background #RRGGBB, or "none" for transparent (default: none)
  --radius F      corner radius as a fraction of the size (default: 0.2237)
  --inset F       background inset from the edge as a fraction of the size (default: 0)
  --glyph F       content's longest side as a fraction of the size
                  (default: 0.56 with a background, 1.0 without)
  --style S       flat, or macos: 824/1024 grid squircle, gradient, rim, shadow (default: flat)
  --source S      macos only: glyph, logo (restyle a full-bleed icon), whole (fit as is) (default: glyph)

Examples:
  icon-compose.sh logo.svg icon.png --bg "#FFFFFF"
  icon-compose.sh --text "🎵" music.png --bg "#1C1C1E"
USAGE
  exit 1
}

[[ $# -eq 0 ]] && usage

LIB="$(cd "$(dirname "$(readlink -f "$0")")/../lib/icons" && pwd)"
SIZE=1024
BG=none
RADIUS=0.2237
INSET=0
GLYPH=""
STYLE=flat
ORIGIN=glyph
TEXT=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --text) TEXT="$2"; shift 2 ;;
    --size) SIZE="$2"; shift 2 ;;
    --bg) BG="$2"; shift 2 ;;
    --radius) RADIUS="$2"; shift 2 ;;
    --inset) INSET="$2"; shift 2 ;;
    --glyph) GLYPH="$2"; shift 2 ;;
    --style) STYLE="$2"; shift 2 ;;
    --source) ORIGIN="$2"; shift 2 ;;
    -h|--help) usage ;;
    -*) echo "Unknown arg: $1"; usage ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

if [[ -n "$TEXT" ]]; then
  [[ ${#POSITIONAL[@]} -eq 1 ]] || usage
  SOURCE=(--text "$TEXT")
  OUTPUT="${POSITIONAL[0]}"
else
  [[ ${#POSITIONAL[@]} -eq 2 ]] || usage
  [[ -f "${POSITIONAL[0]}" ]] || { echo "Input not found: ${POSITIONAL[0]}"; exit 1; }
  SOURCE=(--input "${POSITIONAL[0]}")
  OUTPUT="${POSITIONAL[1]}"
fi

if [[ -z "$GLYPH" ]]; then
  if [[ "$BG" == none ]]; then GLYPH=1.0; else GLYPH=0.56; fi
fi

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/icons"
COMPOSER="$CACHE_DIR/compose-$(shasum "$LIB/compose.swift" | cut -c1-12)"
if [[ ! -x "$COMPOSER" ]]; then
  mkdir -p "$CACHE_DIR"
  swiftc -O -o "$COMPOSER" "$LIB/compose.swift"
fi

"$COMPOSER" "${SOURCE[@]}" --output "$OUTPUT" --size "$SIZE" --bg "$BG" \
  --radius "$RADIUS" --inset "$INSET" --glyph "$GLYPH" \
  --style "$STYLE" --source "$ORIGIN"
echo "$OUTPUT"
