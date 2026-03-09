---
name: team-orchestrator
description: >
  Use when evaluating task complexity, spawning teams, or coordinating multi-agent work.
  Provides team coordination rules and composition patterns for the Batuta ecosystem.
license: MIT
metadata:
  author: Batuta
  version: "2.0"
  created: "2026-02-22"
  scope: [infra]
  auto_invoke:
    - "Evaluating whether to use subagents or Agent Teams"
    - "Spawning a team for complex tasks"
    - "Coordinating multi-agent work"
  platforms: [claude]
allowed-tools: Read Edit Write Glob Grep Bash Task
---

# Team Orchestrator

## Purpose

Decide the optimal execution level for any task and orchestrate Agent Teams when complexity warrants it. This skill integrates with the Execution Gate to recommend the right parallelism strategy.

## Decision Tree

```
Execution Gate fires →

  Q1: How many files will this change?
    1 file → LEVEL 1 (solo)
    2-3 files, same scope → LEVEL 2 (subagent)
    4+ files OR multi-scope → go to Q2

  Q2: Do workers need to communicate?
    No (independent tasks) → LEVEL 2 (subagents in parallel)
    Yes (shared decisions, cross-cutting) → LEVEL 3 (Agent Team)

  Q3: Is there a risk of file conflicts?
    No (each worker owns different files) → LEVEL 3 (team)
    Yes (same files) → LEVEL 2 (sequential subagents)
```

### Level Reference

| Level | Mechanism | When | Token Cost | Coordination |
|-------|-----------|------|------------|--------------|
| 1 — Solo | Single session | Bug fix, 1-file edit, question | 1x | None |
| 2 — Subagent | Task tool | Research, verify, single SDD phase | 1.2-1.5x | Fire-and-forget |
| 3 — Team | Agent Teams | Multi-module feature, full SDD pipeline, debug with hypotheses | 3-5x | Bidirectional, shared task list |

### Anti-patterns (do NOT create a team for)

- Single-file edits (use solo)
- Sequential tasks where each depends on the previous (use subagents)
- Tasks under 3 files that don't need inter-worker communication
- Routine commits, formatting, documentation-only changes

## Spawning a Team

### Pre-spawn checklist

1. Confirm LEVEL 3 via decision tree
2. Identify scope(s) involved (pipeline, infra, observability)
3. Define task list with explicit dependencies
4. Present team plan to user: "Voy a crear un equipo de {N} teammates: {roles}. Procedo?"

### Teammate configuration

Teammates are spawned using the scope agent files in `~/.claude/agents/`. Each scope agent has:
- **Frontmatter**: `skills` (preloaded automatically), `memory: project`
- **Body**: domain knowledge, rules, O.R.T.A. responsibilities

The lead passes the specific task description when creating each teammate.

## Contract-First Protocol

Before spawning ANY teammate, the lead MUST define explicit contracts. This prevents incompatible outputs, file conflicts, and wasted tokens.

### 1. Pre-Spawn Contract Definition

For EACH teammate, define before spawning:

```
TEAMMATE CONTRACT:
├── Name: {teammate-name}
├── Input Contract:
│   ├── Receives: {what data/context this teammate gets}
│   ├── Format: {JSON schema, markdown artifacts, file paths}
│   └── From: {who produces this input — lead or another teammate}
├── Output Contract:
│   ├── Produces: {what this teammate must deliver}
│   ├── Format: {artifact type, file format, location}
│   └── Success criteria: {how to verify output is complete}
└── File Ownership:
    ├── OWNS: {files this teammate can create/modify}
    └── DO NOT TOUCH: {files owned by other teammates}
```

### 2. File Ownership Rules

- Each file belongs to EXACTLY ONE teammate (no overlap)
- Lead is the only one who can touch shared/integration files
- If two teammates need the same file → redesign the task split
- Teammate spawn prompt includes: "You OWN: [files]. Do NOT modify: [other files]"

### 3. Contract Diff (Pre-Completion)

Before marking a teammate's task as done, the lead verifies:

```
CONTRACT DIFF:
├── Compare output vs output contract
├── Missing fields/artifacts → REJECT with specific feedback
├── Extra fields/artifacts → Evaluate if valuable, update contract if yes
├── File ownership violated → REJECT (touched files not in OWNS list)
└── All checks pass → APPROVE completion
```

### 4. Cross-Review Protocol

After teammates produce outputs, cross-review catches interface bugs:

- Frontend teammate reviews Backend API contracts (correct endpoints, response shapes)
- Backend teammate reviews Frontend data consumption (correct field usage)
- All teammates verify their outputs match the SDD specs
- Security reviewer (if present) reviews ALL teammate outputs for the AI-First Security Checklist

### Contract Examples by Pattern

| Pattern | Input Contract | Output Contract |
|---------|---------------|-----------------|
| SDD Pipeline | SDD artifacts (proposal, spec, design) | Phase artifacts per SDD schema |
| Parallel Review | Source code + review checklist | Review report per pyramid layer |
| Investigation | Bug report + hypothesis | Evidence report + confidence score |
| Cross-Layer | API schema + data models | Implementation per layer |

