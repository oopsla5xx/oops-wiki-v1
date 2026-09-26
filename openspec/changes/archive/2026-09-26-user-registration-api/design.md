# Design

## Context

An uncommitted, in-progress implementation already exists in `oops-api-v1` at
`internal/modules/user/...` (handler, command, postgres repository, migration, tests) implementing a
bare-bones `POST /api/v1/users`. This change also moves the route to `POST /api/v1/auth/register` (under
a new `/auth` route group) so the upcoming login endpoint lives next to it as `/auth/login`, instead of
registration looking like resource-CRUD on `/users`. Beyond the route, it has three gaps this change
closes: (1) the module is named `user`
instead of `identity`, the name `system-design.md` §8 assigns to the module that will eventually hold
user + auth + JWT; (2) validation is `binding:"required"` only — no email format check, no password
policy beyond a bcrypt-truncation guard (`max=72`); (3) errors collapse into generic shared codes
(`CONFLICT`, `VALIDATION_ERROR`) that give the frontend no way to pick a specific i18n message, since
`oops-web-v1`'s `api-response.schema.ts` already treats `message` as ignorable and reads only `error.code`.
See `proposal.md` for why this matters now.

The `users` table migration (`20260925015158_create_users_table.sql`) already matches the schema this
change assumes (`first_name, last_name, username, email, password_hash, created_at, updated_at,
deleted_at` with partial-unique indexes on `username` and `email`) — no migration change is needed.

## Goals / Non-Goals

**Goals:**
- Rename the module to `identity` and land registration inside it as the first capability.
- Make validation and the error contract match specs/identity/user-registration/spec.md exactly.
- Normalize email/username case so uniqueness can't be bypassed by letter-case alone.
- Tighten password hashing cost to a modern default.

**Non-Goals:**
- Login, JWT issuance, refresh tokens (separate future change; `identity` module will hold it later).
- Workspace bootstrap/auto-join on registration (separate future change).
- Email verification (explicitly deferred past MVP per proposal).
- Rate limiting / bot mitigation on the endpoint (not raised as a requirement for this change; revisit if
  abuse is observed).

## Decisions

**Route: `POST /api/v1/auth/register`, under a new `/auth` group.** Not `/users` — registration isn't
resource-CRUD on a `users` collection, it's an entry point into auth, and the upcoming login endpoint
belongs right next to it (`/auth/login`). The `identity` module's `Register(rg)` creates its own `/auth`
subgroup rather than mounting directly on `v1`, so login lands in the same group later without another
routing rework.

**Module rename `user` → `identity`.** Matches `system-design.md` §8, which already names this module
`identity` (user, auth, JWT). Renaming now avoids a second rename later when login/JWT lands in the same
module. All internal references (`internal/app/router.go`, `module.go` package path) move in the same
commit — no compatibility shim, since nothing external depends on the Go package path.

**Error shape: per-rule code + `field`, not a field-errors array.** Extend `response.ErrorInfo`
(`internal/shared/response/response.go`) with an optional `Field string \`json:"field,omitempty"\`` next
to the existing `Code`/`Message`. Add five new codes to `internal/shared/constants/error_code.go`:
`EMAIL_ALREADY_TAKEN`, `USERNAME_ALREADY_TAKEN`, `INVALID_EMAIL_FORMAT`, `INVALID_USERNAME_FORMAT`,
`PASSWORD_TOO_WEAK`. Chosen over a field-errors array because this endpoint only ever fails on one field
at a time (first validation error wins) — an array would model a case that can't occur here, and the
frontend already reads `error.code` as a scalar.

**Password policy: length only, no denylist.** Minimum 10 characters (kept: `max=72` guards bcrypt's
silent truncation past 72 bytes). No forced character-class composition (uppercase/digit/symbol rules) —
current NIST 800-63B guidance treats those as adding user friction without materially improving actual
password strength; length is the baseline kept for this change. A common/breached-password denylist was
implemented and then explicitly dropped by the user — out of scope for now; revisit (static bundled list,
or a live breach-check API like HaveIBeenPwned's k-anonymity endpoint) if account-takeover incidents show
the gap matters in practice.

**Bcrypt cost 10 → 12.** `internal/shared/password` currently calls `bcrypt.GenerateFromPassword(...,
bcrypt.DefaultCost)` (cost 10, chosen in 2002). Bump to a fixed constant `12`, in line with current OWASP
guidance for commodity hardware. Trade-off accepted below.

**Email/username normalization: lowercase before compare and store.** Done at the point both are first
handled (`CreateUserCommand` / request mapping), not via a Postgres `citext` column — avoids adding a new
Postgres extension dependency for what a `strings.ToLower` already solves, and the existing partial
unique indexes stay correct once both columns only ever hold lowercased values.

## Risks / Trade-offs

- **No common/breached-password check** — a weak-but-technically-10+-character password like
  `password123` is accepted → acceptable for now per explicit scope decision; revisit (see Password
  policy decision above) if this proves to matter in practice.
- **Bcrypt cost 12 costs more CPU per hash/verify** than cost 10 → acceptable; registration and (future)
  login are not high-QPS paths, and this is the standard modern trade-off of security for latency.
- **Module rename touches every import of the old path** (`router.go`, `module.go`, both test files) →
  mitigated by doing the rename as the first task, before any new behavior is added, so the diff for the
  rename itself stays mechanical and reviewable separately from the behavior changes.
- **No production data exists yet** for this table (migration hasn't run in production) → the case-fold
  normalization and any earlier test-inserted data need no backfill.

## Migration Plan

No user-facing or production data migration — this capability has not shipped. Implementation order
(detailed in `tasks.md`): rename module → add normalization + validation + new error codes → update
`system-design.md` → verify against specs. No feature flag or phased rollout needed since nothing
depends on the current `user`-named module yet.

