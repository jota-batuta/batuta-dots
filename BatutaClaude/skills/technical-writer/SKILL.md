---
name: technical-writer
description: >
  Use when writing documentation, README, API reference, tutorial, migration guide, docs-as-code.
  Trigger: "write docs", "README", "API documentation", "tutorial", "migration guide",
  "documentation audit", "docs-as-code", "Docusaurus", "MkDocs".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-03-09"
  scope: [pipeline]
  auto_invoke: "Writing or reviewing documentation, READMEs, API references, or tutorials"
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash WebSearch
---

# Technical Writer

## Purpose

Documentation specialist for software projects. Covers README authoring, API reference generation (OpenAPI, JSDoc), tutorial creation, docs-as-code infrastructure (Docusaurus, MkDocs, Sphinx), and documentation gap analysis. Ensures documentation is clear enough for non-technical stakeholders.

## When to Use

- Writing or updating a project README
- Creating API reference documentation (OpenAPI, JSDoc, docstrings)
- Building tutorials or getting-started guides
- Auditing existing documentation for gaps, staleness, or accuracy
- Setting up docs-as-code infrastructure (Docusaurus, MkDocs, Sphinx, VitePress)
- During sdd-apply when documentation deliverables are part of the change
- During sdd-verify Step 5 (Documentation Verification) to validate completeness

## Critical Patterns

### Pattern 1: The 5-Second Test

Every README must answer three questions within the first 5 seconds of reading:
1. **What is this?** — one sentence, no jargon
2. **Why should I care?** — the pain it solves, not the features it has
3. **How do I start?** — shortest path to working code

```markdown
# ProjectName

> One-sentence description of what this does and why it matters.

## Why This Exists

<!-- 2-3 sentences: the PROBLEM, not features. What pain does this eliminate? -->

## Quick Start

<!-- Shortest path to working. No theory. Install + 3 lines of code + expected output. -->
```

If a README fails the 5-second test, rewrite it. Features belong in a separate section, not the opening.

### Pattern 2: Code Examples Must Run

Every code snippet in documentation MUST be tested before shipping. Untested examples are bugs.

```
VERIFICATION:
├── Copy the snippet into a clean environment
├── Run it exactly as written
├── Confirm the output matches what's documented
├── If it fails → fix the example, not the text around it
└── If it requires setup → document the prerequisites BEFORE the snippet
```

### Pattern 3: Divio Documentation System

Documentation serves four distinct purposes. Never mix them in the same section:

| Type | Purpose | Oriented to | Example |
|------|---------|------------|---------|
| **Tutorial** | Learning | Newcomers | "Build your first X" — step-by-step, hand-holding |
| **How-to Guide** | Problem-solving | Practitioners | "How to configure Y" — goal-oriented, assumes knowledge |
| **Reference** | Information | Users who need facts | API docs, config tables — complete, accurate, no narrative |
| **Explanation** | Understanding | Curious minds | "Why we chose Z" — conceptual, discusses tradeoffs |

A tutorial that tries to be a reference fails at both. Keep them separate.

### Pattern 4: Documentation Standard (Batuta Integration)

Batuta's DOCUMENTATION > CODE principle means every file MUST include:
1. **Module docstring** with business context (what this module does and why)
2. **Docstrings on all public functions** (what, args, returns)
3. **WHY comments** on non-obvious decisions using prefixes: `# SECURITY:`, `# BUSINESS RULE:`, `# WORKAROUND:`

This skill enforces the same standard for standalone documentation:
- Every doc answers WHY, not just HOW
- Every breaking change has a migration guide BEFORE the release
- Every public API has a reference entry with at least one code example

## Decision Trees

| Situation | Doc Type | Format |
|-----------|----------|--------|
| New user, first contact with project | Tutorial | Step-by-step with expected output at each step |
| User knows the basics, has a specific goal | How-to Guide | Goal-oriented steps, skip theory |
| User needs to look up a function/endpoint | Reference | Table or structured list, complete, no narrative |
| User asks "why does this work this way?" | Explanation | Prose, tradeoffs, alternatives considered |
| New feature ships | README update + API reference + changelog entry | Mixed |
| Breaking change ships | Migration guide + changelog + deprecation notice | Structured |
| Internal architecture decision | ADR (Architecture Decision Record) | Template with context, decision, consequences |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| Wall-of-text README | Users leave in 10 seconds | 5-second test: what, why, quick start |
| Code examples not tested | Broken examples destroy trust | Copy-paste into clean env, verify output |
| Mixing tutorial + reference | Newcomers get lost, experts get bored | Separate by Divio type |
| Docs that assume context | "As described above" in a standalone page | Every doc stands alone or links prerequisites |
| Passive voice throughout | "The function is called" — unclear who acts | Second person, present tense, active voice: "You call the function" |
| No version alignment | Docs describe v1, code is v3 | Version docs alongside code, deprecate old docs |
| Features-first README | Lists features nobody understands yet | Lead with the PAIN, then the solution |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| SDD Pipeline | sdd-apply invokes for documentation deliverables; sdd-verify Step 5 validates |
| Batuta Philosophy | Enforces DOCUMENTATION > CODE — code without docs is incomplete |
| CI/CD | Docs build in pipeline (docs fail = build fail) |

## Code Examples

```markdown
# Example: README Quick Start Section

## Quick Start

```bash
npm install @batuta/core
```

```typescript
import { createPipeline } from '@batuta/core';

const pipeline = createPipeline({ name: 'my-feature' });
const result = await pipeline.run();
console.log(result.status); // "success"
```
```

```markdown
# Example: API Reference Entry

## `createPipeline(options)`

Creates a new SDD pipeline instance.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `options.name` | `string` | Yes | Change name (kebab-case) |
| `options.autoVerify` | `boolean` | No | Run verification after apply. Default: `true` |

**Returns:** `Pipeline` instance

**Throws:** `InvalidNameError` if name contains spaces or uppercase

**Example:**
\```typescript
const pipeline = createPipeline({ name: 'user-auth' });
\```
```

## Commands

```bash
# Audit documentation completeness for a project
grep -rn "^## " README.md | head -20

# Check for broken internal links in markdown
grep -rn "\[.*\](.*\.md)" docs/ | while read line; do
  file=$(echo "$line" | grep -oP '\(.*?\.md\)' | tr -d '()');
  [ ! -f "docs/$file" ] && echo "BROKEN: $line";
done

# Count undocumented public functions (Python)
grep -rn "^def [^_]" src/ | wc -l  # total public functions
grep -rn '"""' src/ | wc -l         # approximate docstring count
```

## Rules

- Every README MUST pass the 5-second test (what, why, how to start)
- Every code example MUST be verified to run in a clean environment
- Never mix documentation types (tutorial, how-to, reference, explanation) in the same section
- Use second person ("you"), present tense, active voice throughout
- Every breaking change MUST have a migration guide published BEFORE the release
- Version documentation alongside the code — stale docs are bugs
- One concept per section — if a section covers two topics, split it
- Public APIs without reference documentation are incomplete, regardless of code quality

## What This Means (Simply)

> **For non-technical readers**: This skill ensures that every piece of software comes with clear, tested instructions that anyone can follow. Think of it like a recipe book — if the recipe says "bake for 30 minutes" but the correct time is 45, people will fail. This skill makes sure all our "recipes" are accurate, organized by skill level (beginner tutorials vs expert references), and kept up-to-date as the software changes. Documentation is not optional — it is part of the product.
