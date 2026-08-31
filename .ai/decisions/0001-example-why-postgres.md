# ADR-0001: Use PostgreSQL as the primary database

**Status:** Accepted  
**Date:** 2025-01-15

---

## Context

The project needs to store data with complex relationships (user, order, product). There are two main options: PostgreSQL and MongoDB. The team is more familiar with SQL than NoSQL.

## Decision

Use PostgreSQL 15.

## Reasons

- Data has a fixed schema and clear relationships — the relational model fits better than the document model
- The team already has experience with SQL, low learning curve
- JSONB support is flexible enough for semi-structured fields if needed

## Tradeoffs

- Horizontal scaling is harder than MongoDB — acceptable because current traffic does not require it
- Schema migration requires more care — a migration review process before deployment is already in place

## Consequences

- All schema changes must go through a migration file, no direct edits allowed
- Complex queries use raw SQL instead of ORM to avoid N+1

---

<!-- Format for new ADRs:
     - File name: NNNN-slug-description.md (incrementing number)
     - Status: Proposed | Accepted | Deprecated | Superseded by ADR-XXXX
     - Keep it short: context + decision + reasons is enough
     - Clearly state accepted tradeoffs — this is the most important part
-->
