---
name: api-design
description: >
  Use when designing REST APIs: endpoints, status codes, versioning, pagination, error format.
  Trigger: "designing API", "REST endpoints", "API versioning", "error responses",
  "pagination strategy", "OpenAPI spec", "API rate limiting".
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-26"
  bucket: build
  auto_invoke:
    - "Designing REST API endpoints or resources"
    - "Choosing pagination, versioning, or error format strategy"
    - "Creating OpenAPI/Swagger specification"
    - "Implementing rate limiting or HATEOAS"
    - "Multi-tenant API route design"
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

# API Design -- REST Conventions for Batuta Projects

## Purpose

Enforce consistent REST API design across Batuta projects. This skill standardizes how endpoints are named, how errors are returned (RFC 9457, the successor to RFC 7807), how pagination works, and how multi-tenant isolation is achieved at the API layer. It prevents the "every developer invents their own format" problem that makes APIs hard to integrate and maintain.

## When to Use

- **During sdd-design**: When the change involves new API endpoints or modifying existing ones
- **During sdd-apply**: When implementing route handlers, middleware, or API responses
- **On demand**: When reviewing API contracts or creating OpenAPI specs
- **Integration work**: When connecting frontends, mobile apps, or third-party services

## Critical Patterns

### Pattern 1: RFC 9457 Error Responses (Problem Details)

Every API error MUST use the `application/problem+json` media type. This replaces ad-hoc error formats and gives clients a machine-readable, consistent structure.

```json
{
  "type": "https://api.example.com/errors/insufficient-stock",
  "title": "Insufficient Stock",
  "status": 422,
  "detail": "Product SKU-1234 has 3 units available but 10 were requested.",
  "instance": "/orders/abc-123",
  "tenant_id": "tenant-acme",
  "errors": [
    {
      "pointer": "/items/0/quantity",
      "detail": "Requested quantity exceeds available stock"
    }
  ]
}
```

```python
# BUSINESS RULE: All API errors use RFC 9457 format for consistency across clients.
from fastapi import Request
from fastapi.responses import JSONResponse

class ProblemDetail(Exception):
    """RFC 9457 Problem Details error response."""
    def __init__(self, type_uri: str, title: str, status: int,
                 detail: str, instance: str = None, **extensions):
        self.type_uri = type_uri
        self.title = title
        self.status = status
        self.detail = detail
        self.instance = instance
        self.extensions = extensions

async def problem_detail_handler(request: Request, exc: ProblemDetail):
    """Convert ProblemDetail exceptions to RFC 9457 JSON responses."""
    body = {"type": exc.type_uri, "title": exc.title,
            "status": exc.status, "detail": exc.detail}
    if exc.instance:
        body["instance"] = exc.instance
    body.update(exc.extensions)
    return JSONResponse(status_code=exc.status, content=body,
                        media_type="application/problem+json")
```

### Pattern 2: Cursor-Based Pagination (Default)

Cursor pagination prevents the "skipping rows" problem that offset pagination has when data changes between requests. Use offset only for admin/backoffice UIs where users need to jump to arbitrary pages.

```python
# BUSINESS RULE: Cursor pagination is the default. Offset only for backoffice admin views.
from pydantic import BaseModel
from typing import Optional, List, TypeVar, Generic

T = TypeVar("T")

class CursorPage(BaseModel, Generic[T]):
    """Cursor-paginated response envelope."""
    data: List[T]
    next_cursor: Optional[str] = None  # Opaque cursor; null = last page
    has_more: bool = False
# Usage: GET /api/v1/products?cursor=eyJpZCI6MTAwfQ&limit=20
```

### Pattern 3: Multi-Tenant Route Isolation

Tenant context comes from a verified JWT claim or a header validated by middleware -- never from the URL path. This prevents tenant ID spoofing and keeps routes clean.

```python
# SECURITY: Tenant ID is extracted from verified JWT, never from URL or user input.
async def get_tenant(x_tenant_id: str = Header(...),
                     token_claims: dict = Depends(verify_jwt)):
    """Validate that header tenant matches JWT claim. Prevents cross-tenant access."""
    if x_tenant_id != token_claims.get("tenant_id"):
        raise ProblemDetail(type_uri="/errors/tenant-mismatch",
            title="Tenant Mismatch", status=403,
            detail="Header tenant does not match authenticated tenant.")
    return x_tenant_id
```

### Principle: Hyrum's Law

> "With a sufficient number of users of an API, it does not matter what you promise in the contract — all observable behaviors will be depended on by somebody."

This means treating every public behavior — including undocumented quirks — as a de facto commitment. Design for extension, not modification. Additive changes are safe; breaking changes require versioning.

