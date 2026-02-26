---
name: jwt-auth
description: >
  Use when implementing JWT authentication, login, registration, tokens.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-23"
  scope: [infra]
  auto_invoke: "Implementing JWT authentication, login/register endpoints"
allowed-tools: Read, Glob, Grep, Write, Edit
platforms: [claude, antigravity]
---

## Purpose

You are a skill for generating **JWT authentication** following Batuta conventions and
modern security best practices. Given a framework (FastAPI, Express, etc.), you produce
the complete auth system: user model, password hashing, token generation, and middleware.

## Input

From the caller:
- **Framework** (FastAPI, Express, etc.)
- **User fields** beyond email/password (e.g., `name: str`, `role: enum[admin,user]`)
- **Token expiration** (default: 30 minutes)
- **Refresh tokens?** (yes/no)

## Steps

### Step 1: Generate User Model

Create `features/auth/models/user.py`:

```python
"""
User model — authentication identity for the application.

Stores credentials (hashed password, never plaintext) and profile data.
Used by the auth service for registration and login flows.
"""
```

Key rules:
- Password field stores HASH only, never plaintext
- Email has unique constraint
- Include `created_at` and `is_active` fields

### Step 2: Generate Auth Schemas

Create `features/auth/schemas/auth.py`:

```python
"""
Authentication schemas — request/response models for auth endpoints.

Separates registration input, login input, and token response.
Password is NEVER included in response schemas.
"""
```

Schemas: `UserRegister`, `UserLogin`, `UserResponse`, `TokenResponse`

### Step 3: Generate Auth Service

Create `features/auth/services/auth_service.py`:

```python
"""
Auth service — password hashing and JWT token management.

Uses bcrypt for password hashing (NOT passlib, which is unmaintained since 2020).
Uses PyJWT for token creation and validation.
"""
import bcrypt
import jwt

def hash_password(password: str) -> str:
    """Hash a plaintext password using bcrypt.

    Args:
        password: Plaintext password from user input

    Returns:
        Bcrypt hash string safe for database storage

    Note:
        Uses bcrypt directly (not passlib) for Python 3.12+ compatibility.
    """
    # SECURITY: bcrypt automatically handles salt generation
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def verify_password(password: str, hashed: str) -> bool:
    """Verify a plaintext password against a stored bcrypt hash.

    Args:
        password: Plaintext password from login attempt
        hashed: Stored bcrypt hash from database

    Returns:
        True if password matches, False otherwise
    """
    return bcrypt.checkpw(password.encode(), hashed.encode())

def create_token(data: dict, expires_minutes: int = 30) -> str:
    """Create a signed JWT token with expiration.

    Args:
        data: Payload to encode (typically {"sub": user_id})
        expires_minutes: Token lifetime in minutes (default: 30)

    Returns:
        Encoded JWT string

    Note:
        Uses HS256 algorithm. For production with multiple services,
        consider RS256 with public/private key pairs.
    """
    # ... implementation
```

### Step 4: Generate Auth Routes

Create `features/auth/routes/auth_routes.py`:

```python
"""
Auth API routes — registration, login, and profile endpoints.

POST /auth/register — Create new user account
POST /auth/login — Authenticate and receive JWT token
GET /auth/me — Get current user profile (requires valid token)
PUT /auth/me — Update current user profile (requires valid token)
"""
```

### Step 5: Generate Auth Dependency

Create `features/auth/dependencies.py`:

```python
"""
Auth dependencies — FastAPI dependency injection for authentication.

Provides `get_current_user` dependency that extracts and validates
JWT tokens from the Authorization header.
"""
```

## Output

Return list of files created with security notes.

## Rules

- ALWAYS use `bcrypt` directly, NEVER `passlib` (unmaintained since 2020, incompatible with bcrypt 5.x)
- ALWAYS use `datetime.now(datetime.UTC)`, NEVER `datetime.utcnow()` (deprecated)
- NEVER store plaintext passwords
- NEVER return password hashes in API responses
- NEVER log passwords or tokens (even in debug mode)
- ALWAYS validate JWT token expiration
- ALWAYS use environment variables for JWT_SECRET (never hardcode)
- ALWAYS generate comprehensive docstrings explaining security decisions
- ALWAYS add # SECURITY: comments on security-critical code
- Default token expiration: 30 minutes (configurable)
- Use HS256 for single-service apps, document RS256 as alternative for multi-service
