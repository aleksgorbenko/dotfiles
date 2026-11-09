#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:?APP_NAME is required}"
PATTERN="DerivedData/.*/Build/Products/[^/]*/$APP_NAME(-Direct)?\.app/Contents/MacOS/$APP_NAME(-Direct)?( |$)"

pids="$(pgrep -f "$PATTERN" || true)"
if [ -z "$pids" ]; then
  exit 0
fi

for pid in $pids; do
  configuration="$(ps -o command= -p "$pid" | sed -E 's|.*/Build/Products/([^/]*)/.*|\1|')"
  echo "Quitting $APP_NAME built from this repo ($configuration, pid $pid): only one copy runs at a time."
  kill "$pid"
done

for _ in $(seq 50); do
  pgrep -f "$PATTERN" >/dev/null || exit 0
  sleep 0.1
done

for pid in $(pgrep -f "$PATTERN" || true); do
  parent="$(ps -o ppid= -p "$pid" | tr -d ' ')"
  if ps -o command= -p "$parent" | grep -q '/debugserver '; then
    echo "Ending the Xcode debug session of pid $pid: the debugger catches a normal quit."
    kill "$parent"
  fi
done

for _ in $(seq 20); do
  pgrep -f "$PATTERN" >/dev/null || exit 0
  sleep 0.1
done
echo "error: $APP_NAME built from this repo is still running after 5 s: $(pgrep -f "$PATTERN" | tr '\n' ' ')" >&2
exit 1
