---
name: write-spec
description: Convert clarify-scope discussion into a structured spec file at .ai/tasks/<name>.md. Run after clarify-scope resolves assumptions and scope. Captures decisions before they're lost in conversation history.
---

# Write Spec

Convert the discussed context (assumptions, resolved questions, confirmed scope) into a structured spec file at `.ai/tasks/<task-name>.md`.

Run immediately after `clarify-scope` completes — don't let context drift away in chat history.

---

## Run

### Step 1 — Name the task

The name must be: short, kebab-case, describing a specific action.

```
# Good
add-password-reset
refactor-auth-middleware
fix-order-status-race-condition

# Bad
feature          ← too generic
fix-bug          ← doesn't say what bug
update-stuff     ← meaningless
```

### Step 2 — Fill each section from the discussion context

Open `.ai/tasks/TEMPLATE.md` as reference, create a new file `.ai/tasks/<task-name>.md`.

**Goal** — taken from the discussed objective. Must satisfy both:
- Specific: know exactly what needs to be done
- Measurable: know when it's "done"

Bad example: "Improve the auth system"
Good example: "User can reset password via email, receives link within 60s, link expires after 1h"

**Scope** — list specific files/modules from confirmed assumptions:
```
- src/auth/password-reset.ts (create new)
- src/api/routes/auth.ts (add endpoint)
- src/email/templates/ (add template)
```

**Out of scope** — taken from what was explicitly said NOT to do, or inferred from scope boundaries. This is the most important section for preventing scope creep later.

**Test plan** — minimum 3 cases:
- Happy path (main flow works correctly)
- Edge case (boundary input, concurrent request...)
- Does not break anything currently working (regression)

**Constraints** — from critical questions answered in clarify-scope. If the user said "backward-compatible" or "must not invalidate existing sessions" → record it here.

**Open questions** — if any questions remain unresolved after clarify-scope, record them here with a `[BLOCKING]` tag if they must be answered before coding.

### Step 3 — Check spec quality

Before saving, ask yourself:

```
[ ] Goal: after reading it, do you immediately know what "done" looks like?
[ ] Out of scope: if someone wants to add X to scope, can you reject it using this file?
[ ] Test plan: is there at least 1 case for "does not break what's currently working"?
[ ] Constraints: have the critical questions from clarify-scope been captured?
```

If any checkbox is NO → fix before saving.

### Step 4 — Update status

After creating the spec:
1. Update `.ai/status.md` — add the task to "In Progress" with the start date
2. Confirm with user: "Spec created at `.ai/tasks/<task-name>.md`. Proceed with implementation?"

---

## When NOT to run this skill

- Task is small and clear (as assessed by clarify-scope) → no spec needed, proceed directly
- Spec already exists in `.ai/tasks/` → update that file instead of creating a new one
