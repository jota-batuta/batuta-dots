---
name: team-orchestrator
description: >
  Decides when to use solo session, subagents, or Agent Teams based on task complexity.
  Provides spawn prompts and team coordination rules for the Batuta ecosystem.
  Trigger: When evaluating task complexity, spawning teams, or coordinating multi-agent work.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-22"
  scope: [infra]
  auto_invoke:
    - "Evaluating whether to use subagents or Agent Teams"
    - "Spawning a team for complex tasks"
    - "Coordinating multi-agent work"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task
---

# Team Orchestrator

## Purpose

Decide the optimal execution level for any task and orchestrate Agent Teams when complexity warrants it. This skill integrates with the Execution Gate to recommend the right parallelism strategy.

## Execution Levels

### Decision Tree

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
3. Read the relevant scope-agent .md files for spawn prompt content
4. Define task list with explicit dependencies
5. Present team plan to user: "Voy a crear un equipo de {N} teammates: {roles}. Procedo?"

### Spawn prompt template

When creating a teammate, use this structure:

```
You are a {ROLE} specialist for the Batuta software factory.

## Your scope
{Content from the relevant scope-agent .md file}

## Your task
{Specific task description from the shared task list}

## Rules
- Follow all patterns in your loaded skills (they load automatically via ~/.claude/skills/)
- Apply the Execution Gate (LIGHT mode) before any code change
- Follow the Scope Rule for ALL file creation
- When done, mark your task as complete and message the lead with a summary
- If blocked, message the lead immediately instead of guessing

## O.R.T.A. Compliance
- Log significant decisions to .batuta/prompt-log.jsonl only if you are the LEAD
- Teammates: report findings to the lead who handles centralized logging
- Never skip quality checks even under time pressure
```

### Team composition patterns

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

**Pattern B: Parallel Review Team**
For comprehensive code review:

| Teammate | Focus | Checks |
|----------|-------|--------|
| security-reviewer | Security | OWASP top 10, auth, input validation, secrets |
| perf-reviewer | Performance | N+1 queries, bundle size, memory leaks |
| test-reviewer | Test coverage | Missing tests, edge cases, mocks vs integration |

Lead handles: synthesizing findings, prioritizing issues.

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

## Team Lifecycle

```
1. PLAN    — Lead evaluates complexity → decides team composition
2. SPAWN   — Lead creates teammates with scope-agent spawn prompts
3. ASSIGN  — Lead creates task list with dependencies
4. WORK    — Teammates self-claim and execute tasks
5. GATE    — TaskCompleted hooks verify quality
6. SYNC    — Lead synthesizes results, resolves conflicts
7. CLOSE   — Lead asks teammates to shut down → cleanup
```

## Integration Points

### With Execution Gate
The gate's FULL mode now includes a "Team Assessment" step:
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
| Team vs solo ratio | Teams created / total sessions | 10-20% (most work is solo) |
| Teammate utilization | Active time / total time per teammate | > 70% |
| Task completion rate | Completed / total tasks | > 90% |
| Gate rejection rate | TaskCompleted rejections / completions | < 15% |
| Skill gap discovery rate | New skills per team session | Track, no target |
| Token efficiency | Result quality / tokens used (vs solo baseline) | > 1.5x quality for 3-5x tokens |

## Platform Notes

- **Windows (Git Bash)**: Only `in-process` mode available. Use Shift+Down to navigate teammates.
- **macOS (tmux/iTerm2)**: Split panes available for visual monitoring.
- **VS Code terminal**: in-process mode only (split panes not supported).
