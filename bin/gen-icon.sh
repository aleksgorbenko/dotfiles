#!/usr/bin/env bash
# gen-icon.sh — generate 1024x1024 icon PNG(s) via Pollinations (free, no API key)
set -euo pipefail

usage() {
  cat <<EOF
Usage:
  gen-icon.sh "<prompt>" <output.png> [--seed N] [--style "extra style text"]
  gen-icon.sh --batch <file.txt> [--outdir DIR] [--seed N] [--style "extra style text"]

Single mode: one prompt -> one file.
Batch mode: file.txt has one content-phrase per line (e.g. grammar patterns).
            Outputs icon_<slug>.png into --outdir (default ./icons).
            Same --seed + --style applied to every line for visual consistency.

Examples:
  gen-icon.sh "torii gate" torii.png --seed 42 --style "minimalist flat line icon, white background"
  gen-icon.sh --batch patterns.txt --outdir icons --seed 42 --style "minimalist flat line icon, white background"
EOF
  exit 1
}

[[ $# -eq 0 ]] && usage

SEED=42
STYLE=""
BATCH=""
OUTDIR="./icons"
PROMPT=""
OUTFILE=""

# first pass: detect mode
if [[ "$1" == "--batch" ]]; then
  BATCH="$2"
  shift 2
else
  [[ $# -lt 2 ]] && usage
  PROMPT="$1"
  OUTFILE="$2"
  shift 2
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --seed) SEED="$2"; shift 2 ;;
    --style) STYLE="$2"; shift 2 ;;
    --outdir) OUTDIR="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; usage ;;
  esac
done

urlenc() {
  python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' "$1"
}

fetch() {
  local prompt="$1" out="$2"
  local full_prompt="$prompt"
  [[ -n "$STYLE" ]] && full_prompt="${prompt}, ${STYLE}"
  local enc; enc=$(urlenc "$full_prompt")
  echo "-> $out : $full_prompt"
  curl -fsSL "https://image.pollinations.ai/prompt/${enc}?width=1024&height=1024&nologo=true&seed=${SEED}" -o "$out"
}

if [[ -n "$BATCH" ]]; then
  [[ -f "$BATCH" ]] || { echo "Batch file not found: $BATCH"; exit 1; }
  mkdir -p "$OUTDIR"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    slug=$(echo "$line" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '_' | sed 's/_\+/_/g; s/^_//; s/_$//')
    fetch "$line" "${OUTDIR}/icon_${slug}.png"
  done < "$BATCH"
  echo "Done. Icons in $OUTDIR"
else
  fetch "$PROMPT" "$OUTFILE"
fi
