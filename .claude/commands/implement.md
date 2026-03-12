# Implement Command

Execute an existing plan step-by-step.

## Input
$ARGUMENTS

## CRITICAL RULES

- **ONLY do what the plan says.** Do not add features, refactor unrelated code, or "improve" things not in the plan.
- **Do NOT assume anything.** If something is unclear or ambiguous, STOP and ask.
- **Do NOT deviate from the plan.** If you think the plan needs changes, ask first - don't just do it.
- **If confused, ask.** Never guess. A question is always better than a wrong assumption.

## Instructions

1. **Locate the plan** from `claude/docs/plans/` based on the feature name provided

2. **Read the ENTIRE plan first** before starting. Understand the full scope.

3. **Use Supabase MCP** before writing any code that touches Supabase

4. **Execute one step at a time**:
   - State which step you're working on (by number/name from the plan)
   - Implement ONLY what that step describes
   - Show key code written
   - Confirm what was completed

5. **Pause for approval** between major steps or milestones

6. **NEVER deviate from the plan** without explicit approval:
   - If you spot an issue with the plan, stop and ask
   - If you think something extra would help, ask first
   - If you're unsure what the plan means, ask for clarification

7. **After each step**, state what's next (per the plan) and wait for confirmation to continue

8. **Track progress** by noting completed steps vs remaining steps
