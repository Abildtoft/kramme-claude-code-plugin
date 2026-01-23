#!/bin/bash
# Session Save Hook - saves session state on Stop
#
# Check if hook is enabled
source "${CLAUDE_PLUGIN_ROOT}/hooks/lib/check-enabled.sh"
exit_if_hook_disabled "session-save" "json"
#
# Creates .claude-session/session.md with:
# - Timestamp
# - Current branch
# - Modified files (from git status)
# - Placeholder for progress summary
#
# The progress summary section should be filled in by the session-summary skill
# or manually before stopping.

SESSION_DIR=".claude-session"
SESSION_FILE="$SESSION_DIR/session.md"

# Create directory if needed
mkdir -p "$SESSION_DIR" 2>/dev/null

# Gather context
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
STATUS=$(git status --porcelain 2>/dev/null | head -20)

# Only update if we have git context (we're in a repo)
if [ -n "$BRANCH" ] && [ "$BRANCH" != "unknown" ]; then
    cat > "$SESSION_FILE" << EOF
# Session State
**Saved:** $TIMESTAMP
**Branch:** $BRANCH

## Modified Files
\`\`\`
$STATUS
\`\`\`

## Progress Summary
<!-- Update this section with current progress before stopping -->

## Next Steps
<!-- What should be done next? -->

EOF

    echo '{"systemMessage": "Session state saved to .claude-session/session.md"}'
else
    echo '{}'
fi
exit 0
