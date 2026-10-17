#!/bin/bash
set -euo pipefail

app_path="$1"
runs="${2:-5}"
budget_ms="${3:-500}"
process="$(basename "$app_path" .app)"
# shellcheck source=scripts/profile-common.sh
source "$(dirname "$0")/profile-common.sh"
stamp="$out_dir/launch-$(date +%Y%m%d-%H%M%S)"

exports=()
for run in $(seq 1 "$runs"); do
  pkill -x "$process" 2>/dev/null || true
  sleep 1
  trace="$stamp-$run.trace"
  xcrun xctrace record --template 'App Launch' --time-limit 5s --output "$trace" --no-prompt \
    --launch -- "$app_path/Contents/MacOS/$process" > "$out_dir/xctrace.log" 2>&1 || { cat "$out_dir/xctrace.log" >&2; exit 1; }
  xcrun xctrace export --input "$trace" --xpath '/trace-toc/run[@number="1"]/data/table[@schema="life-cycle-period"]' > "$trace.xml"
  exports+=("$trace.xml")
done
pkill -x "$process" 2>/dev/null || true

python3 "$(dirname "$0")/launch_time.py" "$budget_ms" "${exports[@]}"
