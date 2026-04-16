---
name: {skill-name}
description: >
  Use when {trigger conditions — max ≤45 chars (~15 tokens) TOTAL for the description
  field; must fit Claude Code's ~450 token metadata budget. Start with "Use when..." and
  contain ONLY activation conditions. Never summarize the workflow.}
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "{YYYY-MM-DD}"
  bucket: {category}  # Valid values: define | plan | build | verify | review | ship | meta
  auto_invoke: "{human-readable trigger for when this skill should be loaded}"
  platforms: [claude, antigravity]
  category: "{workflow | capability}"  # workflow = orchestrates multi-step processes; capability = domain expertise (default)
  # owner_agent: "{agent-name}"  # Optional: agent that maintains this skill
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

{One paragraph: what this skill does, who benefits, and why it exists.
Non-technical readers should understand the skill's role from this alone.}

## When to Use

- {Condition when this skill should be loaded}
- {Another trigger condition}
- {Technology or pattern this covers}

## When NOT to Use

- {Cases where this skill is the wrong tool — redirect to the correct one}
- {Out-of-scope situations to prevent false-positive activation}
- {Overlap with another skill, with guidance on which to prefer}

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

## Common Rationalizations

| Rationalization | Counter |
|-----------------|---------|
| "{Excuse the agent might make to skip this skill's rules}" | {Why that excuse is wrong and what to do instead} |
| "{Another plausible-sounding shortcut}" | {The real cost/risk and the correct path} |
| "{Edge-case argument for bypassing a hard rule}" | {Why the rule exists and how to handle the edge case correctly} |

## Red Flags

- {Observable sign that the agent is drifting away from this skill's guidance}
- {Concrete phrase or behavior that indicates a violation is about to happen}
- {Code or output shape that always warrants a second look}
- {Structural pattern that signals the wrong approach is being taken}

## Verification Checklist

- [ ] {Measurable check a reviewer can run to confirm the skill was followed — binary pass/fail}
- [ ] {Covers a load-bearing guarantee of this skill}
- [ ] {Each item is specific enough to be unambiguous}
- [ ] {No subjective checks — if it requires judgment, rewrite as an observable fact}

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
