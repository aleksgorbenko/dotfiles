#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

for derived_data in "$@"; do
  for products in "$derived_data"/Build/Products/*/; do
    for framework in "$products"PackageFrameworks/*.framework; do
      name="$(basename "$framework" .framework)"
      if [ -e "$products$name.swiftmodule" ]; then
        echo "== removing $products$name.swiftmodule, it shadows PackageFrameworks/$name.framework"
        rm -rf "$products$name.swiftmodule"
      fi
    done
  done
done
