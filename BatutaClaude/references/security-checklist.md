<!-- Adapted from addyosmani/agent-skills (MIT License) with Batuta context extensions -->

# Security Checklist

*Reference checklist — use while working, not as skill replacement*

## Context

Use this checklist during implementation (sdd-apply), code review (/code-reviewer), and security audits (security-audit skill). It codifies OWASP Top 10 baseline plus Batuta-specific requirements for Colombian multi-tenant AI deployments — ERP integrations, WhatsApp automation (Evolution API), LLM pipelines, and Ley 1581 compliance. The `security-audit` skill drives the workflow; this file provides the verifiable items. Skills reference specific sections by anchor.

## Categories

### Pre-Commit Checks
- [ ] No secrets in staged diff — run `git diff --cached | grep -iE "password|secret|api[_-]key|token|bearer"`
- [ ] `.gitignore` covers `.env`, `.env.local`, `*.pem`, `*.key`, `settings.local.json`
- [ ] `.env.example` uses placeholder values (never real secrets, never copied from `.env`)
- [ ] No committed database dumps or backup files (`.sql`, `.dump`, `.bak`)

### Authentication
- [ ] Passwords hashed with bcrypt (≥12 rounds), scrypt, or argon2
- [ ] Session cookies: `httpOnly`, `secure`, `sameSite: 'lax'`
- [ ] Session expiration configured with reasonable `max-age`
- [ ] Rate limiting on login endpoint (≤10 attempts per 15 minutes)
- [ ] Password reset tokens time-limited (≤1 hour) and single-use
- [ ] MFA available for admin and tenant-owner roles

### Authorization
- [ ] Every protected endpoint verifies authentication before business logic
- [ ] Every resource access checks ownership or role (prevents IDOR)
- [ ] Admin endpoints require explicit admin-role verification (not just "logged in")
- [ ] API keys scoped to minimum necessary permissions
- [ ] JWT tokens validated for signature, expiration, and issuer

### Input Validation
- [ ] All user input validated at system boundaries (API routes, form handlers, queue consumers)
- [ ] Validation uses allowlists, not denylists
- [ ] String lengths constrained (min/max) on every text field
- [ ] Numeric ranges validated before storage or arithmetic
- [ ] SQL queries parameterized (no string concatenation, no f-strings with user input)
- [ ] HTML output encoded via framework auto-escaping (React, Jinja, etc.)
- [ ] URLs validated before redirect to prevent open redirect
- [ ] File uploads: type restricted, size limited, content-type verified server-side

