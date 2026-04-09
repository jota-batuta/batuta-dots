---
name: coolify-deploy
description: >
  Step-by-step deployment patterns for Coolify (self-hosted PaaS).
  Trigger: "deploy Coolify", "Coolify service", "one-click Coolify", "Docker Compose Coolify",
  "Coolify networking", "Coolify environment variables".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-04-07"
  scope: [capability]
  auto_invoke: "When deploying services to Coolify"
  platforms: [claude]
  category: "capability"
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

Verified deployment patterns for Coolify. Covers one-click services, Docker Compose, networking between stacks, environment variables, domains/SSL, and known bugs.

## When to Use

- Deploying BATO, Prefect, or Langfuse to Coolify
- Configuring networking between services on Coolify
- Setting up domains and SSL
- Debugging deployment issues

## Critical Patterns

### Pattern 1: One-Click Service (Prefect, Langfuse)

1. Dashboard → New Resource → **Service** (not Application)
2. Search catalog → Click template → Deploy
3. Auto-provisions PostgreSQL with magic variables
4. Services do NOT have CI/CD — update manually via UI

Prefect: auto-configures `PREFECT_API_DATABASE_CONNECTION_URL` with magic variables.
Langfuse: auto-configures PostgreSQL connection.

### Pattern 2: Application from Git (BATO)

1. Dashboard → New Resource → **Application**
2. Source: GitHub App or Public Repository
3. Build pack: **Docker Compose**
4. Set environment variables (Developer View to paste .env)
5. Assign domain with `https://` prefix → auto SSL via Let's Encrypt
6. Deploy

Auto-CI/CD: every push to configured branch triggers rebuild.

### Pattern 3: Cross-Stack Networking

Services in different stacks (BATO, Prefect, Langfuse) need to communicate.

**Recommended method** — External network in compose:
```yaml
services:
  bato:
    networks:
      - default
      - coolify

networks:
  coolify:
    external: true
```

Then reference other services by their container name (visible in Coolify UI for each resource).

DO NOT rely on "Connect to Predefined Network" checkbox — has bug #5597 with Docker Compose.

### Pattern 4: Environment Variables

**Developer View**: paste entire `.env` file at once. Coolify parses automatically.

**Magic variables** for services:
- `SERVICE_PASSWORD_POSTGRES` → auto-generated password
- `SERVICE_USER_POSTGRES` → auto-generated user
- `SERVICE_FQDN_APPNAME` → auto-assigned domain

**Shared variables** across projects:
- `{{team.VAR}}` — team-wide
- `{{project.VAR}}` — project-wide

### Pattern 5: Domains and SSL

- Assign domain with `https://` prefix → Traefik + Let's Encrypt auto
- Without custom domain: Coolify generates `http://<uuid>.<ip>.sslip.io` (HTTP only)
- Multiple domains: comma-separated in domain field
- Wildcard domain at server level for auto-subdomains

### Pattern 6: Webhook URL for Evolution API

BATO needs a public URL for Evolution API webhooks:
1. Assign domain to BATO in Coolify (e.g., `https://bato.yourdomain.com`)
2. Configure Evolution API webhook: `https://bato.yourdomain.com/webhook/whatsapp`
3. Coolify handles SSL and routing via Traefik

## Gotchas (Verified)

1. **NEVER use `ports:` in compose** — Coolify manages routing via Traefik. Use `expose:` to document internal ports. `ports:` causes conflicts.
2. **Prefect has NO authentication** — UI is publicly accessible. Protect with: (a) no public domain, (b) Traefik BasicAuth labels, or (c) Cloudflare Access.
3. **Langfuse Traefik label bug** (#5702) — After editing domain, add label manually: `traefik.http.services.langfuse.loadbalancer.server.port=3000`
4. **"Connect to Predefined Network" is broken** for Docker Compose (#5597) — Use external network method instead.
5. **Compose filename must match exactly** — `docker-compose.yml` or `docker-compose.yaml`, matching what's configured in Coolify.
6. **Health check failures = Traefik stops routing** — If container health check is unreliable, disable in Coolify UI.
7. **Small VPS: enable swap** — Builds OOM on 2GB RAM. Enable 6GB swap.
8. **Services don't auto-update** — One-click services need manual "Update" click. No CI/CD.
9. **Deployments may falsely show "Failed"** — Container is actually healthy. Redeploy fixes it.
10. **Persistent storage bug** (#5099) — Use named volumes in compose, not Coolify UI volumes.

## Quick Deploy Order for BATOVF

```
1. Langfuse (one-click) → note container name
2. Prefect (one-click) → note container name + internal API URL
3. BATO (Application from Git, Docker Compose)
   → external network: coolify
   → env vars: PREFECT_API_URL=http://<prefect-container>:4200/api
   → domain: https://bato.yourdomain.com
4. Evolution API webhook → https://bato.yourdomain.com/webhook/whatsapp
5. Supabase (cloud) → paste SQL in SQL Editor
6. WhatsApp groups → GET /group/fetchAllGroups → map to .env
```
