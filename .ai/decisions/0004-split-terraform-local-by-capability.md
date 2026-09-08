# ADR-0004: Split `terraform/local/*.tf` by infra capability, not application domain

**Status:** Accepted
**Date:** 2026-09-08

---

## Context

`oops-infra-v1/terraform/local/main.tf` holds all three provisioned resources (S3 bucket, RDS instance, ElastiCache replication group) in one 33-line file (see [ADR-0003](0003-floci-local-aws-emulation.md) for why they exist). IAM policy resources are the next planned addition. Before that lands, decide how `terraform/local/*.tf` should be organized so growth doesn't keep piling into `main.tf`.

## Decision

Split `terraform/local/` by **infra capability**, not by application domain/feature:

```
terraform/local/
├── provider.tf     (existing, unchanged)
├── variables.tf    (new)
├── locals.tf       (new)
├── outputs.tf      (existing, stays centralized)
├── storage.tf      (aws_s3_bucket.attachments)
├── database.tf     (aws_db_instance.postgres)
├── cache.tf        (aws_elasticache_replication_group.redis)
└── identity.tf     (IAM policy resources, when added)
```

File names describe what the infra *is* (storage, database, cache, identity), not which application feature consumes it — one cache instance or one bucket can back multiple app features, so a domain-named file (`attachments.tf`, `users.tf`) would misattribute ownership as soon as a resource is reused. `variables.tf`/`outputs.tf` stay single centralized files even though resources are split — Terraform doesn't scope by file, and this matches standard Terraform layout convention.

`variables.tf` gets **only resource naming/credential values**, each with a default equal to its current hardcoded value (no behavior change): bucket name, DB identifier/name/username/password, ElastiCache replication group id. Floci-emulator-specific config (`us-east-1` fake region, `test`/`test` credentials, `http://localhost:4566` endpoint) stays hardcoded in `provider.tf` — it isn't something that should ever vary, and putting it in `variables.tf` would falsely imply otherwise.

`locals.tf` gets `name_prefix = "oops-dev"`, extracted because all three current resources already share that literal prefix — this is real, present duplication, not a placeholder for hypothetical future reuse.

No shared Terraform modules between `terraform/local/` and any future staging/prod environment. This split is scoped to `terraform/local/` only.

## Reasons

- IAM policy resources are concretely planned next — this isn't preemptive scaffolding, `main.tf` growth is imminent
- Infra capability naming survives application refactors; domain naming breaks the moment one resource serves more than one feature
- Promoting only naming/credentials to variables (not Floci's provider config) keeps the "what can legitimately change" boundary honest
- `name_prefix` as a local removes duplication that exists today, not duplication anticipated for later

## Tradeoffs

- This is a structure-only refactor: no resource is renamed or re-addressed, so it ships as its own PR ahead of `identity.tf`, verified by `terraform plan` reporting no changes
- Confirms and does not change ADR-0003's existing tradeoff: `terraform/local/` still isn't designed to share modules with a future production Terraform setup. Floci-emulated resources (no VPC, no multi-AZ, no KMS, fake credentials) don't share shape with real AWS resources — forcing a shared module now would mean conditional (`count = var.is_local ? 0 : 1`) branching to paper over that gap. Decide module extraction only once a real staging/prod environment actually exists and the real overlap is visible

## Consequences

- Adding a new provisioned resource means adding to (or creating) its capability file, not growing `main.tf` (which no longer exists after this refactor)
- Resource naming/credential values are changed in one place (`variables.tf`) instead of hunting through resource blocks
- `terraform/local/` and any future `terraform/staging/` or `terraform/prod/` remain independent until a real environment forces the module-sharing question

---
