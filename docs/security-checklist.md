# Security Checklist

Generic pre-ship checklist, applicable to any repo in this workspace. Stack-specific security notes (Go, Next.js, Terraform) live in each repo's own `docs/architecture/security.md` and reference this file rather than repeating it — see `docs/agent-context/authority.md`.

Use this before considering security-sensitive work done:

```
[ ] input-validation: User/external input is validated and constrained before use
[ ] authz-authn: Access control/authentication paths are correct for changed behavior
[ ] secrets: No hardcoded secrets/credentials/tokens in code, config, logs, or tests
[ ] data-access: No SQL/query string concatenation from untrusted input (use parameterization)
[ ] race-condition: Shared-state/concurrent flows are reviewed for race conditions and unsafe ordering
[ ] error-exposure: No stack traces/internal details exposed to end users
[ ] file-handling: If file upload/download is touched, type/size/path handling is validated
[ ] dependency-risk: If new dependencies are added, vulnerability check has been completed
```

Completion format (use this exact inline style for each checklist line):
- Applicable and verified: `[x] <item>: <existing checklist text>`
- Not applicable: `[x] <item>: N/A — <short reason>`

Example N/A entry:
`[x] file-handling: N/A — feature does not touch upload/download`

For the auth model itself (JWT, RBAC, service-to-service tokens), see `docs/architecture/system-design/system-design.md` §4 — this checklist is process, not architecture.
