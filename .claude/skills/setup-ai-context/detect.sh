#!/bin/bash
# Run from project root to gather info for filling .ai/ templates.
# Output is structured for agent consumption.

set -euo pipefail

echo "=== STACK ==="
[ -f package.json ]       && echo "nodejs"
[ -f Cargo.toml ]         && echo "rust"
[ -f pyproject.toml ]     && echo "python"
[ -f setup.py ]           && echo "python"
[ -f go.mod ]             && echo "golang"
[ -f pom.xml ]            && echo "java (maven)"
[ -f build.gradle ]       && echo "java/kotlin (gradle)"
[ -f build.gradle.kts ]   && echo "kotlin (gradle)"
[ -f mix.exs ]            && echo "elixir"
[ -f Gemfile ]            && echo "ruby"

echo ""
echo "=== FRAMEWORKS (from package.json) ==="
if [ -f package.json ]; then
  node -e "
    const d = require('./package.json');
    const all = {...(d.dependencies||{}), ...(d.devDependencies||{})};
    const fw = ['next','react','vue','nuxt','svelte','express','fastify','nestjs','hono','remix','astro','solid-js'];
    fw.filter(k => all[k]).forEach(k => console.log(k + '@' + all[k]));
  " 2>/dev/null || true
fi

echo ""
echo "=== SCRIPTS (from package.json) ==="
if [ -f package.json ]; then
  node -e "
    const d = require('./package.json');
    Object.entries(d.scripts||{}).forEach(([k,v]) => console.log(k + ': ' + v));
  " 2>/dev/null || true
fi

echo ""
echo "=== SCRIPTS (from Makefile) ==="
if [ -f Makefile ]; then
  grep -E "^[a-zA-Z_-]+:" Makefile | sed 's/:.*//' | head -20
fi

echo ""
echo "=== SCRIPTS (from pyproject.toml / Cargo.toml) ==="
if [ -f pyproject.toml ]; then
  grep -A1 '^\[tool\.poetry\.scripts\]\|^\[project\.scripts\]' pyproject.toml 2>/dev/null || true
  grep -E '^\[tool\.(pytest|ruff|black|isort)\]' pyproject.toml 2>/dev/null | head -5 || true
fi
if [ -f Cargo.toml ]; then
  grep -E '^\[\[bin\]\]|^name\s*=' Cargo.toml 2>/dev/null | head -10 || true
fi

echo ""
echo "=== TEST FRAMEWORKS ==="
if [ -f package.json ]; then
  node -e "
    const d = require('./package.json');
    const all = {...(d.dependencies||{}), ...(d.devDependencies||{})};
    const tf = ['jest','vitest','mocha','jasmine','ava','tap','@playwright/test','cypress','@testing-library/react'];
    tf.filter(k => all[k]).forEach(k => console.log(k));
  " 2>/dev/null || true
fi
[ -f pyproject.toml ] && grep -oE 'pytest|unittest|nose' pyproject.toml 2>/dev/null || true
[ -f Cargo.toml ] && echo "cargo test (built-in)" 2>/dev/null || true

echo ""
echo "=== LINTING / FORMATTING CONFIG ==="
ls .eslintrc .eslintrc.js .eslintrc.json .eslintrc.yaml \
   .prettierrc .prettierrc.js .prettierrc.json \
   biome.json \
   tsconfig.json \
   ruff.toml .ruff.toml \
   .rubocop.yml \
   .editorconfig \
   golangci.yml .golangci.yml \
   clippy.toml 2>/dev/null || echo "(none found)"

echo ""
echo "=== TOP-LEVEL STRUCTURE ==="
find . -maxdepth 2 -type d \
  -not -path './.git' \
  -not -path './.git/*' \
  -not -path './node_modules' \
  -not -path './node_modules/*' \
  -not -path './.venv' \
  -not -path './.venv/*' \
  -not -path './target' \
  -not -path './target/*' \
  -not -path './dist' \
  -not -path './dist/*' \
  -not -path './.next' \
  -not -path './.next/*' \
  | sort

echo ""
echo "=== README EXCERPT (first 40 lines) ==="
if [ -f README.md ]; then
  head -40 README.md
elif [ -f README.rst ]; then
  head -40 README.rst
else
  echo "(no README found)"
fi

echo ""
echo "=== DATABASE SIGNALS ==="
if [ -f package.json ]; then
  node -e "
    const d = require('./package.json');
    const all = {...(d.dependencies||{}), ...(d.devDependencies||{})};
    const dbs = ['pg','postgres','mysql2','mongoose','prisma','drizzle-orm','@prisma/client','typeorm','sequelize','redis','ioredis'];
    dbs.filter(k => all[k]).forEach(k => console.log(k));
  " 2>/dev/null || true
fi
[ -f pyproject.toml ] && grep -oE 'sqlalchemy|psycopg|pymongo|redis' pyproject.toml 2>/dev/null || true
ls prisma/schema.prisma drizzle.config.ts drizzle.config.js 2>/dev/null || true
