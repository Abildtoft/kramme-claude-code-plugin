#!/bin/bash
# Session Restore Hook - loads previous session state on SessionStart
#
# Checks for .claude-session/session.md in working directory and returns
# its contents as a systemMessage to provide context from previous sessions.

SESSION_FILE=".claude-session/session.md"

if [ -f "$SESSION_FILE" ]; then
    # Read content (limit to first 50 lines to avoid overwhelming context)
    # Escape backslashes first, then quotes, then convert newlines to spaces
    content=$(head -50 "$SESSION_FILE" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')

    if [ -n "$content" ]; then
        printf '{"systemMessage": "Previous session state found:\\n\\n%s"}' "$content"
    else
        echo '{}'
    fi
else
    echo '{}'
fi
exit 0
