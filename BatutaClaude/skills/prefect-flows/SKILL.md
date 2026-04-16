---
name: prefect-flows
description: >
  Patterns for Prefect 3 self-hosted: flows, tasks, scheduling, Docker setup.
  Trigger: "Prefect", "flow", "task", "scheduled check", "cron schedule", "prefect server",
  "work pool", "prefect deploy".
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-04-07"
  bucket: build
  auto_invoke: "When building or deploying Prefect flows"
  platforms: [claude]
  category: "capability"
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

Patterns for Prefect 3 self-hosted with Docker/Coolify. Covers flow definition, scheduling, retry, logging, and the correct deployment pattern for a single-node setup.

## When to Use

- Defining scheduled flows (checks every hour)
- Setting up Prefect server with Docker
- Configuring cron schedules
- Understanding work pools vs serve()

## Critical Patterns

### Pattern 1: Flow and Task Definition

```python
from prefect import flow, task, get_run_logger

@task(retries=3, retry_delay_seconds=30, log_prints=True)
def check_stock_negativo(store_code: str) -> dict:
    """Check for new negative stock items in a store."""
    logger = get_run_logger()
    # ... query SQL Server ...
    logger.info(f"Found {len(anomalies)} anomalies in {store_code}")
    return {"store": store_code, "anomalies": anomalies}

@flow(name="inventory-check", log_prints=True, retries=2, retry_delay_seconds=60)
def inventory_check_flow(store_codes: list[str]) -> None:
    for code in store_codes:
        result = check_stock_negativo(code)
        if result["anomalies"]:
            send_alerts(code, result["anomalies"])
```

### Pattern 2: Scheduling with .serve() (Recommended for BATOVF)

```python
from prefect import serve

if __name__ == "__main__":
    check_dep = inventory_check_flow.to_deployment(
        name="inventory-hourly",
        cron="0 * * * *",
        timezone="America/Bogota",
        parameters={"store_codes": ["PQ", "PT", "PSB", "CHP", "PVV", "PRD"]},
    )
    turno_dep = turno_report_flow.to_deployment(
        name="turno-report",
        cron="0 6,14,22 * * *",  # At shift changes
        timezone="America/Bogota",
    )
    serve(check_dep, turno_dep)  # Single process serves both
```

`.serve()` is the correct pattern for single-node Coolify. NO work pools needed. The flow runs inside the same container.

### Pattern 3: Docker Compose for Prefect

```yaml
services:
  postgres-prefect:
    image: postgres:16
    environment:
      POSTGRES_USER: prefect
      POSTGRES_PASSWORD: prefect_secret
      POSTGRES_DB: prefect
    volumes:
      - prefect_pg:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U prefect"]
      interval: 10s

  prefect-server:
    image: prefecthq/prefect:3-latest
    command: prefect server start
    environment:
      PREFECT_API_DATABASE_CONNECTION_URL: postgresql+asyncpg://prefect:prefect_secret@postgres-prefect:5432/prefect
      PREFECT_SERVER_API_HOST: "0.0.0.0"
    ports:
      - "4200:4200"
    depends_on:
      postgres-prefect:
        condition: service_healthy

  batovf-flows:
    build: .
    command: python -m src.bato.flows
    environment:
      PREFECT_API_URL: http://prefect-server:4200/api
      # ... app env vars ...
    depends_on:
      - prefect-server
```

### Pattern 4: Retry with Exponential Backoff

```python
from prefect.tasks import exponential_backoff

@task(
    retries=4,
    retry_delay_seconds=exponential_backoff(backoff_factor=2),  # [2, 4, 8, 16]
    retry_jitter_factor=0.5,
)
def query_sql_server(query: str) -> list:
    ...
```

### Pattern 5: Logging

```python
@flow(log_prints=True)
def my_flow():
    print("This appears in Prefect UI")  # Captured automatically
    logger = get_run_logger()
    logger.info("Structured log")
    logger.warning("Warning message")
    logger.error("Error with details")
```

All logs visible in Prefect UI at port 4200, per flow run.

## Key Decision: .serve() vs .deploy()

| Aspect | .serve() | .deploy() + work pool |
|--------|----------|----------------------|
| Infra needed | Same container | Separate worker + pool |
| If process dies | May pause schedules | Schedules survive |
| Complexity | Minimal | Requires pool config |
| For BATOVF | **USE THIS** | Overkill for single node |

Use `pause_on_shutdown=False` and `restart: unless-stopped` in Docker to mitigate serve() dying.

