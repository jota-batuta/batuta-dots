---
name: debugging-systematic
description: >
  Use when investigating bugs, test failures, unexpected behavior, or production issues.
  Trigger: "debug", "bug", "not working", "error", "failing test", "unexpected behavior",
  "broken", "regression", "root cause", "why is this happening".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-26"
  scope: [pipeline]
  auto_invoke:
    - Investigating a bug or unexpected behavior
    - Test failures with unclear cause
    - Production errors or regressions
    - User reports something is broken or not working
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

This skill enforces a hypothesis-driven debugging methodology that replaces guessing with
structured investigation. Every bug goes through four phases -- Investigate, Analyze, Test,
Fix -- with a hard gate: if three fix attempts fail, stop and question the architecture.
The goal is not just to fix the bug, but to produce artifacts (a failing test, a root cause
explanation, and a backtrack log entry) that prevent recurrence and teach the team.

## When to Use

- A test is failing and the cause is not immediately obvious
- Production error or user-reported bug
- Unexpected behavior that contradicts the spec or design
- Performance degradation or race conditions
- Build failures or integration issues
- Any time the instinct is "let me just try changing this" -- STOP and use this process
- After two quick fix attempts that did not work

## Critical Patterns

### Pattern 1: The Four-Phase Debugging Loop

Every debugging session follows these phases in order. Skipping phases leads to symptom
fixes that create new bugs.

```
PHASE 1 — INVESTIGATE (Gather evidence, do not touch code)
├── Read the COMPLETE error message (stack trace, line numbers, error codes)
├── Reproduce the bug consistently (exact steps, exact input)
├── Check recent changes: git diff, git log --oneline -10, new dependencies
├── Identify the boundary: which component produces the wrong output?
└── OUTPUT: A clear problem statement: "X happens when Y, but Z was expected"

PHASE 2 — ANALYZE (Find patterns, still do not touch code)
├── Locate similar WORKING code in the same codebase
├── Compare working vs broken: list EVERY difference
├── Trace data flow backward from the symptom to the source
├── Check assumptions: "Is this value actually what I think it is?"
└── OUTPUT: The suspected root cause location (file, function, line)

PHASE 3 — HYPOTHESIZE AND TEST (One hypothesis at a time)
├── State the hypothesis explicitly: "I think the cause is X because Y"
├── Design the SMALLEST test that would prove or disprove the hypothesis
├── Run the test — does the evidence support the hypothesis?
├── If NO → form a new hypothesis, return to Phase 2 with new evidence
└── OUTPUT: Confirmed root cause with evidence

PHASE 4 — FIX (Now you may touch code)
├── Write a failing test that reproduces the bug (TDD integration)
├── Implement the MINIMAL fix addressing the root cause
├── Run ALL tests — the new test passes, existing tests still pass
├── Document WHY the bug happened (# WORKAROUND: or # BUG FIX: comment)
└── OUTPUT: Fix + test + documentation
```

### Pattern 2: The Three Strikes Rule

If three fix attempts fail, the problem is architectural, not local.

```
Fix 1 fails → Return to Phase 1, gather more evidence
Fix 2 fails → Return to Phase 2, question your assumptions
Fix 3 fails → FULL STOP. Do NOT attempt a fourth fix.
              Document what you tried and why each failed.
              Escalate from Direct Fix to SDD Pipeline (sdd-explore).
              The bug is a SYMPTOM of a deeper design issue.
```

### Pattern 3: Error Classification

Classify the error type first -- each type has a different investigation strategy.

| Error Type | Key Signal | First Action |
|-----------|-----------|-------------|
| SYNTAX | Error message with exact location | Read the message -- fix is mechanical |
| TYPE | Expected type X, got type Y | Trace value backward to where it was created |
| LOGIC | Wrong output, no error | Add logging at decision points, check branches |
| RUNTIME | Null, division by zero, out of bounds | Find where the value was supposed to be set |
| INTEGRATION | Two components disagree on contract | Check boundary: request format, response shape |
| RACE CONDITION | Intermittent, order-dependent | Add timestamps, look for shared mutable state |
| ENVIRONMENT | Works locally, fails elsewhere | Diff versions, env vars, config, dependencies |

