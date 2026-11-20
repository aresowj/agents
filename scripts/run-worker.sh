#!/usr/bin/env bash
# Run one headless OpenCode worker, fully detached from the calling harness.
#
# Usage: ./scripts/run-worker.sh <worktree-dir> <plan-file> <log-name>
#
# Guarantees:
#   - stdin is /dev/null, so the worker never blocks reading a TTY
#   - stdout and stderr both go to <log-dir>/opencode-<log-name>.log
#   - exactly one summary line reaches the caller's stdout:
#       worker=<log-name> exit=<code> model=<model> log=<path>
#
# Model fallback (tried in order, see OPENCODE_WORKER_MODELS):
#   1. opencode/deepseek-v4.1-flash-free   OpenCode free tier
#   2. opencode-go/deepseek-v4.1-flash     OpenCode Go subscription
#   3. deepseek/deepseek-flash             DeepSeek API direct (DEEPSEEK_API_KEY
#                                          or `opencode auth login`)
# The next model is tried only when an attempt made no progress: HEAD and
# `git status --porcelain` are unchanged. That covers rate limits, exhausted
# quota, auth errors and unavailable models. An attempt that changed the
# worktree is final, pass or fail, so partial work is never handed to another
# model. The last tier (Claude Sonnet/Haiku) is the calling harness's job.
#
# Exit status is the final attempt's own status, except:
#   75 every model made no progress (fall back to Claude Sonnet/Haiku)
#   64 usage, 66 missing input, 127 missing opencode.
#
# Environment overrides:
#   OPENCODE_WORKER_MODELS   space-separated fallback chain (provider/model)
#   OPENCODE_WORKER_MODEL    pin one model; disables the fallback chain
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

DEFAULT_MODELS="opencode/deepseek-v4.1-flash-free opencode-go/deepseek-v4.1-flash deepseek/deepseek-flash"
if [ -n "${OPENCODE_WORKER_MODEL:-}" ]; then
  MODELS=$OPENCODE_WORKER_MODEL
else
  MODELS=${OPENCODE_WORKER_MODELS:-$DEFAULT_MODELS}
fi
[ -n "${MODELS// /}" ] || die "empty model list" 64
PROMPT="Implement ${PLAN_FILE}. Run tests until passing, then commit."

# opencode run has no --dir flag (v2.2.7); the working directory is the target.
cd "$WORKTREE_DIR" || die "cannot enter worktree: $WORKTREE_DIR"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "not a git worktree: $WORKTREE_DIR"

snapshot() {
  git rev-parse HEAD 2>/dev/null || echo none
  git status --porcelain 2>/dev/null
}

: >"$LOG_FILE"
status=75
model=none
for model in $MODELS; do
  before=$(snapshot)
  printf '\n===== run-worker attempt: model=%s =====\n' "$model" >>"$LOG_FILE"
  # errexit must be suspended around the worker call, otherwise a failed worker
  # would kill the wrapper before the exit status is captured and reported.
  status=0
  opencode run --auto --archived --model "$model" "$PROMPT" \
    </dev/null >>"$LOG_FILE" 2>&1 || status=$?
  if [ "$(snapshot)" != "$before" ]; then
    break
  fi
  printf '===== run-worker: no progress with %s (exit %s) =====\n' \
    "$model" "$status" >>"$LOG_FILE"
  status=75
done

printf 'worker=%s exit=%s model=%s log=%s\n' "$LOG_NAME" "$status" "$model" "$LOG_FILE"
exit "$status"
