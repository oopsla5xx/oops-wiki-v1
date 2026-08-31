#!/bin/bash
# Detect which .ai/ context files are potentially stale.
# Run from project root. Output is structured for agent consumption.
#
# Exit codes: 0 = all fresh, 1 = at least one stale signal found

set -uo pipefail

AI_DIR=".ai"
STALE=0

# Portable mtime display
file_age() {
  local f="$1"
  date -r "$f" "+%Y-%m-%d %H:%M" 2>/dev/null \
    || stat -c "%y" "$f" 2>/dev/null | cut -d'.' -f1 \
    || echo "unknown"
}

echo "=== FILE AGES ==="
for f in \
  "$AI_DIR/commands.md" \
  "$AI_DIR/context/architecture.md" \
  "$AI_DIR/context/conventions.md"
do
  if [ -f "$f" ]; then
    echo "$f  →  $(file_age "$f")"
  else
    echo "$f  →  MISSING"
  fi
done

# ── commands.md ──────────────────────────────────────────────────────────────

echo ""
echo "=== STALE SIGNALS: commands.md ==="
TRIGGERS_CMD=(package.json Makefile Cargo.toml pyproject.toml go.mod build.gradle build.gradle.kts)
FOUND_CMD=0
if [ -f "$AI_DIR/commands.md" ]; then
  for src in "${TRIGGERS_CMD[@]}"; do
    if [ -f "$src" ] && [ "$src" -nt "$AI_DIR/commands.md" ]; then
      echo "STALE  $src is newer than commands.md"
      FOUND_CMD=1
      STALE=1
    fi
  done
  [ "$FOUND_CMD" -eq 0 ] && echo "OK  no trigger files changed"
else
  echo "MISSING  commands.md not found — run /setup-ai-context first"
fi

# ── architecture.md ──────────────────────────────────────────────────────────

echo ""
echo "=== STALE SIGNALS: architecture.md ==="
if [ -f "$AI_DIR/context/architecture.md" ]; then
  FOUND_ARCH=0

  # New top-level dirs not mentioned in the file
  while IFS= read -r dir; do
    name=$(basename "$dir")
    if ! grep -qF "$name" "$AI_DIR/context/architecture.md" 2>/dev/null; then
      echo "STALE  new directory '$dir' not mentioned in architecture.md"
      FOUND_ARCH=1
      STALE=1
    fi
  done < <(find . -maxdepth 2 -mindepth 1 -type d \
    -not -path './.git' -not -path './.git/*' \
    -not -path './node_modules' -not -path './node_modules/*' \
    -not -path './.venv' -not -path './.venv/*' \
    -not -path './target' -not -path './target/*' \
    -not -path './dist' -not -path './dist/*' \
    -not -path './.next' -not -path './.next/*' \
    -not -path './.ai' -not -path './.ai/*' \
    -not -path './.claude' -not -path './.claude/*' \
    2>/dev/null | sort)

  # README changed since last update
  if [ -f README.md ] && [ README.md -nt "$AI_DIR/context/architecture.md" ]; then
    echo "STALE  README.md is newer than architecture.md"
    FOUND_ARCH=1
    STALE=1
  fi

  [ "$FOUND_ARCH" -eq 0 ] && echo "OK  no structural changes detected"
else
  echo "MISSING  architecture.md not found — run /setup-ai-context first"
fi

# ── conventions.md ───────────────────────────────────────────────────────────

echo ""
echo "=== STALE SIGNALS: conventions.md ==="
TRIGGERS_CONV=(
  .eslintrc .eslintrc.js .eslintrc.json .eslintrc.yaml
  .prettierrc .prettierrc.js .prettierrc.json
  biome.json tsconfig.json
  ruff.toml .ruff.toml
  .rubocop.yml
  .editorconfig
  golangci.yml .golangci.yml
)
FOUND_CONV=0
if [ -f "$AI_DIR/context/conventions.md" ]; then
  for src in "${TRIGGERS_CONV[@]}"; do
    if [ -f "$src" ] && [ "$src" -nt "$AI_DIR/context/conventions.md" ]; then
      echo "STALE  $src is newer than conventions.md"
      FOUND_CONV=1
      STALE=1
    fi
  done
  [ "$FOUND_CONV" -eq 0 ] && echo "OK  no linting config changes"
else
  echo "MISSING  conventions.md not found — run /setup-ai-context first"
fi

# ── git log summary (if available) ───────────────────────────────────────────

echo ""
echo "=== RECENT GIT CHANGES (last 10 commits) ==="
if git rev-parse --git-dir > /dev/null 2>&1; then
  git log --oneline -10 --name-status 2>/dev/null \
    | grep -E "^[MAD]\s" \
    | awk '{print $2}' \
    | grep -v node_modules \
    | sort -u \
    | head -30 \
    || echo "(no changes or empty repo)"
else
  echo "(not a git repo)"
fi

exit $STALE
