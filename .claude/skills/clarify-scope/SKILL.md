---
name: clarify-scope
description: Decide whether to ask before coding or proceed with stated assumptions. Small/clear tasks → do it. Large/ambiguous tasks → state assumptions and ask at most 1 critical question. Run at the start of any task.
---

# Clarify Scope

Before starting a task, apply the following decision tree.

---

## Decision tree

### Small, clear task → do it immediately

Signals:
- Know exactly which files need to be touched
- Goal cannot be interpreted in multiple ways
- Scope does not extend beyond 1 module

Action: **do not ask, proceed immediately.**

---

### Large or ambiguous task → state assumptions + ask at most 1 question

Signals of a large/ambiguous task:
- Goal can be interpreted in multiple ways
- Touches > 1 module or > 1 layer
- Success criteria are unclear
- May affect existing behavior

**Response format:**

```
Assumptions:
- [what I assume about the scope/approach]
- [what I assume about constraints]
- ...

→ Proceeding with this approach. Correct me if anything is wrong.
```

If there is **1 thing** that, if wrong, would send the work in a completely wrong direction — ask that one thing, nothing else.

---

## "Worth asking" vs "not worth asking"

**Worth asking** (if wrong, heads in the opposite direction):
- "Is this a new endpoint or modifying an existing one?"
- "Is this feature for all users or only admins?"
- "Does this need to be backward-compatible or is a breaking change allowed?"

**Not worth asking** (if wrong, only requires a small fix):
- "What should the variable be named?"
- "What should the error message say?"
- "Should I use `const` or `let`?"

---

## Examples

**Task:** "Fix bug where login doesn't redirect correctly"
→ Small, clear → do it immediately, no questions.

**Task:** "Refactor the auth system"
→ Large, ambiguous. Response:
```
Assumptions:
- Keep the existing API surface (backward-compatible)
- Only refactor internal logic, no DB schema changes
- Scope: src/auth/ and files that call into it

→ Proceeding with this approach. Correct me if anything is wrong.

Single question: are there any active sessions on production that need to be migrated, or is it acceptable to invalidate all of them?
```