### Pattern 4: Strategic Logging Placement

Log at decision points and boundaries, not everywhere. Five `logger.debug` lines
tracing enter/exit/value are noise. Two strategic logs that capture WHY a branch
was taken and WHAT an external system returned are signal.

```python
# GOOD — log at decision points and boundaries only
def process_order(order):
    validated = validate(order)
    if not validated.ok:
        logger.warning(f"Order rejected: {validated.reason}",
                       extra={"order_id": order.id})
        return OrderResult(status="rejected", reason=validated.reason)

    result = charge(order)  # BOUNDARY: external payment API
    if not result.success:
        logger.error(f"Payment failed: {result.error_code}",
                     extra={"order_id": order.id, "gateway_response": result.raw})
    return result
```

## Decision Trees

### Which Debugging Strategy Should I Use?

| Symptom | Strategy | First Action |
|---------|----------|-------------|
| Error message with stack trace | Read the trace | Go to the exact file and line reported |
| "It used to work" (regression) | Binary search (git bisect) | Find the commit that introduced the bug |
| Wrong output, no error | Add logging at decision points | Trace data flow from input to output |
| Intermittent failure | Look for shared state | Add timestamps, check for race conditions |
| Works locally, fails in CI | Compare environments | Diff env vars, dependency versions, OS |
| Performance degradation | Profile, do not guess | Measure before and after with a profiler |
| Multi-tenant issue (one tenant affected) | Isolate tenant context | Check tenant-specific config, data, and feature flags |

### When to Escalate from Direct Fix to SDD Pipeline

| Signal | Action | Why |
|--------|--------|-----|
| Bug is in 1 file, clear root cause | Direct Fix (Execution Gate LIGHT) | Simple, contained, no architectural risk |
| Bug spans 2-3 files, same module | Direct Fix (Execution Gate FULL) | Still contained but check for ripple effects |
| Bug reveals a missing validation layer | SDD Pipeline (sdd-explore) | Need to understand the scope before adding a new layer |
| Three fix attempts failed | SDD Pipeline (sdd-explore) | Architectural issue, not a local bug |
| Bug is in shared code used by 4+ features | SDD Pipeline (sdd-propose) | Change has wide blast radius, needs proposal |
| Bug involves concurrency or state machines | SDD Pipeline (sdd-design) | Need a proper design for the fix, not a patch |

### Git Bisect for Regressions

Binary search through commits to find the one that introduced the bug.
Mark HEAD as `bad`, a known working commit as `good`, then test the midpoint
Git selects. Repeat until the culprit is found (log2(N) steps). Automate with
`git bisect run <test-command>`. Always end with `git bisect reset`.

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| "Let me just try changing this" | Random changes create new bugs and obscure the cause | Phase 1 first: gather evidence, then hypothesize |
| Fixing symptom, not cause | Bug reappears in a different form, harder to find | Trace backward to ROOT cause, fix there |
| Multiple changes at once | Cannot know WHICH change fixed it | One hypothesis, one change, one test |
| Removing error handling | Silencing errors hides them until production | Fix the cause, keep the guard |
| "It works on my machine" | Environment differences only surface in production | Document and test environment assumptions |
| Debugging without reproducing | Cannot verify fix without reliable reproduction | Reproduce BEFORE investigating |
| try/catch everywhere | Broad handling masks real error location | Specific exceptions at specific boundaries |
| Blaming dependencies first | Most bugs are in YOUR code | Check your code first, then verify dependency |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| SDD Backtrack | Debugging that reveals spec/design flaws logs a backtrack entry, triggering re-evaluation |
| tdd-workflow | Phase 4 invokes tdd-workflow: write failing test, then fix. Debugging finds cause, TDD proves fix |
| sdd-verify | Reproduction tests and root cause comments feed into verify as correctness evidence |
| AI Validation Pyramid | Reinforces Layer 2 (reproduction tests) and Layer 1 (error classification) |
| Auto-Routing | This skill defines WHEN a Direct Fix should escalate to SDD Pipeline |
| Multi-Tenant | For tenant-specific bugs: check RLS policies, context propagation, feature flags first |

