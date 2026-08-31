---
name: review-pr
description: Review PR diff against the spec before shipping — check spec compliance, conventions, scope, required security checklist, and test coverage. Outputs a structured verdict (APPROVE / REQUEST CHANGES / COMMENT). Run after self-check, before Phase 4 ship.
---

# Review PR

Review the PR diff against the written spec. This is not a generic "code review" — it checks whether the code matches what was committed to in the spec.

---

## Run

### Step 1 — Read context

```bash
# View the full diff about to be shipped
git diff main...HEAD    # or git diff <base-branch>...HEAD
```

Also read:
- `.ai/tasks/<task-name>.md` — spec (Goal, Scope, Out of scope, Constraints, Plan)
- `.ai/context/conventions.md` — project code conventions
- `.ai/context/security-checklist.md` — required security checks

### Step 2 — Review across 5 dimensions

Evaluate each dimension, record findings using `[BLOCKING]` or `[MINOR]` format:

---

**A. Spec compliance**

- [ ] Does the code achieve the Goal in the spec?
- [ ] Are there any changes outside `## Scope`?
- [ ] Are there any changes that violate `## Out of scope`?
- [ ] Are the `## Constraints` respected?
- [ ] Have all steps in `## Plan` been implemented?

`[BLOCKING]`: any Out of scope item violated, or Goal not achieved.
`[MINOR]`: a small step in Plan is missing but does not affect the Goal.

---

**B. Conventions**

Compare each change against `.ai/context/conventions.md`:

- [ ] Is error handling following the correct pattern? (no silent error swallowing)
- [ ] Does naming follow the convention?
- [ ] Are there any hardcoded values?
- [ ] Is there any copy-pasted code causing duplicate logic?

`[BLOCKING]`: violation of a hard convention (e.g., swallowing errors in a production path).
`[MINOR]`: naming slightly off style, can be fixed later.

---

**C. Scope creep**

```bash
# Check which files were touched outside the defined scope
git diff --name-only main...HEAD
```

Compare the list of changed files against `## Scope` in the spec.

- [ ] Are there any files modified that are not mentioned in Scope?
- [ ] If so — is that change justified? (incidental bugfix, required refactor)

`[BLOCKING]`: unrelated change that increases risk unnecessarily.
`[MINOR]`: small cleanup in a related file.

---

**D. Test coverage**

- [ ] Does each item in `## Test plan` of the spec have a corresponding test?
- [ ] Do tests cover the happy path?
- [ ] Do tests cover at least 1 edge case?
- [ ] Were any tests deleted without a clear reason?

```bash
# View changed test files
git diff --name-only main...HEAD | grep -E "test|spec"
```

`[BLOCKING]`: happy path has no tests at all.
`[MINOR]`: some minor edge cases missing.

---

**E. Security checklist** (required)

- [ ] Complete every item in `.ai/context/security-checklist.md` using `[x]` (including N/A items as `[x] <item>: N/A — <reason>`)
- [ ] For each N/A item, is there a short reason?
- [ ] Are there any unresolved findings from the checklist?

`[BLOCKING]`: any unresolved finding, or any checklist item left blank (not completed with `[x]`, including N/A-with-reason entries).

---

### Step 3 — Summarize verdict

**Output format:**

```markdown
## PR Review: <task-name>

**Verdict:** ✅ APPROVE | 🔄 REQUEST CHANGES | 💬 COMMENT ONLY

---

### Blocking issues (must fix before merging)
<!-- Only present if verdict is REQUEST CHANGES -->
- [BLOCKING] <dimension> — <specific description> | <file:line if available>

### Minor issues (can fix in a follow-up PR)
- [MINOR] <dimension> — <description>

### Notes
<!-- Observations that are not issues, or positive highlights -->
-

---
Spec: `.ai/tasks/<task-name>.md`
Diff: <number of changed files> files, +<lines added>/-<lines removed>
```

**Verdict rules:**
- `✅ APPROVE` — no blocking issues
- `🔄 REQUEST CHANGES` — ≥1 blocking issue, must fix before merging
- `💬 COMMENT ONLY` — no blocking issues but something worth noting

### Step 4 — If there are blocking issues

Do not fix them yourself. Report clearly, let the agent/implementer decide:
- Fix in the current PR → re-run review after fixing
- Create a follow-up task for minor issues → note in `.ai/tasks/` or create an issue

---

## What is NOT reviewed here

- Style preferences not in conventions.md → do not flag
- Architectural opinions outside the task scope → do not flag (that is ADR work)
- Performance that has not been measured as a problem → do not flag
- Absolute test coverage % → only check test plan items, do not require 100%