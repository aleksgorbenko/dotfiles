#!/usr/bin/env bash
set -uo pipefail

# Check Go project
if [[ ! -f "go.mod" ]]; then
  echo "go-proof: no go.mod found" >&2
  exit 1
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
MODULE=$(grep -m1 '^module ' go.mod | awk '{print $2}')

# Run build, capture stdout+stderr
BUILD_OUTPUT=$(go build ./... 2>&1)
BUILD_EXIT=$?

if [[ $BUILD_EXIT -eq 0 ]]; then
  STATUS="✅  Build passed"
else
  STATUS="❌  Build failed"
fi

# Compose snippet
if [[ -n "$BUILD_OUTPUT" ]]; then
  SNIPPET="$ go build ./...
${BUILD_OUTPUT}
${STATUS}"
else
  SNIPPET="$ go build ./...
${STATUS}"
fi

# Write to temp file and render with codesnap
TMP=$(mktemp /tmp/go-proof-XXXXXX.sh)
echo "$SNIPPET" > "$TMP"

PROOF_FILE="$HOME/.claude/tmp/go-proof.png"
mkdir -p "$(dirname "$PROOF_FILE")"

# Render to file
codesnap \
  -f "$TMP" \
  -o "$PROOF_FILE" \
  --language bash \
  --title "${MODULE} — ${TIMESTAMP}" \
  --mac-window-bar true \
  --margin-x 20 \
  --margin-y 20 \
  --silent

# Also copy to clipboard
osascript -e "set the clipboard to (read (POSIX file \"$PROOF_FILE\") as «class PNGf»)"

rm -f "$TMP"

echo "${STATUS} — snapshot copied to clipboard"
exit $BUILD_EXIT
