---
name: kramme:session-summary
description: Summarize session progress before stopping or compacting. Use when asked to summarize progress, save session state, prepare for /compact, or before ending a session.
---

# Session Summary

Summarize current session progress and update `.claude-session/session.md`.

## When to Use

- Before running `/compact` to preserve important context
- Before stopping a session
- When asked to summarize progress
- At natural transition points between phases

## Instructions

1. **Review Work Done**
   - List files created or modified (check git status)
   - Summarize key changes made
   - Note any decisions or discoveries

2. **Capture Current State**
   - What task was being worked on?
   - What's the next logical step?
   - Are there any blockers or open questions?

3. **Update Session File**

   Update `.claude-session/session.md` with:

   ```markdown
   ## Progress Summary

   **Last worked on:** [brief description]

   **Key changes:**
   - [change 1]
   - [change 2]

   **Decisions made:**
   - [decision with rationale]

   ## Next Steps
   1. [next step]
   2. [another step]

   ## Open Questions
   - [any blockers or uncertainties]
   ```

4. **Clean Up (Optional)**
   - Reset tool counter: `rm -f .claude-session/tool-counter`
   - Clear changes log if no longer needed: `rm -f .claude-session/changes.log`

## Output

Confirm what was captured in the session summary.
