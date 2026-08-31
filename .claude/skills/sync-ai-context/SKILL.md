---
name: sync-ai-context
description: Refresh stale .ai/ context files before starting a task — detect which of commands.md, architecture.md, conventions.md are outdated and patch only those sections. Run at the start of each task session.
---

# Sync AI Context

Check and update stale `.ai/` files before starting a task. Only patch the stale parts — do not rewrite the entire file.

Use when: starting a new task, after pulling from remote, or when the context is suspected to be inaccurate.

---

## Run

### Step 1 — Detect stale files

```bash
bash .claude/skills/sync-ai-context/check-staleness.sh
```

Read the entire output. The script produces 3 types of results:
- `OK` — this file is still fresh, skip it
- `STALE <source> is newer than <target>` — the relevant section needs updating
- `MISSING` — file does not exist yet, run `/setup-ai-context` first

### Step 2 — Handle each STALE signal

**If `package.json` is newer than `commands.md`:**
```bash
node -e "const d=require('./package.json'); Object.entries(d.scripts||{}).forEach(([k,v])=>console.log(k+': '+v))"
```
Compare the output with `.ai/commands.md`. Update only the sections with different commands — do not remove any section unless you are certain it has been removed from the project.

**If `Makefile` is newer than `commands.md`:**
```bash
grep -E "^[a-zA-Z_-]+:" Makefile | sed 's/:.*//'
```
Add or update the corresponding targets in `commands.md`.

**If `README.md` is newer than `architecture.md`:**
```bash
head -60 README.md
```
Read the changed parts. Update only the affected section (usually "What the project is" or "Stack").

**If there is a new directory not present in `architecture.md`:**
Read the contents of that directory (`ls <dir>`). Add 1-2 lines of description to the "Module structure" section — do not describe it if the purpose is unclear.

**If a lint config (`.eslintrc*`, `biome.json`, `ruff.toml`...) is newer than `conventions.md`:**
```bash
cat <config-file>
```
Update the relevant rule in `conventions.md`. Do not remove old rules unless the new config clearly contradicts them.

### Step 3 — Implicitly update timestamps

After updating a file: touch that file to reset the baseline for the next check.

```bash
touch .ai/commands.md          # only files that were just updated
touch .ai/context/architecture.md
touch .ai/context/conventions.md
```

### Step 4 — Report

Print:
- Which files were updated and which sections were changed
- Which files were `OK` (no action needed)
- Any STALE signals the agent does not have enough information to handle — needs to ask the user

---

## Gotchas

**Script exit code 1 is not an error:** Exit 1 only means there are stale files. Exit 0 = everything is fresh. Do not treat exit 1 as a failure.

**`find -newer` uses filesystem mtime:** If the project was just `git clone`d, all files will have mtime = the clone time — the script will report many false STALEs. In this case, use the "RECENT GIT CHANGES" section to make judgments instead of relying on file timestamps.

**Do not update when unsure:** If a STALE signal is `package.json` newer but only the `version` field changed → skip it, `commands.md` does not need updating. Prefer not being wrong over not updating.

**Monorepo:** The script detects new directories at depth 1-2. If the project is a monorepo with many `apps/`, only care about directories inside the sub-project being worked on.
