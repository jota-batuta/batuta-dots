---
name: team-orchestrator
description: >
  Decides when to use solo session, subagents, or Agent Teams based on task complexity.
  Provides team coordination rules and composition patterns for the Batuta ecosystem.
  Trigger: When evaluating task complexity, spawning teams, or coordinating multi-agent work.
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
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
platforms: [claude]
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
- **TeammateIdle hook**: centralizes logging when teammates finish
- **TaskCompleted hook**: quality gate before marking tasks done
- **Plan approval**: lead reviews teammate plans (= Execution Gate for teams)

### With Skill Gap Detection
During team work, if a teammate encounters a technology without a skill:
1. Teammate messages lead: "Necesito skill para {tech}"
2. Lead spawns a new "researcher" teammate to create the skill
3. Researcher creates SKILL.md → runs skill-sync
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
| Gate rejection rate | TaskCompleted rejections / completions | < 15% |
| Skill gap discovery rate | New skills per team session | Track, no target |
| Token efficiency | Result quality / tokens used (vs solo baseline) | > 1.5x quality for 3-5x tokens |

## Platform Note

Windows (Git Bash) only supports `in-process` mode. macOS supports split panes via tmux/iTerm2.
