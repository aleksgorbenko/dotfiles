#!/bin/bash
set -euo pipefail

app_path="$1"
seconds="${2:-60}"
top="${3:-20}"
process="$(basename "$app_path" .app)"
# shellcheck source=scripts/profile-common.sh
source "$(dirname "$0")/profile-common.sh"
trace="$out_dir/cpu-$(date +%Y%m%d-%H%M%S).trace"

launch_app "$app_path"

echo "Recording $process (pid $pid) with Instruments' Time Profiler for ${seconds}s. Use the app now."
xcrun xctrace record --template 'Time Profiler' --attach "$pid" --time-limit "${seconds}s" --output "$trace" --no-prompt > "$out_dir/xctrace.log" 2>&1 \
  || { cat "$out_dir/xctrace.log" >&2; exit 1; }
xcrun xctrace export --input "$trace" --xpath '/trace-toc/run[@number="1"]/data/table[@schema="time-profile"]' > "$trace.xml"

echo
python3 "$(dirname "$0")/cpu_profile_top.py" "$trace.xml" "$top"
echo
echo "Trace: open $trace"
