#!/bin/bash

out_dir="build.noindex/profile"
mkdir -p "$out_dir"
out_dir="$(cd "$out_dir" && pwd)"

launch_app() {
  local app_path="$1" process
  process="$(basename "$app_path" .app)"
  shift
  pkill -x "$process" 2>/dev/null || true
  sleep 1
  open "$@" -a "$app_path"
  for _ in $(seq 1 20); do
    pid="$(pgrep -nx "$process" || true)"
    [ -n "$pid" ] && return 0
    sleep 0.5
  done
  echo "error: $process did not start" >&2
  exit 1
}
