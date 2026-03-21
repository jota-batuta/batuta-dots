# Notion KB Schema — Batuta Knowledge Base

<!-- BUSINESS RULE: This file is the single source of truth for the structure of
     entries written to Notion KB. Any agent or hook that writes to KB must follow
     this schema. Without a formal contract, the KB becomes a free-text dump that
     is impossible to query systematically in sdd-explore Step 2.8. -->

## Database Identifier

- **Notion Database**: KB
- **data_source_id**: `58433974-5511-45b8-bd09-54551f6c0c23`
- **Written by**: Stop hook Step 2 (automatic) + sdd-archive Step 5.5 (user-approved)
- **Read by**: sdd-explore Step 2.8 (Approach Research)

---

## Field Schema

| Field | Notion Type | Required | Description |
|-------|------------|----------|-------------|
| **Title** | Title | YES | `[Tipo] Brief description` — see Title Conventions below |
| **Campo** | Select | YES | Technical domain — see Campo Values below |
| **Tipo** | Select | YES | Category of knowledge — see Tipo Values below |
| **Confianza** | Select | YES | Evidence level — see Confianza Values below |
| **Descripción** | Rich Text | YES | Pattern + evidence + solution (free text, substantive) |
| **Date_Discovered** | Date | YES | `YYYY-MM-DD` when discovered/verified |
| **Project** | Rich Text | NO | Source project(s) where confirmed (helps gauge applicability) |
| **Status** | Select | NO | `Active \| Deprecated` — mark old entries when superseded |

---

## Title Conventions

Format: `[Tipo] Brief description (max 80 chars)`

| Tipo | Example Title |
|------|--------------|
| Gotcha | `[Gotcha] pyodbc pooling=False must precede engine creation` |
| Decisión | `[Decisión] Use AsyncAnthropic in FastAPI endpoints` |
| Workaround | `[Workaround] Windows PYTHONPATH for pytest in Git Bash` |
| Edge Case | `[Edge Case] SQLAlchemy session not thread-safe per request` |
| Patrón | `[Patrón] Repository pattern for FastAPI + SQLAlchemy` |

---

## Campo Values (technical domain)

Use the most specific applicable domain. If multiple apply, pick the primary one.

| Campo | Covers |
|-------|--------|
| `python-async` | asyncio, async/await, event loops, async libraries |
| `python-database` | SQLAlchemy, pyodbc, psycopg2, connection pooling |
| `python-fastapi` | FastAPI patterns, dependencies, lifespan, middleware |
| `python-testing` | pytest, fixtures, mocking, PYTHONPATH, test config |
| `python-general` | stdlib, packaging, imports, general Python gotchas |
| `typescript-node` | TypeScript, Node.js, ESM, build tooling |
| `react-nextjs` | React, Next.js App Router, server components |
| `docker` | Dockerfile, Compose, networking, volumes |
| `git` | Git commands, hooks, workflow, Windows paths |
| `claude-code` | Claude Code CLI, hooks, skills, agents, settings |
| `notion` | Notion API, MCP server, schema, blocks |
| `n8n` | n8n workflows, nodes, credentials, execution |
| `sql` | SQL queries, migrations, schema design |
| `auth` | JWT, OAuth, sessions, credentials |
| `deployment` | Coolify, reverse proxy, env vars, production |
| `security` | OWASP, secrets, injection, CORS |
| `general` | Cross-cutting patterns that don't fit a specific domain |

---

## Tipo Values

| Tipo | When to Use |
|------|-------------|
| `Gotcha` | Unexpected behavior, trap, or non-obvious constraint discovered through failure |
| `Decisión` | Architecture or design decision with trade-off analysis |
| `Workaround` | Temporary fix for a known limitation (implies a better solution exists) |
| `Edge Case` | Behavior that differs from expected in specific conditions |
| `Patrón` | Reusable solution pattern that works well in this tech stack |

---

## Confianza Values

| Confianza | Evidence Required |
|-----------|-----------------|
| `High` | Confirmed by error message, test output, official docs, or benchmarks |
| `Medium` | Inferred from behavior, partially verified, or single occurrence |
| `Low` | Hypothesis or preliminary observation — not yet confirmed by evidence |

---

## Descripción Template

Write the Descripción field with this structure (adapt as needed):

```
**Problem**: What fails or is unexpected?
**Root Cause**: Why does it happen?
**Solution**: What to do instead.
**Evidence**: {error message | test output | doc link | benchmark result}
**Applies to**: {tech stack conditions where this is relevant}
```

Example:
```
**Problem**: Creating a SQLAlchemy engine inside a FastAPI route function causes
massive connection overhead and the pool never reuses connections.

**Root Cause**: Each request creates a new engine with its own pool. Engine creation
is expensive (~100ms) and the pool is thrown away after each request.

**Solution**: Create the engine once at app startup (inside `@asynccontextmanager lifespan`
or `@app.on_event("startup")`). Inject a session factory via FastAPI `Depends()`.

**Evidence**: Error "connection pool size exceeded" + 50x latency increase measured in
inventory-agent (2026-02-25). Fixed by moving engine to lifespan event.

**Applies to**: Any FastAPI project using SQLAlchemy (sync or async).
```

---

## Persist Decision Rule (for Stop hook Step 2)

**Binary test**: Would this help a future agent on a DIFFERENT project with SIMILAR technology?

```
YES or MAYBE → persist (duplicates are cheaper than repeated re-discovery)
NO           → skip
```

**Always persist:**
- Bugs + root cause + fix (even if project-specific — the pattern transfers)
- Library/version constraints and ordering dependencies
- Integration gotchas (library A + library B together)
- Architecture decisions with explicit trade-off evidence

**Never persist:**
- Step counters (`"estoy en 3/5"`)
- Project-specific file paths
- Timestamps and session metadata
- Trivial observations without root cause

---

## Querying the KB in sdd-explore Step 2.8

When searching Notion KB for Approach Research:

1. Search by **Campo** matching the project's tech stack
2. Search by keywords in **Title** and **Descripción**
3. Filter by **Confianza = High** first (most reliable)
4. Check **Status ≠ Deprecated** to avoid stale patterns
5. Include relevant findings in `explore.md` under `## Approach Research`

If Notion MCP is not available, note explicitly in explore.md:
```
**Notion KB**: Not consulted (MCP not configured — set OPENAPI_MCP_HEADERS to enable).
Past project gotchas not available for this session.
```
