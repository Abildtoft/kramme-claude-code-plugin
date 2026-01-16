#!/bin/bash
# Context Links Hook - displays active PR/MR and Linear issue links at end of messages
#
# This Stop hook detects:
# - Linear issue ID from branch name (pattern: {prefix}/{TEAM-ID}-description)
# - Open PR/MR for the current branch (GitHub or GitLab)
#
# Outputs JSON with systemMessage containing clickable links.

# Get current branch
BRANCH=$(git branch --show-current 2>/dev/null)
if [ -z "$BRANCH" ]; then
    echo '{}'
    exit 0
fi

# Initialize output parts
LINEAR_LINK=""
PR_LINK=""

# Extract Linear issue ID from branch name
# Pattern: {prefix}/{TEAM-ID}-description where TEAM is WAN|HEA|MEL|POT|FIR|FEG
ISSUE_ID=$(echo "$BRANCH" | grep -oiE '(wan|hea|mel|pot|fir|feg)-[0-9]+' | head -1 | tr '[:lower:]' '[:upper:]')
if [ -n "$ISSUE_ID" ]; then
    LINEAR_LINK="[${ISSUE_ID}](https://linear.app/consensusaps/issue/${ISSUE_ID})"
fi

# Detect platform and check for open PR/MR
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
if echo "$REMOTE_URL" | grep -q "github.com"; then
    # GitHub - check for PR
    PR_JSON=$(gh pr view --json url,number 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$PR_JSON" ]; then
        PR_URL=$(echo "$PR_JSON" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
        PR_NUM=$(echo "$PR_JSON" | grep -o '"number":[0-9]*' | cut -d':' -f2)
        if [ -n "$PR_URL" ]; then
            PR_LINK="[PR #${PR_NUM}](${PR_URL})"
        fi
    fi
elif echo "$REMOTE_URL" | grep -qE "(gitlab.com|consensusaps)"; then
    # GitLab - check for MR
    MR_URL=$(glab mr view --web 2>/dev/null | grep -o 'https://[^ ]*')
    if [ -n "$MR_URL" ]; then
        MR_NUM=$(echo "$MR_URL" | grep -o '[0-9]*$')
        PR_LINK="[MR !${MR_NUM}](${MR_URL})"
    fi
fi

# Build output message
if [ -n "$LINEAR_LINK" ] || [ -n "$PR_LINK" ]; then
    PARTS=""
    [ -n "$LINEAR_LINK" ] && PARTS="Linear: $LINEAR_LINK"
    if [ -n "$PR_LINK" ]; then
        [ -n "$PARTS" ] && PARTS="$PARTS | "
        PARTS="${PARTS}${PR_LINK}"
    fi
    echo "{\"systemMessage\": \"$PARTS\"}"
else
    echo '{}'
fi
exit 0
