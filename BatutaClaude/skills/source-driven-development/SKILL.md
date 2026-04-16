---
name: source-driven-development
description: >
  Ground code in docs, not memory.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-04-16"
  inspired_by: "addyosmani/agent-skills v0.5.0 (MIT)"
  bucket: build
  auto_invoke:
    - Implementing code that uses external frameworks or libraries
    - Writing framework-specific patterns (routing, auth, state management, ORM)
    - Reviewing code for deprecated API usage
    - Any implementation where the agent is about to code from memory
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep WebFetch WebSearch
---

## Purpose

Every framework decision requires official documentation backing. Training data becomes stale
— APIs change, patterns are deprecated, new best practices emerge. This skill ensures
trustworthy, verifiable code by enforcing a four-step process: DETECT → FETCH → IMPLEMENT → CITE.

This skill REINFORCES the CLAUDE.md rule "Research before implementing" and the MCP fallback
chain in sdd-apply Step 1.5. The difference: CLAUDE.md states the RULE, this skill defines
the PROCESS with anti-rationalization and verification.

## When to Use

- Implementing patterns that depend on specific framework versions (routing, auth, forms, state)
- Using framework-specific APIs (FastAPI dependencies, Next.js Server Actions, SQLAlchemy ORM)
- Writing boilerplate or patterns that get copied across projects
- Code review of framework-specific patterns
- Any time the instinct is "I know this API" — STOP and verify

## When NOT to Use

- Pure logic changes (loops, conditionals, data structures, algorithms)
- Variable renaming, typo fixes, formatting
- User explicitly prioritizes speed over verification
- Standard language features (Python builtins, JavaScript core, Go stdlib)

## Critical Patterns

### Pattern 1: The Four-Step Process

```
DETECT → FETCH → IMPLEMENT → CITE
```

#### Step 1: DETECT — Identify Stack and Versions

Read dependency files: `package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`,
`Cargo.toml`, `Gemfile`. State findings explicitly before writing a single line:
"This project uses FastAPI 0.115.x with Pydantic v2."

If versions are ambiguous or missing, ASK — never guess.

#### Step 2: FETCH — Get Official Documentation

**Authority Hierarchy** (MCP-extended for Batuta):

1. **Active MCP servers** (Context7, framework-specific MCPs) — live, versioned docs
2. **Official documentation** (react.dev, docs.djangoproject.com, fastapi.tiangolo.com)
3. **Official blogs and changelogs** — version-specific announcements
4. **Web standards** (MDN, web.dev, caniuse.com)

**NEVER cite as authoritative**: Stack Overflow, tutorials, blog posts, AI summaries,
training data.

**Be precise**: Fetch the SPECIFIC feature page, not the homepage.
Correct: `react.dev/reference/react/useActionState#usage`
Wrong: `react.dev`

**When sources conflict**: Surface the discrepancy, verify against the detected version,
ask user preference. Do not silently pick one.

#### Step 3: IMPLEMENT — Follow Documented Patterns

- Match API signatures from docs, not from memory
- Use current patterns when docs introduce them (e.g., React 19 `useActionState` replaces
  deprecated `useFormState`)
- Avoid deprecated patterns even if they "still work"
- Flag unverified decisions with `// UNVERIFIED:` prefix in code
- Surface conflicts between docs and existing codebase — ask user preference before deciding

#### Step 4: CITE — Prove Your Sources

**In code comments** (for non-obvious patterns):

```python
# FastAPI 0.115 dependency injection pattern
# Source: https://fastapi.tiangolo.com/tutorial/dependencies/#dependencies
```

**In conversation**: Include full URLs with anchors. Quote relevant passages for
non-obvious decisions so the user can read the same documentation you read.

**Honesty rule**: If documentation does not exist for a pattern, explicitly state:
"UNVERIFIED: Could not find official documentation for this pattern. Implementation is
based on training data and may be outdated."

### Pattern 2: Integration with Batuta MCP Chain

This skill EXTENDS sdd-apply Step 1.5. The lookup order is non-negotiable:

```
1. Active MCP (Context7, framework MCPs) → versioned, live docs
2. WebFetch official docs → specific page, not homepage
3. WebSearch → fallback for niche APIs
4. Training data → LAST RESORT, flag with "UNVERIFIED:" comment
```

