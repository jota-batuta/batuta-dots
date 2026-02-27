---
name: message-queues
description: >
  Use when implementing message queues: pub/sub, dead letters, retries, idempotency.
  Trigger: "message queue", "RabbitMQ", "Redis Streams", "Kafka", "pub/sub",
  "dead letter queue", "event-driven", "async messaging", "fan-out".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-26"
  scope: [pipeline]
  auto_invoke:
    - "Implementing message queue or event-driven architecture"
    - "Choosing between RabbitMQ, Redis Streams, or Kafka"
    - "Designing dead letter queue or retry strategy"
    - "Implementing idempotent message consumers"
    - "Setting up pub/sub or fan-out patterns"
    - "Deciding between queues and Temporal workflows"
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

# Message Queues -- Async Messaging Patterns for Batuta Projects

## Purpose

Standardize how Batuta projects implement asynchronous messaging. This skill covers when to use message queues versus Temporal workflows, which queue technology fits each use case, and how to implement reliable message processing with retries, dead letter queues, and idempotency. It prevents the two most common failures: lost messages (no acknowledgment, no retry) and duplicate processing (no idempotency).

## When to Use

- **During sdd-design**: When the architecture includes asynchronous processing, event-driven communication, or decoupled services
- **During sdd-apply**: When implementing producers, consumers, or queue infrastructure
- **Queue vs Temporal decision**: When choosing between queue-based workers and Temporal workflow orchestration
- **On demand**: When debugging message processing failures or designing retry strategies

## Critical Patterns

### Pattern 1: Idempotent Consumer

Every message consumer MUST be idempotent. Messages can be delivered more than once (network retries, consumer crashes after processing but before acknowledgment). The consumer must produce the same result whether it processes a message once or ten times.

```python
"""Idempotent consumer: "exactly once" is impossible; we achieve "effectively once"."""

class IdempotentConsumer:
    """Check dedup table in a transaction, process only if message_id is new."""
    def __init__(self, db):
        self.db = db

    async def handle(self, message: dict):
        """Process message idempotently. Returns None if already processed."""
        msg_id = message["message_id"]
        # BUSINESS RULE: Check + process + record in one transaction prevents races.
        async with self.db.transaction():
            if await self.db.fetch_one(
                "SELECT 1 FROM processed_messages WHERE message_id = :id", {"id": msg_id}):
                return None
            result = await self.process(message)
            await self.db.execute(
                "INSERT INTO processed_messages (message_id, processed_at) VALUES (:id, now())",
                {"id": msg_id})
        return result

    async def process(self, message: dict):
        """Override with business logic."""
        raise NotImplementedError
```

```sql
-- Deduplication table. Purge daily: DELETE WHERE processed_at < now() - interval '7 days'
CREATE TABLE processed_messages (
    message_id TEXT PRIMARY KEY,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_processed_messages_ttl ON processed_messages (processed_at);
```

### Pattern 2: Dead Letter Queue with Structured Error Context

When a message fails after all retries, it goes to a Dead Letter Queue (DLQ) with full context about why it failed. DLQ messages are never silently dropped -- they require human investigation or automated recovery.

```python
"""DLQ: failed messages are never dropped -- they go to a dead letter queue with full context."""

async def send_to_dlq(original_message: dict, error: Exception,
                      queue_name: str, attempt_count: int, tenant_id: str):
    """Send failed message to DLQ with error context for investigation."""
    dlq_entry = {
        "original_message": original_message,
        "error": {"type": type(error).__name__, "message": str(error),
                  "trace_id": get_current_trace_id()},  # SECURITY: trace_id, not stack trace
        "metadata": {"source_queue": queue_name, "attempt_count": attempt_count,
                     "tenant_id": tenant_id, "failed_at": datetime.utcnow().isoformat()},
    }
    # BUSINESS RULE: DLQ entries stored in PostgreSQL for dashboard queries + in broker.
    await db.execute(
        """INSERT INTO dead_letter_queue (tenant_id, source_queue, payload, error_type, failed_at)
           VALUES (:t, :q, :p, :e, now())""",
        {"t": tenant_id, "q": queue_name, "p": json.dumps(dlq_entry),
         "e": type(error).__name__})
    await broker.publish("dlq." + queue_name, dlq_entry)
```

