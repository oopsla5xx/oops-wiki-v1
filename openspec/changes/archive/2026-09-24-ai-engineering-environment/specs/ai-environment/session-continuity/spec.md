# Spec Delta

## Purpose

Defines how in-progress work state survives across sessions, and the automation boundary that governs which readiness/validation checks may run unprompted versus on demand.

## ADDED Requirements

### Requirement: No mandatory SessionStart automation
The workspace SHALL NOT run a mandatory `SessionStart` hook. Readiness checks (submodule sync state, OpenSpec root health, dependency/runtime versions, local service availability, working-tree state, OpenSpec change validity) SHALL happen on demand, at the point where the agent is about to act on the relevant thing, not proactively at the start of every session.

#### Scenario: Session starts with a root-docs-only task
- **WHEN** an agent starts a session and the task only involves reading root-level documentation
- **THEN** no submodule-sync check, dependency check, or `openspec doctor` call runs automatically before the agent can begin

#### Scenario: Agent about to edit code in a submodule
- **WHEN** an agent is about to modify code inside a specific submodule
- **THEN** the agent checks that submodule's git state at that point, not as a blanket session-start action

### Requirement: PreCompact hook nudges toward handoff
The workspace SHALL configure a `PreCompact` hook that reminds the agent to consider writing a handoff before context is compacted. This SHALL be the only hook that runs automatically in this workspace.

#### Scenario: Context approaches compaction
- **WHEN** a session's context is about to be compacted
- **THEN** the `PreCompact` hook fires and the agent is reminded to consider capturing a handoff before the compaction proceeds

### Requirement: Progress narrative is scoped to one active OpenSpec change
When a task spanning an OpenSpec change needs to hand off state to a future session, the agent SHALL use the `handoff` skill to produce a `progress.md` file inside that change's directory (`openspec/changes/<name>/progress.md`). This is not required at the end of every session — only when one of these applies: context is approaching compaction, the task is at a natural phase boundary spanning multiple sessions, or the session is stopping mid-task with an unresolved thread (an approach tried and rejected, or an open blocker) that would not be reconstructable from `tasks.md` and the code diff alone.

#### Scenario: Task completes cleanly within one session
- **WHEN** a task tied to an OpenSpec change is completed within a single session with nothing left unresolved
- **THEN** no `progress.md` is created for that change

#### Scenario: Session stops with a rejected approach not yet reflected elsewhere
- **WHEN** a session stops mid-task after trying an approach that failed for a reason not evident from the code or `tasks.md`
- **THEN** the agent writes a `progress.md` capturing what was tried, why it was rejected, and the concrete next step

### Requirement: Progress narrative content is constrained
`progress.md` SHALL be a short, structured handoff artifact, not a conversation transcript or full reasoning log. It SHALL be limited to: current state, what is done, what was tried and rejected (with why), what is blocked, key decisions or assumptions, and the concrete next step.

#### Scenario: Handoff produced at a trigger point
- **WHEN** the `handoff` skill produces a `progress.md`
- **THEN** the file contains only the fields above, and does not reproduce the full conversation

### Requirement: Progress narrative has the lowest authority
`progress.md` SHALL NOT be treated as a source of truth. When it conflicts with `tasks.md` or the actual state of the code, the code and `tasks.md` SHALL win.

#### Scenario: progress.md says a step is done but tasks.md disagrees
- **WHEN** `progress.md` states a step is complete but the corresponding `tasks.md` checkbox is unchecked or the code does not reflect it
- **THEN** the agent trusts `tasks.md`/the code and treats `progress.md` as outdated on that point, correcting or discarding it rather than acting on it

### Requirement: Progress narrative is deleted on archive
`progress.md` SHALL be scoped to the lifetime of its OpenSpec change. When the change is archived, `progress.md` SHALL be deleted along with the rest of the change's in-flight artifacts, not preserved as durable documentation.

#### Scenario: Change is archived
- **WHEN** an OpenSpec change with a `progress.md` is archived
- **THEN** `progress.md` is removed and no reference to it remains in the archived record
