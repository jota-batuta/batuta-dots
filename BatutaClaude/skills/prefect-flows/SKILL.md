---
name: prefect-flows
description: >
  Patterns for Prefect 3 self-hosted: flows, tasks, scheduling, Docker setup.
  Trigger: "Prefect", "flow", "task", "scheduled check", "cron schedule", "prefect server",
  "work pool", "prefect deploy".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-04-07"
  scope: [capability]
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
