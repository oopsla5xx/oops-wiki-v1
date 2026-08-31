---
name: debug
description: Systematic bug investigation workflow. Tool-agnostic but MCP-aware — test cases and MCP tools are evidence sources, not prerequisites. Applies to any stack (frontend, backend, CLI, mobile, distributed systems).
---

# Debug

Debugging is an **investigation**, not a guessing game. Every step produces evidence that either confirms or eliminates a hypothesis. Do not write a single line of fix code until the root cause is confirmed.

---

## Workflow

```
Bug report
    │
    ▼
1. REPRODUCE   →  establish ground truth
    │
    ▼
2. REDUCE      →  isolate the minimal case
    │
    ▼
3. OBSERVE     →  collect evidence
    │
    ▼
4. HYPOTHESIZE →  form ranked candidates
    │
    ▼
5. EXPERIMENT  →  eliminate candidates one by one
    │
    ▼
6. ROOT CAUSE  →  confirm with evidence, not intuition
    │
    ▼
7. FIX         →  smallest change that removes the root cause
    │
    ▼
8. VERIFY      →  rerun the original reproduction, confirm clean
```

---

## Step-by-step

### 1. Reproduce

**Goal:** establish a reliable way to trigger the bug before touching any code.

Priority order:
1. If a **use case / test case** already exists → run it and confirm it fails
2. If no test exists → create a minimal reproduction first, then proceed
3. If the bug is intermittent → reproduce it at least 3 times before continuing

> A bug you cannot reproduce reliably is a bug you cannot verify you fixed.

### 2. Reduce

**Goal:** strip the reproduction down to the smallest input / fewest steps that still triggers the bug.

Techniques:
- Remove unrelated inputs, routes, or modules one by one
- Isolate a single HTTP request, function call, or UI interaction
- Comment out surrounding code until the bug disappears, then add back the minimum
- Binary-search the commit history (`git bisect`) if the regression is recent

A reduced case makes the root cause obvious and the fix precise.

### 3. Observe

**Goal:** collect raw evidence without interpretation yet.

Collect what is relevant to the bug's layer:

| Layer | Evidence sources |
|---|---|
| UI / browser | console errors, network tab, DOM state, screenshots, layout |
| API / HTTP | request/response payload, status codes, headers, timing |
| Server / backend | application logs, stack traces, slow query logs |
| Data | database state before/after, cache contents |
| System | memory usage, CPU, file descriptors, environment variables |

**Tool-agnostic collection** — use whatever is available in the current environment:

- Playwright MCP, Chrome DevTools MCP, or browser devtools → UI/network evidence
- Server log tailing, `curl`, `httpie` → API evidence
- Database client, ORM query logging → data evidence
- `console.log` / structured logging → runtime state

Do not commit to a hypothesis during this step. Collect first, interpret later.

### 4. Hypothesize

**Goal:** form a ranked list of candidate root causes based on the evidence.

Format:
```
H1 (most likely): [cause] — because [evidence that points here]
H2: [cause] — because [evidence]
H3: [cause] — because [evidence]
```

Rules:
- Each hypothesis must be falsifiable (you can design an experiment to disprove it)
- Start with the layer closest to the symptom, then work outward
- A hypothesis that cannot be tested is not a hypothesis — it is a guess

### 5. Experiment

**Goal:** eliminate hypotheses one by one, starting from H1.

For each hypothesis:
1. Design the **smallest possible experiment** that would disprove it
2. Run it
3. Record the result — confirmed or eliminated
4. Move to the next hypothesis

Do not move to Fix until all alternatives are eliminated and one hypothesis stands alone.

### 6. Root Cause

**Goal:** state the root cause with supporting evidence, not intuition.

Required format before writing any fix:
```
Root cause: [precise statement]
Evidence: [the specific observation that confirms it]
Layer: [where in the stack the defect lives]
```

If you cannot fill in all three fields, you have not found the root cause yet — return to Observe or Experiment.

### 7. Fix

**Goal:** remove the root cause with the smallest possible change.

Rules:
- Fix only the root cause — do not refactor surrounding code unless it is part of the cause
- If the fix touches > 3 files, question whether you have correctly identified the root cause
- If there was no test covering this case → add one now (the reproduction from Step 1 becomes the regression test)
- Do not change unrelated behavior

### 8. Verify

**Goal:** confirm the bug is gone and nothing else broke.

Checklist:
```
[ ] Original reproduction: now passes (or no longer triggers the bug)
[ ] Regression test (if added): green
[ ] Full test suite: green
[ ] Adjacent behavior: manually spot-checked for side effects
[ ] Evidence collected in Step 3: all anomalies are now explained or resolved
```

Only after all checks pass: declare the bug fixed.

---

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| Fix before reproducing | You cannot verify a fix for a bug you cannot trigger |
| Skip Reduce | Large reproduction hides the real cause; fix is often wrong |
| Skip Hypothesize | Random code changes waste time and may introduce new bugs |
| "I think it's probably X" without evidence | Intuition without evidence is noise |
| Fix symptoms instead of root cause | Bug comes back |
| Declare done before verifying | Bug ship rate increases |

---

## Quick reference

```
Can I reproduce it?          → No: find reproduction first
Can I reduce it further?     → Yes: keep reducing
Do I have a hypothesis?      → No: observe more
Is my hypothesis falsifiable? → No: rephrase or discard it
Is the root cause confirmed?  → No: experiment more
Is my fix minimal?           → No: trim it
Is the original repro green? → No: you are not done
```
