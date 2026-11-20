#!/usr/bin/env bash
# Run one headless OpenCode worker, fully detached from the calling harness.
#
# Usage: ./scripts/run-worker.sh <worktree-dir> <plan-file> <log-name>
#
# Guarantees:
#   - stdin is /dev/null, so the worker never blocks reading a TTY
#   - stdout and stderr both go to <log-dir>/opencode-<log-name>.log
#   - exactly one summary line reaches the caller's stdout:
#       worker=<log-name> exit=<code> log=<path>
#
# Exit status is the worker's own exit status. Harness/usage errors are:
#   64 usage, 66 missing input, 127 missing opencode.
#
# Environment overrides:
#   OPENCODE_WORKER_MODEL    model in provider/model form
#   OPENCODE_WORKER_LOG_DIR  directory for log files (default: /tmp)

set -euo pipefail

usage() {
  printf 'usage: %s <worktree-dir> <plan-file> <log-name>\n' "${0##*/}" >&2
  exit 64
}

die() {
  printf '%s: %s\n' "${0##*/}" "$1" >&2
  exit "${2:-66}"
}

[ "$#" -eq 3 ] || usage

WORKTREE_DIR=$1
PLAN_FILE=$2
LOG_NAME=$3

# A log name is a label, not a path. Keep it inside the log directory.
case "$LOG_NAME" in
  ''|*/*|.|..|*..*) die "invalid log name: $LOG_NAME" 64 ;;
esac

[ -d "$WORKTREE_DIR" ] || die "worktree directory not found: $WORKTREE_DIR"
[ -f "$PLAN_FILE" ] || die "plan file not found: $PLAN_FILE"
command -v opencode >/dev/null 2>&1 || die "opencode not found on PATH" 127

# Resolve paths before changing directory so relative arguments keep working.
WORKTREE_DIR=$(cd "$WORKTREE_DIR" && pwd)
PLAN_FILE=$(cd "$(dirname "$PLAN_FILE")" && pwd)/$(basename "$PLAN_FILE")

LOG_DIR=${OPENCODE_WORKER_LOG_DIR:-/tmp}
LOG_DIR=${LOG_DIR%/}
[ -n "$LOG_DIR" ] || LOG_DIR=/
mkdir -p "$LOG_DIR" || die "cannot create log directory: $LOG_DIR"
LOG_FILE="$LOG_DIR/opencode-${LOG_NAME}.log"

MODEL=${OPENCODE_WORKER_MODEL:-opencode-go/deepseek-v4.1-flash}
PROMPT="Implement ${PLAN_FILE}. Run tests until passing, then commit."

# opencode run has no --dir flag (v2.2.7); the working directory is the target.
cd "$WORKTREE_DIR" || die "cannot enter worktree: $WORKTREE_DIR"

# errexit must be suspended around the worker call, otherwise a failed worker
# would kill the wrapper before the exit status is captured and reported.
status=0
opencode run --auto --archived --model "$MODEL" "$PROMPT" \
  </dev/null >"$LOG_FILE" 2>&1 || status=$?

printf 'worker=%s exit=%s log=%s\n' "$LOG_NAME" "$status" "$LOG_FILE"
exit "$status"
