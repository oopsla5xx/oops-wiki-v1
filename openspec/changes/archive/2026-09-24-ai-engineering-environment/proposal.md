# Proposal

## Why

The workspace is mid-migration away from the old `.ai/` context system (deleted, uncommitted, across the root and the `oops-api-v1`/`oops-web-v1` submodules) toward OpenSpec, but the migration stopped halfway: `CLAUDE.md` in all three repos is now an empty shell (headers with no content, one had dangling references to deleted files — already fixed as a standalone bugfix). There is currently no defined answer for where repo context should live, which source wins when two sources disagree, or how an agent resumes a task across sessions without re-reading the whole conversation. Left as-is, the workspace has strictly less agent context than before the migration, and is at risk of recreating the old system's problems (unbounded context growth, stale docs, no continuity) if filled in ad hoc.

## What Changes

- Establish a 3-tier context layering (root workspace context, per-repo `CLAUDE.md`, per-repo detailed docs) applied consistently to both architecture and security content — replacing the flat, now-empty `.ai/`-derived `CLAUDE.md` files.
- Define an explicit authority/conflict-resolution matrix across source code, active OpenSpec changes, the durable `openspec/specs/` tree, archived changes, repo-local docs, and `CLAUDE.md` — so an agent never silently picks a source when two disagree.
- Formalize session-to-session continuity: a `progress.md` per active OpenSpec change (via the existing `handoff` skill), scoped to that change's lifetime and treated as the lowest-authority source.
- Set an explicit automation boundary: no mandatory `SessionStart` hook; the only hook introduced is a narrow `PreCompact` hook that nudges toward `handoff`. All other readiness checks (submodule sync, OpenSpec root health, dependency state, doc staleness) happen on demand, at the point of use, not proactively every session.
- Confirm skill scope policy: prefer already-installed generic skills over stack-specific ones; only add a repo/stack-specific skill when a generic one demonstrably fails a real workflow.
- Place domain glossary and cross-repo/business-level security requirements at the root as the single source of truth; repo-local docs hold only the stack-specific "how", referencing root instead of duplicating it.

## Capabilities

### New Capabilities
- `ai-environment/context-layering`: where different kinds of agent-facing context live (root vs. per-repo `CLAUDE.md` vs. per-repo docs vs. OpenSpec artifacts) and which source has authority when two disagree.
- `ai-environment/session-continuity`: how in-progress work state survives across sessions (`progress.md` lifecycle via `handoff`) and the automation boundary that governs which checks may run unprompted.

### Modified Capabilities
None — this is a greenfield capability area (`openspec list --specs` returns no existing specs in this workspace).

## Impact

- **Affected files**: `CLAUDE.md` at the root and in `oops-api-v1`, `oops-web-v1`, `oops-infra-v1` (content to be authored per the new layering); new `docs/architecture/` (and, where warranted, a security doc) per repo; `openspec/config.yaml` at root (domain/business context, if needed); `.claude/settings.json` (adds the `PreCompact` hook).
- **Not affected**: no runtime/application code in any of the four products changes. This is process and agent-context tooling only.
- **Repos touched**: `oops-wiki-v1` (root) plus the three existing submodules. `oops-agent-v1` does not exist yet and is out of scope.
