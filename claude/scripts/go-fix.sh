#!/usr/bin/env bash
set -euo pipefail

# Check go.mod exists in current directory
if [[ ! -f "go.mod" ]]; then
  exit 0
fi

# 1. Parse Go version from go.mod and verify >= 1.26
GO_VERSION=$(grep -m1 '^go ' go.mod | awk '{print $2}')

if [[ -z "$GO_VERSION" ]]; then
  echo "go-fix: could not read Go version from go.mod" >&2
  exit 1
fi

MINOR=$(echo "$GO_VERSION" | cut -d. -f2)

if [[ "$MINOR" -lt 26 ]]; then
  echo "go-fix: Go $GO_VERSION < 1.26, skipping"
  exit 0
fi

# 2. Run go fix twice (incremental fixes may require multiple passes)
echo "go-fix: pass 1"
go fix ./...

echo "go-fix: pass 2"
go fix ./...

echo "go-fix: done"
