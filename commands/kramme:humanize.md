---
name: kramme:humanize
description: Humanize provided text or file content using the kramme:humanizer skill
argument-hint: [file-path or text]
---

# Humanize Text

Use the `kramme:humanizer` skill to rewrite text so it reads more natural and human.

## Input Handling

- `$ARGUMENTS` may be a file path, multiple file paths, or raw text.
- If any arguments match existing file paths, read those files.
- Treat remaining arguments as raw text input.
- If nothing is provided, ask the user for a file path or text to humanize.

## Process

1. Collect input chunks (one per file, plus any inline text).
2. For each chunk, invoke the skill with the text:

```
skill: "kramme:humanizer"
```

3. Return the rewritten text, keeping the original meaning and tone.

## File Output (when input is a file)

- Show the humanized output first.
- Ask the user whether to overwrite the file, save to a new path, or leave it as output only.
- If overwrite is approved, write back to the same file path.