### Pattern: Type-Level Safety

Use type system features to prevent bugs at compile time:

```typescript
// Discriminated unions clarify variant types
type Result =
  | { type: "success"; data: User }
  | { type: "error"; code: string; message: string };
// NOT: { data: User | null; error: string | null }  // ambiguous

// Input/output separation prevents ID confusion
type CreateUserInput = { name: string; email: string };  // No ID (server generates)
type UserOutput = { id: UUID; name: string; email: string };  // Server ID in response

// Branded types prevent ID mix-ups across entities
type UserId = string & { readonly __brand: "UserId" };
type OrderId = string & { readonly __brand: "OrderId" };
// Compiler catches: getUser(orderId)  // Type error!
```

## Decision Trees

### Versioning Strategy

| Situation | Approach | Why |
|-----------|----------|-----|
| Breaking change (field removed, type changed) | URL path: `/api/v2/resource` | Explicit, cacheable, easy to route in reverse proxy |
| Additive change (new optional field) | No version bump needed | Adding fields is backward-compatible |
| Experimental endpoint | Header: `X-API-Version: 2-beta` | Avoids polluting URL namespace with unstable versions |
| Internal microservice-to-microservice | No versioning, deploy together | Co-deployed services share release cycle |

### Pagination Strategy

| Situation | Approach | Why |
|-----------|----------|-----|
| Public API, mobile clients | Cursor-based | Stable under concurrent writes, efficient for "load more" |
| Admin dashboard with page numbers | Offset-based | Users expect "page 3 of 10" navigation |
| Real-time feed (chat, notifications) | Cursor + timestamp | Enables "since last seen" queries |
| Full dataset export | Keyset pagination (WHERE id > last_id) | No performance degradation on deep pages |

### HTTP Method Selection

| Operation | Method | Status (success) | Idempotent? |
|-----------|--------|-------------------|-------------|
| List resources | GET | 200 | Yes |
| Get single resource | GET | 200 | Yes |
| Create resource | POST | 201 + Location header | No |
| Full update (replace) | PUT | 200 | Yes |
| Partial update | PATCH | 200 | No |
| Delete resource | DELETE | 204 (no body) | Yes |
| Check existence | HEAD | 200 / 404 | Yes |
| Long-running operation | POST + 202 Accepted | 202 + status URL | No |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| Verbs in URLs: `/api/getUsers` | REST uses nouns; HTTP methods convey the action | `GET /api/v1/users` |
| Returning 200 with `{"error": "not found"}` | Clients cannot distinguish success from failure by status code | Return 404 with RFC 9457 body |
| Tenant ID in URL path: `/api/tenants/{id}/...` | Exposes tenant structure, risks enumeration attacks | Extract from JWT claims |
| Nested resources deeper than 2 levels | URLs become unreadable and rigid | `/orders/{id}/items` is fine; flatten beyond that |
| Returning different error shapes per endpoint | Clients need per-endpoint error parsing | Use RFC 9457 everywhere |
| `PUT` for partial updates | PUT means "replace entire resource"; partial data deletes omitted fields | Use PATCH for partial updates |
| Pagination without `has_more` or total count | Client cannot know when to stop fetching | Always include `has_more` in cursor; include `total` in offset |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| **FastAPI** | Use `fastapi-crud` skill patterns for CRUD routers; this skill adds conventions on top |
| **PostgreSQL + RLS** | Tenant isolation at DB level complements API-level tenant validation |
| **Coolify/Docker** | API versioning via URL path enables blue-green deploys per version |
| **OpenAPI** | Auto-generate from FastAPI; use `servers` field for environment URLs |
| **n8n Webhooks** | Webhook endpoints follow same error format; n8n parses RFC 9457 for error handling |

## Code Examples

```python
# Example: FastAPI router combining all Batuta API conventions
router = APIRouter(prefix="/api/v1/products", tags=["products"])

@router.get("", response_model=CursorPage[ProductOut])
async def list_products(
    cursor: str = Query(None), limit: int = Query(20, ge=1, le=100),
    tenant: str = Depends(get_tenant),
):
    """List products with cursor pagination and tenant isolation."""
    # BUSINESS RULE: RLS on PostgreSQL filters by tenant automatically.
    products, next_cursor = await product_repo.list_paginated(
        tenant_id=tenant, cursor=cursor, limit=limit)
    return CursorPage(data=products, next_cursor=next_cursor,
                      has_more=next_cursor is not None)

@router.post("", status_code=201, response_model=ProductOut)
async def create_product(body: ProductCreate, tenant: str = Depends(get_tenant)):
    """Create product. Returns 201 + Location header."""
    return await product_repo.create(tenant_id=tenant, data=body)
```

