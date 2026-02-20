---
name: {skill-name}
description: >
  {One-line description of what this skill does}.
  Trigger: {When the AI should load this skill -- include natural language triggers
  such as "working with {technology}", "setting up {component}", "{action} {target}"}.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "{YYYY-MM-DD}"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- {Condition when this skill should be loaded}
- {Another trigger condition}
- {Technology or pattern this covers}

## Critical Patterns

{The most important rules -- what the AI MUST know when working in this domain.
These are the conventions that differ from generic best practices or that are
specific to the Batuta ecosystem.}

### Pattern 1: {Pattern Name}

{Description of the pattern and why it matters.}

```{language}
{Minimal, focused code example demonstrating the pattern}
```

### Pattern 2: {Pattern Name}

{Description and example.}

## Decision Trees

{Use tables when the AI needs to choose between approaches.}

| Situation | Approach | Why |
|-----------|----------|-----|
| {Condition A} | {Do X} | {Reason} |
| {Condition B} | {Do Y} | {Reason} |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| {Anti-pattern 1} | {Reason} | {Correct approach} |

## Stack Integration

{How this skill's patterns interact with the broader Batuta stack.
Only include sections that are relevant -- not every skill touches the full stack.}

| Layer | Integration Point |
|-------|-------------------|
| {e.g., Database} | {How this skill interacts with PostgreSQL/RLS} |
| {e.g., Orchestration} | {How this skill interacts with Temporal/n8n} |

## Code Examples

{Minimal, focused examples. Prefer showing the Batuta-specific pattern,
not generic usage that the AI already knows.}

```{language}
# Example: {what this demonstrates}
{code}
```

## Commands

```bash
# {Description of command}
{command}

# {Description of another command}
{command}
```

## Rules

- {Hard constraint 1 -- things the AI MUST always do}
- {Hard constraint 2 -- things the AI MUST never do}
- {Convention that differs from the default}

## What This Means (Simply)

> **For non-technical readers**: {Plain language summary of what this skill enforces
> and why it matters. No jargon, no code references. Explain in terms anyone on the
> team can understand.}

## Resources

- **Templates**: See [assets/](assets/) for {description of templates}
- **Documentation**: See [references/](references/) for local docs
