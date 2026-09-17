#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

TARGET="$(launchd_target)"

if service_loaded; then
  launchctl bootout "${TARGET}"
  echo "Stopped ${LABEL}"
else
  echo "Service ${LABEL} is not loaded"
fi

if [[ -f "${PLIST_DEST}" ]]; then
  rm "${PLIST_DEST}"
  echo "Removed ${PLIST_DEST}"
fi