### Pattern 3: Exponential Backoff with Jitter

Retries without backoff cause "thundering herd" problems -- all failed messages retry at the same time, overloading the downstream service. Exponential backoff with jitter spreads retries over time.

```python
"""Exponential backoff with jitter: prevents thundering herd on retries."""
import random

# BUSINESS RULE: Retry policies per queue type (adjust max_retries by criticality).
RETRY_POLICIES = {
    "orders":        {"max_retries": 5, "base_delay_s": 1, "max_delay_s": 60},
    "notifications": {"max_retries": 3, "base_delay_s": 2, "max_delay_s": 30},
    "analytics":     {"max_retries": 2, "base_delay_s": 5, "max_delay_s": 60},
}

def calculate_backoff(attempt: int, base_delay: float, max_delay: float) -> float:
    """Full jitter backoff: random(0, min(base * 2^attempt, max_delay))."""
    return random.uniform(0, min(base_delay * (2 ** attempt), max_delay))
```

## Decision Trees

### Queue Technology Selection

| Situation | Technology | Why |
|-----------|-----------|-----|
| Task queues, complex routing, priority | **RabbitMQ** | Mature, rich routing (exchanges, bindings), priority queues, DLQ built-in |
| Already using Redis, simple pub/sub | **Redis Streams** | No extra infra, consumer groups, good for <100K msg/s |
| Event log, replay needed, high throughput | **Kafka** | Append-only log, replay from any offset, >1M msg/s |
| AWS-native, serverless consumers | **SQS + SNS** | Managed, auto-scaling, native Lambda triggers |
| Simple in-process background tasks | **asyncio.Queue** or **Celery** | No broker needed for single-process; Celery for multi-worker |

### Queue vs Temporal Decision

This is the most important decision in the Batuta stack. Getting it wrong means either overcomplicating simple tasks (Temporal for notifications) or under-engineering complex ones (queues for multi-step sagas).

| Situation | Use | Why |
|-----------|-----|-----|
| Fire-and-forget: send email, push notification | **Queue** | No coordination needed; simple consumer processes and acknowledges |
| Fan-out: same event to multiple consumers | **Queue** (pub/sub) | Each consumer processes independently |
| Multi-step saga: order → payment → shipment | **Temporal** | Needs compensation (rollback), state tracking, long-running |
| Human-in-the-loop: approval workflows | **Temporal** | Workflows can wait days/weeks for signals |
| Retry with complex conditions | **Temporal** | Activity-level retry policies, heartbeats, timeouts |
| Simple retry (3 attempts, then DLQ) | **Queue** | Built-in broker retry + DLQ is sufficient |
| Event sourcing, audit trail | **Kafka** | Immutable log, replay capability |

### Message Ordering Guarantees

| Requirement | Approach | Tradeoff |
|-------------|----------|----------|
| No ordering needed | Multiple consumers, max throughput | Best performance, no constraints |
| Per-entity ordering (all orders for customer X in sequence) | Partition by entity key | Limits parallelism per entity |
| Strict global ordering | Single consumer | No parallelism; bottleneck at high volume |
| Causal ordering (A before B, but C is independent) | Use message dependencies, not global order | Complex but best for most real-world scenarios |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| Processing without acknowledgment | Consumer crashes = message lost forever | ACK only after successful processing and dedup record |
| Infinite retry loops | Poison messages block the queue indefinitely | Set max_retries; send to DLQ after exhausting retries |
| Immediate retry (no backoff) | Overloads the downstream service that is already struggling | Exponential backoff with jitter |
| Non-idempotent consumers | Duplicate delivery = duplicate side effects (double charge, double email) | Use deduplication table pattern |
| Tenant ID not in message | Cannot route, filter, or isolate tenant messages | Always include tenant_id in message envelope |
| Synchronous RPC over queues | Adds latency and complexity vs a direct HTTP call | Use queues for async work; use HTTP for sync request/response |
| Publishing without outbox pattern | DB commit succeeds but publish fails = inconsistent state | Transactional outbox: write to DB outbox table, publish asynchronously |
| Giant message payloads (>1MB) | Queues are for routing, not data transfer | Store payload in S3/DB; send reference (ID/URL) in message |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| **Temporal** | Use `worker-scaffold` skill for Temporal workers; queues handle fire-and-forget tasks that Temporal is overkill for |
| **PostgreSQL** | Transactional outbox table; deduplication table; DLQ audit table |
| **FastAPI** | API endpoints publish to queues; never process async work inline in request handlers |
| **Coolify/Docker** | Queue consumers run as separate containers with independent scaling |
| **Observability** | Trace messages with OpenTelemetry; DLQ entries trigger Sentry alerts |
| **n8n** | n8n can consume from queues or publish events; use for workflow-triggered messaging |

