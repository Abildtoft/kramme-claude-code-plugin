#!/bin/bash
# Strategic Compact Suggester - suggests /compact after N tool calls
#
# Runs on PreToolUse for all tools. Tracks tool invocations in a counter file
# and suggests compacting context at regular intervals.
#
# Why manual over auto-compact:
# - Auto-compact happens at arbitrary points, often mid-task
# - Strategic compacting preserves context through logical phases
# - Compact after exploration, before execution
# - Compact after completing a milestone, before starting next

SESSION_DIR=".claude-session"
COUNTER_FILE="$SESSION_DIR/tool-counter"
THRESHOLD=50

# Create directory if needed
mkdir -p "$SESSION_DIR" 2>/dev/null

# Read current count
if [ -f "$COUNTER_FILE" ]; then
    COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
else
    COUNT=0
fi

# Increment
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Suggest compact at threshold intervals
if [ $((COUNT % THRESHOLD)) -eq 0 ]; then
    echo "{\"systemMessage\": \"Tool call #$COUNT. Consider /compact if transitioning phases.\"}"
else
    echo '{}'
fi
exit 0
