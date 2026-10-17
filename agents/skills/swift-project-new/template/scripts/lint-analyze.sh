#!/bin/bash
set -uo pipefail

log_dir="${TMPDIR:-/tmp}/analyze-$(basename "$PWD")"
mkdir -p "$log_dir"

if [ -n "${COMPILER_LOG:-}" ]; then
  swiftlint analyze --compiler-log-path "$COMPILER_LOG" --config .swiftlint.yml --strict --quiet
  exit $?
fi

if [ $# -eq 0 ]; then
  log="$log_dir/app.log"
  xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" clean build > "$log" 2>&1 \
    || { tail -40 "$log"; exit 1; }
  swiftlint analyze --compiler-log-path "$log" --config .swiftlint.yml --strict --quiet
  exit $?
fi

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
  rm -rf "Packages/$1/.build"
  (cd "Packages/$1" && swift build -v) > "$log_dir/compile-$1.log" 2>&1 || { cat "$log_dir/compile-$1.log"; return 1; }
}

analyze() {
  swiftlint analyze --compiler-log-path "$log_dir/compile-$1.log" --config .swiftlint.yml --strict --quiet
}

run_parallel build "$@" || exit 1
run_parallel analyze "$@" || exit 1
echo "Analyzed: $*"
