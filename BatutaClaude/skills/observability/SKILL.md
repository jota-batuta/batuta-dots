---
name: observability
description: >
  Use when implementing logging, metrics, tracing, or alerting infrastructure.
  Trigger: "structured logging", "OpenTelemetry", "tracing", "metrics",
  "Sentry", "alerting", "observability", "monitoring", "Langfuse".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-26"
  scope: [observability]
  auto_invoke:
    - "Setting up structured logging or log levels"
    - "Implementing distributed tracing with OpenTelemetry"
    - "Configuring Sentry error tracking"
    - "Adding metrics (counters, gauges, histograms)"
    - "Designing alerting rules or escalation policies"
    - "Implementing O.R.T.A. observability framework"
    - "Setting up Langfuse for LLM observability"
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

# Observability -- O.R.T.A. Framework for Batuta Projects

## Purpose

Implement the O.R.T.A. framework (Observabilidad, Repetibilidad, Trazabilidad, Auto-supervision) across Batuta projects. This skill standardizes how we collect logs, metrics, and traces so that when something goes wrong at 2 AM, we can answer "what happened, where, and why" without guessing. It integrates OpenTelemetry as the vendor-neutral telemetry backbone, Sentry for error tracking, and Langfuse for LLM pipeline observability.

## When to Use

- **During sdd-design**: When the architecture includes distributed services, background workers, or LLM pipelines
- **During sdd-apply**: When adding logging, tracing, or error handling to implementations
- **During sdd-verify**: When validating that observability requirements are met
- **On demand**: When debugging production issues or setting up monitoring for a new service

## Critical Patterns

### Pattern 1: Structured Logging with Tenant Context

Every log entry MUST be structured JSON with correlation IDs. Plain-text logs are not searchable, not parseable, and not filterable. Include tenant context for multi-tenant isolation in log aggregation.

```python
"""Structured logging with OpenTelemetry trace correlation for Batuta services."""
import structlog
from opentelemetry import trace

def configure_logging(service_name: str):
    """Configure structlog with JSON output and automatic trace context injection."""
    structlog.configure(
        processors=[
            structlog.contextvars.merge_contextvars,
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            _add_otel_context,  # BUSINESS RULE: Every log gets trace_id + span_id
            structlog.processors.JSONRenderer(),
        ],
        wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
    )

def _add_otel_context(logger, method_name, event_dict):
    """Inject trace_id and span_id from active OpenTelemetry span."""
    span = trace.get_current_span()
    ctx = span.get_span_context()
    if ctx.is_valid:
        event_dict["trace_id"] = format(ctx.trace_id, "032x")
        event_dict["span_id"] = format(ctx.span_id, "016x")
    return event_dict

# Usage: structlog.contextvars.bind_contextvars(tenant_id="acme", request_id="req-123")
#        log.info("order.created", order_id="ord-456", items_count=3)
# Output: {"event":"order.created","level":"info","tenant_id":"acme","trace_id":"abc..."}
```

### Pattern 2: OpenTelemetry Instrumentation

Use the OpenTelemetry SDK to instrument services. Auto-instrumentation covers HTTP frameworks and database clients; manual spans cover business logic that matters for debugging.

```python
"""OpenTelemetry tracing setup for Batuta FastAPI services."""
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor

def setup_tracing(service_name: str, otlp_endpoint: str):
    """Initialize OTel tracing. Use BatchSpanProcessor in production, Simple in dev."""
    provider = TracerProvider(resource=Resource.create({"service.name": service_name}))
    provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter(endpoint=otlp_endpoint)))
    trace.set_tracer_provider(provider)

def instrument_app(app, engine):
    """Auto-instrument FastAPI routes and SQLAlchemy queries."""
    FastAPIInstrumentor.instrument_app(app)
    SQLAlchemyInstrumentor().instrument(engine=engine)
```

### Pattern 3: Sentry Integration with OpenTelemetry

Sentry handles error tracking and alerting. Connect it to OpenTelemetry so errors are linked to the distributed trace that caused them.

```python
"""Sentry error tracking with PII scrubbing for Batuta services."""
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

def setup_sentry(dsn: str, environment: str, service_name: str):
    """Initialize Sentry. Samples 100% errors, 10% transactions in production."""
    sentry_sdk.init(
        dsn=dsn, environment=environment,
        traces_sample_rate=0.1 if environment == "production" else 1.0,
        integrations=[FastApiIntegration()],
        before_send=_scrub_pii,  # SECURITY: Never send PII to Sentry
    )
    sentry_sdk.set_tag("service", service_name)

def _scrub_pii(event, hint):
    """Redact passwords, tokens, cedulas before sending to Sentry."""
    if "request" in event and "data" in event["request"]:
        for field in ("password", "token", "secret", "ssn", "cedula"):
            if field in event["request"]["data"]:
                event["request"]["data"][field] = "[REDACTED]"
    return event
```

## Decision Trees

### Log Level Selection

| Situation | Level | Example |
|-----------|-------|---------|
| Request received/completed (routine) | INFO | `log.info("request.completed", status=200, duration_ms=45)` |
| Retry attempt, fallback activated | WARNING | `log.warning("payment.retry", attempt=2, reason="timeout")` |
| Unhandled exception, data corruption | ERROR | `log.error("order.save_failed", order_id="x", exc_info=True)` |
| System startup, config loaded | INFO | `log.info("service.started", version="1.2.3")` |
| Detailed debugging (never in production) | DEBUG | `log.debug("cache.hit", key="product:123")` |
| Security event (auth failure, permission denied) | WARNING | `log.warning("auth.failed", ip="1.2.3.4", reason="invalid_token")` |

