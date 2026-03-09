---
name: fastapi-crud
description: >
  Use when building REST APIs with FastAPI, creating CRUD endpoints.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-23"
  scope: [pipeline]
  auto_invoke: "Creating FastAPI CRUD endpoints, REST API routes"
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep Write Edit
---

## Purpose

You are a skill for generating **FastAPI CRUD endpoints** following Batuta conventions.
Given a domain/resource name and its fields, you produce the complete set of files:
models, Pydantic schemas, service layer, and API routes.

All generated code follows:
- **Scope Rule**: files go in `features/{domain}/` structure
- **Documentation standard**: every file has module docstring, every function has docstring
- **User isolation**: queries filter by authenticated user when applicable
- **Pagination**: list endpoints support `skip` and `limit` with validation

## Input

From the caller:
- **Resource name** (e.g., "task", "product", "order")
- **Fields** with types (e.g., `title: str`, `status: enum[pending,done]`, `due_date: datetime | None`)
- **Relations** (e.g., "belongs to user", "has many tags")
- **User-scoped?** (whether queries filter by current user)

## Steps

### Step 1: Generate Model

Create `features/{resource}/models/{resource}.py`:

```python
"""
{Resource} database model — SQLAlchemy ORM definition.

Defines the {Resource} table with its columns, relationships, and constraints.
Business context: {why this entity exists in the domain}.
"""
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from core.database import Base

class {Resource}(Base):
    __tablename__ = "{resources}"
    # ... columns from input fields
```

### Step 2: Generate Schemas

Create `features/{resource}/schemas/{resource}.py`:

```python
"""
{Resource} Pydantic schemas — request/response validation.

Separates Create, Update, and Response schemas to enforce
what clients can send vs. what they receive.
"""
from pydantic import BaseModel, Field

class {Resource}Create(BaseModel):
    """Schema for creating a new {resource}. Validates required fields."""
    # ... fields from input

class {Resource}Update(BaseModel):
    """Schema for updating a {resource}. All fields optional."""
    # ... optional fields

class {Resource}Response(BaseModel):
    """Schema for API responses. Includes id and timestamps."""
    # ... all fields + id + created_at
    model_config = ConfigDict(from_attributes=True)
```

### Step 3: Generate Service

Create `features/{resource}/services/{resource}_service.py`:

```python
"""
{Resource} service layer — business logic separated from HTTP concerns.

Handles CRUD operations with user isolation (if applicable),
pagination, and error handling. Database session managed by caller.
"""
from sqlalchemy.orm import Session

def create_{resource}(db: Session, data: {Resource}Create, user_id: int) -> {Resource}:
    """Create a new {resource} owned by user_id.

    Args:
        db: Database session (caller manages lifecycle)
        data: Validated creation data
        user_id: Owner's ID for data isolation

    Returns:
        The created {Resource} instance
    """
    # ... implementation

def get_{resources}(db: Session, user_id: int, skip: int = 0, limit: int = 20) -> list[{Resource}]:
    """List {resources} for a specific user with pagination.

    Args:
        db: Database session
        user_id: Filter by owner
        skip: Offset for pagination (default: 0)
        limit: Max results (default: 20, capped at 100)

    Returns:
        List of {Resource} instances
    """
    # ... implementation with .offset(skip).limit(min(limit, 100))
```

### Step 4: Generate Routes

Create `features/{resource}/routes/{resource}_routes.py`:

```python
"""
{Resource} API routes — FastAPI router for {resource} CRUD operations.

All endpoints require authentication. Data is isolated per user.
Follows RESTful conventions: POST (create), GET (list/detail), PUT (update), DELETE (remove).
"""
from fastapi import APIRouter, Depends, HTTPException, Query

router = APIRouter(prefix="/{resources}", tags=["{Resources}"])

@router.post("/", response_model={Resource}Response, status_code=201)
def create_{resource}(data: {Resource}Create, ...):
    """Create a new {resource} for the authenticated user."""
    # ... implementation

@router.get("/", response_model=list[{Resource}Response])
def list_{resources}(skip: int = Query(0, ge=0), limit: int = Query(20, ge=1, le=100), ...):
    """List {resources} with pagination. Returns only the current user's data."""
    # ... implementation
```

### Step 5: Register Router

Update `core/main.py` to include the new router:
```python
app.include_router({resource}_router)
```

## Output

Return list of files created with their paths.

## Rules

- ALWAYS generate module docstrings explaining business context
- ALWAYS generate function docstrings with Args/Returns
- ALWAYS add inline comments for non-obvious business logic
- ALWAYS use Scope Rule: `features/{resource}/` structure
- ALWAYS validate pagination limits (cap at 100)
- ALWAYS filter by user_id when resource is user-scoped
- NEVER use `from_orm` (deprecated) — use `model_config = ConfigDict(from_attributes=True)`
- NEVER use `datetime.utcnow()` (deprecated) — use `datetime.now(datetime.UTC)`
- Service layer MUST be separate from routes (thin controllers, fat services)
