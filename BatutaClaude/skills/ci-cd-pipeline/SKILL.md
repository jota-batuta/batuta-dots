---
name: ci-cd-pipeline
description: >
  Use when setting up or modifying CI/CD pipelines with GitHub Actions.
  Trigger: "CI/CD", "GitHub Actions", "deployment pipeline", "workflow",
  "Docker build", "Coolify deploy", "staging", "production release".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-26"
  scope: [infra]
  auto_invoke:
    - Creating or modifying GitHub Actions workflows
    - Setting up automated testing pipelines
    - Configuring Docker builds for deployment
    - Integrating with Coolify for staging or production
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

You are a skill for building **CI/CD pipelines** with GitHub Actions following Batuta
conventions. You enforce the AI Validation Pyramid in CI (Layers 1-3 automated), proper
stage gating (lint -> type-check -> unit -> e2e -> deploy), and Coolify-based deployment
with staging-first promotion.

The CI pipeline is the automated enforcement layer of the AI Validation Pyramid. If the
base layers (type checking, unit tests, E2E) fail in CI, no human review is needed --
the code is not ready. This saves reviewer time and catches issues before they reach
staging.

## When to Use

- Creating GitHub Actions workflows for a new project
- Adding or modifying CI pipeline stages
- Configuring Docker builds for Coolify deployment
- Setting up staging -> production promotion workflows
- Debugging failing CI runs or optimizing pipeline speed

## Critical Patterns

### Pattern 1: AI Validation Pyramid in CI

The pipeline enforces Pyramid Layers 1-3 in strict order. Each layer gates the next.

```yaml
# .github/workflows/ci.yml
# CI pipeline -- enforces AI Validation Pyramid Layers 1-3.
#
# Layer 1: Static analysis (lint + type-check) catches syntax and type errors.
# Layer 2: Unit + integration tests verify business logic in isolation.
# Layer 3: E2E tests validate full user journeys through the browser.
#
# BUSINESS RULE: layers run sequentially. If Layer 1 fails, Layer 2 never runs.
# This saves CI minutes and provides fast feedback.

name: CI

on:
  pull_request:
    branches: [main, staging]
  push:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # --- Layer 1: Static Analysis ---
  lint-and-typecheck:
    name: "L1: Lint & Type Check"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run lint
      - run: npx tsc --noEmit

  # --- Layer 2: Unit & Integration Tests ---
  test-unit:
    name: "L2: Unit & Integration Tests"
    needs: lint-and-typecheck
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm test -- --coverage
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/test_db

  # --- Layer 3: E2E Tests ---
  test-e2e:
    name: "L3: E2E Tests"
    needs: test-unit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - run: npx playwright test
        env:
          CI: true
```

### Pattern 2: Docker Build for Coolify

```yaml
# .github/workflows/deploy.yml
# Deployment pipeline -- builds Docker image and triggers Coolify deploy.
#
# BUSINESS RULE: only deploys after CI passes on main branch.
# Staging deploys automatically; production requires manual approval.

name: Deploy

on:
  workflow_run:
    workflows: [CI]
    types: [completed]
    branches: [main]

jobs:
  build-and-push:
    name: Build Docker Image
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:${{ github.sha }}
            ghcr.io/${{ github.repository }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-staging:
    name: Deploy to Staging
    needs: build-and-push
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Trigger Coolify Deploy
        # WORKAROUND: Coolify webhook triggers deployment of the latest image
        run: |
          curl -X POST "${{ secrets.COOLIFY_WEBHOOK_STAGING }}" \
            -H "Authorization: Bearer ${{ secrets.COOLIFY_TOKEN }}"

  deploy-production:
    name: Deploy to Production
    needs: deploy-staging
    runs-on: ubuntu-latest
    # BUSINESS RULE: production deploys require manual approval in GitHub
    environment: production
    steps:
      - name: Trigger Coolify Deploy
        run: |
          curl -X POST "${{ secrets.COOLIFY_WEBHOOK_PRODUCTION }}" \
            -H "Authorization: Bearer ${{ secrets.COOLIFY_TOKEN }}"
```

### Pattern 3: Dockerfile for Batuta Projects

```dockerfile
# Dockerfile -- multi-stage build for Next.js / Node.js projects.
#
# Stage 1 (deps): install dependencies with locked versions
# Stage 2 (build): compile application
# Stage 3 (runner): minimal production image
#
# BUSINESS RULE: standalone output reduces image size from ~1GB to ~150MB

FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
# SECURITY: run as non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public
USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
```

### Pattern 4: Workflow File Placement

```
.github/
  workflows/
    ci.yml              # AI Pyramid Layers 1-3 (lint, test, e2e)
    deploy.yml          # Build + Coolify staging/production
    dependabot.yml      # Dependency updates (auto-PR)
```

## Decision Trees