```
# Rate limit headers (MUST include on all public endpoints):
# X-RateLimit-Limit: 100 | X-RateLimit-Remaining: 42 | X-RateLimit-Reset: <unix_ts>
# When exceeded: 429 Too Many Requests + Retry-After header
```

## Commands

```bash
# Generate OpenAPI spec from FastAPI app
python -m app.main --export-openapi > openapi.json

# Validate OpenAPI spec with Spectral
npx @stoplight/spectral-cli lint openapi.json

# Test API endpoints with httpie
http GET localhost:8000/api/v1/products cursor==abc limit==20 "Authorization: Bearer $TOKEN"
```

## Rules

- MUST use RFC 9457 (Problem Details) for ALL error responses -- no custom error shapes
- MUST use cursor-based pagination for public-facing list endpoints
- MUST extract tenant context from verified JWT claims, never from URL path or unvalidated headers
- MUST include rate limit headers (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`) on public endpoints
- MUST return `201 Created` with Location header for POST resource creation
- MUST return `204 No Content` (empty body) for successful DELETE operations
- NEVER use verbs in URL paths -- REST resources are nouns
- NEVER nest resources deeper than two levels (`/parents/{id}/children` is the deepest)
- MUST version via URL path (`/api/v1/`) for breaking changes; additive changes need no version bump

## What This Means (Simply)

> **For non-technical readers**: This skill ensures that every API we build "speaks the same language." When something goes wrong, every endpoint reports errors in the same standard format (like a standardized incident report). When a client asks for a list of items, pagination always works the same way. When we have multiple customers (tenants), each one can only see their own data. Think of it as a style guide for how our software talks to other software -- consistency means fewer bugs, faster integrations, and happier developers.

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "REST conventions don't matter for internal APIs -- only the team will use them" | Internal APIs become external APIs the moment a second service or BFF is added. Inconsistency forces every new consumer to learn a one-off contract; the rewrite cost dwarfs what consistency would have cost upfront |
| "Returning HTTP 200 with `{ok: false}` is fine, the body tells the story" | Status codes are part of the contract. Monitoring, retries, circuit breakers, log dashboards, and HTTP middleware key off the status. A 200 with an error body silently breaks alerting and confuses every observability tool downstream |
| "Putting tenant_id in the URL path is convenient and explicit" | URL-based tenant IDs are user-controlled input. They invite enumeration attacks (`/tenants/1`, `/tenants/2`...) and force defensive checks at every endpoint. Verified JWT claims are tamper-proof and centralize the trust boundary |
| "Versioning can wait until we have v2 -- right now we have one client" | The first breaking change without a version is a multi-day coordinated deploy across every consumer. Adding `/v1/` from day one costs nothing and buys you the option to ship `/v2/` in parallel later |
| "Cursor pagination is overkill, offset works for our small dataset" | Offset breaks the moment data changes between requests (skipped or duplicated rows during scroll). It also degrades quadratically on deep pages. Cursor pagination is the same amount of code and avoids both problems forever |

## Red Flags

- An endpoint that returns 200 with `{"error": "..."}` in the body
- Tenant ID extracted from URL path or unvalidated header
- Custom error format that does not match RFC 9457 / `application/problem+json`
- POST that returns the resource without a `Location` header or 201 status
- DELETE that returns a body or 200 status (should be 204 No Content)
- Verbs in URL paths (`/api/getUsers`, `/api/createOrder`)
- Resources nested 3+ levels deep (`/orgs/{a}/teams/{b}/users/{c}/settings`)
- Pagination response without `has_more` or `next_cursor`
- Public endpoint without rate limit headers (`X-RateLimit-*`)
- Breaking change shipped without a version bump in the URL path

## Verification Checklist

- [ ] All error responses use `application/problem+json` (RFC 9457) with `type`, `title`, `status`, `detail` fields
- [ ] Tenant context is extracted from a verified JWT claim or middleware-validated header, never from URL path
- [ ] Public list endpoints use cursor-based pagination with `next_cursor` and `has_more` fields
- [ ] POST resource creation returns 201 + `Location` header pointing to the new resource
- [ ] DELETE returns 204 with empty body on success
- [ ] URL paths use nouns (resources), not verbs -- HTTP methods carry the action
- [ ] Resource nesting is at most 2 levels deep
- [ ] Breaking changes ship under a new URL version (`/api/v2/`); additive changes do not bump versions
- [ ] Rate limit headers (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`) are present on public endpoints
- [ ] OpenAPI spec is generated from the framework (FastAPI, etc.) and validated with Spectral or similar linter
