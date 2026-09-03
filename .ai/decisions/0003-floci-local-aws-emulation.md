# ADR-0003: Floci for local AWS infrastructure emulation

**Status:** Accepted
**Date:** 2026-09-02

---

## Context

ADR-0002 deferred both Floci and Terraform: `oops-api-v1` had no S3/SQS consumer, so adding an AWS emulator would have been speculative infra with nothing to test against. That's no longer true — Phase 2 (`docs/architecture/system-design/system-design.md`) adds attachments via presigned S3 PUT, and production already runs RDS PostgreSQL + ElastiCache Redis + S3 (PRD §12). Local dev still ran Postgres/Redis as plain Docker Compose services, diverging from what production actually looks like.

## Decision

`oops-infra-v1` runs [Floci](https://github.com/floci-io/floci) (`docker/dev/compose.yaml`) as a local AWS emulator, and `oops-infra-v1/terraform/local/` provisions one RDS PostgreSQL instance, one ElastiCache Redis replication group, and one S3 bucket against it. `oops-api-v1` connects to these instead of directly-run `postgres:16-alpine`/`redis:7-alpine` containers. `oops-api-v1/Makefile` gained `infra-apply`/`infra-destroy`/`dev-up`.

`DATABASE_DSN`/`REDIS_ADDR` are hardcoded in `.env.example`/`.env.development` (`localhost:7001`, `localhost:6379`) rather than synced from `terraform output` by a script. An earlier pass built that sync script on the general "Terraform is the source of truth for endpoints" principle, but for this specific setup it was solving a problem that doesn't exist: `terraform/local/` only ever provisions exactly one RDS instance and one ElastiCache group, and empirically (repeated full destroy/apply cycles during testing) the endpoint is always `localhost:7001`/`localhost:6379` — RDS's proxy port is the range's base port since there's only ever one instance to allocate it to, and ElastiCache's port is pinned directly in the Terraform resource (`port = 6379`). A script keeping two things in sync that never actually diverge is pure overhead — deleted. If a second RDS or ElastiCache resource is ever added here, check `terraform output` and update the hardcoded values by hand; don't reintroduce the sync script preemptively.

CI is unaffected — it keeps using native GitHub Actions `services:` blocks (ADR-0002's CI reasoning still holds). `docker/test/compose.yaml` is unaffected too — test infra stays on plain, fast, ephemeral containers.

## Reasons

- Local dev now mirrors the actual production topology (RDS/ElastiCache/S3), not just "some Postgres and some Redis" — reduces the class of bugs that only show up against real AWS-shaped behavior (connection strings, endpoint resolution, IAM-style auth paths)
- S3 has a genuine Phase 2 consumer now — no longer speculative
- Terraform starting here (local only, targeting Floci) gives the team a real IaC habit before a production AWS environment exists, without having to invent one

## Key implementation details (found by direct testing against Floci, not assumed from docs)

- **ElastiCache must use `aws_elasticache_replication_group` with cluster mode enabled** (`num_node_groups = 1`, `replicas_per_node_group = 0`, `parameter_group_name` ending `.cluster.on`) — not `aws_elasticache_cluster` (Floci rejects it for the Redis engine, matching real AWS), and not a plain non-cluster-mode replication group. Floci only reconciles/respawns the backend container on restart for cluster-mode groups; a first attempt with a plain replication group never recovered after any Floci restart. Cache *data* still doesn't survive a restart either way ("caches restart empty" per Floci's own docs) — this only affects whether the *service* comes back, which matters since Redis here is cache/queue/pub-sub, not source of truth
- **RDS/ElastiCache need published port ranges**, not just the 4566 edge port — `7001-7099` for RDS, narrowed to exactly `6379` for ElastiCache (see below) — and RDS additionally needs `FLOCI_SERVICES_RDS_ENDPOINT_HOST=localhost`, or its advertised endpoint is an unreachable internal Docker IP
- **ElastiCache's proxy port range collides with `docker/test/compose.yaml`'s `redis-test` on `:6380`** if left at Floci's default `6379-6399` — narrowed to exactly `6379` (`FLOCI_SERVICES_ELASTICACHE_PROXY_BASE_PORT`/`_MAX_PORT`), matching the single instance actually provisioned. Widen it if a second ElastiCache resource is ever added here
- **No IAM/SigV4 auth needed for either service** — despite ElastiCache's docs mentioning IAM-auth support, a plain unauthenticated connection works by default; verified with the app's actual drivers (`pgx/v5`, `go-redis/v9`), not just `psql`/`redis-cli`
- **`aws_db_instance.postgres` needs `lifecycle { ignore_changes = [publicly_accessible] }`** — Floci's `DescribeDBInstances` always reports it `false` regardless of the configured value, causing a ~1m20s no-op "fix" on every `terraform apply` otherwise
- **`aws_s3_bucket` needs `force_destroy = true`** — real AWS S3 semantics (can't delete a non-empty bucket), faithfully reproduced by Floci
- **`redis_addr` output needs a fallback**: `primary_endpoint_address` is `null` for this replication group shape (a Floci quirk); `configuration_endpoint_address` is populated correctly
- **A forceful container removal (`docker rm -f`/`kill`) orphans RDS/ElastiCache child containers**; a graceful `docker compose down` (SIGTERM) does not — Floci's own shutdown cleanup handles that case fine

## Tradeoffs

- `infra-apply` takes ~25-90s (RDS creation/modification is the slow part) — noticeably slower than the old direct-compose Postgres/Redis, which started in seconds. Accepted: it's a one-time cost per session (`make dev-up`), not per-request
- Local Terraform (`terraform/local/`) is not designed to share modules with a future production Terraform setup — deliberately deferred (see ADR-0002's still-standing YAGNI reasoning) until a real AWS environment is actually being built
- Redis cache data does not survive a Floci restart (even with cluster mode enabled) — acceptable since it's cache/queue/pub-sub, never source of truth here

## Consequences

- New service versions/config for RDS/ElastiCache/S3 are changed in exactly two places: `oops-infra-v1/docker/dev/compose.yaml` (Floci image/env) and `oops-infra-v1/terraform/local/*.tf` (resource config)
- `oops-api-v1` developers run `make dev-up` (or `docker-up` then `infra-apply`) instead of a single `docker-up` — an extra step, but explicit rather than a hidden side effect
- `oops-infra-v1/terraform/local/` state is local-only, gitignored, never shared — each developer provisions their own

---
