#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.env"

LABEL="com.cursor.agent-worker"
PLIST_NAME="${LABEL}.plist"
PLIST_DEST="${HOME}/Library/LaunchAgents/${PLIST_NAME}"
LOG_DIR="${HOME}/Library/Logs"
STDOUT_LOG="${LOG_DIR}/cursor-agent-worker.log"
STDERR_LOG="${LOG_DIR}/cursor-agent-worker.err.log"

# Defaults; override in scripts/cursor-worker/config.env
WORKER_NAME=""
WORKER_DIR=""
AGENT_BIN=""

if [[ -f "${CONFIG_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${CONFIG_FILE}"
fi

WORKER_NAME="${WORKER_NAME:-kagami}"
WORKER_DIR="${WORKER_DIR:-${REPO_ROOT}}"
AGENT_BIN="${AGENT_BIN:-$(command -v agent 2>/dev/null || echo "${HOME}/.local/bin/agent")}"

launchd_target() {
  echo "gui/$(id -u)/${LABEL}"
}

require_agent_bin() {
  if [[ ! -x "${AGENT_BIN}" ]]; then
    echo "error: Cursor agent CLI not found at ${AGENT_BIN}" >&2
    echo "Install with: curl https://cursor.com/install -fsS | bash" >&2
    exit 1
  fi
}

require_worker_dir() {
  if [[ ! -d "${WORKER_DIR}" ]]; then
    echo "error: worker directory does not exist: ${WORKER_DIR}" >&2
    exit 1
  fi
}

render_plist() {
  sed \
    -e "s|@@HOME@@|${HOME}|g" \
    -e "s|@@AGENT_BIN@@|${AGENT_BIN}|g" \
    -e "s|@@WORKER_DIR@@|${WORKER_DIR}|g" \
    -e "s|@@WORKER_NAME@@|${WORKER_NAME}|g" \
    -e "s|@@STDOUT_LOG@@|${STDOUT_LOG}|g" \
    -e "s|@@STDERR_LOG@@|${STDERR_LOG}|g" \
    "${SCRIPT_DIR}/${PLIST_NAME}.in"
}

service_loaded() {
  launchctl print "$(launchd_target)" >/dev/null 2>&1
}
