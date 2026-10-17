#!/bin/bash
set -euo pipefail

secret() {
  if [ -n "${!1:-}" ]; then printf '%s' "${!1}"; else security find-generic-password -a "$USER" -s "$2" -w; fi
}

export ASC_TELEMETRY_DISABLED=1 ASC_BYPASS_KEYCHAIN=1
ASC_KEY_ID="$(secret ASC_KEY_ID asc:key-id)"
ASC_ISSUER_ID="$(secret ASC_ISSUER_ID asc:issuer-id)"
ASC_PRIVATE_KEY_B64="$(secret ASC_KEY_P8 asc:key-p8)"
export ASC_KEY_ID ASC_ISSUER_ID ASC_PRIVATE_KEY_B64
exec "$@"
