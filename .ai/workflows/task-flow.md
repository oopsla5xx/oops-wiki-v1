# Task Flow

Every task goes through these 4 phases. Do not skip phases, do not merge until the self-check is complete.

---

## Phase 1 — Brief

**Before writing a single line of code:**

1. Run `/clarify-scope` — decide whether to ask or assume and proceed
2. Run `/write-spec` — convert the discussion context into a file at `.ai/tasks/<task-name>.md`
3. Run `/plan-tasks` — break the spec into ordered implementation steps, append `## Plan` to the spec file

If the task is small and clear (clarify-scope rates it "just do it") → skip write-spec and plan-tasks, go directly to Phase 2.

---

## Phase 2 — Implement

Run `/implement-tdd` — iterate the Red → Green → Refactor cycle for each step in `## Plan`.

If the task is small (no spec/plan): read `.ai/context/conventions.md`, confirm the baseline tests are green, then code directly.

**Never:**
- Write implementation before having a failing test (when using TDD)
- Refactor code outside the scope of the current step
- Fix tests to pass instead of fixing the code
- Add a new dependency without recording it in `.ai/decisions/`

---

## Phase 3 — Self-check

1. Run `/write-test-scenarios` — create a UC/TC file at `.ai/tasks/<task-name>-manual-tests.md` for manual user testing

2. **Self-review before declaring "done":**

```
[ ] test: entire test suite is green
[ ] lint: no new errors
[ ] typecheck: no new errors (if project has it)
[ ] conventions: re-read changes, no violations
[ ] scope: no code outside the brief's scope
[ ] side effects: no unintended changes in other files
[ ] security: `.ai/context/security-checklist.md` completed, no blocking findings
[ ] docs: if changes affect docs → already updated
[ ] manual-tests: UC/TC file created and covers the entire Test plan
```

Only when all checks pass, move to Phase 4.

---

## Phase 4 — Ship

1. Run `/review-pr` — verdict must be ✅ APPROVE before proceeding
2. Run `/create-pr-description` — fill in the template from `.github/PULL_REQUEST_TEMPLATE.md`
3. If there is a technical decision worth recording → create a file in `.ai/decisions/`
4. Run `/ship` — push branch, create the actual PR, clean up task files
