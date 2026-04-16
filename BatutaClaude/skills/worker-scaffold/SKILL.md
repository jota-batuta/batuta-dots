---
name: worker-scaffold
description: >
  Use when scaffolding workers: Temporal, Docker, Coolify deployment.
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-23"
  source: "CTO Layer skill 04"
  bucket: build
  auto_invoke: false
  platforms: [claude, antigravity]
allowed-tools: Read Write Edit Glob Grep Bash WebSearch
---

# Worker Scaffold — Platform Specialist

## Purpose

Scaffolding de workers hasta deploy en produccion, monitoring, y lifecycle management.

**Regla**: Si no puedes reconstruir tu infra desde cero en 30 minutos, no la entiendes.

## When to Invoke

- Nuevo worker Temporal
- Deploy de servicio via Coolify
- Configuracion monitoring
- Docker optimization

## Worker Lifecycle

### 1. Scaffold

```
worker-{domain}-{function}/
├── Dockerfile
├── pyproject.toml
├── src/
│   ├── worker.py, config.py
│   ├── workflows/        # @workflow.defn
│   ├── activities/       # @activity.defn
│   ├── models/schemas.py # @dataclass
│   ├── ml/, llm/         # (si aplica)
│   └── events/publisher.py
└── tests/
```

**Convenciones**: tenant_id primero, retry explicita (3 attempts, backoff 2.0), timeouts explicitos, heartbeat >30s, claim-check >256KB, no asyncio.as_completed/set/random en workflow.

### 2. Temporal Config

- Task Queue: `{domain}-{function}-queue`
- Search Attributes: tenant_id, domain, solution_type (Keyword)
- Multi-tenant: max 5 activities/sec, max 50 concurrent

### 3. Dockerize

Python 3.12-slim, health check interval 30s, never include .env/secrets.

### 4. Deploy via Coolify

Git repo → Dockerfile → env vars → health check → resource limits → Tailscale/Cloudflare.

### 5. Monitor

Container restart → alert. Error rate >5% → alert. Temporal unhealthy → immediate.

### 6. n8n Triggers

Webhook/Cron/Email → n8n → signal/start Temporal workflow.

## Infrastructure Topology

```
Internet → Cloudflare → Hetzner VPS → Coolify
  ├── Temporal (:7233, Tailscale only)
  ├── Workers (N containers)
  ├── n8n, Langfuse, Presidio
  ├── PostgreSQL + Redis
  └── Prometheus + Grafana
```

## Output Files

- `scaffold-{domain}-{function}/` (directorio completo)
- `deploy-config-{nombre}-{fecha}.md`
- `monitoring-setup-{nombre}.md`

## Handoff

- **sdd-design**: Infrastructure section en design.md
- **sdd-apply**: Scaffold como primer paso de implementacion
- **sdd-verify**: Health check + monitoring como criterios
- **llm-pipeline-design**: Worker con capa LLM

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "No idempotency key needed — Temporal handles it" | Temporal handles workflow-level retry, but ACTIVITIES can still have side effects (sending emails, charging cards, calling external APIs). Without an idempotency key on the activity, a retry produces duplicate side effects. |
| "Retries can be infinite — Temporal will eventually succeed" | Activities calling external services with permanent failures (404, validation errors) will retry forever, burning CPU and money. Configure `maximum_attempts` and use non-retryable error types for permanent failures. |
| "We don't need claim-check for large payloads — Temporal can handle it" | Temporal events have a 2MB hard limit per event and 50MB per workflow history. Large payloads silently corrupt workflows. Always claim-check anything >256KB to S3/DB and pass the reference. |

## Red Flags

- Activity with side effects (HTTP POST, email, DB write) without an idempotency key.
- Workflow uses `asyncio.as_completed`, `set()` iteration, `random`, or `datetime.now()` — non-deterministic, breaks replay.
- No explicit `start_to_close_timeout` on activities — defaults are usually wrong.
- Heartbeat missing on activities >30 seconds — Temporal cannot detect stuck activities.
- `maximum_attempts=None` (infinite retry) without circuit breaker for permanent failures.
- Payload >256KB passed through workflow events instead of claim-check pattern.
- Worker container missing `/health` endpoint — Coolify cannot detect degraded workers.
- Secrets baked into Docker image (`.env` copied) instead of injected at runtime.
- `tenant_id` not the first argument of every activity — multi-tenant routing/observability broken.
- Single Temporal task queue used for all domains — noisy neighbor problems at scale.

## Verification Checklist

- [ ] Worker scaffold follows directory convention: `worker-{domain}-{function}/` with `src/workflows/`, `src/activities/`, `src/models/`
- [ ] `tenant_id` is the FIRST argument on every activity signature
- [ ] Every activity has explicit `start_to_close_timeout` AND `retry_policy` (max_attempts, backoff)
- [ ] Activities >30s emit heartbeats via `activity.heartbeat()`
- [ ] Payloads >256KB use claim-check pattern (S3/DB reference, not inline)
- [ ] Workflows are deterministic: no `asyncio.as_completed`, no `random`, no `datetime.now()`, no `set()` iteration
- [ ] Idempotency key passed into every side-effecting activity
- [ ] Permanent failures raised as non-retryable error types (Temporal does not retry these)
- [ ] Task queue named `{domain}-{function}-queue` (one per worker domain)
- [ ] Search attributes registered: `tenant_id`, `domain`, `solution_type` (Keyword type)
- [ ] Multi-tenant rate limits configured: max 5 activities/sec per tenant, max 50 concurrent
- [ ] Dockerfile uses `python:3.12-slim`, has health check at 30s interval, NO `.env` files copied
- [ ] Secrets injected via Coolify environment variables, never in image
- [ ] Container restart triggers an alert; error rate >5% triggers an alert
- [ ] Service deployed behind Tailscale or Cloudflare; Temporal :7233 reachable only via Tailscale
