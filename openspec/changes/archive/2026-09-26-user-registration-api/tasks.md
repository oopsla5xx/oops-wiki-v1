# Tasks

## 1. Module rename (`user` → `identity`)

- [x] 1.1 Rename `internal/modules/user/` to `internal/modules/identity/` (directory, package names, doc
      comments) and verify `make build` succeeds
- [x] 1.2 Update `internal/app/router.go` to import/register the renamed module and verify `make build`
      succeeds
- [x] 1.3 Change `Handler.Register` to mount a `/auth` subgroup on the given `*gin.RouterGroup` and
      register `POST /register` on it (so the full path is `/api/v1/auth/register`, not `/api/v1/users`);
      verify a handler test asserts `201` on `POST /auth/register` and `404` on the old `/users` path
- [x] 1.4 Update the two existing test files' imports and request paths
      (`application/command/create_user_test.go`, `interface/handler_test.go`) for the new package path
      and route, and verify `make test` still passes for this module

## 2. Docs sync

- [x] 2.1 Update `docs/architecture/system-design/system-design.md` §3.1 `users` schema block to list
      `first_name`, `last_name`, `username`, `updated_at`, `deleted_at` alongside the existing columns,
      matching `database/migrations/20260925015158_create_users_table.sql`

## 3. Input validation and normalization

- [x] 3.1 Add `binding:"email"` to the `Email` field in `createUserRequest`; verify a new handler test
      case submitting a malformed email gets `400` with code `INVALID_EMAIL_FORMAT` and field `email`
      (implemented as a `net/mail.ParseAddress` check in `interface/validate.go` rather than a gin
      binding tag, so the failure maps to the specific code instead of a generic bind error)
- [x] 3.2 Add username format validation (3–30 chars, `^[a-z0-9_-]+$`) enforced before the command runs;
      verify a new handler test case for an invalid username gets `400` with code `INVALID_USERNAME_FORMAT`
      and field `username`
- [x] 3.3 Normalize `email` and `username` to lowercase in `CreateUserCommand` before hashing/persisting;
      verify a unit test confirms the stored/returned value is lowercased and a registration differing
      only by case from an existing account is rejected as a duplicate

## 4. Password policy

- [x] 4.1 Add a `password.Validate(plain string) error` function in `internal/shared/password` enforcing a
      10-character minimum; verify a unit test rejects a 9-character password and accepts a 10-character
      one
- [x] 4.2 Change `password.Hash` to use a fixed bcrypt cost of `12` instead of `bcrypt.DefaultCost`;
      verify existing hash/verify unit tests still pass
- [x] 4.3 Call `password.Validate` from `CreateUserCommand` (or request-layer validation) before hashing,
      returning error code `PASSWORD_TOO_WEAK` with field `password` on failure; verify a handler test
      case for a too-short password gets `400` with that code

## 5. Error contract

- [x] 5.1 Add `Field string \`json:"field,omitempty"\`` to `response.ErrorInfo`
      (`internal/shared/response/response.go`); verify existing response/error tests still pass
- [x] 5.2 Add `EMAIL_ALREADY_TAKEN`, `USERNAME_ALREADY_TAKEN`, `INVALID_EMAIL_FORMAT`,
      `INVALID_USERNAME_FORMAT`, `PASSWORD_TOO_WEAK` to `internal/shared/constants/error_code.go`
- [x] 5.3 Update the identity module's error mapping so `ErrEmailTaken` → `EMAIL_ALREADY_TAKEN`
      (field `email`) and `ErrUsernameTaken` → `USERNAME_ALREADY_TAKEN` (field `username`), replacing the
      generic `CONFLICT` code; verify handler test asserts the exact code and field for each case

## 6. Spec conformance verification

- [x] 6.1 Extend `handler_test.go` to cover every scenario in
      `specs/identity/user-registration/spec.md`: successful registration response shape (no password/hash,
      no token field present), malformed email, invalid username, too-short password,
      case-differing duplicate email, duplicate username — run `make test` and confirm all pass
- [x] 6.2 Run `make lint` and `make build` and confirm both succeed (repo Definition of Done)
