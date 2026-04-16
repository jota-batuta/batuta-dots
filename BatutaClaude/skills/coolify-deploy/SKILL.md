---
name: coolify-deploy
description: >
  Step-by-step deployment patterns for Coolify (self-hosted PaaS).
  Trigger: "deploy Coolify", "Coolify service", "one-click Coolify", "Docker Compose Coolify",
  "Coolify networking", "Coolify environment variables".
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-04-07"
  bucket: build
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

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Ports in compose work fine on my machine" | They DO work locally and even pass initial Coolify deploys — then break silently when Traefik tries to route. Coolify uses Traefik for routing; `ports:` causes conflicts. Use `expose:` for documentation only. |
| "Coolify is just Docker Compose with a UI" | Coolify adds Traefik routing, network management, environment variable injection, magic variables, SSL via Let's Encrypt, and webhook deploys. Compose patterns that work locally often don't translate (e.g. the predefined network checkbox bug #5597). |
| "The 'Connect to Predefined Network' checkbox should work" | It has a documented bug with Docker Compose stacks (#5597). Use the external network method in compose explicitly. Trust the gotchas list, not the UI. |
| "Health check failures are a code problem" | Coolify health check failures cause Traefik to STOP ROUTING traffic — even when the app is healthy. If your health check is unreliable, disable it in Coolify UI rather than letting it false-fail your deploy. |
| "I'll just SSH in to fix env vars quickly" | Coolify env vars are injected at container start. SSH-edited values are lost on next deploy. Use Developer View in Coolify UI to paste full `.env` blocks. |
| "Services and Applications are basically the same" | Services have NO CI/CD (manual update only) and NO custom build. Applications have full CI/CD via webhooks but require Docker/Dockerfile. Pick based on update strategy, not familiarity. |

## Red Flags

- `ports:` directive in docker-compose.yml deployed to Coolify (use `expose:` instead)
- Reliance on the "Connect to Predefined Network" checkbox for cross-stack networking (broken — bug #5597)
- Using Coolify UI volumes instead of named volumes in compose (persistent storage bug #5099)
- Compose filename mismatch (`compose.yml` instead of `docker-compose.yml`) — silent fail
- Prefect deployed with public domain and no auth (UI is publicly accessible by default)
- Building on 2GB RAM VPS without swap enabled — OOM kills builds silently
- Treating "Failed" deploy status as authoritative without checking if container is actually healthy
- One-click services treated as auto-updating (they require manual "Update" click)
- Hardcoded container IPs in env vars instead of container names (IPs change on redeploy)
- Webhook URLs (Evolution API, Stripe, etc.) configured before assigning a public domain
- Domain assigned without `https://` prefix (Let's Encrypt won't auto-provision SSL)
- Multiple compose stacks attempting to bind the same host port via `ports:` (Traefik conflict)
- Langfuse deployed without manually adding Traefik label fix (bug #5702)
- No backup strategy for the persistent Coolify host (compose is reproducible but DB data is not)

## Verification Checklist

- [ ] No `ports:` directives in docker-compose.yml — all internal ports declared via `expose:`
- [ ] Compose filename is exactly `docker-compose.yml` or `docker-compose.yaml` (matching Coolify config)
- [ ] Cross-stack networking uses external `coolify` network in compose, not the UI checkbox
- [ ] Other services referenced by container name (visible in Coolify UI), not by IP
- [ ] Domain assigned with `https://` prefix → Let's Encrypt SSL provisioned automatically
- [ ] Environment variables loaded via Developer View (full `.env` block paste)
- [ ] Magic variables used where applicable (`SERVICE_PASSWORD_POSTGRES`, `SERVICE_FQDN_*`)
- [ ] Persistent data in named volumes inside compose, not Coolify UI volumes (avoid bug #5099)
- [ ] Health check: enabled with reliable endpoint, OR disabled if unreliable (no false-fails)
- [ ] Prefect protected: no public domain, OR Traefik BasicAuth labels, OR Cloudflare Access
- [ ] Langfuse: Traefik label fix applied manually after domain edit (bug #5702 workaround)
- [ ] Small VPS (<= 4GB RAM): swap enabled (recommend 6GB swap)
- [ ] Service vs Application chosen correctly: Service for one-click templates without custom build, Application for Git-based with CI/CD
- [ ] Webhook URLs configured AFTER assigning public domain
- [ ] Deploy order respected for stacks with dependencies (Langfuse + Prefect → BATO → integrations)
- [ ] If a deploy shows "Failed" but container is healthy: redeploy to clear false status
- [ ] Container backup strategy for stateful services (DB dumps to S3 or similar)
- [ ] Coolify webhook tokens stored in GitHub Secrets, not in workflow YAML