### Metric Type Selection

| What You Measure | Metric Type | Example |
|------------------|-------------|---------|
| Total requests served (only goes up) | Counter | `http_requests_total{method="GET", status="200"}` |
| Current active connections (goes up and down) | Gauge | `active_connections{service="api"}` |
| Request duration distribution | Histogram | `http_request_duration_seconds{endpoint="/orders"}` |
| Items in queue (snapshot) | Gauge | `queue_depth{queue="order_processing"}` |
| Error rate (derived) | Counter ratio | `errors_total / requests_total` |

### Observability Stack Choice

| Need | Tool | Why |
|------|------|-----|
| Distributed tracing | OpenTelemetry + Jaeger/Tempo | Vendor-neutral, wide ecosystem |
| Error tracking + alerting | Sentry | Rich error context, release tracking, alerting built-in |
| LLM pipeline observability | Langfuse | Prompt versioning, cost tracking, quality scoring |
| Log aggregation | Loki or Elasticsearch | Loki for cost efficiency; ES for full-text search |
| Dashboards | Grafana | Unified view of metrics, logs, and traces |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| `print("Error: something went wrong")` | No structure, no level, no context, lost in stdout | `log.error("payment.failed", order_id=x, exc_info=True)` |
| Logging PII (emails, passwords, tokens) | Compliance violation (GDPR, Habeas Data), security risk | Redact PII before logging; use field-level scrubbing |
| Catching exceptions silently (`except: pass`) | Errors disappear; impossible to diagnose failures | Log the error, report to Sentry, then decide on recovery |
| One log level for everything (all INFO) | Cannot filter noise from signal during incidents | Use level guidelines from decision tree above |
| Logging inside tight loops | Generates millions of entries, overwhelms storage | Log aggregates or sample (1 in 1000) |
| Per-request Sentry alerts | Alert fatigue -- team ignores all alerts within a week | Alert on error rate thresholds, not individual errors |
| Missing trace context in logs | Cannot correlate logs to the trace that produced them | Inject trace_id and span_id into every structured log |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| **FastAPI** | Auto-instrumented by OpenTelemetry; structlog middleware for request logging |
| **PostgreSQL** | SQLAlchemy instrumented for query tracing; slow query logs via `log_min_duration_statement` |
| **Temporal Workers** | Workers emit spans per workflow/activity; use `worker-scaffold` tracing setup |
| **Coolify/Docker** | Containers export OTLP to collector sidecar; Sentry DSN via environment variables |
| **LLM Pipelines** | Langfuse traces prompt/completion pairs; integrates with `llm-pipeline-design` skill |
| **n8n Workflows** | Webhook nodes log request_id for correlation; error nodes report to Sentry |

## Code Examples

```python
# Example: O.R.T.A. health check for auto-supervision
@router.get("/health")
async def health_check():
    """Aggregate dependency health. Used by Coolify and Grafana."""
    checks = {"database": await check_db(), "redis": await check_redis(),
              "sentry": sentry_sdk.is_initialized()}
    return {"status": "healthy" if all(checks.values()) else "degraded",
            "checks": checks, "version": APP_VERSION}
```

```python
# Example: Langfuse LLM observability -- every LLM call traced for cost/quality
from langfuse import Langfuse
langfuse = Langfuse()

def classify_document(text: str, tenant_id: str) -> str:
    """Classify document via LLM with Langfuse tracing for cost attribution."""
    trace = langfuse.trace(name="document_classification",
                           metadata={"tenant_id": tenant_id})
    generation = trace.generation(name="classify", model="claude-sonnet-4-20250514", input=text)
    result = call_llm(text)
    generation.end(output=result, usage={"input_tokens": 150, "output_tokens": 10})
    return result
```

## Commands

```bash
# Run OpenTelemetry collector locally (Docker)
docker run -p 4317:4317 -p 4318:4318 otel/opentelemetry-collector-contrib:latest

# Verify Sentry integration
python -c "import sentry_sdk; sentry_sdk.init('DSN'); 1/0"

# Check structured log output
python -c "import structlog; structlog.get_logger().info('test', key='value')"

# View Jaeger traces locally
docker run -p 16686:16686 jaegertracing/all-in-one:latest
```

## Rules

- MUST use structured JSON logging (structlog or equivalent) -- never plain-text print statements
- MUST inject OpenTelemetry trace_id and span_id into every log entry for correlation
- MUST scrub PII (passwords, tokens, cedulas, emails) before sending to Sentry or log aggregator
- MUST implement `/health` endpoint in every service for O.R.T.A. auto-supervision
- MUST use Langfuse for any LLM pipeline calls to track cost, latency, and quality
- MUST include `tenant_id` in log context for multi-tenant log isolation
- NEVER log inside tight loops -- aggregate or sample instead
- NEVER alert on individual errors -- alert on error rate thresholds (e.g., >5% error rate over 5 minutes)
- NEVER use `except: pass` or `except Exception: pass` without logging -- silent failures are invisible failures
- MUST set `traces_sample_rate` appropriately: 1.0 in development, 0.1-0.3 in production (adjust based on volume)

## What This Means (Simply)

> **For non-technical readers**: Observability is like having security cameras, smoke detectors, and a dashboard for your software. Structured logging is the security camera footage -- organized and searchable. Tracing is the ability to follow a single customer request across all the systems it touches, like tracking a package through every sorting facility. Metrics are the dashboard gauges (how many requests per second, how fast are responses). Alerting is the smoke detector -- it notifies the team when something is wrong before customers notice. O.R.T.A. is our framework that ensures every service has all four of these in place, so nothing runs "blind."
