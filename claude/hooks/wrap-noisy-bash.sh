#!/usr/bin/env bash
# Reads PreToolUse JSON from stdin; wraps noisy commands with compact-run.sh
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Skip if empty, already wrapped, or already piped to head/tail/grep
if [[ -z "$CMD" ]] || [[ "$CMD" == *"compact-run.sh"* ]] || [[ "$CMD" =~ \|[[:space:]]*(head|tail|rg|grep) ]]; then
  exit 0
fi

# Target noisy test, build, and log commands
if [[ "$CMD" =~ ^(go\ test|npm\ test|npx\ jest|yarn\ test|pnpm\ test|pytest|cargo\ test|docker\ logs|xcodebuild) ]]; then
  WRAPPED="$HOME/.claude/scripts/compact-run.sh bash -c $(printf '%q' "$CMD")"
  jq -n --arg cmd "$WRAPPED" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      updatedInput: { command: $cmd }
    }
  }'
fi