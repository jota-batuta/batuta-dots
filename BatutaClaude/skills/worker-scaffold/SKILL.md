---
name: worker-scaffold
description: >
  Use when scaffolding workers: Temporal, Docker, Coolify deployment.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-23"
  source: "CTO Layer skill 04"
  scope: [pipeline]
  auto_invoke: false
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep WebSearch
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
