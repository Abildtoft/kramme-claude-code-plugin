#!/bin/bash
# Change Logger Hook - logs file modifications for session awareness
#
# Check if hook is enabled
source "${CLAUDE_PLUGIN_ROOT}/hooks/lib/check-enabled.sh"
exit_if_hook_disabled "log-changes" "json"
#
# Runs on PostToolUse for Write, Edit, and Bash tools.
# Appends to .claude-session/changes.log for session review and debugging.
#
# Useful for:
# - Understanding what was modified during a session
# - Input to learning extraction at session end
# - Debugging when something went wrong

input=$(cat)
tool=$(echo "$input" | jq -r '.tool // empty')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
command=$(echo "$input" | jq -r '.tool_input.command // empty')

SESSION_DIR=".claude-session"
LOG_FILE="$SESSION_DIR/changes.log"

# Create directory if needed
mkdir -p "$SESSION_DIR" 2>/dev/null

TIMESTAMP=$(date '+%H:%M:%S')

# Log file operations
if [ -n "$file_path" ]; then
    echo "[$TIMESTAMP] $tool: $file_path" >> "$LOG_FILE"
# Log bash commands that modify files
elif [ -n "$command" ]; then
    if echo "$command" | grep -qE '\b(git add|git commit|git push|mkdir|touch|mv|cp|rm)\b'; then
        # Truncate long commands
        short_cmd=$(echo "$command" | head -c 80)
        echo "[$TIMESTAMP] Bash: $short_cmd" >> "$LOG_FILE"
    fi
fi

echo '{}'
exit 0
