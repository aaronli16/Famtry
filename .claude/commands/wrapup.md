---
description: End-of-session handoff. Use when finishing work for the day to save progress and context for the next session.
---

# Wrapup Command

End the current session with a proper handoff.

## Instructions

1. **Update SESSION_LOG.md** (`claude/docs/SESSION_LOG.md`) with a new entry for today:

   ```markdown
   ## YYYY-MM-DD
   ### Completed
   - (list what was built/decided/finished)

   ### In Progress
   - (list anything partially done)

   ### Next Session
   - (list where to pick up, what to do next)

   ### Key Decisions
   - (important choices made, with brief reasoning)
   ```

2. **Check for learnings**: Ask the user:
   "Did we hit any gotchas or mistakes today that should go in LEARNINGS.md?"

3. **Provide a summary** to the user:
   - What we accomplished
   - What's next
   - Any blockers or things to think about

Do NOT write any code - this is documentation only.
