---
name: ship
description: Final ship step — push branch, open PR on GitHub, update status.md, clean up task files. Run after review-pr APPROVE and create-pr-description.
---

# Ship

Final step: push branch, create the actual PR on GitHub, clean up task files.

**Precondition:** `/review-pr` has given a ✅ APPROVE verdict and `/create-pr-description` has been run.

---

## Run

### Step 1 — Confirm state

```bash
git status          # no unstaged changes
git log main...HEAD --oneline   # the right commits to ship
```

If there are still unstaged changes → commit or stash first.

### Step 2 — Push branch

```bash
git push -u origin HEAD
```

If the branch already exists on remote: `git push`.

### Step 3 — Create PR

**If `gh` CLI is available:**
```bash
gh pr create \
  --title "<type>: <task name>" \
  --body "$(cat <<'EOF'
<description from create-pr-description>
EOF
)"
```

Use the description prepared by `/create-pr-description`.

**If `gh` is not available:**
1. Open GitHub in a browser
2. GitHub will detect the new branch and show a "Compare & pull request" banner
3. Paste the prepared description into the body

### Step 4 — Cleanup

```bash
# Find the task name from the spec file in .ai/tasks/
ls .ai/tasks/*.md | grep -v TEMPLATE | grep -v -- '-manual-tests\.md$'

After confirming the PR was created successfully:

1. Update `.ai/status.md` — move task from "In Progress" to "Recently Completed":
   ```
   ## Recently Completed
   - <task-name> — done: <today's date> — PR: <PR URL>
   ```

2. Delete task files:
   ```bash
   rm .ai/tasks/<task-name>.md
   rm .ai/tasks/<task-name>-manual-tests.md 2>/dev/null || true
   ```

### Step 5 — Report

```
✅ Shipped: <PR URL>
   Branch: <branch-name>
   Cleaned up: .ai/tasks/<task-name>.md
```

---

## Gotchas

**Do not push directly to `main`.** If the current branch is `main` or `master` → stop and ask the user.

**Protected branch:** If push is rejected due to branch protection → guide the user to create a feature branch first: `git checkout -b <task-name>`.

**PR already exists:** `gh pr create` will error if a PR already exists for this branch. Check with `gh pr view` — if one already exists, just update the description instead.
