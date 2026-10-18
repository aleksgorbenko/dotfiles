#!/usr/bin/env bash
# test.sh - integration tests for the icon-*.sh scripts (needs network for Iconify/favicons)
set -uo pipefail

BIN="$(cd "$(dirname "$(readlink -f "$0")")/../../bin" && pwd)"
export PATH="$BIN:$PATH"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
passed=0
failed=0

check() {
  local name="$1"
  shift
  if "$@" >"$WORK/last.log" 2>&1; then
    passed=$((passed + 1))
    echo "ok   $name"
  else
    failed=$((failed + 1))
    echo "FAIL $name"
    sed 's/^/     /' "$WORK/last.log"
  fi
}

fails() { ! "$@"; }

size_is() {
  local file="$1" expected="$2"
  [[ "$(sips -g pixelWidth "$file" | awk '/pixelWidth/ { print $2 }')" == "$expected" ]] &&
    [[ "$(sips -g pixelHeight "$file" | awk '/pixelHeight/ { print $2 }')" == "$expected" ]]
}

pixel() {
  python3 - "$1" "$2" "$3" <<'PY'
import struct, sys, zlib
path, x, y = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
data = open(path, "rb").read()
pos, chunks = 8, {}
width = height = 0
idat = b""
while pos < len(data):
    length, kind = struct.unpack(">I4s", data[pos:pos + 8])
    body = data[pos + 8:pos + 8 + length]
    if kind == b"IHDR":
        width, height, depth, colour = struct.unpack(">IIBB", body[:10])
        assert depth == 8 and colour == 6, "expected 8-bit RGBA"
    elif kind == b"IDAT":
        idat += body
    pos += 12 + length
raw = zlib.decompress(idat)
stride = width * 4
rows, previous = [], bytearray(stride)
for row in range(height):
    kind = raw[row * (stride + 1)]
    line = bytearray(raw[row * (stride + 1) + 1:(row + 1) * (stride + 1)])
    for i in range(stride):
        left = line[i - 4] if i >= 4 else 0
        up = previous[i]
        corner = previous[i - 4] if i >= 4 else 0
        if kind == 1: line[i] = (line[i] + left) & 255
        elif kind == 2: line[i] = (line[i] + up) & 255
        elif kind == 3: line[i] = (line[i] + (left + up) // 2) & 255
        elif kind == 4:
            p = left + up - corner
            pa, pb, pc = abs(p - left), abs(p - up), abs(p - corner)
            line[i] = (line[i] + (left if pa <= pb and pa <= pc else up if pb <= pc else corner)) & 255
    rows.append(line)
    previous = line
print("%02X%02X%02X%02X" % tuple(rows[y][x * 4:x * 4 + 4]))
PY
}

pixel_is() { [[ "$(pixel "$1" "$2" "$3")" == "$4" ]]; }

packs() {
  local target="$1" expected="$2"
  (cd "$WORK" && icon-pack.sh --input "$WORK/bell.png" --output "$target" --name T >/dev/null) &&
    test -f "$WORK/out/$expected"
}

renames() {
  icon-rename.sh App-Dark- "$WORK/rename" && test -f "$WORK/rename/icon_20.png"
}

searches_for() {
  icon-iconify.sh --search music --set lucide,tabler | grep -qx "$1"
}

check "compose: transparent corners with background" \
  icon-compose.sh --text "🎵" "$WORK/emoji-text.png" --size 128 --bg "#FF0033"
check "compose: corner outside rounded background is transparent" pixel_is "$WORK/emoji-text.png" 0 0 00000000
check "compose: edge midpoint is background colour" pixel_is "$WORK/emoji-text.png" 0 64 FF0033FF
check "compose: missing input fails" fails icon-compose.sh "$WORK/nope.png" "$WORK/x.png"
check "compose: bad colour fails" fails icon-compose.sh --text "🎵" "$WORK/x.png" --bg red

check "symbol: renders" icon-symbol.sh bell "$WORK/bell.png" --size 256
check "symbol: 256px square" size_is "$WORK/bell.png" 256
check "symbol: default red background" pixel_is "$WORK/bell.png" 2 128 FF0033FF
check "symbol: unknown symbol fails" fails icon-symbol.sh not.a.symbol "$WORK/x.png"
printf 'one bell\n# comment\n\ntwo house\n' >"$WORK/symbols.txt"
check "symbol: batch" icon-symbol.sh --batch "$WORK/symbols.txt" --outdir "$WORK/batch" --size 64
check "symbol: batch outputs" test -f "$WORK/batch/one.png" -a -f "$WORK/batch/two.png"
check "symbol: batch skips comments" test "$(find "$WORK/batch" -name '*.png' | wc -l | tr -d ' ')" = 2
printf 'blue bell #0A84FF\nplain bell\n' >"$WORK/colours.txt"
check "symbol: batch with per-line background" icon-symbol.sh --batch "$WORK/colours.txt" --outdir "$WORK/colours" --size 64
check "symbol: per-line background colour" pixel_is "$WORK/colours/blue.png" 1 32 0A84FFFF
check "symbol: default background without colour column" pixel_is "$WORK/colours/plain.png" 1 32 FF0033FF

check "emoji: transparent background" icon-emoji.sh "🍣" "$WORK/sushi.png" --bg none --size 128
check "emoji: corner transparent" pixel_is "$WORK/sushi.png" 0 0 00000000
check "emoji: 128px square" size_is "$WORK/sushi.png" 128

check "iconify: search within sets finds tabler:music" searches_for tabler:music
check "iconify: search within sets excludes others" fails searches_for mdi:music
check "iconify: search honours limit" test "$(icon-iconify.sh --search music --limit 3 | wc -l | tr -d ' ')" = 3
check "iconify: renders" icon-iconify.sh lucide:music "$WORK/music.png" --size 128
check "iconify: background colour" pixel_is "$WORK/music.png" 1 64 FF0033FF
check "iconify: unknown icon fails" fails icon-iconify.sh lucide:not-an-icon-xyz "$WORK/x.png"
check "iconify: name without set fails" fails icon-iconify.sh music "$WORK/x.png"

check "favicon: github.com" icon-favicon.sh github.com "$WORK/github.png"
check "favicon: 256px default" size_is "$WORK/github.png" 256
check "favicon: unknown domain fails" fails icon-favicon.sh nonexistent-domain-xyz123.invalid "$WORK/x.png"

check "app: Finder icon by bundle id" icon-app.sh --size 128 "$WORK/apps" com.apple.finder
check "app: output written" test -f "$WORK/apps/com.apple.finder.png"

check "pack: alfred" packs alfred T.alfredworkflow
check "pack: macos icns" packs macos T.icns

icon-symbol.sh bell "$WORK/glyph.png" --bg "#FFFFFF" --fg "#000000" --glyph 0.9 --size 256 >/dev/null
check "menubar: image set" icon-menubar.sh "$WORK/glyph.png" "$WORK/Bell.imageset"
check "menubar: 3 scales" test -f "$WORK/Bell.imageset/icon@3x.png"

mkdir -p "$WORK/rename" && touch "$WORK/rename/App-Dark-20@1x.png" "$WORK/rename/App-Dark-40.png" "$WORK/rename/icon_40.png"
check "rename: renames and drops @1x" renames
check "rename: never overwrites" test -f "$WORK/rename/App-Dark-40.png"

echo "$passed passed, $failed failed"
[[ $failed -eq 0 ]]
