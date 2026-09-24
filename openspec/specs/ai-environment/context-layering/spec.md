# ai-environment/context-layering Specification

## Purpose

Defines where different kinds of agent-facing context live across the workspace — root vs. per-repo `CLAUDE.md` vs. per-repo docs vs. OpenSpec artifacts — and which source has authority when two of them disagree, so an agent gets correct context without loading more than necessary.

## Requirements

### Requirement: Root context scope
The root workspace (`oops-wiki-v1`) SHALL be the single source of truth for cross-repo and business-level context: the PRD, cross-repo/system-level architecture, the domain glossary, and business-level security requirements. Repo-local docs SHALL NOT duplicate this content; they SHALL reference it instead.

#### Scenario: Agent needs a business term definition
- **WHEN** an agent needs the definition of a business/domain term while working in any repo (root or a submodule)
- **THEN** the agent looks it up in the root domain glossary, and does not find a duplicate or conflicting definition in a repo-local `CLAUDE.md` or doc

#### Scenario: Repo-local doc touches a cross-repo security requirement
- **WHEN** a repo-local security doc needs to state a cross-repo/business-level security requirement (for example, an auth model constraint)
- **THEN** it references the root document by name instead of restating the requirement in full

### Requirement: CLAUDE.md is a lean index, not a knowledge store
Each repo's `CLAUDE.md` (root and every submodule) SHALL contain only: a minimal set of always-relevant facts (overall structure, main modules, critical boundaries, dependency direction, invariants), hard "NEVER" constraints, and pointers to where more detail lives. It SHALL NOT contain the full text of conventions, architecture detail, or security checklists.

#### Scenario: Agent looks for detailed module wiring
- **WHEN** an agent needs the detailed internal module map or data flow of a repo
- **THEN** `CLAUDE.md` points it to a repo-local doc rather than containing that detail itself

#### Scenario: CLAUDE.md reviewed for compliance
- **WHEN** a `CLAUDE.md` file is reviewed against this requirement
- **THEN** it has no heading with empty content underneath, and no reference to a file that does not exist

### Requirement: Repo-local docs hold implementation-level detail
Each repo SHALL keep detailed, stack-specific context (module maps, data flow, coding conventions, testing conventions, and stack-specific security checklists) in repo-local docs, read on demand rather than always loaded.

#### Scenario: Agent about to write security-sensitive code in a repo
- **WHEN** an agent is about to write authentication, authorization, or input-handling code in a specific repo
- **THEN** it reads that repo's local security doc for the stack-specific checklist, in addition to (not instead of) the root's cross-repo security requirements

### Requirement: Single shared OpenSpec root by default
The workspace SHALL use one shared `openspec/` root at `oops-wiki-v1`, resolved via OpenSpec's nearest-root lookup from any submodule. A submodule SHALL only gain its own `openspec/` root when it needs isolated specs/changes, and doing so SHALL NOT require any change to the shared root.

#### Scenario: Agent works inside a submodule with no local openspec root
- **WHEN** an agent runs an OpenSpec command from within a submodule that has no `openspec/` directory of its own
- **THEN** the command resolves to the root workspace's `openspec/` directory

### Requirement: Explicit authority order on conflicting information
When two sources of information disagree, the agent SHALL first classify the question, then resolve it:
- "What is currently implemented" SHALL be resolved by source code, tests, and configuration — never by docs, specs, or `CLAUDE.md`.
- "What is the intended state" SHALL be resolved by the active (non-archived) OpenSpec change covering that area if one exists, otherwise by `openspec/specs/` (durable, current). Archived changes SHALL only be used as historical rationale, never as current-state authority.
- "What is the agent allowed to do" SHALL be resolved by `CLAUDE.md` constraints, regardless of what code or docs elsewhere show.

Repo-local architecture/security docs are navigational only: if they conflict with source code, the agent SHALL treat the doc as potentially stale and SHALL NOT treat the code as wrong on that basis. The agent SHALL NOT silently pick a source and continue without surfacing the discrepancy when it is relevant to the task at hand.

#### Scenario: Doc says module X calls module Y directly, code shows an interface layer
- **WHEN** a repo-local architecture doc states that module X calls module Y directly, but the source code shows the call routed through an interface layer
- **THEN** the agent treats the source code as the current implementation truth, treats the doc as potentially stale, and mentions the discrepancy in its response

#### Scenario: Code diverges from an active change's spec
- **WHEN** code does not yet implement something required by an active (non-archived) OpenSpec change covering that area
- **THEN** the agent treats this as expected incompleteness, not as a conflict to silently resolve in favor of either side

#### Scenario: Code diverges from durable specs with no active change
- **WHEN** code diverges from a requirement in `openspec/specs/` and no active change explains the divergence
- **THEN** the agent flags this as undocumented drift and asks whether to open a change to reconcile it, rather than silently updating the spec or the code

#### Scenario: CLAUDE.md rule appears contradicted by widespread code
- **WHEN** a `CLAUDE.md` hard constraint appears to conflict with a pattern that is widespread in the existing codebase
- **THEN** the agent asks the user rather than assuming the rule is stale and following the code pattern instead

### Requirement: On-demand doc staleness check uses commit history, not filesystem mtime
Before treating a repo-local doc's content as reliable in a case where staleness is plausible, the agent SHALL be able to compare the doc's last commit timestamp against the last commit timestamp of the source it describes, using version-control history rather than filesystem modification time.

#### Scenario: Fresh checkout or submodule update
- **WHEN** a repo has just been freshly cloned or a submodule has just been updated, resetting filesystem modification times on all files
- **THEN** a staleness check based on commit history does not report false staleness, unlike a filesystem-mtime-based check would

#### Scenario: Doc genuinely outdated
- **WHEN** the directory a doc describes has commits newer than the doc's own last commit
- **THEN** the agent treats the doc as a candidate for being stale before relying on its content for a task-relevant decision
