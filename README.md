# oops-wiki-v1

Workspace root for **Oops** — an AI-native Software Development Workspace that
unifies the whole SDLC into one system, managing artifacts as a Semantic
Model instead of scattered documents. Full spec: [`PRD.md`](./PRD.md).

This repo is the workspace root: it holds the shared docs (PRD, ADRs,
engineering standards) and links the four project repos below as **git
submodules**, so a clone of `oops-wiki-v1` gives you the whole system in one
place.

## Repositories

| Repo | Stack | Responsibility |
|---|---|---|
| [`oops-web-v1`](./oops-web-v1) | Next.js + React | Frontend |
| [`oops-api-v1`](./oops-api-v1) | Go + Gin + DDD | Backend API |
| `oops-agent-v1` | FastAPI + LangGraph | AI agent service |
| [`oops-infra-v1`](./oops-infra-v1) | Terraform + AWS, Docker Compose | Production infra + shared local dev/test infra |

Each repo is developed and released independently (own remote, own commit
history, own README with its dev setup). Open the linked README for the
one you're working on.

## Getting started

```bash
git clone git@github.com:oopsla5xx/oops-wiki-v1.git
cd oops-wiki-v1
git submodule update --init
```

Then follow the README of the repo you're working on (e.g. `oops-api-v1/README.md`)
for its own setup steps.

## Docs

- [`PRD.md`](./PRD.md) — product vision, architecture, repository strategy
- [`.ai/decisions/`](./.ai/decisions) — ADRs, key technical decisions
- [`docs/`](./docs) — engineering standards, conventions, git workflow

## AI Workflow

This workspace also carries a shared AI agent workflow (`.ai/` + `.claude/skills/`)
used across all four repos — spec-driven development, task planning, TDD
implementation, and self-check/ship gates. See [`docs/ai-workflow.md`](./docs/ai-workflow.md).