## Code Examples

```bash
# Example: Automated git bisect — finds the breaking commit unattended
git bisect start
git bisect bad HEAD
git bisect good HEAD~20
git bisect run pytest tests/test_pricing.py::test_discount_calculation -x
# Git outputs the first bad commit → read the diff → root cause found
git bisect reset
```

```python
# Example: Root cause documentation in a bug fix
def process_payment(order):
    """Process payment for an order via the payment gateway."""
    discount = calculate_discount(order)

    # BUG FIX (2026-02-26): discount returned 0.0 instead of original price
    # when no discount applied, causing gateway INVALID_AMOUNT error.
    # Root cause: missing guard in calculate_discount for empty discount rules.
    # Reproduction test: test_zero_discount_charges_full_price

    # WORKAROUND: Gateway rejects amount=0 even for valid $0 transactions.
    if order.total - discount <= 0:
        return PaymentResult(status="comped", amount=0)
    return gateway.charge(amount=order.total - discount)
```

## Commands

```bash
# Reproduce a failure in isolation
pytest tests/test_orders.py::test_specific_case -x --tb=long

# Check recent changes (first suspect for regressions)
git log --oneline -10
git diff HEAD~3 -- src/

# Automated git bisect with a test script
git bisect start && git bisect bad HEAD && git bisect good v1.2.0
git bisect run pytest tests/test_orders.py::test_failing -x

# Find when a specific line was last changed
git log -p -S "the_broken_function" -- src/module.py

# Compare environments (local vs staging)
diff <(env | sort) <(ssh staging 'env | sort')
```

## Rules

- NEVER attempt a fix before completing Phase 1 (Investigate). "Let me just try this" is the most expensive sentence in debugging.
- ALWAYS reproduce the bug consistently before investigating. If you cannot reproduce it, you cannot verify the fix.
- ALWAYS state hypotheses explicitly before testing them. "I think X because Y" forces clarity and prevents random changes.
- NEVER make more than ONE change per hypothesis test. Multiple simultaneous changes make it impossible to know which one worked.
- AFTER three failed fix attempts, STOP. Escalate from Direct Fix to SDD Pipeline. Three strikes means the problem is architectural.
- ALWAYS write a failing test that reproduces the bug before implementing the fix (integrates with tdd-workflow).
- ALWAYS document the root cause in a code comment using `# BUG FIX:` or `# WORKAROUND:` prefix. Future developers need to know WHY the code looks this way.
- When debugging reveals a spec or design flaw, log it in backtrack-log.md. Do not silently patch around a bad design.
- For regressions ("it used to work"), use `git bisect` FIRST. Binary search finds the culprit commit in minutes instead of hours.
- NEVER remove error handling to make errors go away. Fix the cause, preserve the guard.
- For multi-tenant bugs, ALWAYS check tenant isolation (RLS policies, context propagation, feature flags) before assuming a global issue.

## What This Means (Simply)

> **For non-technical readers**: Systematic debugging is like being a detective instead
> of playing a guessing game. When something breaks, we follow four steps: (1) gather
> clues -- what went wrong, when, what changed, (2) analyze -- compare what works to
> what is broken, trace to the source, (3) form a theory and test it with one small
> experiment, (4) only then apply the fix with a permanent check to prevent recurrence.
> If three attempts fail, we stop and redesign instead of patching endlessly. This
> approach solves problems in 15-30 minutes instead of 2-3 hours, and fixes stick
> because we address the root cause, not the symptom.
