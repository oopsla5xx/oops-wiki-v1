---
name: setup-ai-context
description: Bootstrap .ai/ context files — auto-detect stack and fill commands.md, architecture.md, conventions.md instead of filling TODO placeholders manually. Run when setting up oops-skills template in a new project.
---

# Setup AI Context

Automatically fill in the 3 template files in `.ai/` by probing the project instead of filling them in manually.

**Do not write placeholders, do not guess.** Only fill in what can be found in the project.

---

## Run

### Step 1 — Run the detection script

```bash
bash .claude/skills/setup-ai-context/detect.sh
```

Read the entire output before proceeding to the next step.

### Step 2 — Fill in `.ai/commands.md`

Based on the `SCRIPTS` section in the output:

- Find the `test` command: prioritize scripts named `test`, `test:ci`, or direct test framework invocations
- Find the `build` command: scripts named `build`, `compile`, or equivalent
- Find the `lint` command: scripts named `lint`, `check`, or direct eslint/ruff/clippy calls
- Find the `typecheck` command: scripts named `typecheck`, `type-check`, `tsc`
- Find the `dev` command: scripts named `dev`, `start`, `serve`
- Find the `deploy` command: scripts named `deploy`, or related Makefile targets

For each command: if found → write the actual command to the file. If not present → remove that section (do not leave placeholders).

### Step 3 — Fill in `.ai/context/architecture.md`

Use the `README EXCERPT` and `TOP-LEVEL STRUCTURE` sections:

**What the project is**: taken from the beginning of the README (usually the first line after the title).

**Stack**: from the `STACK`, `FRAMEWORKS`, `DATABASE SIGNALS` sections.

**Module structure**: from `TOP-LEVEL STRUCTURE` — describe the 3-5 most important directories, skip `node_modules`, `dist`, `.git`, etc.

**Data flow**: if the README describes a flow → write it down. If not → leave this section with the comment `<!-- TODO: describe the main request/event flow -->` and notify the user.

**Module boundaries** and **External dependencies**: if the README does not mention them → leave as TODO and notify the user.

### Step 4 — Fill in `.ai/context/conventions.md`

Use the `LINTING / FORMATTING CONFIG` section:

- Has `biome.json` → write: "Formatter and linter: Biome. Run `biome check --apply`"
- Has `.eslintrc*` + `.prettierrc*` → write: "Lint: ESLint. Format: Prettier."
- Has `ruff.toml` → write: "Lint + format: Ruff."
- Has `.rubocop.yml` → write: "Lint: RuboCop."
- Has `.editorconfig` → read that file, extract indent_style and indent_size

Create an `Error Handling` rule skeleton based on the stack (see Gotchas below).
The `Naming`, `Data Access`, `Testing` sections → leave empty with `<!-- TODO -->` comment and notify the user they need to fill these in.

### Step 5 — Report results

Print:
- What was successfully filled in (with specific commands/values)
- Remaining TODOs that the agent cannot fill in automatically (data flow, business logic, naming conventions)

---

## Gotchas

**`node` not available:** The script uses `node -e` to parse JSON. If the project is non-Node and node is not available → the script will skip those sections. That is fine; the output is still useful from other sections.

**Monorepo:** Running `detect.sh` from the root will surface too much. If `TOP-LEVEL STRUCTURE` contains `apps/`, `packages/`, `services/` → ask the user which sub-project they want to set up `.ai/` for, then re-run from that directory.

**Sparse README:** Many projects have READMEs with only a few lines. In that case `architecture.md` will have many TODOs — this is expected behavior, not an error.

**Error Handling rule by stack:**
- Node.js/TS → example with `try/catch` and typed errors
- Python → example with `except Exception as e` and logging
- Rust → example with `Result<T, E>` and `?` operator
- Go → example with `if err != nil`
