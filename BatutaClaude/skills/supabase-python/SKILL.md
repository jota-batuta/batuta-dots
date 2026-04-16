---
name: supabase-python
description: >
  Patterns for using Supabase with Python (supabase-py SDK).
  Trigger: "Supabase", "supabase-py", "Supabase Python", "Supabase insert", "Supabase select",
  "RLS", "service_role key", "pgvector Supabase".
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-04-07"
  bucket: build
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

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "The anon key is fine for the backend -- I'll add RLS policies later" | Anon key + no RLS = silent empty results on every read (Issue #845). The query does not error; it just returns `[]`. You will spend hours debugging "why is my data missing" before realizing the key never had access in the first place. Use `service_role` from day one |
| "RLS is extra work -- the backend already validates user identity" | Backend validation breaks the moment a script connects directly with the wrong key, an admin tool runs without scoping, or a future endpoint forgets a check. RLS is a database-level guardrail that catches every one of those. It is not extra work; it is the work that prevents data leaks |
| "I'll keep the connection alive between calls -- the SDK is async" | The Supabase async client has a known background timer (auth refresh) that prevents process exit. In scripts and serverless contexts you must call `client.auth.sign_out()` or the process hangs. Long-running services need explicit lifespan management |
| "PostgREST handles vector queries -- I can use `.eq()` on embeddings" | PostgREST does not expose vector operators. You must wrap the query in a SQL function (`buscar_similares`) and call it via `.rpc()`. Trying to filter `embedding` directly returns an error or silently returns nothing |
| "Free tier is fine forever -- 500MB is a lot" | 500MB is ~6-12 months of conversation history for a small workload. Plan rotation, archival, or a paid tier upgrade BEFORE you hit the wall, not after the project is paused |

## Red Flags

- `SUPABASE_ANON_KEY` used in any backend code (only `SUPABASE_SERVICE_ROLE_KEY` belongs there)
- Table created without an RLS policy (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY` + at least one policy)
- Async script that exits with a hanging process (forgot to call `client.auth.sign_out()`)
- Direct `.eq("embedding", ...)` filter on a vector column (must use SQL function + `.rpc()`)
- Connection created inside a request handler instead of a singleton in lifespan
- `ClientOptions` instead of `AsyncClientOptions` when using the async client (v2.24.0 bug)
- Service deployed without monitoring storage growth toward the 500MB free-tier cap
- Migration applied via SQL Editor without being committed to the repo (`supabase/migrations/`)
- Project that has been idle for 6+ days without a keep-alive ping (auto-pauses at 7 days)
- Production code reading directly from `supabase` global without dependency injection (untestable)

## Verification Checklist

- [ ] Backend uses `SUPABASE_SERVICE_ROLE_KEY` only; the anon key is reserved for browser code
- [ ] Every table has RLS enabled AND at least one policy that explicitly defines who can read/write
- [ ] Async clients are managed in FastAPI lifespan and reused across requests (not created per-call)
- [ ] Async scripts call `await client.auth.sign_out()` before exit to release the auth refresh timer
- [ ] Vector similarity queries go through SQL functions invoked via `.rpc()`, never direct `.eq()` on vector columns
- [ ] All migration SQL is committed under `supabase/migrations/` with a timestamp prefix
- [ ] A keep-alive job pings the project at least every 5 days to prevent auto-pause on free tier
- [ ] Storage usage is monitored and approaching 500MB triggers a rotation/archival job (or upgrade)
- [ ] Async client uses `AsyncClientOptions` (NOT `ClientOptions`) per the v2.24.0+ API
- [ ] Database access is wrapped in a repository or service layer for testability (no `from supabase_client import supabase` scattered throughout the codebase)
