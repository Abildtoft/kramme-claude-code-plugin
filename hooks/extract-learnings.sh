#!/bin/bash
# Learning Extraction Prompt Hook - suggests /kramme:learn at session end
#
# Runs on Stop. Checks if the session had meaningful work (via changes.log)
# and suggests extracting learnings if substantial work was done.
#
# The threshold is set to 10 changes to avoid prompting for trivial sessions.

SESSION_DIR=".claude-session"
CHANGES_LOG="$SESSION_DIR/changes.log"

# Check if there were meaningful changes
if [ -f "$CHANGES_LOG" ]; then
    CHANGE_COUNT=$(wc -l < "$CHANGES_LOG" 2>/dev/null | tr -d ' ')

    # Only suggest extraction for substantial sessions (>10 changes)
    if [ "${CHANGE_COUNT:-0}" -gt 10 ]; then
        echo "{\"systemMessage\": \"$CHANGE_COUNT changes logged this session. Consider /kramme:learn to extract reusable patterns.\"}"
        exit 0
    fi
fi

echo '{}'
exit 0
