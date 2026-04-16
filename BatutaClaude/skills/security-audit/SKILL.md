---
name: security-audit
description: >
  Use when performing security review: OWASP, secrets, threat modeling.
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-22"
  bucket: review
  auto_invoke:
    - "Security review or audit of code"
    - "Checking for vulnerabilities in implementation"
    - "Creating threat model for a feature"
    - "Scanning for hardcoded secrets"
    - "Auditing dependencies for known vulnerabilities"
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep Bash WebSearch
---

# Security Audit — AI-First Security Practices

## Purpose

Provide a systematic security review process optimized for AI-generated code. AI agents write correct-looking code fast, but can introduce subtle vulnerabilities that pass linting and tests. This skill catches what automated tools miss and what AI agents commonly get wrong.

## When to Use

- **During sdd-design**: Run the Threat Model Template to identify risks early
- **During sdd-verify**: Run as cross-layer security check after Pyramid Layers 1-3 pass
- **On demand**: When the user asks for a security review, audit, or hardening
- **Before deploy**: Final security gate before production deployment

## Three-Tier Security Decision

| Tier | When | Action |
|---|---|---|
| **Always Do** | Input validation, parameterized queries, secrets in env vars, HTTPS | Apply without asking. These are non-negotiable. |
| **Ask First** | New auth flows, changing encryption schemes, modifying CORS, adding third-party integrations | Propose to user with tradeoffs before implementing. |
| **Never Do** | Hardcode credentials, disable security headers, log sensitive data, trust client input | Block immediately. No rationalizations accepted. |

## AI-First Security Checklist

The top 10 security issues that AI-generated code commonly introduces. Check ALL of these during any security review.

### 1. Command Injection

AI agents frequently use `subprocess`, `exec`, `eval`, or template strings to run commands.

```
CHECK:
├── Search for: subprocess.call, subprocess.run, os.system, exec(), eval()
├── Search for: child_process.exec, child_process.spawn (Node.js)
├── Search for: os/exec (Go)
├── FAIL if user input flows into any of these without sanitization
├── RECOMMENDATION: Use parameterized calls, avoid shell=True
└── SAFE patterns: subprocess.run([cmd, arg1, arg2], shell=False)
```

### 2. SQL Injection

AI agents sometimes write raw SQL queries when ORMs seem complex.

