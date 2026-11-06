#!/bin/bash
set -uo pipefail

log_dir="${TMPDIR:-/tmp}/__SLUG__-analyze"
mkdir -p "$log_dir"

mode="${ANALYZE_MODE:-changed}"

if [ -n "${COMPILER_LOG:-}" ]; then
  swiftlint analyze --compiler-log-path "$COMPILER_LOG" --config .swiftlint.yml --strict --quiet Packages/*/Sources
  exit $?
fi

changed_files() {
  local base
  base="$(command git merge-base HEAD "${ANALYZE_BASE:-main}")"
  {
    command git diff --name-only --diff-filter=d "$base"
    command git ls-files --others --exclude-standard
  } | grep -E '^Packages/[^/]+/Sources/.*\.swift$' | sort -u
}

run_parallel() {
  local step=$1
  shift
  local pids=() packages=()
  for pkg in "$@"; do
    "$step" "$pkg" > "$log_dir/$step-$pkg.log" 2>&1 &
    pids+=("$!")
    packages+=("$pkg")
  done
  local failed=0
  for index in "${!pids[@]}"; do
    if ! wait "${pids[$index]}"; then
      echo "--- $step failed: ${packages[$index]} ---"
      cat "$log_dir/$step-${packages[$index]}.log"
      failed=1
    fi
  done
  return $failed
}

build() {
  if [ "$mode" = full ]; then
    rm -rf "Packages/$1/.build"
  else
    grep "^Packages/$1/" "$log_dir/files" | xargs touch
  fi
  (cd "Packages/$1" && swift build -v) > "$log_dir/compile-$1.log" 2>&1 || { cat "$log_dir/compile-$1.log"; return 1; }
}

analyze() {
  swiftlint analyze --compiler-log-path "$log_dir/compile-$1.log" --config .swiftlint.yml --strict --quiet
}

if [ "$mode" != full ]; then
  changed_files > "$log_dir/files"
  packages=()
  for pkg in "$@"; do
    grep -q "^Packages/$pkg/" "$log_dir/files" && packages+=("$pkg")
  done
  if [ "${#packages[@]}" -eq 0 ]; then
    echo "Analyzed: no changed package sources"
    exit 0
  fi
  set -- "${packages[@]}"
fi

run_parallel build "$@" || exit 1
run_parallel analyze "$@" || exit 1
echo "Analyzed ($mode): $*"
