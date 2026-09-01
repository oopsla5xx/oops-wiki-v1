# Commands

Every agent reads this file to know the specific commands for this project. Do not guess, do not hardcode.

This repo (`oops-wiki-v1`) is the workspace root — docs, PRD, ADRs, and git
submodule links only. It has no build/test/lint/dev commands of its own.

For actual commands, go into the submodule you're working on and read its
own `.ai/commands.md`:

- `oops-web-v1/.ai/commands.md`
- `oops-api-v1/.ai/commands.md`
- `oops-agent-v1/.ai/commands.md` (if present)
- `oops-infra-v1` (Terraform + Docker Compose — no `.ai/` yet)

## Submodule setup

```bash
git submodule update --init
```

---
<!-- Add project-specific commands below using the same format -->