## Gotchas (Verified)

1. **PREFECT_API_URL has TWO values** — Server uses `0.0.0.0:4200`, workers use Docker hostname `http://prefect-server:4200/api`
2. **Prefect 3 uses asyncpg** — Connection string MUST be `postgresql+asyncpg://...`, NOT `psycopg2`
3. **Prefect 3 has workers, NOT agents** — `prefect agent start` is Prefect 2. Don't mix docs.
4. **Server has NO auth by default** — Protect port 4200 in Coolify/reverse proxy
5. **pymssql needs freetds-dev** — Install system package in Dockerfile before pip install
6. **Logs only appear in UI if PREFECT_API_URL is correctly set** — Otherwise they go to stdout only
7. **Redis is optional** for single-worker setup — Can be added later for scaling

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Cron is simpler -- I'll just use a system crontab and skip Prefect" | System cron has no observability, no retry, no logging UI, no schedule history, no failure alerting, and no concurrency control. The first time a job silently fails on Saturday at 3am you will spend hours rebuilding what Prefect gives you out of the box |
| "I'll skip retries on tasks -- the network is reliable enough" | The network is never reliable enough. Transient failures (DNS hiccup, SQL Server restart, brief auth refresh) are the most common cause of false alerts. `retries=3` with exponential backoff costs nothing and turns a 5% failure rate into a 0.0125% one |
| "I'll use .deploy() with work pools because that's what the docs show" | The docs show .deploy() because it scales horizontally. For a single-node Coolify deployment, .serve() is the correct pattern -- it runs flows in the same container, no work pool config, no separate worker process. Use .deploy() only when you actually have multiple workers |
| "Prefect 3 still uses agents -- I saw `prefect agent start` in a tutorial" | That tutorial is for Prefect 2. Prefect 3 uses workers, not agents. Mixing the two leads to processes that start without errors but never pick up flow runs. Always verify version-specific docs |
| "PREFECT_API_URL is the same everywhere -- localhost:4200" | The server uses `0.0.0.0:4200` to bind, but workers and clients inside Docker need `http://prefect-server:4200/api` (the Docker DNS name). Using localhost from inside a container connects to the container itself, not to the Prefect server |

## Red Flags

- A scheduled job running via `crontab -e` instead of a Prefect flow (no observability, no retry, no UI)
- `@task` without `retries=` for any operation that touches network, database, or external API
- `@flow` deployed via `.deploy()` + work pool when only a single Prefect process exists
- `prefect agent start` in a Dockerfile or compose file (Prefect 2 syntax; Prefect 3 uses `prefect worker start`)
- `PREFECT_API_URL=http://localhost:4200/api` in a container that needs to reach a sibling container
- `postgresql://` (psycopg2) in `PREFECT_API_DATABASE_CONNECTION_URL` instead of `postgresql+asyncpg://`
- `print()` calls in flows without `log_prints=True` on the `@flow` decorator (logs lost)
- Prefect server exposed on port 4200 without auth or reverse-proxy protection
- Dockerfile installing `pymssql` without `apt-get install freetds-dev` first (build will fail)
- `pause_on_shutdown=True` (default) on a `serve()` call where you want schedules to survive container restart
- Same flow function used for both proactive (scheduled) and reactive (manual) runs without parameter differentiation

## Verification Checklist

- [ ] All scheduled work is defined as Prefect flows; no system crontab entries running production logic
- [ ] Every `@task` that touches network/DB/external API has `retries=` and `retry_delay_seconds=` configured (use `exponential_backoff` for variability)
- [ ] Single-node deployments use `.serve()` and `serve(...)`; only multi-worker setups use `.deploy()` + work pools
- [ ] Prefect 3 syntax used throughout: `prefect worker start` (not `prefect agent start`)
- [ ] `PREFECT_API_URL` for workers/flows uses Docker DNS name (`http://prefect-server:4200/api`), not localhost
- [ ] Database connection string uses `postgresql+asyncpg://` driver
- [ ] All `@flow` decorators include `log_prints=True` if the flow uses `print()` for output
- [ ] Prefect server port 4200 is firewalled or fronted by an authenticated reverse proxy
- [ ] Dockerfile installs `freetds-dev` (or equivalent system deps) before `pip install pymssql`
- [ ] `serve()` is called with `pause_on_shutdown=False` and the container has `restart: unless-stopped`
- [ ] Proactive and reactive runs use different flow names or parameters so logs and history are separable
