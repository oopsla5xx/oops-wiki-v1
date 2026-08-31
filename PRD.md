# Product Requirements Document (PRD)

# Product Name

## Oops *(Working Name)*

## 1. Product Vision

Oops là một nền tảng **AI-native Software Development Workspace** giúp
hợp nhất toàn bộ SDLC (Software Development Life Cycle) vào một hệ thống
thống nhất.

Oops quản lý các artifact dưới dạng **Semantic Model** thay vì các tài
liệu rời rạc, cho phép AI và con người cùng cộng tác trên một nguồn dữ
liệu duy nhất.

Các vai trò được hỗ trợ:

* Product Manager
* Designer
* Software Architect
* Developer
* QA Engineer
* DevOps Engineer

---

## 2. Problem Statement

Các nhóm phát triển hiện nay phải sử dụng nhiều công cụ:

| Artifact    | Tool                |
| ----------- | ------------------- |
| Requirement | Jira / Notion       |
| Flow        | Draw.io / Whimsical |
| UI          | Figma               |
| API         | Swagger / Postman   |
| Code        | GitHub              |
| Testing     | TestRail, Zephyr    |

Điều này dẫn đến:

* Không có Single Source of Truth.
* Documentation nhanh lỗi thời.
* AI thiếu business context.
* Khó trace từ Requirement → Code → Test.

---

## 3. Product Goals

* Xây dựng AI-native workspace cho SDLC.
* Mọi artifact đều có quan hệ ngữ nghĩa (Semantic Relationship).
* AI có thể hiểu toàn bộ project context.
* Tự động phân tích impact khi requirement thay đổi.
* Giảm effort trong việc tạo và duy trì tài liệu.

---

## 4. Core Concepts

### Workspace (Multi-tenant)

* Members
* Roles
* Projects
* Knowledge Graph
* AI Memory
* Integrations

### Project

* Requirements
* Business Rules
* Flows
* Components
* APIs
* Database
* Test Cases
* Documentation

---

## 5. Semantic Model

Diagram chỉ là cách hiển thị.

Oops lưu semantic entity:

```json
{
  "type": "business_rule",
  "name": "Order Cancellation",
  "relations": [
    "API",
    "UI",
    "TestCase"
  ]
}
```

---

## 6. Knowledge Graph

Requirement

↓

Business Rule

↓

Flow

↓

API

↓

Database

↓

Component

↓

Test Case

---

## 7. MVP

### Phase 1

* Authentication
* Workspace
* Members
* Roles
* Projects

### Phase 2

* Infinite Canvas
* Semantic Nodes
* Relationships
* Versioning
* Comments

### Phase 3

* Knowledge Graph
* Traceability
* Dependency Analysis

### Phase 4

* AI Copilot
* Spec Generation
* Flow Generation
* Impact Analysis

---

## 8. AI Agents

* PM Agent
* Architect Agent
* Developer Agent
* QA Agent
* DevOps Agent

---

## 9. Technology Stack

### Frontend

* Next.js
* React
* TypeScript
* React Flow
* Zustand
* Tailwind CSS
* shadcn/ui

### Core Backend

* Go
* Gin
* Domain Driven Design
* Modular Monolith

### AI Platform

* Python
* FastAPI
* Domain Driven Design
* LangGraph
* LangChain

---

## 10. Database

### PostgreSQL

* Users
* Workspace
* Project
* Permission
* Billing
* Metadata
* Relationships

### MongoDB

* Canvas State
* Flow Structure
* UI Tree
* Design Artifacts
* AI Generated Documents

### Redis

* Cache
* Session
* Realtime
* Queue

### Amazon S3

* Images
* Attachments
* Generated Assets

---

## 11. Repository Strategy

Oops sử dụng mô hình **Multi Repository**.

Các repository được quản lý độc lập:

```text
oops-web
oops-api
oops-agent
oops-infra
oops-wiki
```

Mỗi repository có trách nhiệm riêng:

### oops-web

Next.js + React

### oops-api

Go + Gin + DDD

### oops-agent

FastAPI + LangGraph

### oops-infra

Terraform + AWS (production infrastructure), và Docker Compose cho shared
local dev/test infrastructure (Postgres, Redis — dùng chung giữa oops-api
và oops-agent). Chi tiết: `.ai/decisions/0002-shared-local-infra-in-oops-infra.md`.

### oops-wiki

Chứa tài liệu dùng chung:

* PRD
* ADR
* Technical Design
* Engineering Standards
* Project Knowledge

`oops-wiki` là workspace root, gắn 4 repository kia (`oops-api`, `oops-agent`,
`oops-web`, `oops-infra`) làm **git submodule** — không phải symlink filesystem.
Mỗi repo vẫn được quản lý độc lập (remote, lịch sử commit riêng), nhưng được
checkout thành sibling directory bên trong `oops-wiki` để AI agent và con người
có system-level context khi làm việc.

Ví dụ:

```text
oops-wiki/                  # workspace root, git repo
├── PRD.md, docs/, ...
├── oops-api-v1/             # git submodule → repo riêng
├── oops-agent-v1/           # git submodule → repo riêng
├── oops-web-v1/             # git submodule → repo riêng
└── oops-infra-v1/           # git submodule → repo riêng
```

Clone workspace:

```bash
git clone git@github.com:oopsla5xx/oops-wiki-v1.git
cd oops-wiki-v1
git submodule update --init
```

---

## 12. AWS Infrastructure

* CloudFront
* Application Load Balancer
* ECS/Fargate
* Amazon RDS PostgreSQL
* MongoDB Atlas / Amazon DocumentDB
* ElastiCache Redis
* Amazon S3
* CloudWatch

---

## 13. Architecture Principles

* Single Source of Truth
* Semantic First
* Version Everything
* AI as Collaborator
* Right Storage for Right Data
* Contract First
* Independent Repositories

---

## 14. Success Metrics

* Active Workspaces
* Active Projects
* AI Usage
* Traceability Coverage
* Documentation Accuracy
* Delivery Time Reduction

---

## 15. Long-term Vision

Oops trở thành nền tảng AI-native Semantic Engineering Workspace, nơi
mọi artifact của SDLC đều được liên kết bằng mô hình ngữ nghĩa và AI có
thể hỗ trợ toàn bộ vòng đời phát triển phần mềm.
