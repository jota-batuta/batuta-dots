---
name: sqlalchemy-models
description: >
  Use when creating database models or ORM relationships with SQLAlchemy.
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-23"
  bucket: build
  auto_invoke: "Creating SQLAlchemy models, database relationships, ORM patterns"
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep Write Edit
---

## Purpose

You are a skill for generating **SQLAlchemy models and database infrastructure**
following Batuta conventions. Given a data model description, you produce the
complete database layer: Base class, models with relationships, session management,
and optionally Alembic migration setup.

## Input

From the caller:
- **Entities** with their fields and types
- **Relationships** (one-to-many, many-to-many, self-referential)
- **Database engine** (PostgreSQL for production, SQLite for testing)
- **Multi-tenant?** (whether RLS policies are needed)

## Steps

### Step 1: Generate Database Core

Create `core/database.py`:

```python
"""
Database configuration — SQLAlchemy engine, session, and Base class.

Provides the foundational database infrastructure:
- Engine creation from DATABASE_URL environment variable
- Session factory for dependency injection
- Declarative Base for all ORM models

Supports PostgreSQL (production) and SQLite (testing) via URL configuration.
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# Engine configuration
# NOTE: For SQLite, connect_args={"check_same_thread": False} is required
# because SQLite by default only allows the creating thread to use the connection
engine = create_engine(DATABASE_URL, **engine_args)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    """Provide a database session for dependency injection.

    Yields:
        Session: SQLAlchemy session that auto-closes after use

    Usage:
        @router.get("/items")
        def list_items(db: Session = Depends(get_db)):
            return db.query(Item).all()
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### Step 2: Generate Models

For each entity, create `features/{domain}/models/{entity}.py`:

```python
"""
{Entity} model — {business context for this entity}.

Table: {table_name}
Relationships: {list key relationships}
Constraints: {list key constraints like unique, not null}
"""
```

#### Relationship Patterns

**One-to-Many** (e.g., User has many Tasks):
```python
# In User model:
# A user can own multiple tasks — cascade delete removes orphaned tasks
tasks = relationship("Task", back_populates="owner", cascade="all, delete-orphan")

# In Task model:
# SECURITY: user_id enforces data isolation — every task belongs to exactly one user
user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
owner = relationship("User", back_populates="tasks")
```

**Many-to-Many** (e.g., Task has many Tags):
```python
# Association table — no model class needed for simple M2M
# WHY a separate table: allows a task to have multiple tags and a tag
# to appear on multiple tasks without data duplication
task_tags = Table(
    "task_tags",
    Base.metadata,
    Column("task_id", Integer, ForeignKey("tasks.id", ondelete="CASCADE")),
    Column("tag_id", Integer, ForeignKey("tags.id", ondelete="CASCADE")),
)
```

### Step 3: Generate Init Script

Create `core/init_db.py`:

```python
"""
Database initialization — creates all tables from ORM models.

Called at application startup. Safe to call multiple times
(create_all is idempotent — skips existing tables).
"""
def init_db():
    """Create all database tables defined by SQLAlchemy models.

    This imports all model modules to ensure they are registered
    with Base.metadata before calling create_all().
    """
    # Import models so they register with Base.metadata
    from features.auth.models.user import User  # noqa: F401
    from features.tasks.models.task import Task  # noqa: F401

    Base.metadata.create_all(bind=engine)
