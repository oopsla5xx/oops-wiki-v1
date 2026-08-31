---
name: implement-tdd
description: Implement each step from the plan using TDD — write failing test first, then minimal code to pass, then refactor. Run for each unchecked step in the Plan section of .ai/tasks/<name>.md.
---

# Implement TDD

Implement each step in the `## Plan` of the spec file following the TDD cycle.

**Hard rule:** Do not write implementation before having a failing test. No exceptions.

---

## Setup

Before the first step, run the full test suite to confirm the baseline is green:

```bash
# Get the command from .ai/commands.md
<test-command>
```

If the baseline is red → stop, report to user, do not implement on a red baseline.

---

## Cycle for each step in the Plan

Take the next unchecked `- [ ]` step from `## Plan` in the spec file. Execute:

### 🔴 Red — Write the test first

1. Read the step's "Done when:" to know what the test needs to assert
2. Write the test — only test the behavior of this step, nothing more
3. Run the test: **it must be red**

**Correctly red test:**
```
FAIL: expected X but got undefined   ← correct, function doesn't exist yet
FAIL: expected true but got false    ← correct, logic not yet implemented
```

**Incorrectly red test (must fix before continuing):**
```
SyntaxError / TypeError              ← test has a syntax error
Cannot find module                   ← wrong import path
Expected 2 arguments but got 1      ← test itself is written incorrectly
```

If the test is red for the wrong reason → fix the test, do not write implementation.

### 🟢 Green — Minimal code to pass

4. Write the smallest implementation that can make the test green
5. Run the test: **it must be green**
6. Run full suite: **must not introduce any new red**

**"Minimal" means:**
- Do not add logic for cases that don't have a test yet
- Do not add abstractions that aren't needed yet
- Do not refactor related code outside the scope of this step

If the full suite has new red → find the regression, fix it before continuing.

### 🔵 Refactor — Clean up while green

7. Only refactor if the code just written has clear issues: bad names, duplicate logic, magic numbers
8. After each refactor change → run tests again
9. If tests go red during refactor → revert immediately, don't carry the debt

**Do not refactor in this step:**
- Code belonging to other steps in the plan
- Code unrelated to the current step
- "Improvements" that are speculative (YAGNI)

### ✅ Tick and commit

10. Mark the step as done in the spec file:
    ```
    - [x] 1. Create `src/auth/reset-token.ts` ...
    ```
11. Commit with a clear message:
    ```
    test: <step just completed>
    feat: <step just completed>
    ```
    Or combine if small:
    ```
    feat: <step just completed> (with tests)
    ```

Then take the next step and repeat.

---

## Special cases

**Step is a DB migration:**
Tests don't follow the normal Red/Green cycle. Instead:
1. Write the migration
2. Run the migration up: `<migrate-command>`
3. Verify schema is correct (query or inspect)
4. Run rollback: `<rollback-command>`
5. Run migration again → confirm idempotent
Done when: both directions run cleanly.

**Step is a UI component:**
If the project has component tests (Storybook, Testing Library) → use them. If not:
1. Write a simple render test (snapshot or "renders without crash")
2. Implement the component
3. If possible — test interaction (click, input)
Do not skip tests entirely for UI — a minimal render test still has value.

**Step is wiring/integration:**
Test at the integration layer, not unit. Mock external services (email, payment) if needed. Do not mock your own internal code.

**Step has an Open question `[BLOCKING]`:**
Stop, ask the user, do not assume. Do not implement a step with a blocking question.

---

## Stop and report when

- Full suite is red after implementation and the cause is unknown → report immediately, do not continue implementing
- Scope has expanded beyond the spec → stop, update spec/plan, confirm with user
- You discover the plan has the wrong order (step N needs code from step N+2) → report it, do not reorder on your own

---

## After all steps are done

1. Run the full suite one final time
2. Run lint and typecheck (get commands from `.ai/commands.md`)
3. Move on to `/self-check` (Phase 3 of task-flow)