| Scenario | Pipeline Design | Why |
|----------|-----------------|-----|
| PR opened / updated | Run full CI (L1 -> L2 -> L3) | Validate before merge |
| Push to main | CI + auto-deploy to staging | Staging always reflects main |
| Staging verified | Manual promotion to production | Human gate for production |
| Dependency update (Dependabot) | Run CI, auto-merge if patch | Keep dependencies current |
| Hotfix needed | Branch from main, PR, CI, fast-track deploy | Skip staging soak only in emergencies |

| Build Optimization | When | Tradeoff |
|--------------------|------|----------|
| `npm ci` (not `npm install`) | Always in CI | Deterministic builds, faster |
| GitHub Actions cache (`cache: npm`) | Always | Saves 30-60s per run |
| Docker layer caching (`type=gha`) | Docker builds | Saves 2-5 min per build |
| `concurrency: cancel-in-progress` | PR workflows | Cancels outdated runs, saves minutes |
| Playwright single browser in PR | PRs | Multi-browser only on main (saves CI time) |
| `runs-on: ubuntu-latest` | Default | Most cost-effective runner |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| Deploy without CI passing | Broken code reaches users | Gate deploy on CI success (`workflow_run`) |
| Skip type-check in CI | Types catch bugs that tests miss | Always run `tsc --noEmit` in L1 |
| Run E2E before unit tests pass | Wastes CI minutes on doomed runs | Sequential `needs:` dependencies |
| Store secrets in workflow files | Security breach risk | Use GitHub Secrets + environment protection |
| `npm install` in CI | Non-deterministic, can break randomly | Use `npm ci` for locked dependencies |
| Deploy directly to production | No safety net for regressions | Always deploy to staging first |
| Build Docker image without multi-stage | Images are 1GB+, slow deploys | Multi-stage: deps -> build -> runner |
| Run all browsers on every PR | Wastes CI minutes | Chromium-only in PR, multi-browser on main |
| No `concurrency: cancel-in-progress` | Old PR runs waste resources | Cancel outdated runs automatically |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| AI Validation Pyramid | CI automates Layers 1-3. Human review (L4) happens AFTER CI passes |
| Coolify | Webhook triggers deploy. Coolify pulls image from GHCR and runs it |
| PostgreSQL | CI uses `services: postgres` for integration tests with real database |
| Docker | Multi-stage builds for minimal production images |
| Playwright | E2E tests run headless in CI with `chromium` only (multi-browser on main) |
| GitHub Environments | `staging` auto-deploys, `production` requires approval reviewers |
| sdd-verify | Pipeline must pass before sdd-verify gate G2 is satisfied |

## Code Examples

```yaml
# Example: Python/FastAPI CI (alternative stack)
# .github/workflows/ci-python.yml
name: CI (Python)
on:
  pull_request:
    branches: [main]

jobs:
  lint-and-typecheck:
    name: "L1: Lint & Type Check"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - run: pip install -r requirements.txt
      - run: ruff check .
      - run: mypy src/ --strict

  test:
    name: "L2: Unit Tests"
    needs: lint-and-typecheck
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        ports: ["5432:5432"]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - run: pip install -r requirements.txt
      - run: pytest --cov=src tests/
```

## Commands

```bash
# Run CI workflow locally with act (GitHub Actions local runner)
act pull_request --container-architecture linux/amd64

# Build Docker image locally (same as CI)
docker build -t app:local .

# Test Docker image runs correctly
docker run --rm -p 3000:3000 app:local

# View workflow run status via GitHub CLI
gh run list --limit 5

# View details of a specific run
gh run view <run-id>

# Re-run failed jobs
gh run rerun <run-id> --failed

# Check Coolify deployment status
curl -s -H "Authorization: Bearer $COOLIFY_TOKEN" \
  "$COOLIFY_URL/api/v1/applications/$APP_ID" | jq '.status'
```

## Rules

- ALWAYS enforce AI Validation Pyramid order: L1 (lint/types) -> L2 (unit) -> L3 (E2E).
- ALWAYS use `needs:` to gate pipeline stages -- never allow parallel independent layers.
- ALWAYS use `npm ci` (not `npm install`) in CI for deterministic builds.
- ALWAYS use multi-stage Docker builds to minimize production image size.
- ALWAYS deploy to staging before production. Production requires manual approval.
- ALWAYS use `concurrency: cancel-in-progress` on PR workflows.
- ALWAYS store secrets in GitHub Secrets, never hardcoded in workflow files.
- NEVER deploy without CI passing first -- gate with `workflow_run` or `needs`.
- NEVER skip type-checking in CI -- it catches entire categories of bugs for free.
- NEVER run Docker containers as root in production -- use a dedicated non-root user.

## What This Means (Simply)

> **For non-technical readers**: This skill defines the automatic quality control
> assembly line for our code. Every time a developer submits code changes, the system
> automatically checks three things in order: (1) does the code follow our formatting
> rules and type safety, (2) do all the logic tests pass, (3) does the application work
> correctly when a simulated user clicks through it in a browser. Only after all three
> checks pass can the code go to a test environment, and only after a human approves the
> test environment does it go live for real users. Think of it as a factory quality
> inspection line where each station must approve before the product moves forward.
