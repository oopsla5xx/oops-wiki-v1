# Conventions

<!-- Each rule: clear name, ❌ (wrong) and ✅ (correct) examples, short rationale -->
<!-- Remove sections not relevant to your project -->

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
