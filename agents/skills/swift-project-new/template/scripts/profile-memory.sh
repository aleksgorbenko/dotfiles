#!/bin/bash
set -euo pipefail

app_path="$1"
seconds="${2:-60}"
process="$(basename "$app_path" .app)"
out_dir="build.noindex/profile"
mkdir -p "$out_dir"
stamp="$(cd "$out_dir" && pwd)/memory-$(date +%Y%m%d-%H%M%S)"
trace="$stamp.trace"
baseline="$stamp-start.memgraph"
graph="$stamp.memgraph"
top="${3:-20}"

footprint_mb() {
  footprint "$1" 2>/dev/null | awk '/phys_footprint:/ && !found { size = $2; unit = $3; if (unit == "KB") size /= 1024; if (unit == "GB") size *= 1024; print int(size); found = 1 }' || true
}

class_table() {
  awk -v top="$top" '/^ *COUNT +BYTES/ { rows = top + 2 } rows > 0 { print; rows-- }'
}

pkill -x "$process" 2>/dev/null || true
sleep 1
open -a "$app_path"
for _ in $(seq 1 20); do
  pid="$(pgrep -nx "$process" || true)"
  [ -n "$pid" ] && break
  sleep 0.5
done
[ -n "${pid:-}" ] || { echo "error: $process did not start" >&2; exit 1; }

for _ in $(seq 1 10); do
  sleep 1
  leaks --outputGraph="$baseline" "$pid" > /dev/null 2>&1 && break
done

echo "Recording $process (pid $pid) with Instruments' Leaks template for ${seconds}s. Use the app now."
xcrun xctrace record --template Leaks --attach "$pid" --time-limit "${seconds}s" --output "$trace" --no-prompt > "$out_dir/xctrace.log" 2>&1 &
recorder=$!

peak=0
while kill -0 "$recorder" 2>/dev/null; do
  current="$(footprint_mb "$pid")"
  [ -n "$current" ] && [ "$current" -gt "$peak" ] && peak="$current"
  sleep 1
done
wait "$recorder" || { cat "$out_dir/xctrace.log" >&2; exit 1; }

final="$(footprint_mb "$pid")"
leaks --outputGraph="$graph" "$pid" > /dev/null 2>&1 || true
leak_line="$( (leaks "$graph" 2>/dev/null || true) | grep -E 'leaks for' | sed 's/^Process [0-9]*: //' || true)"

echo
echo "Peak memory:  ${peak} MB"
echo "Final memory: ${final:-?} MB"
echo "Leaks:        ${leak_line:-unknown}"
echo "Trace:        open $trace"
echo "Graph:        open $graph"
echo
echo "Largest classes (top $top by size):"
(heap -s -H -q "$graph" 2>/dev/null || true) | class_table
echo
echo "Growth since launch (top $top by size):"
(heap -s -H -q --diffFrom="$baseline" "$graph" 2>/dev/null || true) | class_table
