#!/usr/bin/env bash
# pack-icon.sh — convert a 1024x1024 source PNG into platform-specific icon format
# Requires macOS (sips, iconutil).
set -euo pipefail

usage() {
  cat <<EOF
Usage:
  pack-icon.sh --input <source.png> --output ios|macos|alfred|all [--name NAME] [--keep-iconset]

  ios     -> single 1024x1024 PNG, alpha stripped (Xcode 15+ single-asset icon; iOS/iPadOS/watchOS)
  macos   -> classic AppIcon.icns via iconutil (legacy format; may not apply on Tahoe/Xcode26 Icon Composer builds)
  alfred  -> icon.png (512x512) + minimal info.plist, zipped as NAME.alfredworkflow
  all     -> runs all three into ./out/

Flags:
  --name NAME       base filename / workflow name (default: AppIcon)
  --keep-iconset     don't delete intermediate .iconset folder (macos only)
EOF
  exit 1
}

[[ $# -eq 0 ]] && usage

INPUT=""
TARGET=""
NAME="AppIcon"
KEEP=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input) INPUT="$2"; shift 2 ;;
    --output) TARGET="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --keep-iconset) KEEP=1; shift ;;
    *) echo "Unknown arg: $1"; usage ;;
  esac
done

[[ -z "$INPUT" || -z "$TARGET" ]] && usage
[[ -f "$INPUT" ]] || { echo "Input not found: $INPUT"; exit 1; }

W=$(sips -g pixelWidth "$INPUT" | awk '/pixelWidth/{print $2}')
H=$(sips -g pixelHeight "$INPUT" | awk '/pixelHeight/{print $2}')
if [[ "$W" != "1024" || "$H" != "1024" ]]; then
  echo "Warning: input is ${W}x${H}, expected 1024x1024. Continuing, quality may suffer."
fi

OUTDIR="./out"
mkdir -p "$OUTDIR"

do_ios() {
  local dest="${OUTDIR}/${NAME}-ios-1024.png"
  cp "$INPUT" "$dest"
  # strip alpha channel - iOS requires fully opaque icon
  sips -s format png -s formatOptions default "$dest" --out "$dest" >/dev/null
  sips -s hasAlpha no "$dest" >/dev/null 2>&1 || true
  echo "iOS/iPadOS/watchOS icon: $dest (drop into Xcode single-size app icon slot)"
}

do_macos() {
  local iconset="${OUTDIR}/${NAME}.iconset"
  mkdir -p "$iconset"
  declare -A sizes=( [16]=1 [32]=1 [128]=1 [256]=1 [512]=1 )
  for s in "${!sizes[@]}"; do
    sips -z "$s" "$s" "$INPUT" --out "${iconset}/icon_${s}x${s}.png" >/dev/null
    d=$((s*2))
    sips -z "$d" "$d" "$INPUT" --out "${iconset}/icon_${s}x${s}@2x.png" >/dev/null
  done
  iconutil -c icns "$iconset" -o "${OUTDIR}/${NAME}.icns"
  [[ $KEEP -eq 0 ]] && rm -rf "$iconset"
  echo "macOS icon: ${OUTDIR}/${NAME}.icns"
  echo "NOTE: this is the legacy .icns format. If your app targets macOS 26 (Tahoe) Icon Composer / Liquid Glass, Xcode may expect a .icon bundle instead — that requires the Icon Composer GUI, not scriptable here."
}

do_alfred() {
  local work="${OUTDIR}/${NAME}_alfred"
  mkdir -p "$work"
  sips -z 512 512 "$INPUT" --out "${work}/icon.png" >/dev/null
  cat > "${work}/info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>bundleid</key>
	<string>com.example.${NAME}</string>
	<key>name</key>
	<string>${NAME}</string>
	<key>objects</key>
	<array/>
	<key>connections</key>
	<dict/>
	<key>uidata</key>
	<dict/>
</dict>
</plist>
PLIST
  (cd "$work" && zip -q -r "../${NAME}.alfredworkflow" icon.png info.plist)
  rm -rf "$work"
  echo "Alfred workflow skeleton: ${OUTDIR}/${NAME}.alfredworkflow (import into Alfred, then add script filters/objects)"
}

case "$TARGET" in
  ios) do_ios ;;
  macos) do_macos ;;
  alfred) do_alfred ;;
  all) do_ios; do_macos; do_alfred ;;
  *) echo "Unknown --output: $TARGET"; usage ;;
esac
