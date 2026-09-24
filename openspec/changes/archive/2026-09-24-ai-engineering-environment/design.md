# Design

## Context

See `proposal.md` - Why for motivation. Current state, verified during exploration:

- `.ai/` is deleted (uncommitted) at root, `oops-api-v1`, and `oops-web-v1`; `oops-infra-v1` never had it or already resolved it. This was a deliberate strategic move to OpenSpec, not a reaction to a measured `.ai/` failure — the "too much context/token cost" complaint was never actually benchmarked.
- `openspec/` exists only at the root, currently empty (no specs, no changes before this one).
- `CLAUDE.md` in all three repos is now an empty shell: headers with no content underneath. One (`oops-web-v1`) had dangling references to the deleted `.ai/context/*` files; that was fixed as a standalone bugfix, independent of this change.
- No project-level Claude Code hook exists anywhere in the workspace today.
- Workflow constraint (confirmed, not assumed): every repo is always checked out through `oops-wiki-v1` as a git submodule. A submodule is never used standalone, so this design does not need to support that case.
- OpenSpec's root resolution is a directory walk-up ("nearest root") — verified experimentally with a throwaway nested-directory test: a submodule with no `openspec/` of its own resolves to the parent's, and a submodule that creates its own `openspec/` shadows the parent without affecting it.

## Goals / Non-Goals

**Goals:**
- An agent starting any session in any of the four repos has the load-bearing facts it needs without loading more than necessary.
- No ambiguity about which source of information wins when two disagree.
- A multi-session task can resume without replaying the full prior conversation.
- No automation runs unprompted except one narrowly-scoped hook justified by a real, previously-experienced pain point.

