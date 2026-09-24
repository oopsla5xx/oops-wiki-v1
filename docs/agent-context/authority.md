# Authority: what wins when sources disagree

This workspace has several sources of "truth" — source code, OpenSpec artifacts, repo-local docs, `CLAUDE.md` — that can disagree at any point in time. This doc is the single place that says which one wins, so no agent has to decide that ad hoc, and no other doc in this workspace should restate this table (see `docs/agent-context/authority.md` referenced from every `CLAUDE.md`).

## Step 1 — classify the question

Before resolving a conflict, decide which kind of question it is:

1. **What is currently implemented** — "what does the system actually do right now?"
2. **What is the intended state** — "what should the system do?"
3. **What is the agent allowed to do** — "what am I permitted to do while working here?"

The same disagreement can look different depending on which question you're actually asking.

## Step 2 — resolve by source and question type

| Source | Authority for | Not authority for |
|---|---|---|
| Source code, tests, config, migrations already run | (1) What is currently implemented. Always wins here — never overridden by docs, specs, or `CLAUDE.md`. | Why something is the way it is; what it *should* be |
| Active (non-archived) OpenSpec change covering the area | (2) What is the intended state, for the part it covers. Code not yet matching it is expected incompleteness, not a conflict. | (1) Current implementation state |
| `openspec/specs/` (durable, post-archive) | (2) What is the intended state, when no active change covers the area | (1) Current implementation state |
| Archived OpenSpec changes | Historical rationale only — why a past decision was made | Anything about current state, implemented or intended |
| Repo-local docs (`docs/architecture/`, security checklists, etc.) | Navigation and architectural intent | (1) Current implementation state — if it conflicts with code, treat the doc as potentially stale, not the code as wrong |
| `CLAUDE.md` | (3) What the agent is allowed to do — hard constraints and conventions | (1) or (2) — never used to describe implementation or intended state |
| Root domain glossary / PRD | Business vocabulary and product intent | Technical implementation detail |

## Where technical decisions are recorded

There is no standalone ADR folder in this workspace (the old `.ai/decisions/` per repo is gone; those specific past decisions now live only in git history, not restored). A new technical decision goes in the `design.md` of the OpenSpec change that introduces it — once that change is archived, `design.md` becomes the historical record for it, per the "Archived OpenSpec changes" row above.

## Rules for handling a conflict

- **Never silently pick a side and continue.** If a conflict is relevant to the task at hand, say so in your response.
- **Active change vs. code**: code lagging an active change's spec is normal — it means the work isn't done yet, not that either source is wrong.
- **Durable specs vs. code, with no active change**: this is undocumented drift. Flag it and ask whether to open a change to reconcile — do not silently edit the spec or the code to make them agree.
- **`CLAUDE.md` vs. widespread code pattern**: if a hard constraint looks contradicted by code that does the forbidden thing everywhere, ask the user. Don't assume the rule is stale just because the code disagrees with it — legacy code awaiting cleanup looks identical to a stale rule from the outside.
- **Repo-local doc vs. code**: treat the doc as the thing that might be wrong. Don't conclude the code is broken because a doc says otherwise.

## Doc staleness: use commit history, not file-modification time

When you have reason to doubt a repo-local doc (task depends on it, or something looks off), compare its last commit against the last commit of what it describes, using version control — not filesystem modification time:

```bash
git log -1 --format=%ct -- path/to/doc.md
git log -1 --format=%ct -- path/to/described/dir/
```

Filesystem mtime is unreliable here: a fresh clone or a `git submodule update` resets mtimes on every file, which makes a naive `find -newer` check report false staleness on everything. Commit timestamps don't have that problem.
