# Domain Glossary

Business/domain terms for the Oops platform, shared across every repo (`oops-api-v1`, `oops-web-v1`, `oops-infra-v1`, `oops-agent-v1`). Agents read this to use the correct name for a concept instead of inventing a new one. This is the single copy — no repo should keep its own version; see `docs/agent-context/authority.md`.

Source: `PRD.md` and `docs/architecture/system-design/system-design.md`. Extend this file as new terms are established there; do not invent a term here that those documents don't back.

---

**Workspace** — the multi-tenant top-level container: members, roles, projects, the Knowledge Graph, AI memory, and integrations. One workspace can hold many projects.

**Project** — a unit of work inside a Workspace holding Requirements, Business Rules, Flows, Components, APIs, Database design, Test Cases, and Documentation — all as Semantic Entities.

**Semantic Entity** — the unit of content the platform stores (a requirement, business rule, flow, API definition, etc.), as opposed to a diagram or document. A diagram is just a view over semantic entities and their relations; the entity is the source of truth. See PRD.md §5.

**Semantic Model** — the overall scheme of semantic entities and their typed relations (e.g. a `business_rule` entity related to an API, a UI, and a test case). Distinguish from **Knowledge Graph**, which is the traversable structure built from these relations.

**Knowledge Graph** — the graph of relations between semantic entities, used for context retrieval (instead of embeddings/vector search — see `system-design.md`). The canonical relation chain: Requirement → Business Rule → Flow → API → Database → Component → Test Case.

**Draft / Publish** — the lifecycle status of an AI-generated semantic entity. `oops-agent` always creates entities as `draft`; a human must explicitly publish before the entity is considered accepted. Do not treat a `draft` entity as authoritative content.

**Role** — one of the AI agent personas the platform supports (Product Manager, Designer, Software Architect, Developer, QA Engineer, DevOps Engineer). `oops-agent-v1` runs one shared LangGraph graph parameterized by role, not one graph per role.
