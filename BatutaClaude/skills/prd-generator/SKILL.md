---
name: prd-generator
description: >
  Use when consolidating SDD planning artifacts into a clean execution brief.
  Trigger: "generate PRD", "PRD consolidado", "consolidar planning", "listo para implementar".
  Invoked automatically by pipeline-agent after Task Plan Approval (G1.5).
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-03-30"
  scope: [pipeline]
  auto_invoke: "Generating PRD after task plan approval"
  platforms: [claude, antigravity]
allowed-tools: Read Write Glob
---

## Purpose

You are a sub-agent responsible for generating a **PRD (Product Requirements Document)** —
a consolidated, concise execution brief derived from the SDD planning artifacts.

The PRD solves the context-reset problem: the planning session accumulates exploratory
reasoning, rejected proposals, and revisions. The execution session should start clean
with only the final, approved decisions. The PRD is that clean input.

**When invoked**: After Task Plan Approval, before sdd-apply begins.
**Output**: `openspec/changes/{change-name}/PRD.md`

---

## Step 1 — Locate artifacts

Read from `openspec/changes/{change-name}/`:
- `spec.md` — requirements and acceptance criteria
- `design.md` — technical decisions and architecture
- `tasks.md` — implementation breakdown and exit criteria

If any of these files is missing, report: "PRD generation blocked — missing: {file}. Complete {phase} first."

---

## Step 2 — Extract and consolidate

From the three artifacts, extract only the final approved content:

| Source | Extract |
|--------|---------|
| `spec.md` | Problem statement, user stories with acceptance criteria, non-functional requirements |
| `design.md` | Non-negotiable technical decisions, key constraints, architecture summary |
| `tasks.md` | Task list (names only, not implementation detail), definition of done |

**Do NOT include**: rejected alternatives, exploratory notes, rationale paragraphs,
intermediate decisions, or content marked as "considered but not chosen."

---

## Step 3 — Write PRD.md

Write to `openspec/changes/{change-name}/PRD.md`:

```markdown
# PRD — {change-name}
*Generated from spec.md + design.md + tasks.md on {ISO date}*
*Read this file + tasks.md to start the execution session.*

## What We're Building
{1 paragraph: problem + solution. No more.}

## User Stories with Acceptance Criteria
- As {role}, I want {action} so that {benefit}.
  ✓ Criteria: {list of testable conditions}

## Non-Negotiable Technical Decisions
- {technology/approach}: {decision} — {one-line reason}

## Constraints
- {hard limit or requirement that cannot be changed}

## Definition of Done
{Copy the exit criteria section from tasks.md verbatim}

## Implementation Plan
See: `openspec/changes/{change-name}/tasks.md`
```

Keep the PRD under 80 lines. If it grows beyond 80 lines, you are including too much detail — trim.

---

## Step 4 — Report

Return to pipeline-agent with:

```
STATUS: success
ARTIFACT: openspec/changes/{change-name}/PRD.md
LINES: {line count}
READY_MESSAGE: "Lee PRD.md y tasks.md de {change-name}, implementa Task 1"
```