## Handoff Protocol

Context loss is the #1 cause of multi-agent coordination failure. Structured handoffs prevent it. Every time a teammate finishes work and passes it to another, use one of these templates.

### Standard Handoff (teammate → teammate)

When a teammate completes a task and another teammate needs the results:

```markdown
## Handoff: {task-name}

| Field | Value |
|-------|-------|
| **From** | {teammate-name} |
| **To** | {teammate-name} |
| **Task Reference** | {task ID from task list} |

### Context
- **Current state**: {what was completed, specific results}
- **Relevant files**: {file paths with brief description of each}
- **Dependencies**: {what this work depends on being complete}
- **Constraints**: {technical or timeline constraints discovered}

### Deliverable Request
- **What is needed**: {specific, measurable deliverable}
- **Acceptance criteria**:
  - [ ] {criterion 1 — measurable}
  - [ ] {criterion 2 — measurable}
- **References**: {links to specs, design decisions, previous outputs}

### Quality Expectations
- **Must pass**: {specific quality criteria}
- **Evidence required**: {what proof of completion looks like}
```

### QA Rejection Handoff (reviewer → implementer)

When verification or review finds issues that need fixing:

```markdown
## QA Rejection: {task-name}

| Field | Value |
|-------|-------|
| **Task** | {task ID} — {description} |
| **Reviewer** | {reviewer-name} |
| **Implementer** | {implementer-name} |
| **Attempt** | {N} of 3 |

### Issues Found

**Issue 1**: {title}
- **Category**: {lint / test / spec mismatch / security / docs}
- **Severity**: {CRITICAL / HIGH / MEDIUM}
- **Expected**: {what should happen}
- **Actual**: {what actually happens}
- **Fix instruction**: {specific and actionable — what to change, not just what's wrong}
- **File(s)**: {exact paths to modify}

{Repeat for each issue}

### Retry Instructions
- Fix ONLY the listed issues — do NOT introduce new changes
- Re-submit when all issues are addressed
- If attempt 3 fails → escalation (see below)
```

### Escalation Handoff (teammate → lead)

When a task fails 3 attempts and needs lead intervention:

```markdown
## Escalation: {task-name}

| Field | Value |
|-------|-------|
| **Task** | {task ID} — {description} |
| **Attempts Exhausted** | 3/3 |
| **Implementer** | {teammate-name} |
| **Reviewer** | {teammate-name} |

### Failure History
- **Attempt 1**: {issues found} → {fixes applied} → {result}
- **Attempt 2**: {issues found} → {fixes applied} → {result}
- **Attempt 3**: {issues found} → {fixes applied} → {result}

### Root Cause Analysis
- **Why it keeps failing**: {pattern identified}
- **Systemic issue?**: {yes/no — does this point to a deeper problem?}

### Recommended Resolution
Pick ONE:
- [ ] **Reassign** to a different teammate with different expertise
- [ ] **Decompose** into smaller sub-tasks: {proposed breakdown}
- [ ] **Revise approach** — the design decision may need rethinking
- [ ] **Accept with limitations** — document what doesn't work and why
- [ ] **Defer** to a future change — remove from current scope

### Impact
- **Blocked tasks**: {task IDs that depend on this one}
- **Timeline impact**: {how this affects the overall delivery}
```

### Handoff Readiness Checklist

Before sending ANY handoff, the sender MUST verify:

```
HANDOFF READINESS:
├── All acceptance criteria from MY contract are met
├── Files I OWN are in a clean state (no partial implementations)
├── My output is documented (not just "it works" — what exactly was done)
├── Context the receiver needs is explicitly stated (not assumed)
└── If I found issues outside my scope, they are noted in the handoff
```

### When to Use Each Template

| Situation | Template |
|-----------|----------|
| Task complete, passing to next teammate | Standard Handoff |
| Review/verify rejects implementation | QA Rejection |
| 3 failed attempts on same task | Escalation |
| Lead assigns initial work | Use Contract-First Protocol (above) — not a handoff |

## Composition Patterns

**Pattern A: SDD Pipeline Team**
For full feature implementation following SDD:

| Teammate | Scope Agent | Tasks |
|----------|-------------|-------|
| researcher | pipeline-agent | explore, propose |
| architect | pipeline-agent | spec, design |
| implementor-1 | pipeline-agent + infra-agent | apply (batch 1) |
| implementor-2 | pipeline-agent + infra-agent | apply (batch 2) |
| reviewer | pipeline-agent | verify |

Lead handles: init, tasks (splitting), archive, coordination.

**Pattern B: Parallel Review Team (AI Validation Pyramid)**
For comprehensive code review, aligned with the AI Validation Pyramid layers:

