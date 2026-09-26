# Proposal

## Why

`oops-api-v1` has no way for a person to create an account yet — a prerequisite for login, workspace
onboarding, and every authenticated capability planned for Phase 1. Work toward this already started
uncommitted in the repo (`internal/modules/user/...`, a `users` migration) but has gaps against modern
security practice (weak validation, generic error codes the frontend can't map to distinct i18n
messages) and drifts from `system-design.md` (module name, DB schema). This change closes both gaps and
formalizes the registration contract before it's built on top of.

## What Changes

- Add `POST /api/v1/auth/register` — creates a user account (first name, last name, username, email,
  password). Grouped under `/auth` (not `/users`) so the upcoming login endpoint (`/auth/login`) sits
  next to it consistently — both are entry points into the `identity` module's auth surface, not
  resource-CRUD on `/users`.
- Rename `internal/modules/user` → `internal/modules/identity`, matching `system-design.md` §8 (single
  module for user + future auth/JWT).
- Add real validation on top of `binding:"required"`:
  - Email: valid email format.
  - Username: fixed allowed character set + length bounds (not just non-empty).
  - Password: minimum length (modern length-based policy, no forced character-class composition).
- Replace generic error codes (`CONFLICT`, `VALIDATION_ERROR`) for this endpoint with rule-specific codes
  carrying a `field` name, so the frontend can map `code` → its own localized message without parsing
  `message` text (`EMAIL_ALREADY_TAKEN`, `USERNAME_ALREADY_TAKEN`, `INVALID_EMAIL_FORMAT`,
  `INVALID_USERNAME_FORMAT`, `PASSWORD_TOO_WEAK`).
- Registration explicitly does **not**: create or join a workspace, send/require email verification, or
  return a JWT/session — the client calls a separate (future) `/login` endpoint to obtain a token.
  Out of scope for this change: login itself, JWT issuance, workspace bootstrap, email verification.
- Update `docs/architecture/system-design/system-design.md` §3.1 `users` schema to match the actual
  columns (`first_name`, `last_name`, `username`, `updated_at`, `deleted_at` — not just
  `id, email, password_hash, created_at`).

## Capabilities

### New Capabilities
- `identity/user-registration`: account creation via `POST /api/v1/auth/register` — request validation, password
  hashing, uniqueness enforcement, and the error contract the frontend consumes.

### Modified Capabilities
None — no existing spec capability covers user/identity today.

## Impact

- **oops-api-v1**: `internal/modules/user` → `internal/modules/identity` (rename + rework), request
  validation, error mapping, `internal/shared/constants/error_code.go` (new codes), existing migration
  (`database/migrations/20260925015158_create_users_table.sql`) stays as-is (schema already matches this
  proposal).
- **oops-wiki-v1 docs**: `docs/architecture/system-design/system-design.md` §3.1 and §8 updated for the
  schema and confirmed module boundary.
- **oops-web-v1**: no code change required — its error schema already reads only `error.code` and ignores
  `message` (`src/schemas/api-response.schema.ts`); it will need the new codes added to
  `src/constants/error-codes.ts` when it builds the registration form (tracked as a task here, implemented
  there).
- No dependency on login/JWT/workspace work — those remain separate future changes.
