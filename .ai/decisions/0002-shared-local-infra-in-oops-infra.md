# ADR-0002: Shared local dev/test infrastructure lives in oops-infra-v1

**Status:** Accepted
**Date:** 2026-08-31

---

## Context

`oops-api-v1` owned its own `docker-compose.{dev,test,prod}.yml` for Postgres/Redis. As `oops-agent-v1` comes online, it will need the same Postgres/Redis (and a new AWS-emulator service, Floci) for local dev. Duplicating compose files per repo risks version drift (e.g. API on `postgres:16-alpine`, Agent on a different tag) and contradicts the intended "one shared image per service" model.

The workspace (`oops-wiki-v1`) links `oops-api-v1`, `oops-agent-v1`, `oops-web-v1`, `oops-infra-v1` as **git submodules** (not filesystem symlinks — `.gitmodules` confirms this; the original PRD §11 description of "symlink" was inaccurate to the actual implementation and has been corrected).

## Decision

`oops-infra-v1` owns all shared local dev/test infrastructure as Docker Compose files (`docker/dev/compose.yaml`, `docker/test/compose.yaml`). `oops-api-v1` and (later) `oops-agent-v1` consume these via relative path from their Makefiles; they do not define their own Postgres/Redis/Floci compose services.

CI does **not** cross-checkout `oops-infra-v1`. Each app repo's CI defines its own Postgres/Redis via GitHub Actions native `services:` blocks, matching image tags by hand with `docker/dev/compose.yaml`.

## Reasons

- Single source of truth for shared service versions across API and Agent
- Avoids cross-repo checkout complexity/secrets in CI (service containers are simpler and don't need repo access)
- Terraform (real AWS infra) and Docker Compose (local infra) both belong under "infrastructure" ownership conceptually, even though only Docker is being built now

## Tradeoffs

- `oops-api-v1` can no longer be cloned standalone for local dev — must clone via `oops-wiki-v1` and `git submodule update --init`. Accepted: multi-repo standalone-clone independence was already partially theoretical (this workspace itself isn't a git repo yet).
- CI and local compose image versions must be kept in sync manually (no shared source between GitHub Actions `services:` and `compose.dev.yaml`). Accepted: simpler CI outweighs the small sync burden; revisit if drift causes real bugs.
- `oops-infra-v1` repo had to be created from scratch (didn't exist on GitHub or locally) — this ADR also fixes `.gitmodules`, which pointed to a non-existent local path instead of the GitHub remote used by sibling repos.

## Consequences

- New service versions (Postgres, Redis, Floci) are bumped in exactly one file: `oops-infra-v1/docker/dev/compose.yaml`
- Any repo needing shared local infra depends on `oops-infra-v1` being checked out as a sibling submodule — document this in each consuming repo's README
- Terraform structure under `oops-infra-v1/terraform/` is deferred until an actual AWS environment is needed (YAGNI) — not scaffolded by this decision

---
