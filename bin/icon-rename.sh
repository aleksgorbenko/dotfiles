#!/usr/bin/env bash
# icon-rename.sh - rename exported "<prefix><name>[@1x].png" files to "icon_<name>.png"
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  icon-rename.sh <prefix> [dir]

Renames every <prefix>*.png in dir (default: current directory) to icon_*.png,
dropping "@1x". Never overwrites an existing file.

Examples:
  icon-rename.sh Bukku-iOS-Dark-
  icon-rename.sh Export- ./Exports
USAGE
  exit 1
}

[[ $# -ge 1 && $# -le 2 ]] || usage
[[ "$1" == -h || "$1" == --help ]] && usage

PREFIX="$1"
DIR="${2:-.}"

for file in "$DIR/$PREFIX"*.png; do
  [[ -e "$file" ]] || continue
  base="$(basename "$file")"
  name="icon_${base#"$PREFIX"}"
  name="${name//@1x/}"
  if [[ -e "$DIR/$name" ]]; then
    echo "skip: $DIR/$name exists" >&2
    continue
  fi
  mv "$file" "$DIR/$name"
  echo "$base -> $name"
done
