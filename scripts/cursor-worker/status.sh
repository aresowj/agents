#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

TARGET="$(launchd_target)"

echo "=== Cursor worker daemon ==="
echo "Label:     ${LABEL}"
echo "Worker:    ${WORKER_NAME}"
echo "Directory: ${WORKER_DIR}"
echo "Plist:     ${PLIST_DEST}"
echo

if service_loaded; then
  echo "=== launchd ==="
  launchctl print "${TARGET}" 2>&1 | rg -n 'state =|path =|working directory|stdout path|stderr path|runs =|pid =' || true
else
  echo "=== launchd ==="
  echo "not loaded"
fi

echo
echo "=== process ==="
if pgrep -fl 'agent.*worker' >/dev/null 2>&1; then
  pgrep -fl 'agent.*worker'
else
  echo "no worker process found"
fi

echo
if command -v agent >/dev/null 2>&1; then
  echo "=== worker debug ==="
  agent worker debug 2>&1 || true
else
  echo "=== worker debug ==="
  echo "agent CLI not on PATH"
fi

echo
echo "=== recent logs ==="
echo "-- stdout --"
if [[ -f "${STDOUT_LOG}" ]]; then
  tail -10 "${STDOUT_LOG}"
else
  echo "(missing)"
fi
echo "-- stderr --"
if [[ -f "${STDERR_LOG}" ]]; then
  tail -10 "${STDERR_LOG}"
else
  echo "(missing)"
fi
