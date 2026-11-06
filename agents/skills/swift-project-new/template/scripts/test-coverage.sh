#!/usr/bin/env bash
set -euo pipefail

: "${WORKSPACE:?}" "${SCHEME:?}" "${DESTINATION:?}" "${RESULT:?}" "${COVERAGE_MIN:?}"
read -r -a flags <<<"${XCODEBUILD_FLAGS:-}"

main_result="${RESULT%.xcresult}-main.xcresult"
keychain_result="${RESULT%.xcresult}-keychain.xcresult"
rm -rf "$RESULT" "$main_result" "$keychain_result"

run_tests() {
  local result=$1 append=$2
  shift 2
  local command=(xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION"
    "$@" -enableCodeCoverage YES -resultBundlePath "$result" ${flags[@]+"${flags[@]}"} test)
  if [ -n "${XCODEBUILD_LOG:-}" ]; then
    mkdir -p "$(dirname "$XCODEBUILD_LOG")"
    if [ "$append" = append ]; then
      "${command[@]}" 2>&1 | tee -a "$XCODEBUILD_LOG"
    else
      "${command[@]}" 2>&1 | tee "$XCODEBUILD_LOG"
    fi
  else
    "${command[@]}"
  fi
}

run_tests "$main_result" new
run_tests "$keychain_result" append -testPlan __APP__-Keychain
xcrun xcresulttool merge "$main_result" "$keychain_result" --output-path "$RESULT"
xcrun xccov view --report --json "$RESULT" >"$RESULT.json"
python3 scripts/check_coverage.py "$RESULT.json" "$COVERAGE_MIN"
