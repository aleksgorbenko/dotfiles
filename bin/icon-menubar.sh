#!/usr/bin/env bash
# icon-menubar.sh - turn a flat single-colour glyph into a macOS menu-bar template image set
# Requires macOS with the Swift toolchain.
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  icon-menubar.sh <input.png> <output.imageset> [height]

Writes icon.png, icon@2x.png and icon@3x.png plus a template-rendering Contents.json.
Luminance becomes alpha, so use black-on-white glyphs, not multi-colour art.

Options:
  height          1x point height (default: 18)

Examples:
  icon-menubar.sh glyph.png Resources/Assets.xcassets/MenuBarIcon.imageset
  icon-symbol.sh bell glyph.png --bg "#FFFFFF" --fg "#000000" --glyph 0.9 && icon-menubar.sh glyph.png Bell.imageset
USAGE
  exit 1
}

[[ $# -ge 2 && $# -le 3 ]] || usage
[[ "$1" == -h || "$1" == --help ]] && usage

LIB="$(cd "$(dirname "$(readlink -f "$0")")/../lib/icons" && pwd)"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/icons"
BUILDER="$CACHE_DIR/menubar-$(shasum "$LIB/menubar.swift" | cut -c1-12)"
if [[ ! -x "$BUILDER" ]]; then
  mkdir -p "$CACHE_DIR"
  swiftc -O -o "$BUILDER" "$LIB/menubar.swift"
fi

"$BUILDER" "$@"
