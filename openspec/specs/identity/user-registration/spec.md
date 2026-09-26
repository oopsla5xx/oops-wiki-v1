# user-registration Specification

## Purpose

Lets a person create an `oops-api-v1` user account with a validated email, username, and password,
enforced as unique (case-insensitively) and immediately usable — without email verification or an
issued session — via a single registration endpoint.

## Requirements

### Requirement: Account Registration
The system SHALL allow creating a user account by submitting `username`, `email`, and `password` to
`POST /api/v1/auth/register`, returning the created account on success without ever exposing the
password or its hash. `first_name` and `last_name` are not collected at registration — they start
empty and are set later via profile update.

#### Scenario: Successful registration
- **WHEN** a client submits valid `username`, `email`, and `password`
- **THEN** the system creates the account, stores a hash of the password (never the plaintext), and
  responds `201 Created` with the account's `id`, `first_name` (empty), `last_name` (empty),
  `username`, `email`, `created_at`, and `updated_at` — with no password or password hash field
  present

### Requirement: Email Format Validation
The system SHALL reject a registration request whose `email` is not a syntactically valid email
address, before attempting to persist anything.

#### Scenario: Malformed email rejected
- **WHEN** a client submits an `email` that is not a valid email address format
- **THEN** the system responds `400 Bad Request` with error code `INVALID_EMAIL_FORMAT` and field
  `email`, and creates no account

### Requirement: Username Format Validation
The system SHALL require `username` to be 3–30 characters long and contain only lowercase letters,
digits, underscore, or hyphen.

#### Scenario: Invalid username format rejected
- **WHEN** a client submits a `username` shorter than 3 characters, longer than 30 characters, or
  containing a character outside `[a-z0-9_-]`
- **THEN** the system responds `400 Bad Request` with error code `INVALID_USERNAME_FORMAT` and field
  `username`, and creates no account

### Requirement: Password Strength Policy
The system SHALL require `password` to be at least 10 characters long.

#### Scenario: Password too short rejected
- **WHEN** a client submits a `password` shorter than 10 characters
- **THEN** the system responds `400 Bad Request` with error code `PASSWORD_TOO_WEAK` and field
  `password`, and creates no account

### Requirement: Case-Insensitive Email and Username Uniqueness
The system SHALL treat `email` and `username` as case-insensitive for both storage and uniqueness
comparison, so two registrations differing only by letter case for the same value are treated as
the same account.

#### Scenario: Duplicate differing only by case rejected
- **GIVEN** an account already exists with email `foo@example.com`
- **WHEN** a client submits a registration with email `Foo@Example.com`
- **THEN** the system responds `409 Conflict` with error code `EMAIL_ALREADY_TAKEN` and field `email`,
  and creates no account

### Requirement: Duplicate Account Rejection with Field-Specific Error Codes
The system SHALL reject registration when `email` or `username` is already taken, reporting which field
caused the conflict via a distinct error code.

#### Scenario: Email already registered
- **GIVEN** an account already exists with a given email
- **WHEN** a client submits a registration with that same email
- **THEN** the system responds `409 Conflict` with error code `EMAIL_ALREADY_TAKEN` and field `email`,
  and creates no account

#### Scenario: Username already taken
- **GIVEN** an account already exists with a given username
- **WHEN** a client submits a registration with that same username (different email)
- **THEN** the system responds `409 Conflict` with error code `USERNAME_ALREADY_TAKEN` and field
  `username`, and creates no account

### Requirement: No Workspace Side Effects
Registration SHALL NOT create, assign, or join the new account to any workspace.

#### Scenario: Registration does not create a workspace
- **WHEN** a client successfully registers a new account
- **THEN** no workspace, workspace membership, or role assignment is created as a result

### Requirement: No Email Verification Gate
A newly registered account SHALL be immediately usable — the system SHALL NOT place it in a
pending-verification state or require a verification step before it is otherwise usable.

#### Scenario: Account carries no pending-verification state
- **WHEN** a client successfully registers a new account
- **THEN** the returned account has no unverified/pending status blocking its use

### Requirement: No Session Issued on Registration
The registration response SHALL NOT include an access token, refresh token, or any other session
identifier.

#### Scenario: Registration response contains no token
- **WHEN** a client successfully registers a new account
- **THEN** the `201` response body contains no access token, refresh token, or session identifier field
