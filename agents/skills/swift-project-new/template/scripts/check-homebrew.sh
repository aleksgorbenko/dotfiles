#!/usr/bin/env bash
set -euo pipefail

[ $# -eq 1 ] || { echo "usage: check-homebrew.sh <cask.rb>" >&2; exit 2; }
cask_file=$1
token="$(basename "$cask_file" .rb)"
tap="__SLUG__-local/check"
version="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$cask_file")"
! brew list --cask "$token" >/dev/null 2>&1 || { echo "$token is installed with Homebrew; uninstall it before the checks" >&2; exit 1; }
appdir="$(mktemp -d)"

cleanup() {
  brew uninstall --cask "$tap/$token" >/dev/null 2>&1 || true
  brew untrust --cask "$tap/$token" >/dev/null 2>&1 || true
  brew untrust --tap "$tap" >/dev/null 2>&1 || true
  brew untap "$tap" >/dev/null 2>&1 || true
  rm -rf "$appdir"
}
trap cleanup EXIT

brew tap-new --no-git "$tap" >/dev/null
tap_dir="$(brew --repository "$tap")"
mkdir -p "$tap_dir/Casks"
cp "$cask_file" "$tap_dir/Casks/$token.rb"
brew trust --quiet --tap "$tap"

echo "== brew style"
brew style --cask "$tap/$token"
echo "== brew audit --new --online --strict"
brew audit --cask --new --online --strict "$tap/$token"
echo "== brew livecheck"
latest="$(brew livecheck --cask --json "$tap/$token" | jq -r '.[0].version.latest')"
[ "$latest" = "$version" ] || { echo "livecheck finds $latest, not $version" >&2; exit 1; }
echo "== brew install (into a temporary folder, not /Applications)"
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --cask --appdir="$appdir" "$tap/$token"
echo "== brew uninstall"
brew uninstall --cask "$tap/$token"
echo "== $token passes every Homebrew check"
