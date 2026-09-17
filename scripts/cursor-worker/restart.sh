#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

TARGET="$(launchd_target)"

if ! service_loaded; then
  echo "error: ${LABEL} is not loaded. Run ./scripts/cursor-worker/install.sh first." >&2
  exit 1
fi

launchctl kickstart -k "${TARGET}"
echo "Restarted ${LABEL}"