```

### Step 4: Testing with SQLite

Generate test database fixture in `tests/conftest.py`:

```python
"""
Test configuration — SQLite in-memory database for fast, isolated tests.

WHY SQLite for tests: PostgreSQL requires a running server and is slower.
SQLite in-memory databases are created and destroyed per test, ensuring
complete isolation. The ORM abstracts away SQL dialect differences.

LIMITATION: Some PostgreSQL-specific features (JSONB, array columns,
full-text search) won't work with SQLite. For those, use integration
tests with a real PostgreSQL instance.
"""
```

## Output

Return list of files created with relationship diagram (ASCII).

## Rules

- ALWAYS add module docstring explaining business context of each model
- ALWAYS add inline comments explaining WHY for relationships and constraints
- ALWAYS use `datetime.now(datetime.UTC)` for timestamps, NEVER `datetime.utcnow()`
- ALWAYS add `ondelete="CASCADE"` on foreign keys when parent deletion should cascade
- ALWAYS use `back_populates` (explicit) over `backref` (implicit) for clarity
- NEVER put database URL in code — use environment variable
- For Many-to-Many: use `Table()` for simple associations, model class for associations with extra data
- For testing: provide SQLite in-memory configuration with clear documentation of limitations
- Use `declarative_base()` (SQLAlchemy 1.4+) or `DeclarativeBase` class (SQLAlchemy 2.0+) based on project version
- Document cascade behavior explicitly — silent cascades cause data loss surprises

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "RLS is optional -- the app filters by tenant_id in the WHERE clause anyway" | Application-layer filtering breaks the moment a junior dev forgets a `WHERE` clause, runs an admin script without scoping, or a SQL injection slips through. RLS at the database is a defense-in-depth layer that catches every one of those failure modes. The day you skip it is the day a tenant sees another tenant's invoices |
| "I'll add tenant_id to the model later when we onboard the second customer" | "Later" means a multi-week migration where every existing row gets a backfill, every query gets a rewrite, and every index gets recreated -- often while the first customer is using the system. Adding `tenant_id NOT NULL` from day one costs nothing |
| "Cascade deletes are scary -- I'll handle it in code" | Application-side cascade is a race condition waiting to happen. Two concurrent requests can leave orphans or partially deleted graphs. `ondelete='CASCADE'` is atomic at the DB layer |
| "back_populates is verbose -- backref is shorter" | `backref` hides the relationship on one side, which means the next developer reading the child model has no idea the parent has a back-reference. Verbosity is a feature: explicit relationships make code reviewable |
| "SQLite for tests is fine, the ORM abstracts SQL differences" | The ORM abstracts SQL syntax, not feature parity. JSONB, array columns, partial indexes, full-text search, and CHECK constraints behave differently or not at all. Tests pass on SQLite, production breaks on Postgres |

## Red Flags

- Multi-tenant model without a `tenant_id` column or RLS policy
- Foreign key without explicit `ondelete=` behavior (default is RESTRICT and silent)
- Use of `backref=` instead of `back_populates=` (relationship is invisible from one side)
- `datetime.utcnow()` instead of `datetime.now(timezone.utc)` (deprecated in Python 3.12+)
- Database URL hardcoded in source instead of read from environment
- `Session()` instantiated directly instead of going through `SessionLocal` factory
- Missing module docstring explaining the business context of the model
- Test suite that uses SQLite for code paths that rely on Postgres-only features (JSONB, arrays, full-text)
- N+1 query pattern visible (loop that triggers a query per iteration via lazy-loaded relationship)
- Migration files generated by Alembic without manual review of the auto-generated SQL

## Verification Checklist

- [ ] Every multi-tenant model has a `tenant_id` column (NOT NULL) AND a corresponding RLS policy enabled on the table
- [ ] All foreign keys declare an explicit `ondelete=` (CASCADE, SET NULL, or RESTRICT) -- never rely on the default
- [ ] Relationships use `back_populates=` on both sides; `backref=` is not used
- [ ] Timestamps use `datetime.now(timezone.utc)` -- no `datetime.utcnow()` anywhere
- [ ] Database URL is read from environment via Pydantic Settings or equivalent, never hardcoded
- [ ] All sessions are created via `SessionLocal()` and used inside a `try/finally` or context manager
- [ ] Module docstring on every model file explains the business entity it represents
- [ ] Tests that depend on Postgres-specific features (JSONB, arrays, RLS) run against a real Postgres instance, not SQLite
- [ ] Eager loading (`joinedload`, `selectinload`) is used for relationships accessed in loops
- [ ] Alembic migrations are reviewed and edited manually after `alembic revision --autogenerate`
