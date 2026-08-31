---
name: plan-tasks
description: Break a spec file into ordered, concrete implementation steps with done criteria. Appends a Plan section to the existing .ai/tasks/<name>.md. Run after write-spec, before coding.
---

# Plan Tasks

Read the written spec, break it down into ordered implementation steps. Output is a `## Plan` section appended to the end of the spec file — do not create a new file.

---

## Run

### Step 1 — Read the inputs

```
Read: .ai/tasks/<task-name>.md          ← spec to plan
Read: .ai/context/architecture.md      ← understand current structure
```

Answer these questions before writing the plan:
- Is there existing code that needs to be read/modified? If so, read it now.
- Is this completely new (greenfield) or modifying existing code (brownfield)?
- Are there any dependencies that must be created first (DB schema, interface, type)?

### Step 2 — Find "atoms"

An **atom** is the smallest unit that can be verified independently.

How to find them: read Scope in the spec → for each file/module, ask "what is the smallest piece that can be done and tested independently?"

Example decomposition:
```
Scope: "add password reset"
→ Break into:
   - token generation logic (pure function, testable)
   - DB schema (migration)
   - API endpoint request (HTTP layer)
   - email send (side effect, mockable)
   - API endpoint confirm (HTTP layer)
   - wiring (integration)
```

### Step 3 — Order by dependency

Standard order (bottom-up):

```
1. Types / interfaces / contracts  ← depend on nothing
2. Pure business logic              ← depends on types
3. Data persistence (migrations, models)
4. Side effects (email, queue, cache)
5. API / interface layer            ← calls into logic + persistence
6. Wiring / integration             ← connects the layers
7. Tests covering the full flow     ← confirms end-to-end
```

Rule: step N must not call code from step N+1.

### Step 4 — Write the plan

Append to the end of the spec file:

```markdown
## Plan

<!-- Execute in order. Each step only begins when the previous one is done. -->

- [ ] 1. <verb> <specific file/function> — <short description>
         Done when: <specific, verifiable criteria>

- [ ] 2. ...
```

**Requirements for each step:**
- Start with an action verb: `Create`, `Add`, `Update`, `Remove`, `Wire`, `Migrate`, `Test`
- Include specific file/function names if known
- `Done when:` must be immediately verifiable (run a command, check output, read code) — must not be a "gut feeling"

**Example of a good step:**
```
- [ ] 1. Create `src/auth/reset-token.ts` — generateToken() and validateToken() functions
         Done when: unit tests pass for both functions, including the expired token case
```

**Example of a bad step:**
```
- [ ] 1. Implement password reset logic   ← too broad, no idea what "done" means
- [ ] 2. Make sure it works              ← not verifiable
```

### Step 5 — Check plan quality

Before saving:

```
[ ] Does each step have a specific "Done when:"?
[ ] Does the first step not depend on anything that doesn't exist yet?
[ ] Does no step span more than one coding session (~2-3h)?
[ ] Can the largest step be broken down further?
[ ] If step 3 fails → can step 4 still start? (if not, note the dependency explicitly)
```

If any step fails a check → break it up or rewrite it before saving.

---

## After the plan is done

Confirm with user: display the plan just written, ask "Start from step 1?" or "Are there any steps that need adjustment?"

Do not start coding automatically — do not implement until the user has approved the plan.

---

## Gotchas

**Brownfield: read the existing code before planning.** Plans based on assumptions about old code will be wrong. Use grep/read to confirm function names, interfaces, and current patterns before writing them into the plan.

**Avoid a "mega step" at the end.** "Integration + testing + polish" lumped into one final step is a sign the plan is not detailed enough. Break it up.

**Don't plan too far ahead.** If the spec has unresolved Open questions → plan only up to the point before that decision is needed, and note clearly "⚠️ need to confirm X before continuing."
