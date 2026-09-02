# Status

This file is used for coordination between multiple agents. Always read before starting a task, always update when starting and finishing.

## In Progress

<!-- Format: - [agent/person] task-name — short description — started: YYYY-MM-DD -->

## Blocked

<!-- Format: - task-name — blocked by: X — needs: Y -->
- convert-api-web-to-real-submodules — blocked by: needs careful git surgery on oops-api-v1 (has uncommitted WIP) and oops-web-v1 — needs: dedicated task, deliberately deferred out of centralize-local-infra-in-oops-infra

## Recently Completed

<!-- Keep the 3-5 most recent entries for context -->
<!-- Format: - task-name — done: YYYY-MM-DD — notes: ... -->
- setup-floci — done: 2026-09-02 — replaced oops-api-v1's local Postgres/Redis with Floci-provisioned RDS/ElastiCache/S3 (`oops-infra-v1/terraform/local/`), see ADR-0003 (supersedes ADR-0002's Terraform-deferral). Full spike/build record at `.ai/tasks/setup-floci.md`. PRs open on `oops-infra-v1` and `oops-api-v1` (branch `feat/floci-local-aws-emulation` on both).
- centralize-local-infra-in-oops-infra — done: 2026-08-31 — created oops-infra-v1 repo + real git submodule (oops-wiki-v1 was not a git repo at all, had to `git init` it), moved shared dev/test docker compose there, updated oops-api-v1 Makefile/CI/README, PR #32 open (CI green except 2 pre-existing unrelated failures: missing migration files, stale mocks). oops-api-v1/oops-web-v1 NOT yet converted to real submodules — separate follow-up, see Blocked.
- add-debug-skill — done: 2026-07-26 — tool-agnostic investigation workflow (Reproduce → Reduce → Observe → Hypothesize → Experiment → Root Cause → Fix → Verify), MCP-aware but not MCP-required
