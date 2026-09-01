# Conventions

<!-- Each rule: clear name, ❌ (wrong) and ✅ (correct) examples, short rationale -->
<!-- Remove sections not relevant to your project -->

This root repo (`oops-wiki-v1`) has no linter/formatter config and no code of
its own — no stack-specific conventions were detected to auto-fill here.
Language/framework conventions (Go, TypeScript, Python) belong in each
submodule's own `.ai/context/conventions.md`.

One cross-repo rule from `docs/architecture/system-design/system-design.md`
§8: inside `oops-api`, a module must never call another module's database
directly — only through that module's interface layer (see
[architecture.md](./architecture.md#module-boundaries)).

---

## Error Handling

### Rule: Do not silently swallow errors

❌
```typescript
try {
  await doSomething()
} catch (e) {
  // ignore
}
```

✅
```typescript
try {
  await doSomething()
} catch (e) {
  logger.error('doSomething failed', { error: e, context: ... })
  throw e // or handle specifically
}
```

**Rationale:** Swallowed errors lose the trace, making debugging very difficult later.

---

## Naming

### Rule: <!-- TODO: add the project's naming rule -->

❌
```
// wrong example
```

✅
```
// correct example
```

---

## Data Access

### Rule: <!-- TODO: add rule for how to access database/store -->

---

## API / Interface

### Rule: <!-- TODO -->

---

## Testing

### Rule: <!-- TODO: unit test or integration test? where to mock, where not to mock? -->

---

<!-- Add new rule groups using the same format -->