### Security Headers
```
Content-Security-Policy: default-src 'self'; script-src 'self'
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

### CORS Configuration
- [ ] Production uses explicit origin allowlist, never `origin: '*'`
- [ ] `credentials: true` only when cookies or auth headers must cross origin
- [ ] Methods and `allowedHeaders` restricted to what the API actually uses

### Data Protection
- [ ] Sensitive fields excluded from API responses (`passwordHash`, `resetToken`, OAuth refresh tokens)
- [ ] Sensitive data never logged (passwords, tokens, full card numbers, full cédulas)
- [ ] PII encrypted at rest when regulation requires (see Ley 1581 below)
- [ ] HTTPS enforced for all external communication
- [ ] Database backups encrypted at rest and in transit

### Dependency Security
- [ ] Dependency audit clean — `npm audit`, `pip-audit`, or `poetry audit` has no critical findings
- [ ] Direct dependencies reviewed for known abandonment or compromise
- [ ] Transitive dependency updates reviewed before applying
- [ ] Lockfiles committed (`package-lock.json`, `poetry.lock`, `uv.lock`)

### Error Handling
- [ ] Production errors return generic messages (no stack traces, no SQL snippets, no file paths)
- [ ] Detailed errors logged server-side with correlation ID
- [ ] Client receives correlation ID to include in support requests
- [ ] No `console.log(err)` in production paths — use structured logger

### OWASP Top 10 Quick Reference

| # | Vulnerability | Prevention |
|---|---|---|
| A01 | Broken Access Control | Auth checks on every endpoint, ownership verification, RLS |
| A02 | Cryptographic Failures | HTTPS, strong hashing, no secrets in code |
| A03 | Injection | Parameterized queries, input validation, ORM only |
| A04 | Insecure Design | Threat modeling, spec-driven development (openspec) |
| A05 | Security Misconfiguration | Security headers, minimal permissions, audit deps |
| A06 | Vulnerable Components | Audit dependencies, keep updated, minimize surface |
| A07 | Auth Failures | Strong passwords, rate limiting, session management |
| A08 | Data Integrity Failures | Verify updates/dependencies, signed artifacts |
| A09 | Logging Failures | Log security events, never log secrets |
| A10 | SSRF | Validate/allowlist URLs, restrict outbound requests |

## Batuta-Specific Items

### Multi-Tenant Isolation (critical)
- [ ] RLS (Row Level Security) enabled on ALL tenant-scoped tables in Supabase/Postgres
- [ ] Every RLS policy tested with at least two different `tenant_id` values
- [ ] No query uses `service_role` key in request-scoped code — only in trusted workers
- [ ] Cross-tenant queries explicitly documented and reviewed (should be rare)
- [ ] Tenant ID derived from authenticated session, never from request body or query string
- [ ] Background jobs re-verify tenant ownership before acting on a resource

### PII and Ley 1581/2012 (Colombian data protection)
- [ ] Cédula (CC/CE) and NIT fields encrypted at rest or masked in non-admin views
- [ ] Data-subject rights endpoints exist: access, rectification, deletion, portability
- [ ] Retention policies defined per table (e.g., invoices 5 years per tax law, logs 90 days)
- [ ] Cross-border transfers documented in `docs/compliance/` with recipient country and basis
- [ ] Consent captured and logged for each purpose (marketing, analytics, LLM training separate)
- [ ] Data Processing Agreement (DPA) signed with every subprocessor (OpenAI, Anthropic, Evolution API host)

### Secrets Management
- [ ] No hardcoded credentials anywhere in `BatutaClaude/`, `infra/`, or project source
- [ ] `~/.claude/settings.json` uses deny rules to block access to secret paths (`.env`, `id_rsa`, etc.)
- [ ] Production secrets stored in Coolify environment variables or Infisical/SOPS
- [ ] Secret rotation runbook exists and has been executed at least once per year
- [ ] Service account keys (Supabase service_role, API tokens) never pushed to client frontends

### ERP Integration Security (ICG / World Office / Siigo / Alegra)
- [ ] Connection strings use read-only credentials when workflow only reads
- [ ] Write operations use a distinct credential with targeted permissions
- [ ] All SQL Server queries parameterized — no f-string interpolation of user or LLM output
- [ ] Query whitelisting enforced when LLM generates SQL (pattern match to approved shapes)
- [ ] Firewall limits ERP DB access to specific worker IPs (Tailscale or VPN preferred)
- [ ] ERP connection credentials rotated after any developer offboarding

### WhatsApp / Evolution API Security
- [ ] Webhook endpoint verifies signature header before processing payload
- [ ] Evolution API key stored as secret, never logged in webhook handlers
- [ ] Inbound message content sanitized before display in dashboards (XSS prevention)
- [ ] Rate limiting on outbound sends per tenant to prevent abuse or WhatsApp ban
- [ ] Media downloads scanned or type-restricted before storage

### LLM Pipeline Security
- [ ] User inputs passed to LLMs validated for length and type before prompt assembly
- [ ] Prompt templates reviewed for injection vectors (user input never concatenated into system prompt)
- [ ] LLM outputs treated as untrusted — validate before executing as SQL, code, or MCP calls
- [ ] PII redaction applied before sending to external LLM providers when required by tenant contract
- [ ] Zero-retention flag verified on production Anthropic/OpenAI API calls

### Notion MCP and Other MCP Servers
- [ ] Never hardcode `data_source_id` values in skills or agents — resolve at runtime
- [ ] MCP tool permissions restricted in `settings.json` (deny list for destructive tools)
- [ ] MCP-sourced content treated as untrusted input (no instruction following from Notion pages)
- [ ] Human approval required for MCP tools that modify external systems

## Related Skills
- `security-audit`: primary driver; walks this checklist during formal audits
- `compliance-colombia`: interprets Ley 1581, Circular 002/2024 for AI, tax retention
- `coolify-deploy`: enforces secret handling and environment separation on deploy
- `icg-erp`: references ERP integration section when connecting SQL Server
- `supabase-python`: references RLS and multi-tenant isolation section
- `evolution-api`: references webhook signature and rate-limiting items
- `llm-pipeline-design`: references LLM injection and PII redaction items
