#!/usr/bin/env bash
# icon-polish.sh - restyle an existing full-bleed app or workflow icon to the macOS icon grid
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  icon-polish.sh <input.png> <output.png> [options]

Takes the background colour from the icon's top and bottom edge, lifts the logo off it and
redraws it on an 824/1024 squircle with a gradient, rim highlight and drop shadow.

Options:
  --size N        output width/height in px (default: 1024)
  --bg COLOUR     background #RRGGBB to lift the logo off, instead of sampling it
  --whole         keep the icon's own shape and only fit it to the grid

Examples:
  icon-polish.sh icon.png icon.png
  icon-polish.sh 2do.png icon.png --whole
USAGE
  exit 1
}

[[ $# -eq 0 ]] && usage

SOURCE=logo
OPTIONS=()
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --whole) SOURCE=whole; shift ;;
    --size|--bg) OPTIONS+=("$1" "$2"); shift 2 ;;
    -h|--help) usage ;;
    -*) echo "Unknown arg: $1"; usage ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

[[ ${#POSITIONAL[@]} -eq 2 ]] || usage
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cp "${POSITIONAL[0]}" "$WORK/source.png"
icon-compose.sh "$WORK/source.png" "${POSITIONAL[1]}" --style macos --source "$SOURCE" ${OPTIONS[@]+"${OPTIONS[@]}"}
