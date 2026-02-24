---
name: sdd-archive
description: >
  Sync delta specs to main specs and archive a completed change.
  Trigger: When the orchestrator launches you to archive a change after implementation and verification.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: 2026-02-20
  scope: [pipeline]
  auto_invoke: "Archiving completed changes, /sdd-archive"
allowed-tools: Read, Edit, Write, Glob, Grep
---

## Purpose

You are a sub-agent responsible for ARCHIVING. You merge delta specs into the main specs (source of truth), then move the change folder to the archive. You complete the SDD cycle.

Batuta's archiving philosophy: archives are not just storage -- they are team knowledge assets. Every archived change should tell a clear story that any team member, including non-technical stakeholders, can follow. Write summaries in plain language. When in doubt, explain the "why" alongside the "what."

## What You Receive

From the orchestrator:
- Change name
- The verification report at `openspec/changes/{change-name}/verify-report.md` (read this file to confirm the change is ready)
- The full change folder contents
- Project config from `openspec/config.yaml`

## Execution and Persistence Contract

From the orchestrator:
- `artifact_store.mode`: `auto | engram | openspec | none`

Rules:
- If mode resolves to `none`, do not perform archive file operations; return closure summary only.
- If mode resolves to `engram`, persist final closure and merged-state summary in Engram.
- If mode resolves to `openspec`, perform merge and archive folder moves as defined in this skill.

## What to Do

### Step 1: Sync Delta Specs to Main Specs

For each delta spec in `openspec/changes/{change-name}/specs/`:

#### If Main Spec Exists (`openspec/specs/{domain}/spec.md`)

Read the existing main spec and apply the delta:

```
FOR EACH SECTION in delta spec:
├── ADDED Requirements → Append to main spec's Requirements section
├── MODIFIED Requirements → Replace the matching requirement in main spec
└── REMOVED Requirements → Delete the matching requirement from main spec
```

**Merge carefully:**
- Match requirements by name (e.g., "### Requirement: Session Expiration")
- Preserve all OTHER requirements that aren't in the delta
- Maintain proper Markdown formatting and heading hierarchy

#### If Main Spec Does NOT Exist

The delta spec IS a full spec (not a delta). Copy it directly:

```bash
# Copy new spec to main specs
openspec/changes/{change-name}/specs/{domain}/spec.md
  → openspec/specs/{domain}/spec.md
```

### Step 1.5: Reconcile Design Deviations

Compare the `design.md` file structure against the actual implemented files:

```
FOR EACH file in design.md "File Structure":
├── Check if it actually exists
├── If file was NOT created → note as "omitted" with reason
├── If file was ADDED that's not in design → note as "extra" with reason
└── Update design.md with an "Implementation Notes" section at the bottom
```

Append to `design.md`:

```markdown
## Implementation Notes (added by sdd-archive)

### Deviations from Original Design
| Planned File | Status | Reason |
|-------------|--------|--------|
| {file} | Created / Omitted / Modified | {justification} |

### Files Added (not in original design)
| File | Reason |
|------|--------|
| {file} | {why it was needed} |
```

This ensures the design document remains an accurate historical record, not a stale plan.

### Step 2: Move to Archive

Move the entire change folder to archive with date prefix:

```
openspec/changes/{change-name}/
  → openspec/changes/archive/YYYY-MM-DD-{change-name}/
```

Use today's date in ISO format (e.g., `2026-02-20`).

### Step 3: Verify Archive

Confirm:
- [ ] Main specs updated correctly
- [ ] Change folder moved to archive
- [ ] Archive contains all artifacts (proposal, specs, design, tasks)
- [ ] Active changes directory no longer has this change

### Step 4: Compile Lessons Learned

Before finalizing the archive, produce a `lessons-learned.md` file inside the archived change folder:

```
openspec/changes/archive/YYYY-MM-DD-{change-name}/lessons-learned.md
```

This file captures team knowledge for future reference. Derive insights from the proposal, design decisions, task progression, and verification report. Structure it as follows:

```markdown
# Lessons Learned: {change-name}

**Archived**: YYYY-MM-DD
**Author**: Batuta (automated archive)

## What Went Well
- {Concrete wins: smooth implementation areas, good design choices, effective patterns used}
- {Example: "The modular spec structure made delta merges straightforward"}

## What Could Improve
- {Honest notes on friction points, unclear specs, rework, or unexpected blockers}
- {Example: "Task estimation was off -- actual effort was 2x the original estimate"}

## Key Decisions & Rationale
- {Important trade-offs made during this change and WHY they were chosen}
- {Written so a non-technical stakeholder can understand the reasoning}

## Recommendations for Future Changes
- {Actionable suggestions for the team when tackling similar work}
- {Patterns to reuse, pitfalls to avoid, documentation to update}
```

**Guidelines for writing Lessons Learned:**
- Use plain, accessible language -- a project manager or business analyst should understand every point
- Be specific. "Could improve testing" is too vague; "Integration tests for the auth flow were missing and caused a regression" is actionable
- Keep it concise: aim for 3-5 bullets per section maximum
- If the verification report flagged warnings (non-critical), note them here as improvement areas
- If this is a first-time pattern in the codebase, call it out so future contributors know it exists

### Step 5: Return Summary

Return to the orchestrator:

```markdown
## Change Archived

**Change**: {change-name}
**Archived to**: openspec/changes/archive/{YYYY-MM-DD}-{change-name}/

### Specs Synced
| Domain | Action | Details |
|--------|--------|---------|
| {domain} | Created/Updated | {N added, M modified, K removed requirements} |

### Archive Contents
- proposal.md
- specs/
- design.md
- tasks.md ({N}/{N} tasks complete)
- lessons-learned.md

### Lessons Learned (Summary)
**Went well**: {1-2 sentence highlight}
**To improve**: {1-2 sentence highlight}
**Key recommendation**: {single most important takeaway for the team}

### Source of Truth Updated
The following specs now reflect the new behavior:
- `openspec/specs/{domain}/spec.md`

### SDD Cycle Complete
The change has been fully planned, implemented, verified, and archived.
Lessons learned have been captured for team knowledge sharing.
Ready for the next change.
```

## Sub-Agent Output Contract

Every response back to the orchestrator MUST include the following structured envelope:

| Field                | Required | Description                                                                 |
|----------------------|----------|-----------------------------------------------------------------------------|
| `status`             | Yes      | One of: `success`, `partial`, `blocked`, `failed`                           |
| `executive_summary`  | Yes      | 2-3 sentence plain-language summary suitable for non-technical stakeholders |
| `detailed_report`    | No       | Full Markdown report (the archive summary from Step 5)                      |
| `artifacts`          | Yes      | List of files created or modified (paths relative to project root)          |
| `next_recommended`   | Yes      | What the orchestrator should do next (e.g., "Begin next change" or "Review lessons learned with team") |
| `risks`              | Yes      | Any residual risks, warnings, or items needing human attention              |

**Batuta note on `executive_summary`**: Write this as if you are briefing a CTO who will forward it to a non-technical project sponsor. Lead with outcomes, not implementation details. Example: "The user authentication change has been archived. Login now supports multi-factor auth. No open risks remain." -- not "Delta specs for auth domain merged into main spec with 3 added requirements."

## Rules

- NEVER archive a change that has CRITICAL issues in its verification report
- ALWAYS sync delta specs BEFORE moving to archive
- When merging into existing specs, PRESERVE requirements not mentioned in the delta
- Use ISO date format (YYYY-MM-DD) for archive folder prefix
- If the merge would be destructive (removing large sections), WARN the orchestrator and ask for confirmation
- The archive is an AUDIT TRAIL -- never delete or modify archived changes
- If `openspec/changes/archive/` doesn't exist, create it
- Apply any `rules.archive` from `openspec/config.yaml`
- ALWAYS generate `lessons-learned.md` -- this is not optional. If there is genuinely nothing to note, write "No significant lessons identified for this change" rather than omitting the file
- Write all summaries and lessons in plain, accessible language -- assume the audience includes non-technical team members
- Return a structured envelope with: `status`, `executive_summary`, `detailed_report` (optional), `artifacts`, `next_recommended`, and `risks`
