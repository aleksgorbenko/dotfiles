#!/usr/bin/env bash
set -euo pipefail

[ $# -eq 1 ] || { echo "usage: check-homebrew.sh <cask.rb>" >&2; exit 2; }
cask_file=$1
token="$(basename "$cask_file" .rb)"
tap="__SLUG__-local/check"
appdir="$(mktemp -d)"

cleanup() {
  brew uninstall --cask "$tap/$token" --appdir="$appdir" >/dev/null 2>&1 || true
  brew untap "$tap" >/dev/null 2>&1 || true
  rm -rf "$appdir"
}
trap cleanup EXIT

brew tap-new --no-git "$tap" >/dev/null
tap_dir="$(brew --repository "$tap")"
mkdir -p "$tap_dir/Casks"
cp "$cask_file" "$tap_dir/Casks/$token.rb"

echo "== brew style"
brew style --cask "$tap/$token"
echo "== brew audit --new --online"
brew audit --cask --new --online "$tap/$token"
echo "== brew install (into a temporary folder, not /Applications)"
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --cask --appdir="$appdir" "$tap/$token"
echo "== brew uninstall"
brew uninstall --cask --appdir="$appdir" "$tap/$token"
echo "== $token passes every Homebrew check"
