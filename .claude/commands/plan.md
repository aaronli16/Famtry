# Plan Command

Create a detailed implementation plan without writing any code.

## Input
$ARGUMENTS

## Instructions

1. **Ask clarifying questions FIRST** before creating any plan:
   - If the scope is unclear, ask what's in vs. out of scope
   - If there are multiple approaches, ask which direction is preferred
   - If technical details are missing, ask about expected behavior
   - If integrations are involved, confirm which services/APIs to use
   - Don't assume - when in doubt, ask
   - Only proceed to planning once you have a clear understanding

2. **Use Supabase MCP** to verify all Supabase API usage before including in plan

3. **Create a plan document** saved to `claude/docs/plans/{feature-name}.md` with:

   ### Overview
   What we're building and why

   ### Dependencies
   New packages, services, or APIs needed

   ### Files
   List of files to create/modify with brief description of changes

   ### Data Model
   Any database schema changes (Supabase tables, types)

   ### Implementation Steps
   Ordered list of small, incremental steps

   ### Edge Cases
   What could go wrong, validation needed, error states

   ### Testing Notes
   What should be tested and how

   ### Open Questions
   Anything that needs clarification before implementing

4. **Do NOT write any implementation code, IMPORTANT!!!!!!!!!!** - planning only


5. Present the plan and wait for approval before any implementation begins
