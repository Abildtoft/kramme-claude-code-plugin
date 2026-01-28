---
name: kramme:granola-meeting-notes
description: Query your Granola meeting notes
argument-hint: [query]
---

# Granola Meeting Notes

Query meeting data from your local Granola app.

## Your Task

1. **Read the Granola cache** from `~/Library/Application Support/Granola/cache-v3.json`
2. **Parse the meeting data** following the instructions in the `kramme:granola-meeting-notes` skill
3. **Answer the user's query** based on the argument provided

## Query Handling

| Query Pattern | Action |
|---------------|--------|
| `today` | Show today's meetings |
| `yesterday` | Show yesterday's meetings |
| `last week`, `this week` | Show meetings from the relevant week |
| `last N days` | Show meetings from the last N days |
| Person name/email | Find meetings with that attendee (fuzzy match) |
| Topic/keyword | Search meeting titles, notes, and transcripts |
| `patterns`, `analytics` | Show meeting patterns and statistics |
| `who do I meet with most` | Participant frequency analysis |
| `export [meeting]` | Export a specific meeting to markdown |
| No argument | Show recent meetings (last 7 days) |

## Search Options

When searching, use weighted scoring:
- **Title matches**: 2x weight (most relevant)
- **Attendee matches**: 1x weight
- **Notes/summary matches**: 1x weight
- **Transcript matches**: 0.5x weight (broad context)

Use fuzzy matching (60% similarity threshold) for flexible queries.

## Output Formats

**For meeting lists** - compact table with stats:

```
| Date | Meeting | Attendees | Duration |
|------|---------|-----------|----------|
| Jan 20 | Weekly Standup | alice, bob | 45m |
| Jan 19 | Product Review | dave, eve | 1h 15m |
```

**For meeting details** - full view with statistics:

```
## Product Review
**Date:** January 19, 2025 at 2:00 PM
**Attendees:** charlie, dave
**Location:** Zoom
**Duration:** 1h 15m | **Words:** 4,230 | **Speakers:** 3

### Notes
- Discussed Q1 roadmap
- Agreed on priority features

### AI Summary
The team reviewed the product roadmap...
```

**For pattern analysis**:

```
## Meeting Patterns (Last 30 Days)

### Top Collaborators
1. alice@company.com - 12 meetings
2. bob@company.com - 8 meetings

### Weekly Trend
- Week 3: 8 meetings
- Week 2: 6 meetings

### Common Topics
standup (15), review (8), planning (6)
```

## Export

When user asks to export, save to `~/granola-exports/` with auto-generated filename:
`YYYY-MM-DD-meeting-title-slug.md`