```
CHECK:
├── Search for: raw SQL strings with f-strings, .format(), or string concatenation
├── Search for: cursor.execute() with non-parameterized queries
├── Search for: Prisma.$queryRaw, knex.raw(), sequelize.query()
├── FAIL if user input is interpolated into SQL without parameterization
├── RECOMMENDATION: Always use parameterized queries or ORM methods
└── SAFE patterns: cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

### 3. Cross-Site Scripting (XSS)

AI agents may render user input directly in HTML or JSX without escaping.

```
CHECK:
├── Search for: dangerouslySetInnerHTML (React)
├── Search for: innerHTML assignments
├── Search for: template literals in HTML without escaping
├── Search for: Jinja2/Nunjucks/EJS with {{{ }}} (unescaped)
├── FAIL if user-controlled data is rendered without sanitization
└── RECOMMENDATION: Use framework's built-in escaping, DOMPurify for HTML
```

### 4. Hardcoded Secrets

AI agents often include example secrets that get committed.

```
CHECK (grep patterns):
├── /(api[_-]?key|apikey)\s*[:=]\s*['"][A-Za-z0-9]{16,}/i
├── /(secret|password|passwd|token)\s*[:=]\s*['"][^'"]{8,}/i
├── /sk-[a-zA-Z0-9]{32,}/  (OpenAI/Anthropic keys)
├── /ghp_[a-zA-Z0-9]{36}/  (GitHub tokens)
├── /AKIA[A-Z0-9]{16}/     (AWS access keys)
├── /-----BEGIN (RSA |EC )?PRIVATE KEY-----/
├── ALSO check: .env files committed to git, .gitignore missing .env
├── FAIL if any secret pattern found in tracked files
└── RECOMMENDATION: Use environment variables, .env files (gitignored), or secret managers
```

### 5. Dependency Vulnerabilities

AI agents install packages without checking for known CVEs.

```
CHECK (by language):
├── Node.js: npm audit --audit-level=high
├── Python: pip audit (or safety check)
├── Go: govulncheck ./...
├── Rust: cargo audit
├── ALSO check: Are dependencies pinned? (lockfile exists?)
├── WARNING if audit reports high/critical vulnerabilities
└── RECOMMENDATION: Update vulnerable packages, document if intentionally kept
```

### 6. CORS Misconfiguration

AI agents often set `Access-Control-Allow-Origin: *` for convenience.

```
CHECK:
├── Search for: Access-Control-Allow-Origin: *
├── Search for: cors({ origin: '*' }) or cors({ origin: true })
├── FAIL if wildcard CORS is used with credentials (cookies/auth headers)
├── WARNING if wildcard CORS is used in production config
└── RECOMMENDATION: Whitelist specific origins, never use * with credentials
```

### 7. Authentication Bypass

AI agents may implement auth incorrectly or skip edge cases.

```
CHECK:
├── JWT: Is signature verified? Is expiration checked? Is algorithm fixed (not "none")?
├── Session: Is session ID regenerated after login? Is httpOnly flag set?
├── API Keys: Are they compared with constant-time comparison?
├── Middleware: Is auth middleware applied to ALL protected routes (no gaps)?
├── Password: Is bcrypt/argon2 used (not MD5/SHA1)? Is salt unique?
├── FAIL if any auth mechanism is bypassable
└── RECOMMENDATION: Use established auth libraries (passport, next-auth, jose)
```

### 8. Path Traversal

AI agents may construct file paths from user input without validation.

```
CHECK:
├── Search for: path.join, os.path.join, filepath.Join with user input
├── Search for: fs.readFile, open() with user-controlled paths
├── FAIL if "../" sequences aren't blocked or path isn't resolved to allowed directory
├── RECOMMENDATION: Use path.resolve + startsWith check against allowed base directory
└── SAFE pattern: if (!resolvedPath.startsWith(allowedDir)) throw new Error('Forbidden')
```

### 9. Server-Side Request Forgery (SSRF)

AI agents may fetch URLs provided by users without validation.

```
CHECK:
├── Search for: fetch(), axios(), requests.get() with user-controlled URLs
├── FAIL if URL isn't validated against allowlist or internal network ranges
├── Internal ranges to block: 127.0.0.1, 10.x, 172.16-31.x, 192.168.x, 169.254.x, ::1
├── RECOMMENDATION: URL allowlist, DNS rebinding protection, disable redirects
└── ALSO check: Metadata endpoints (169.254.169.254 for cloud)
```

### 10. Prompt Injection (LLM Apps)

For applications that use Claude, OpenAI, or other LLM APIs.

```
CHECK:
├── Is user input separated from system prompt? (never concatenate directly)
├── Is output validated before executing actions? (tool use, code execution)
├── Are there guardrails on what the LLM can do? (rate limits, action allowlists)
├── Is PII handled? (no logging of personal data in LLM calls)
├── Are API keys for LLM services properly secured? (not in client-side code)
├── Is max_tokens set to prevent cost abuse?
├── FAIL if user input flows into system prompt without separation
└── RECOMMENDATION: Use structured messages, validate tool outputs, implement cost limits
```

## Threat Model Template

Use this template during **sdd-design** to identify security risks before implementation.

```markdown
## Threat Model: {Change Title}

### Assets (What to Protect)

| Asset | Sensitivity | Location |
|-------|------------|----------|
| {e.g., User PII} | HIGH | {e.g., PostgreSQL users table} |
| {e.g., API keys} | CRITICAL | {e.g., .env file} |
| {e.g., Session tokens} | HIGH | {e.g., HTTP cookies} |

### Threat Actors

| Actor | Motivation | Capability |
|-------|-----------|------------|
| {e.g., External attacker} | {e.g., Data theft} | {e.g., Web attacks, social engineering} |
| {e.g., Malicious user} | {e.g., Privilege escalation} | {e.g., Authenticated access} |

### Attack Vectors

| Vector | Target Asset | Likelihood | Impact | Mitigation |
|--------|-------------|-----------|--------|------------|
| {e.g., SQL injection} | {User PII} | {Medium} | {High} | {Parameterized queries} |
| {e.g., XSS} | {Session tokens} | {High} | {High} | {CSP headers, escaping} |

### Residual Risk

{What risks remain after mitigations? What is the acceptable risk level?
Document conscious decisions to accept risk — these must be reviewed before deploy.}
```

## STRIDE Threat Enumeration

Complement the free-form Threat Model Template above with a systematic STRIDE analysis. STRIDE ensures no threat category is accidentally omitted by enumerating all six categories per system component.

### Step 0: Data Flow Diagram (DFD)

Before enumerating threats, identify the system's trust boundaries:

```
DFD MAPPING:
├── List all External Actors (users, third-party APIs, webhooks)
├── List all Processes (services, workers, APIs, LLM pipelines)
├── List all Data Stores (databases, caches, file systems, queues)
├── List all Data Flows between them (HTTP, gRPC, events, file I/O)
├── Draw trust boundaries (public internet → API gateway → internal services → database)
└── Each boundary crossing is a potential attack surface
```

### Step 1: STRIDE per Component

For each component identified in the DFD, enumerate threats across all six categories:

| Category | Question to Ask | What to Look For |
|----------|----------------|-----------------|
| **S**poofing | Can someone pretend to be this component? | Missing authentication, weak identity verification, token reuse |
| **T**ampering | Can someone modify data in transit or at rest? | Unsigned payloads, missing HMAC/checksums, unencrypted storage |
| **R**epudiation | Can someone deny performing an action? | Missing audit logs, mutable log storage, no non-repudiation controls |
| **I**nfo Disclosure | Can someone access data they shouldn't? | Verbose errors, log leaks, missing encryption at rest, debug endpoints |
| **D**enial of Service | Can someone make this unavailable? | No rate limiting, unbounded queries, missing connection pool limits, no circuit breakers |
| **E**levation of Privilege | Can someone gain unauthorized access? | IDOR, role confusion, missing RBAC checks, insecure direct object references |

### Step 2: STRIDE Analysis Template

```markdown
## STRIDE Analysis: {Change Title}

### Trust Boundaries
{DFD summary: actors → processes → data stores, with boundary markers}

### Threats by Component

| Component | Category | Threat | Risk | Mitigation | Status |
|-----------|----------|--------|------|------------|--------|
| {API Gateway} | Spoofing | Unauthenticated requests bypass auth | HIGH | JWT validation middleware on all routes | {TODO/DONE} |
| {API Gateway} | DoS | Unbounded request rate exhausts resources | HIGH | Rate limiting (100 req/min per IP) + WAF | {TODO/DONE} |
| {Database} | Tampering | SQL injection modifies data | CRITICAL | Parameterized queries only (see checklist #2) | {TODO/DONE} |
| {Database} | Info Disclosure | Direct access to production data | HIGH | Network segmentation, encrypted at rest | {TODO/DONE} |
| {User Actions} | Repudiation | User denies performing a transaction | MEDIUM | Immutable audit log with user ID + timestamp | {TODO/DONE} |
| {Admin Panel} | Elevation | Regular user accesses admin functions | CRITICAL | RBAC middleware + session isolation + IDOR checks | {TODO/DONE} |
| {Message Queue} | Tampering | Message payload modified in transit | MEDIUM | HMAC signatures on messages | {TODO/DONE} |
| {LLM Pipeline} | Info Disclosure | System prompt leaked to user | HIGH | Separate system/user messages, output filtering | {TODO/DONE} |
```

### When to Use STRIDE vs Free-Form Threat Model

| Scenario | Use |
|----------|-----|
| Quick security review (< 3 components) | Free-form Threat Model Template (above) |
| Full feature with multiple trust boundaries | STRIDE Analysis (this section) |
| sdd-design phase | STRIDE (comprehensive, catches gaps early) |
| sdd-verify cross-layer check | Free-form checklist (faster, verification-focused) |

## Secrets Scanning Protocol

Run before any commit or deploy:

```
SCAN:
1. Grep for secret patterns (see checklist item 4)
2. Verify .gitignore includes: .env, .env.*, *.key, *.pem, *.p12, *.pfx
3. Check git history: git log --diff-filter=A --name-only -- '*.env' '*.key'
4. If secrets found in history → CRITICAL: requires git filter-branch or BFG
5. Suggest pre-commit hook: pre-commit with detect-secrets or gitleaks
```

## Dependency Audit Protocol

```
AUDIT:
1. Check lockfile exists (package-lock.json, poetry.lock, go.sum, Cargo.lock)
2. Run language-specific audit (see checklist item 5)
3. Check for outdated packages: npm outdated, pip list --outdated
4. Policy:
   ├── CRITICAL/HIGH CVE → Update immediately
   ├── MEDIUM CVE → Update in next sprint
   ├── LOW CVE → Document and track
   └── No fix available → Document risk, add to threat model residual risk
5. Optional: Generate SBOM (Software Bill of Materials) with syft or cyclonedx
```

## Claude Security (LLM Application Hardening)

For applications that integrate with Claude API or other LLMs:

### System Prompt Protection
- Never expose system prompt to end users
- Use `system` message type (not concatenated into user message)
- Implement input validation before sending to LLM
- Add output validation before executing LLM suggestions

### Cost Control
- Set `max_tokens` to reasonable limits per request
- Implement per-user rate limiting
- Monitor API usage with alerts for anomalies
- Use `stop_sequences` to prevent runaway generation

### PII Handling
- Do NOT log full LLM request/response bodies in production
- If PII must be processed, consider Presidio for entity detection/redaction
- Implement data retention policies for LLM interaction logs
- Comply with GDPR/CCPA requirements for stored conversations

### Output Validation
- Validate LLM tool outputs before executing (check against allowed actions)
- Implement circuit breakers for repeated failures
- Log all tool executions with context for audit trail
- Never execute raw code from LLM output without review

## Integration with SDD Pipeline

### In sdd-design (Threat Model Step)
After Architecture Decisions, before File Changes:
1. Identify assets, threat actors, and attack vectors
2. Fill threat model template
3. Add mitigations to design decisions
4. Document residual risk

### In sdd-verify (Cross-Layer Security Check)
After Pyramid Layers 1-3 pass:
1. Run the 10-point AI-First Security Checklist
2. Run secrets scanning protocol
3. Run dependency audit
4. Report findings with severity levels

### Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| CRITICAL | Exploitable vulnerability | Block deploy, fix immediately |
| HIGH | Likely exploitable | Fix before deploy |
| MEDIUM | Potential vulnerability | Fix in next iteration |
| LOW | Best practice violation | Document, fix when convenient |
| INFO | Suggestion for improvement | Optional |

## Verification Report Template

```markdown
## Security Audit Report

**Date**: {ISO-8601}
**Change**: {change-name}
**Auditor**: {agent/human}

### AI-First Checklist Results

| # | Check | Status | Details |
|---|-------|--------|---------|
| 1 | Command Injection | {PASS/FAIL/N-A} | {details} |
| 2 | SQL Injection | {PASS/FAIL/N-A} | {details} |
| 3 | XSS | {PASS/FAIL/N-A} | {details} |
| 4 | Hardcoded Secrets | {PASS/FAIL/N-A} | {details} |
| 5 | Dependency Vulns | {PASS/FAIL/N-A} | {details} |
| 6 | CORS Config | {PASS/FAIL/N-A} | {details} |
| 7 | Auth Bypass | {PASS/FAIL/N-A} | {details} |
| 8 | Path Traversal | {PASS/FAIL/N-A} | {details} |
| 9 | SSRF | {PASS/FAIL/N-A} | {details} |
| 10 | Prompt Injection | {PASS/FAIL/N-A} | {details} |

### Threat Model Status
{Linked to design threat model? Mitigations implemented?}

### Secrets Scan
{Clean / N findings}

### Dependency Audit
{Clean / N vulnerabilities (X critical, Y high)}

### Overall Security Score
{PASS (0 critical, 0 high) / CONDITIONAL (0 critical, N high) / FAIL (N critical)}
```

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "It's internal, no auth needed" | Internal tools get exposed via VPN misconfig, employee compromise, or perimeter breach. Internal = "discovered later." Authenticate everything. |
| "OWASP Top 10 is overkill for this" | OWASP exists because these are the bugs that actually ship to production. "Overkill" = "I don't want to spend the hour." The hour costs less than the breach. |
| "We trust our users" | Users get phished, accounts get compromised, insider threats exist. Trust is not a security control. Authorize every action regardless of who's authenticated. |
| "Secrets in .env aren't committed, we're fine" | .env files leak via backups, container images, log dumps, error pages, and accidental commits. Use a real secret manager (Vault, AWS Secrets Manager, Doppler). |
| "Dependency CVEs are theoretical" | Equifax, log4shell, and event-stream were all "theoretical" until they weren't. Patch HIGH/CRITICAL within 7 days, document any exceptions in the threat model. |

## Red Flags

- "We'll add auth later" — auth retrofitted onto an existing system always has gaps. Build it from day 1.
- Any string concatenation feeding into SQL, shell, or HTML rendering — assume injection until proven otherwise.
- `Access-Control-Allow-Origin: *` combined with cookies or auth headers — credential theft waiting to happen.
- JWT with `alg: none` accepted, or signature not verified server-side.
- `.env`, `*.key`, or `*.pem` not in `.gitignore`.
- LLM system prompt concatenated with user input instead of using structured message types.
- "Just for testing" debug endpoints (`/debug`, `/admin/test`, `?debug=1`) reachable in production.
- No rate limiting on auth, registration, or password reset endpoints.
- Dependency lockfile missing, or `npm install` (not `npm ci`) used in CI.

## Verification Checklist

- [ ] All 10 AI-First Checklist items run, each marked PASS / FAIL / N-A with evidence
- [ ] Threat Model exists for the change (free-form for <3 components, STRIDE for multi-component features)
- [ ] Secrets scan clean: grep patterns for API keys, tokens, private keys, passwords return zero hits in tracked files
- [ ] `.gitignore` includes `.env`, `.env.*`, `*.key`, `*.pem`, `*.p12`, `*.pfx`
- [ ] Git history scanned for historical secret commits (`git log --diff-filter=A --name-only -- '*.env' '*.key'`)
- [ ] Dependency audit run (`npm audit`, `pip audit`, `govulncheck`, or `cargo audit`); HIGH/CRITICAL CVEs patched or documented as residual risk
- [ ] Lockfile present and committed (`package-lock.json`, `poetry.lock`, `go.sum`, `Cargo.lock`)
- [ ] Authentication: signature verification on all tokens, expiration checked, algorithm pinned (not "none"), constant-time comparison for API keys
- [ ] Authorization checks present on every protected route — no gaps in middleware coverage
- [ ] CORS configured with explicit allowlist (no `*` with credentials)
- [ ] User input never concatenated into SQL, shell commands, or HTML rendering
- [ ] LLM applications: system prompt isolated from user input, output validated before tool execution, max_tokens set
- [ ] Severity scored consistently: CRITICAL blocks deploy, HIGH fixed before deploy, MEDIUM tracked, LOW documented
- [ ] Verification report delivered with evidence for each finding

