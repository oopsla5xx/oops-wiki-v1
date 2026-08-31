# AI Workflow

This workspace is bootstrapped from **oops-skills** — a starter template for AI
workflow that works with Claude Code, Cursor, GitHub Copilot, and any AI
coding tool that can read markdown. This page documents that workflow: how
`.ai/` and `.claude/skills/` are structured and how an AI agent (or a human)
should use them.

## Usage in a new project

To bootstrap a new repo with this same workflow:

```
cp -r oops-skills/. your-project/
```

Then run `/setup-ai-context` to let the agent auto-detect the stack and fill in the 3 template files, or fill them in manually:

1. `.ai/context/architecture.md` — system description
2. `.ai/context/conventions.md` — coding rules
3. `.ai/commands.md` — actual build/test/deploy commands for the project

---

## Workflow

### Setup (once)

```
/setup-ai-context   Detect stack, auto-fill .ai/ templates
```

### Each time you start working

```
/sync-ai-context    Check if .ai/ files are stale, patch if needed
```

### Task flow

```
Phase 1 — Brief
  /clarify-scope          Small/clear → proceed. Large/vague → state assumptions + ask 1 question
  /write-spec             Convert discussion context → .ai/tasks/<name>.md
  /plan-tasks             Break spec into ordered steps + "Done when:" for each step

Phase 2 — Implement
  /implement-tdd          Red → Green → Refactor, per step in Plan

Phase 3 — Self-check
  /write-test-scenarios   Create UC/TC for user to manually test
  [checklist]             tests green, lint, conventions, scope, side effects, security checklist

Phase 4 — Ship
  /review-pr              Review diff against spec: 5 dimensions, verdict APPROVE/REQUEST CHANGES
  /create-pr-description  Fill .github/PULL_REQUEST_TEMPLATE.md from spec + git history
  /ship                   Push branch, open PR on GitHub, update status.md, clean up task files
```

**Exception path:** Small, clear task → `/clarify-scope` evaluates "proceed" → skip write-spec, plan-tasks → code directly → self-check → ship.

---

## Structure

```
.ai/                          # Source of truth — all agents read from here
├── commands.md               # Abstract commands → concrete shell commands
├── status.md                 # Multi-agent coordination: who is doing what
├── context/
│   ├── architecture.md       # System overview, data flow
│   ├── conventions.md        # Coding rules with ❌/✅ examples
│   └── domain-glossary.md    # Business/domain terminology
├── workflows/
│   ├── onboarding.md         # What a new agent reads, in what order
│   └── task-flow.md          # Brief → Implement → Self-check → Ship
├── tasks/
│   ├── TEMPLATE.md           # Template for task brief
│   └── <name>.md             # Active task brief (delete after merge)
└── decisions/                # ADR — important technical decisions
    └── 0001-example-...md

.claude/skills/               # Skills — only usable with Claude Code
├── setup-ai-context/         # First-time setup: detect stack, fill templates
├── sync-ai-context/          # Ongoing: check if .ai/ files are stale
├── clarify-scope/            # Decide whether to ask or assume before coding
├── write-spec/               # Convert discussion → .ai/tasks/<name>.md
├── plan-tasks/                # Break spec into ordered implementation steps
├── implement-tdd/            # Red → Green → Refactor per step in Plan
├── write-test-scenarios/     # Create UC/TC markdown for manual testing
├── review-pr/                # Review diff against spec before shipping
├── create-pr-description/    # Fill PR template from spec + git history
├── ship/                     # Push branch, open PR, update status, clean up
└── debug/                    # Systematic bug investigation: Reproduce → Reduce → Observe → Hypothesize → Experiment → Root Cause → Fix → Verify

CLAUDE.md                     # Claude Code adapter (uses @ imports)
.cursorrules                  # Cursor adapter
.github/
├── copilot-instructions.md   # GitHub Copilot adapter
└── PULL_REQUEST_TEMPLATE.md  # PR template (used by create-pr-description)
```

---

## Design Principles

**1. `.ai/` is the single source of truth.**
All tool-specific configs are just adapters pointing to `.ai/`. When updating a convention or workflow, only one place needs to change.

**2. Commands are abstract, not hardcoded.**
Agents read `.ai/commands.md` to know the actual commands — no guessing `npm test` or `pytest`. Allows changing the stack without modifying the workflow.

**3. Workflow in plain markdown.**
`task-flow.md` and skills are step-by-step instructions — any agent can follow them, no plugins or custom DSL required.

**4. Spec is the origin of everything.**
Spec (`write-spec`) → Plan (`plan-tasks`) → Implementation (`implement-tdd`) → Test scenarios (`write-test-scenarios`) → Review (`review-pr`) → PR description (`create-pr-description`) all trace back to the same `.ai/tasks/<name>.md` file.

**5. Coordination via files.**
`status.md` is shared state for multi-agent: agents check before starting, update when done. No server or special tooling required.

---

## Adding a New Tool

Create an adapter file for that tool, pointing to `.ai/`:

```markdown
# [Tool Name] Config

## Before writing code
Read `.ai/context/conventions.md`

## Commands
See `.ai/commands.md`

## Task workflow
Follow `.ai/workflows/task-flow.md`
```