## Code Examples

```python
# Example: Transactional outbox -- atomic DB commit + message publish
async def create_order_with_outbox(order_data: dict, tenant_id: str):
    """Write order + outbox event in one transaction. Worker polls outbox to publish."""
    async with db.transaction():
        order = await order_repo.create(order_data, tenant_id)
        # BUSINESS RULE: Outbox row in same transaction guarantees consistency.
        await db.execute(
            "INSERT INTO outbox (event_type, payload, tenant_id) VALUES (:t,:p,:tid)",
            {"t": "order.created", "tid": tenant_id,
             "p": json.dumps({"order_id": str(order.id), "tenant_id": tenant_id})})
    return order
```

```python
# Example: Multi-tenant RabbitMQ routing -- per-tenant queues with DLQ
async def setup_tenant_routing(channel, tenant_ids: list[str]):
    """Topic exchange routes by tenant_id; per-tenant queues with DLQ on failure."""
    await channel.exchange_declare("events", "topic", durable=True)
    for tid in tenant_ids:
        await channel.queue_declare(f"orders.{tid}", durable=True, arguments={
            "x-dead-letter-exchange": "dlq",
            "x-dead-letter-routing-key": f"dlq.orders.{tid}"})
        await channel.queue_bind(f"orders.{tid}", "events", routing_key=f"order.*.{tid}")
```

## Commands

```bash
# Start RabbitMQ with management UI (Docker)
docker run -d -p 5672:5672 -p 15672:15672 rabbitmq:3-management

# RabbitMQ management UI
# http://localhost:15672 (guest/guest)

# List queues and message counts
docker exec rabbitmq rabbitmqctl list_queues name messages consumers

# Monitor Redis Streams
redis-cli XINFO STREAM mystream
redis-cli XINFO GROUPS mystream

# Check DLQ depth (PostgreSQL)
psql -c "SELECT source_queue, count(*) FROM dead_letter_queue GROUP BY source_queue"
```

## Rules

- MUST implement idempotent consumers using a deduplication table -- assume every message can be delivered more than once
- MUST use exponential backoff with jitter for retries -- never immediate retry
- MUST send failed messages to a Dead Letter Queue after exhausting retries -- never drop messages silently
- MUST include `tenant_id` and `message_id` in every message envelope
- MUST use the transactional outbox pattern when a DB write and queue publish must be atomic
- MUST evaluate Queue vs Temporal using the decision tree before implementing -- see `worker-scaffold` skill for Temporal patterns
- NEVER process async work inline in HTTP request handlers -- publish to a queue and return 202 Accepted
- NEVER send payloads larger than 256KB through the queue -- store the payload externally and send a reference
- NEVER use synchronous RPC over queues -- use HTTP for request/response patterns
- MUST acknowledge messages only after successful processing and deduplication record -- never auto-ACK

## What This Means (Simply)

> **For non-technical readers**: Message queues are like the "to-do inbox" between different parts of our software. When one part finishes its work and needs another part to take action (e.g., "send a confirmation email"), it drops a note in the inbox instead of waiting. This makes the system faster (the first part does not wait) and more reliable (if the second part is busy, the note stays in the inbox until it is ready). This skill ensures that notes are never lost (dead letter queues catch failures), never processed twice (idempotency), and each customer's notes stay separate (tenant isolation). Think of it as the postal service rules for our software's internal mail system.
