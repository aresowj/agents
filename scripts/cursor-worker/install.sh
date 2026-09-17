#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

require_agent_bin
require_worker_dir

mkdir -p "${HOME}/Library/LaunchAgents" "${LOG_DIR}"

render_plist > "${PLIST_DEST}"

UID_NUM="$(id -u)"
TARGET="$(launchd_target)"

if service_loaded; then
  launchctl bootout "${TARGET}" 2>/dev/null || true
  sleep 1
fi

if ! launchctl bootstrap "gui/${UID_NUM}" "${PLIST_DEST}" 2>/dev/null; then
  launchctl bootout "${TARGET}" 2>/dev/null || true
  sleep 1
  launchctl bootstrap "gui/${UID_NUM}" "${PLIST_DEST}"
fi

launchctl kickstart -k "${TARGET}"

echo "Installed ${LABEL}"
echo "  Plist:      ${PLIST_DEST}"
echo "  Worker:     ${WORKER_NAME}"
echo "  Directory:  ${WORKER_DIR}"
echo "  Logs:       ${STDOUT_LOG}"
echo "              ${STDERR_LOG}"
echo
echo "Run ./scripts/cursor-worker/status.sh to verify."
