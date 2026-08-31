---
name: create-pr-description
description: Generate a pull request description by filling in the .github/PULL_REQUEST_TEMPLATE.md from spec, git diff, and commit history. Outputs ready-to-use text or creates PR via gh CLI. Run as part of Phase 4 ship.
---

# Create PR Description

Fill in the PR template from `.github/PULL_REQUEST_TEMPLATE.md` based on the spec and git history. Output is ready to paste into GitHub or use with `gh pr create`.

---

## Run

### Step 1 — Gather context

Run all in parallel:

```bash
# Template
cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null \
  || cat .github/pull_request_template.md 2>/dev/null \
  || echo "(no template found)"

# Git summary
git log main...HEAD --oneline
git diff --stat main...HEAD
```

Read spec: `.ai/tasks/<task-name>.md` (Goal, Scope, Test plan, Constraints)

### Step 2 — Map each section of the template

For each section in the template, pull content from the corresponding source:

| Section | Source |
|---|---|
| **What** | Goal in spec — 1-2 concise sentences |
| **Why** | Reason from clarify-scope discussion, or Constraints in spec |
| **Changes** | `git diff --stat` + Scope in spec |
| **Test plan** | Test plan items in spec (convert to checklist) |
| **Manual test guide** | Link to `<task-name>-manual-tests.md` if it exists |
| **Checklist** | Fill in real test commands from `.ai/commands.md` |
| **Notes for reviewer** | Constraints, trade-offs, or important gotchas from spec |

### Step 3 — Write the description

Rules:

**What:** Describe WHAT, not HOW. After reading, the reader immediately knows what the feature/fix is.
```
# Good
Add password reset via email — users can request a reset link that expires in 1 hour.

# Bad
Implement the reset token logic and add the API endpoints for password reset flow.
```

**Why:** Business or technical reason. Do not re-explain WHAT.
```
# Good
Required by auth security audit — tokens previously had no expiry.

# Bad
Because we need to allow users to reset their password.
```

**Changes:** Use `git diff --stat` to get the file list, add 1 line of context for important files.
```
- `src/auth/reset-token.ts` (new) — token generation and validation
- `src/api/routes/auth.ts` — 2 new endpoints: request + confirm
- `src/email/templates/` — reset-password email template
```

**Notes for reviewer:** Only include what a reviewer CANNOT know from the code:
- Trade-offs considered
- Decisions to skip a particular approach and why
- Known limitations or follow-up work needed

### Step 4 — Output

**If `gh` CLI is available:**
```bash
gh pr create \
  --title "<type>: <short name>" \
  --body "$(cat <<'EOF'
<description content>
EOF
)"
```

**If `gh` is not available:**
Print the full description, ready to paste into GitHub.

**PR title format:**
```
feat: <what>       ← new feature
fix: <what>        ← bug fix
refactor: <what>   ← no behavior change
chore: <what>      ← tooling, deps, config
```

---

## If the project has no PR template

Use the fallback structure:

```markdown
## What
## Why
## Changes
## Test plan
## Notes for reviewer
```

Then suggest creating `.github/PULL_REQUEST_TEMPLATE.md` for the project (template available in oops-skills).

---

## Gotchas

**Do not copy-paste commit messages as the description.** Commit messages describe individual steps; a PR description describes the entire change as a single unit.

**"What" and "Why" are often confused.** What = result/output. Why = reason for existence. If a sentence starts with "Because" or "In order to" → that is Why, not What.

**Checklist must have real commands.** `- [ ] Tests pass (npm test)` is more useful than `- [ ] Tests pass`.