**Non-Goals:**
- Multi-agent/concurrent task coordination (no `status.md`-style registry). Rejected during exploration — work here is sequential, one person/agent at a time; revisit only if that changes.
- OpenSpec `store`/`references`/`workset` — solves cross-machine, non-nested repo sharing, which this workspace does not have.
- New repo/stack-specific Claude Code skills (Go/Next.js/Terraform) written preemptively. Generic already-installed skills are used first; a stack-specific skill is only justified by a demonstrated workflow gap.
- Retroactively benchmarking the old `.ai/` system. No baseline was captured; this design does not claim a quantified improvement over it, only a forward measurement plan (see proposal's Impact / success criteria, not a task of this change).
- `oops-agent-v1` context. The repo does not exist yet.

## Decisions

### 1. Single shared OpenSpec root via nearest-root resolution, not `store`/`references`
OpenSpec already resolves to the nearest `openspec/` directory walking up from any submodule — verified experimentally, not assumed. Given the confirmed constraint that repos are always checked out together, this gives one shared root "for free," with an opt-in escape hatch: any submodule can run `openspec init` locally later to shadow the shared root, without touching it.

**Alternatives considered:** OpenSpec `store`/`references` (beta) — targets repos that are *not* nested and need per-machine registration with no auto-sync; that problem doesn't exist here, so adopting it would add beta-stability risk and registration overhead for nothing. Isolated `openspec/` per submodule by default — rejected as the default because it fragments specs/changes across four places with no evidence of need; kept available as an opt-in per-repo escape hatch instead.

### 2. Three-tier context layering (root / `CLAUDE.md` / repo-local docs), applied uniformly to architecture and security
`CLAUDE.md` pre-migration used `@`-imports and a pointer table into `.ai/context/*.md` — i.e., progressive disclosure. Moving that content directly into `CLAUDE.md` instead of keeping it in referenced, on-demand files would reintroduce the always-loaded bloat that motivated leaving `.ai/`, just relocated. The three tiers keep `CLAUDE.md` small and always-loaded, push detail into on-demand repo-local docs, and keep cross-repo/business content in exactly one place (root).

**Alternatives considered:** Inlining everything into `CLAUDE.md` — rejected, defeats progressive disclosure and risks recreating the cited (if unmeasured) cost problem. One shared root doc covering every repo's internal architecture too — rejected: root already owns cross-repo architecture; folding repo-internal detail in as well breaks that boundary and makes the root doc grow unbounded as repos are added.

### 3. Explicit authority matrix (classify the question, then resolve) instead of one blanket rule
A flat "code always wins" or "spec always wins" rule breaks down predictably: code legitimately lags an active change's not-yet-implemented spec, and a `CLAUDE.md` constraint should not be overridden just because code widely violates it already. The matrix requires classifying the question (current state / intended state / permission) before applying a resolution rule, and separates durable specs, active changes, and archived changes since each has different currency.

**Alternatives considered:** Single blanket rule ("code wins" or "spec wins") — explicitly rejected during exploration; it produces wrong answers in the active-change and `CLAUDE.md`-constraint cases described above.

### 4. Zero mandatory `SessionStart` hook; on-demand checks; the only hook is `PreCompact`
Eight concrete readiness-failure scenarios were worked through with measured latency data (`openspec doctor` ~2.4s, `git submodule status` ~1s). Seven of eight already fail fast at their natural point of use (build tooling, the existing git-safety protocol, OpenSpec's own per-artifact skill checks). The eighth (doc staleness) is silent but cheap to check on demand and doesn't need session-wide coverage. A blanket `SessionStart` hook would tax every session for failure modes that mostly don't need proactive detection.

**Alternatives considered:** A lightweight blanket `SessionStart` readiness hook — rejected after the case-by-case analysis found no case needing it. No automation at all, including near context compaction — rejected: this is the one case where "on demand" is unreliable, since the agent may not reliably notice its own context is about to compact, and it's comparatively rare (unlike "every session"), so the cost is proportional to the benefit.

### 5. `progress.md` lives inside the OpenSpec change directory, authored via the existing `handoff` skill, lowest authority, deleted on archive
Tying the artifact's lifecycle to the change it describes avoids creating a separate, indefinitely-lived documentation surface that could itself go stale. Reusing the already-installed `handoff` skill avoids building bespoke tooling for a need that skill already covers.

**Alternatives considered:** A durable per-repo notes file living outside OpenSpec — rejected, it would outlive its relevance and become exactly the kind of stale doc this design avoids elsewhere. Mandatory handoff at every session's end — rejected as blanket overhead for sessions that finish a task cleanly in one sitting.

## Risks / Trade-offs

- [Migration is currently half-done: two of three repos have empty `CLAUDE.md` shells, and none has repo-local docs yet] → Mitigation: `tasks.md` sequences populating `CLAUDE.md` and the minimum repo-local docs per repo as explicit, trackable tasks rather than leaving them implicit.
- [`progress.md` could drift into a full conversation log if not kept disciplined] → Mitigation: the spec constrains its fields explicitly (current state / done / tried-and-rejected / blocked / decisions / next step); treat longer content as a spec violation, not a style choice.
- [The authority matrix depends on the agent correctly classifying the question type before applying it] → Mitigation: the spec's scenarios give concrete classification examples; revisit if misclassification is observed in practice.
- [No historical baseline exists for the old `.ai/` system's actual token/latency cost] → Mitigation: do not claim a quantified improvement over `.ai/`; measure forward from this point only.

## Migration Plan

No production or runtime system is affected — this is agent-context tooling (markdown files and one hook entry), so there is no traditional deploy/rollback risk.

- Order: root context (domain glossary references, security policy pointers already in `system-design.md`) first, since repo-local docs need something to reference → then `CLAUDE.md` per repo → then the minimum repo-local docs per repo → then the `PreCompact` hook entry.
- Each repo's `CLAUDE.md`/docs work is independent of the others once root is in place, since repo-local content only references root, never duplicates it — repos can be done in any order or in parallel.
- Rollback is a plain `git revert` per affected repo; no data migration is involved anywhere.

## Open Questions

- Does the workspace still need a distinct "manual test scenario" (UC/TC) artifact type, separate from what `tasks.md`/`design.md` already capture? No generic installed skill maps cleanly to the old `write-test-scenarios` skill. Deferred — doesn't change this change's specs or tasks; revisit if a future task needs structured manual-test documentation.
- Should any repo eventually get a stack-specific Claude Code skill beyond the generic catalog? Policy is already decided (generic-first, evidence-based); no concrete case exists yet to decide on. Deferred until a real workflow gap surfaces.
