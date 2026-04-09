---
name: supabase-python
description: >
  Patterns for using Supabase with Python (supabase-py SDK).
  Trigger: "Supabase", "supabase-py", "Supabase Python", "Supabase insert", "Supabase select",
  "RLS", "service_role key", "pgvector Supabase".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-04-07"
  scope: [capability]
  auto_invoke: "When working with Supabase from Python"
  platforms: [claude]
  category: "capability"
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

Setup and usage patterns for Supabase with Python. Covers connection, CRUD, RLS, async, pgvector, and common pitfalls from GitHub issues.

## When to Use

- Connecting to Supabase from Python (sync or async)
- Writing queries (insert, select, update, upsert)
- Setting up tables and migrations
- Using pgvector for embeddings

## Critical Patterns

### Pattern 1: Connection (Backend with service_role)

```python
from supabase import create_client, Client

supabase: Client = create_client(
    os.environ["SUPABASE_URL"],
    os.environ["SUPABASE_SERVICE_ROLE_KEY"],  # ALWAYS service_role for backend
)
```

NEVER use `anon` key in backend. With RLS enabled and no policies, anon key returns empty results silently (Issue #845).

### Pattern 2: CRUD Operations

```python
# INSERT
response = supabase.table("conversations").insert({
    "group_jid": group_jid,
    "sender_jid": sender_jid,
    "content": text,
    "role": "user",
}).execute()

# SELECT with filters
response = (
    supabase.table("conversations")
    .select("*")
    .eq("group_jid", group_jid)
    .order("created_at", desc=True)
    .limit(20)
    .execute()
)
messages = response.data  # list of dicts

# UPSERT
response = (
    supabase.table("sessions")
    .upsert({"group_jid": group_jid, "last_active": "now()", "message_count": count})
    .execute()
)

# UPDATE with filter
response = (
    supabase.table("alerts")
    .update({"delivery_status": "delivered"})
    .eq("id", alert_id)
    .execute()
)
```

### Pattern 3: Async Client (for FastAPI)

```python
from supabase._async.client import AsyncClient, create_client as acreate_client

# In lifespan
supabase_client: AsyncClient | None = None

async def get_supabase() -> AsyncClient:
    global supabase_client
    if supabase_client is None:
        supabase_client = await acreate_client(
            os.environ["SUPABASE_URL"],
            os.environ["SUPABASE_SERVICE_ROLE_KEY"],
        )
    return supabase_client
```

### Pattern 4: Create Tables via SQL Editor

Paste the full `.sql` migration file into Dashboard → SQL Editor → Run. Works for initial setup. For iterative changes use Supabase CLI (`supabase migration new` + `supabase db push`).

### Pattern 5: pgvector for Future RAG

```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;

-- Add embedding column
ALTER TABLE conversations ADD COLUMN embedding extensions.vector(1536);

-- Create search function (PostgREST doesn't support vector ops directly)
CREATE FUNCTION buscar_similares(query_embedding vector(1536), match_count int DEFAULT 5)
RETURNS TABLE (id bigint, content text, similarity float)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT c.id, c.content, 1 - (c.embedding <=> query_embedding) as similarity
  FROM conversations c ORDER BY c.embedding <=> query_embedding LIMIT match_count;
END;
$$;
```

Call from Python: `supabase.rpc("buscar_similares", {"query_embedding": [...], "match_count": 5}).execute()`

## Gotchas (Verified)

1. **RLS + anon key = silent empty results** — Use `service_role` key for backend. Most reported bug (Issue #845).
2. **Free tier: 500MB storage** — ~6-12 months for 7 WhatsApp groups. Plan rotation or upgrade.
3. **Project pauses after 7 days of inactivity** — Keep alive with periodic requests.
4. **v2.24.0 AsyncClientOptions bug** — Use `AsyncClientOptions` not `ClientOptions` for async (Issue #1306).
5. **Connection hangs on exit** — Auth token refresh timer doesn't stop. Call `client.auth.sign_out()` in scripts.
6. **pgvector requires SQL function + rpc()** — PostgREST doesn't support vector operators directly.
7. **API requests are unlimited** on free tier — no rate limiting concern for 7 groups.
