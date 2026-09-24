# CLAUDE.md

## Workspace

`oops-wiki-v1` has no code of its own. It is the workspace root: shared docs (`PRD.md`, `docs/`) plus repos linked as git submodules — `oops-api-v1`, `oops-web-v1`, `oops-infra-v1` (and, not yet created, `oops-agent-v1`). Every submodule is always checked out through this workspace, never standalone — a submodule's `CLAUDE.md` and docs can safely assume `../oops-wiki-v1/` exists alongside them.

`openspec/` at this root is the shared OpenSpec root for the whole workspace: commands run from inside any submodule resolve here automatically (nearest-root lookup), no per-repo `openspec/` needed unless a submodule later opts into its own.

## When starting a new session

| Need to know | Read this |
|---|---|
| Business/domain terms | `docs/domain-glossary.md` |
| Cross-repo / system-level architecture | `docs/architecture/system-design/system-design.md` |
| Cross-repo security policy (auth model, AuthZ/RBAC) | `docs/architecture/system-design/system-design.md` §4 "Auth & AuthZ" — repo-local security docs reference this, they do not restate it |
| Pre-ship security checklist (process, generic across repos) | `docs/security-checklist.md` — repo-local `docs/architecture/security.md` adds only stack-specific notes on top of this |
| Which source wins when information conflicts | `docs/agent-context/authority.md` |
| Git branch protection / quality gates | `docs/github/git-workflow.md` |
| Working inside a submodule | that submodule's own `CLAUDE.md` first — it holds stack-specific conventions this file does not repeat |

**When unsure about anything — read the relevant file above first. Do not guess.**

## When assigned a task

Use OpenSpec (`openspec/`) for spec-driven work — proposal, specs, design, tasks. See `docs/agent-context/authority.md` for how an active change, the durable `openspec/specs/`, and actual code relate when they disagree.

## NEVER
- Do not push to the `main` branch of this repo or any submodule directly — see `docs/github/git-workflow.md` for the enforced gates on `oops-api-v1`/`oops-web-v1`; this repo and `oops-infra-v1` rely on this rule alone (not server-enforced)
- Do not restate content that has exactly one authoritative home elsewhere in this workspace (domain terms, cross-repo architecture, security policy, per-repo conventions) — reference it instead; see `docs/agent-context/authority.md`