| Teammate | Pyramid Layer | Checks |
|----------|---------------|--------|
| static-reviewer | Layer 1: Type Check/Lint | Lint errors, type safety, formatting, dead code |
| test-reviewer | Layer 2-3: Unit + E2E | Missing tests, edge cases, run test suite, E2E coverage |
| security-reviewer | Cross-layer: Security | OWASP top 10, auth, input validation, secrets |
| perf-reviewer | Cross-layer: Performance | N+1 queries, bundle size, memory leaks |

Lead handles: synthesizing findings, ensuring agent layers (1-3) pass before flagging items for human layers (4-5: code review + manual testing). Pyramid rule: **broken base = no human review**.

**Pattern C: Investigation Team**
For debugging complex issues:

| Teammate | Hypothesis | Approach |
|----------|-----------|----------|
| hypothesis-1 | Network issue | Trace API calls, check timeouts |
| hypothesis-2 | State bug | Trace state mutations, check race conditions |
| hypothesis-3 | Config error | Check env vars, deployment config, dependencies |

Lead handles: comparing findings, identifying root cause.

**Pattern D: Cross-Layer Team**
For changes spanning multiple architectural layers:

| Teammate | Layer | Owns |
|----------|-------|------|
| backend-dev | API | Routes, controllers, services |
| frontend-dev | UI | Components, pages, state |
| infra-dev | Deploy | Docker, CI/CD, migrations |

Lead handles: integration points, API contracts, coordination.

**Pattern E: Superpowers-Style Review (per-task quality loop)**
For tasks evaluated as Level 2+ complexity during sdd-apply:

```
SUPERPOWERS REVIEW LOOP (per task batch):
├── Implementer: sdd-apply (writes code for the task batch)
├── Spec Reviewer: verifies implementation matches spec.md scenarios
│   ├── Each Given/When/Then scenario accounted for?
│   ├── Missing features? Extra features not in spec?
│   └── If issues → return to implementer with specific feedback
├── Code Quality Reviewer: verifies patterns, docs, security
│   ├── Scope Rule followed? Documentation complete?
│   ├── Anti-patterns from loaded skills avoided?
│   └── If issues → return to implementer with specific feedback
└── Loop: reviewers approve OR implementer re-implements → re-review
```

| Teammate | Role | Checks |
|----------|------|--------|
| implementer | pipeline-agent | Write code per tasks.md, follow sdd-apply |
| spec-reviewer | pipeline-agent | Compare output vs spec.md scenarios |
| quality-reviewer | infra-agent | Scope Rule, docs, security, skill compliance |

**When to activate**: sdd-apply complexity Level 2+ (4+ files, multi-module, architectural decisions).
**When NOT to**: Level 1 tasks (single-file, trivial edits).
**Key constraint**: Spec review BEFORE code quality review (no point reviewing code quality on wrong implementation).

## SDD Pipeline as Task List

Map SDD phases to team tasks with dependencies:

```
Task 1: explore          (no deps)        → researcher
Task 2: propose          (depends: 1)     → researcher/architect
Task 3: spec             (depends: 2)  ┐
Task 4: design           (depends: 2)  ┘  → architect (PARALLEL)
Task 5: tasks            (depends: 3,4)   → lead
Task 6: apply-batch-1    (depends: 5)  ┐
Task 7: apply-batch-2    (depends: 5)  ┘  → implementors (PARALLEL)
Task 8: verify           (depends: 6,7)   → reviewer
Task 9: archive          (depends: 8)     → lead
```

## Integration Points

### With Execution Gate
The gate's FULL mode includes a "Team Assessment" step:
- Scope count > 1 AND files > 4 → suggest LEVEL 3
- Single scope, focused change → LEVEL 1 or 2

### With O.R.T.A.
- **Session management**: SessionStart/Stop hooks handle context injection and persistence
- **Plan approval**: lead reviews teammate plans (= Execution Gate for teams)
- **Contract Diff**: lead verifies output vs contract before approving completion (replaces external quality gates)

### With Skill Gap Detection
During team work, if a teammate encounters a technology without a skill:
1. Teammate messages lead: "Necesito skill para {tech}"
2. Lead spawns a new "researcher" teammate to create the skill
3. Researcher creates SKILL.md (auto-discovered by description)
4. Original teammate reloads and continues

### With Session Continuity
At team CLOSE, the lead updates .batuta/session.md with:
- Team composition used
- Tasks completed by each teammate
- Patterns discovered (for future team optimization)
- Skills created during team work

## Metrics to Track

| Metric | How to measure | Target |
|--------|---------------|--------|
| Team vs solo ratio | Teams created / total sessions | 10-20% |
| Teammate utilization | Active time / total time per teammate | > 70% |
| Task completion rate | Completed / total tasks | > 90% |
| Contract rejection rate | Contract Diff rejections / completions | < 15% |
| Skill gap discovery rate | New skills per team session | Track, no target |
| Token efficiency | Result quality / tokens used (vs solo baseline) | > 1.5x quality for 3-5x tokens |

## Platform Note

Windows (Git Bash) only supports `in-process` mode. macOS supports split panes via tmux/iTerm2.
