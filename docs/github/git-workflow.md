# Git Workflow — Quality Gates

How code quality is enforced across `oops-api-v1` and `oops-web-v1`, on `main`, `develop`,
`hotfix/*`, and release tags (`v*`). Two layers: a local pre-push hook (fast, bypassable) and
GitHub Rulesets (real gate, enforced server-side).

---

## Layer 1 — Local pre-push hook

Runs automatically on `git push`. Catches most problems before they ever leave your machine.
Can be skipped with `git push --no-verify` — this is a convenience layer, not the real gate.

| Repo | Tool | Setup (once, after clone) | Runs on push |
|---|---|---|---|
| `oops-api-v1` | [Lefthook](https://github.com/evilmartians/lefthook) | `make setup` | `make lint` → `make test` |
| `oops-web-v1` | Husky (already wired via `prepare`) | `pnpm install` | `pnpm lint && pnpm typecheck && pnpm test && pnpm build` |

`oops-api-v1`'s hook deliberately skips `make test-cover` (needs Docker + Postgres/Redis
containers + migrations — too slow for every push) and skips a separate `go vet` (already
covered by `golangci-lint`'s default linters). The full gate — coverage ≥ 90%, staleness check
on generated mocks — still runs in CI. See `oops-api-v1/.ai/decisions/003-lefthook-pre-push-hook.md`.

---

## Layer 2 — GitHub Rulesets (the real gate)

`--no-verify` bypasses layer 1 entirely, so it doesn't stop a bad push on its own. This layer
enforces the same checks server-side, where they can't be skipped by a local flag.

Applied via the GitHub **Rulesets** UI (Settings → Rules → Rulesets) on both repos, 2026-08-31.
The applied config is exported to [`rulesets/*.json`](rulesets/) (sibling of this file) — that's
the source of truth for what's actually live; treat it like Terraform state, not a proposal.
Re-export after any change made in the UI so this stays accurate.

> The two `scripts/setup-branch-protection.sh` files inside each repo target the older, classic
> *branch protection* API (`PUT .../branches/<branch>/protection`), not Rulesets. They're
> superseded by the rulesets below — running them now would layer classic protection on top of
> the ruleset rather than change it. Kept only as a fallback reference; don't run them unless
> deliberately going back to classic branch protection.

### What's configured (from the exported JSON)

| Ruleset | Target | Approvals | Required status checks | Merge method | Notes |
|---|---|---|---|---|---|
| `oops-api-v1-main-protection` | branch `main` | 1, dismiss stale, **last-push approval required** | Test, Lint, Check generated mocks, Build | squash only | + linear history |
| `oops-api-v1-develop-protection` | branch `develop` | 1, dismiss stale | Test, Lint, Check generated mocks, Build | squash only | |
| `oops-api-v1-hotfix-protection` | branch `hotfix/*` | 1, stale reviews **not** dismissed | *(none)* | squash only | CI intentionally not gated — see Known issues |
| `oops-api-v1-release-protection` | tag `v*` | — | — | — | tag protection: no delete/force-update/create by non-bypass actors |
| `oops-web-v1-main-protection` | branch `main` | 1, dismiss stale, **last-push approval required** | quality | squash only | + linear history |
| `oops-web-v1-develop-protection` | branch `develop` | 1, dismiss stale | quality | squash only | |
| `oops-web-v1-hotfix-protection` | branch `hotfix/*` | 1, stale reviews **not** dismissed | *(none)* | squash only | CI intentionally not gated — see Known issues |
| `oops-web-v1-release-protection` | tag `v*` | — | — | — | tag protection: no delete/force-update/create by non-bypass actors |

All branch rulesets also block deletion and non-fast-forward pushes (no force-push). Bypass actor
on every ruleset: repository role id `5` (Admin) can always bypass — no rule is unconditionally
unbypassable, by design (someone needs an escape hatch).

### Known issues

**By design — `hotfix/*` has no required status checks, on both repos.** A hotfix PR merges on 1
approval alone; CI still runs (informational) but doesn't block the merge. Deliberate trade-off
for hotfix speed — documented here so it isn't mistaken for an oversight later.

A required-status-check naming bug on `oops-web-v1` (`main`/`develop` required 5 CI *step* names
instead of the actual job name `quality`, which would have blocked every PR forever) was found
and fixed 2026-08-31 — confirmed live via `gh api repos/oopsla5xx/oops-web-v1/rulesets/<id>`.
If a repo's CI workflow is ever restructured into multiple jobs (or a single job renamed), verify
required status checks still match real check-run names with:

```bash
gh api repos/oopsla5xx/<repo>/commits/main/check-runs -q '.check_runs[].name'
```
