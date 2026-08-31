# Agent Onboarding Protocol

When starting work on this project for the first time (or after a long break), read in the following order.

## Step 1 — Understand the project (required)

1. Read `.ai/context/architecture.md` — what the system does, the main modules, data flow
2. Read `.ai/context/conventions.md` — coding rules, correct/incorrect examples
3. Read `.ai/commands.md` — build, test, deploy commands for this project

## Step 2 — Sync context (if using Claude Code)

Run `/sync-ai-context` to check which files are stale before reading. If the tool is not available, skip this step.

## Step 3 — Check current state

4. Read `.ai/status.md` — are there any in-progress tasks? Is anything blocked?
5. If there is a relevant task brief in `.ai/tasks/` — read that brief
6. Check `../oops-wiki-v1/.ai/decisions/` for cross-repo architectural decisions that may affect this work

## Step 4 — Ready to work

After reading the above files:
- If assigned a task: follow `.ai/workflows/task-flow.md`
- If the task is unclear: ask for clarification, do not assume

## When to re-onboard

- After merging large changes into `main`
- When you notice yourself acting against conventions
- When unsure whether a technical decision fits the architecture
