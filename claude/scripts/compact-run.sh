#!/usr/bin/env bash
set -o pipefail

MAX_LINES=100
HEAD_LINES=20
TAIL_LINES=60
LOG_FILE="/tmp/claude-cmd-$(date +%s)-$$.log"

# Run the command, capturing both stdout and stderr
"$@" >"$LOG_FILE" 2>&1
EXIT_CODE=$?

TOTAL_LINES=$(wc -l < "$LOG_FILE" | tr -d ' ')

if [ "$TOTAL_LINES" -le "$MAX_LINES" ]; then
  cat "$LOG_FILE"
  rm -f "$LOG_FILE"
else
  head -n "$HEAD_LINES" "$LOG_FILE"
  echo ""
  echo "... [TRUNCATED $((TOTAL_LINES - HEAD_LINES - TAIL_LINES)) lines; full log: $LOG_FILE] ..."
  echo ""
  tail -n "$TAIL_LINES" "$LOG_FILE"
fi

exit "$EXIT_CODE"