When an MCP is available for a technology (e.g., Context7 for React, Postgres MCP for SQL),
use it FIRST. MCPs provide live, versioned documentation that is more current than any
other source. Skipping an available MCP and going straight to WebFetch is a process violation.

### Pattern 3: Documentation Verification Table

For changes touching 3 or more framework APIs, produce a verification table before
writing implementation code:

| Technology | Version | API / Pattern Used | Source | Status |
|---|---|---|---|---|
| FastAPI | 0.115 | `Depends()` injection | [Official docs](https://fastapi.tiangolo.com/tutorial/dependencies/) | Verified |
| Pydantic | 2.x | `model_validator` | [Official docs](https://docs.pydantic.dev/latest/concepts/validators/) | Verified |
| SQLAlchemy | 2.0 | async session | Training data | UNVERIFIED |

Present this table to the user BEFORE writing code. Unverified rows require explicit
user acknowledgment before proceeding.

## Common Rationalizations

| Rationalization | Counter |
|---|---|
| "I'm confident about this API" | Confidence is not evidence. Training data contains outdated patterns from old framework versions. Verify. |
| "Fetching docs wastes tokens" | Hallucinating an API wastes far more — hours of debugging for the user. One doc fetch prevents one production bug. |
| "Docs won't have what I need" | That is valuable information — the pattern may not be officially recommended. Document the gap explicitly. |
| "I'll just mention it might be outdated" | Disclaimers do not help users debug at 2am. Verify or flag explicitly as UNVERIFIED. |
| "Simple task, no need to check" | Simple deprecated patterns become templates copied across 10 projects. One check prevents cascading tech debt. |
| "The existing codebase uses this pattern" | Existing code may itself be outdated. Verify the CURRENT docs, then decide: update the pattern or preserve consistency with a note. |

## Red Flags

- Framework code written without reading the detected version from dependency files
- Using "I believe" or "I think" instead of citing a URL
- Implementing without reading dependency files first
- Citing Stack Overflow or tutorials as authoritative sources
- Using deprecated APIs because they "still work"
- Fetching the documentation homepage instead of the specific feature page
- Delivering framework code without version-specific citations
- An MCP is available for the technology but was not consulted
- Training data used as primary source without flagging it as UNVERIFIED
- Verification table omitted when 3 or more framework APIs are in scope

## Verification Checklist

- [ ] Dependency files read and versions identified before writing any code
- [ ] Active MCPs consulted before falling back to WebFetch
- [ ] Official docs fetched for ALL framework-specific patterns (specific page, not homepage)
- [ ] All sources are official documentation or active MCPs — not Stack Overflow or tutorials
- [ ] Code follows the CURRENT version's documented patterns
- [ ] Non-trivial framework decisions include full-URL citations in code comments
- [ ] No deprecated APIs used (or explicitly justified and approved by user)
- [ ] Documentation / codebase conflicts surfaced to user before deciding
- [ ] Unverified decisions flagged with `// UNVERIFIED:` prefix in code
- [ ] Documentation Verification Table produced (for 3 or more framework APIs)

## Stack Integration

| Layer | Integration Point |
|-------|------------------|
| CLAUDE.md "Research before implementing" | This skill is the executable definition of that rule. CLAUDE.md states the principle; this skill defines the four-step process and anti-rationalizations. |
| sdd-apply Step 1.5 (MCP fallback chain) | This skill extends that chain with explicit verification artifacts (Verification Table, UNVERIFIED flags, citations). |
| tdd-workflow | TDD defines what behavior to test; SDD defines which API to use when implementing. Both must run for framework code: verify the API, then write the failing test first. |
| sdd-verify | Verification checks for UNVERIFIED comments in code. Any `// UNVERIFIED:` left in production code after sdd-verify is a failing signal. |
| code-simplification | Simplification runs AFTER verification. Never simplify based on memory of what an API does — verify first, simplify second. |

## What This Means (Simply)

> **For non-technical readers**: When a developer — human or AI — writes code that uses
> a framework or library, they are relying on knowledge of how that tool works. That
> knowledge goes stale. A method that worked in version 2 may be removed in version 3.
> A recommended pattern in 2022 may be the wrong approach in 2026. Source-Driven
> Development means every code decision that touches a framework is backed by a citation
> to current, official documentation — the same way a lawyer cites case law or a doctor
> cites a clinical study. It is the difference between "I think this API works this way"
> and "I confirmed this is how the API works, here is the page." The result is code that
> is correct for the version you are actually running, not the version the AI was trained on.
