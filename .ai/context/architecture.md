# Architecture

## What this project is

Oops is an AI-native Software Development Workspace that unifies the whole
SDLC into one system, managing artifacts as a Semantic Model instead of
scattered documents. `oops-wiki-v1` is the workspace root: it holds the
shared docs (PRD, ADRs, engineering standards) and links the four project
repos below as git submodules. Full spec: [`PRD.md`](../../PRD.md), detailed
architecture: [`docs/architecture/system-design/system-design.md`](../../docs/architecture/system-design/system-design.md).

## Stack

This root repo has no code of its own. It links 4 independently
released repos:

| Repo | Stack | Responsibility |
|---|---|---|
| `oops-web-v1` | Next.js + React | Frontend (SSR) |
| `oops-api-v1` | Go + Gin + DDD modular monolith | Backend API — single source of truth for domain data |
| `oops-agent-v1` | FastAPI + LangGraph | AI agent service (PM/Architect/Developer/QA/DevOps roles, one shared graph) |
| `oops-infra-v1` | Terraform + AWS, Docker Compose | Production infra + shared local dev/test infra |

Data stores (owned exclusively by `oops-api`):
- PostgreSQL — identity, RBAC, graph structure (system of record for relations)
- MongoDB / Amazon DocumentDB — versioned content (canvas, entity bodies)
- Redis — cache, job queue, WebSocket pub/sub
- S3 — attachments (presigned upload, browser → S3 direct)

## Module structure

```
.
├── PRD.md                    # product vision, architecture, repo strategy (source of truth)
├── docs/
│   ├── architecture/system-design/system-design.md  # concrete architecture decisions (v1)
│   ├── conventions.md        # points to .ai/context/conventions.md
│   └── github/                # branch protection rulesets per repo
├── .ai/                       # AI agent context (this directory) + decisions/ (ADRs)
├── oops-web-v1/                # submodule: frontend
├── oops-api-v1/                # submodule: backend API
├── oops-agent-v1/               # submodule: AI agent service
└── oops-infra-v1/               # submodule: infra
```

Each submodule repo has its own `.ai/`, README, and dev setup — read the
submodule's own context files when working inside it.

## Main data flows

From `docs/architecture/system-design/system-design.md`:

**Request path:** `oops-web` (Next.js SSR) talks to `oops-api` (Go/Gin) over
public REST and WebSocket (realtime). `oops-web` and `oops-agent` never
connect to a database directly — only `oops-api` reads/writes Postgres and
MongoDB/DocumentDB.

**AI agent job flow:**
```
oops-web  --POST /projects/:id/agent-jobs-->  oops-api --enqueue--> Redis
Redis --pop job--> oops-agent
oops-agent --GET /internal/.../context (KG traversal)--> oops-api
oops-agent runs LangGraph (1 shared graph, role = param)
oops-agent --POST /internal/entities {status: draft}--> oops-api
oops-api --WebSocket job.completed--> oops-web
oops-web --PATCH /entities/:id/publish (human review)--> oops-api
```
AI-generated entities are always created as `draft`; a human must publish.

**Semantic entity write order:** MongoDB write first (content, with an
app-generated UUIDv7 id), then Postgres write (activates the entity in the
graph/RBAC). If the Postgres step fails, the Mongo doc is compensating-rolled-back.
This ordering avoids exposing a "ghost" entity that's visible via list APIs
before it has content.

## Module boundaries

- `oops-web` and `oops-agent` must never connect directly to Postgres/Mongo —
  all data access goes through `oops-api`.
- Inside `oops-api` (DDD modular monolith, modules under
  `internal/modules/`: `identity`, `workspace`, `project`, `semantic`,
  `knowledgegraph`, `collaboration`, `agentgateway`, `health`), a module must
  not call another module's database directly — it must go through that
  module's interface layer.
- `oops-agent` is not exposed via the public ALB — it only receives traffic
  from `oops-api` over internal VPC DNS (Cloud Map), and authenticates with a
  service-to-service token, not user JWTs.

## External dependencies

- AWS: CloudFront, ALB, ECS/Fargate (3 independent services: web, api,
  agent), RDS (PostgreSQL), Amazon DocumentDB (Mongo-API-compatible — avoid
  advanced aggregation operators like `$graphLookup`), ElastiCache (Redis), S3.
- No third-party IdP for auth — `oops-api` issues its own JWT (RS256 access
  token + Redis-backed revocable refresh token).
- No vector DB — AI context retrieval uses Knowledge Graph traversal
  (recursive Postgres CTE) instead of embeddings/similarity search.
