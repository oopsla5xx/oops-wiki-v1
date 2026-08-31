---
name: write-test-scenarios
description: Generate manual test scenarios (UC/TC) from the spec file after implementation — use cases and step-by-step test cases for human testers to verify the feature by hand. Output saved to .ai/tasks/<name>-manual-tests.md.
---

# Write Test Scenarios

Generate manual test documentation (UC + TC) based on the written spec, so the user can verify the feature by hand after implementation is complete.

**Output:** file `.ai/tasks/<task-name>-manual-tests.md`

---

## Run

### Step 1 — Read inputs

```
Read: .ai/tasks/<task-name>.md    ← get Goal + Test plan + Constraints
Read: .ai/context/domain-glossary.md  ← use correct domain terminology
```

List all items in `## Test plan` — this is the list of UCs to write.

### Step 2 — Identify Use Cases

Group test plan items into UCs by user flow. One UC = one user journey with a clear start and end.

Example:
```
Test plan items:
- happy path: password reset succeeds
- edge case: token expired
- edge case: token reused
- no regression: login still works normally

→ UC-01: Successful password reset
→ UC-02: Handle invalid token
→ UC-03: Login flow unaffected (regression)
```

### Step 3 — Write test file

Create `.ai/tasks/<task-name>-manual-tests.md` using the following format:

```markdown
# Manual Tests: <task-name>

**Feature:** <short description from spec Goal>
**Tester:** ___________
**Test date:** ___________
**Environment:** ___________   (staging / local / production)

---

## UC-01: <use case name>

> <1-2 sentence description of the use case — who does what, and why>

**Preconditions:**
- <condition that must be true before starting the test>
- ...

---

### TC-01-01: <specific test case name>

| | |
|---|---|
| **Priority** | High / Medium / Low |
| **Type** | Happy path / Edge case / Regression / Error handling |

**Steps:**
1. <specific step — detailed enough for someone without code knowledge to follow>
2. ...
3. ...

**Expected result:**
- <what must happen — specific and observable>
- ...

**Actual result:** ___________

**Pass / Fail:** ⬜ Pass  ⬜ Fail

**Notes:** ___________

---

### TC-01-02: <next test case in the same UC>
...

---

## UC-02: ...
```

### Step 4 — Rules for writing good TCs

**Steps must be specific enough for someone without code knowledge to follow:**
```
# Good
1. Open browser, navigate to http://localhost:3000/forgot-password
2. Enter "test@example.com" in the "Email" field
3. Click the "Send password reset link" button
4. Check the inbox of test@example.com

# Bad
1. Call the reset password API
2. Check the result
```

**Expected result must be observable:**
```
# Good
- Page shows message "Email sent. Please check your inbox."
- Email arrives within 60 seconds with subject "Reset your password"
- Link in email matches the format https://.../reset?token=...

# Bad
- System processes correctly
- No errors
```

**Preconditions must be clear:**
- What data must exist (user account, order, ...)
- Required system state (email server running, feature flag enabled, ...)
- What permissions the tester needs

### Step 5 — Ensure coverage

Verify each item in `## Test plan` of the spec has at least 1 TC:

```
[ ] happy path → TC-XX-XX
[ ] edge case 1 → TC-XX-XX
[ ] no regression → TC-XX-XX (regression)
```

If any Test plan item has no TC → add it before saving.

### Step 6 — Report

After creating the file, report:
```
Created: .ai/tasks/<task-name>-manual-tests.md
- X use cases
- Y test cases (Z high priority)
```

---

## Quick format guide by TC type

**Happy path:** Primary actor, normal conditions, straight-through flow from start to finish.

**Edge case:** Boundary inputs (empty, too long, special characters), abnormal states (expired, already used, duplicate), concurrent actions.

**Error handling:** System responds correctly when an error occurs — clear message, no crash, no sensitive information leaked.

**Regression:** Existing flows not directly related to the new feature — must verify they still work normally.
