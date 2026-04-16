---
name: tdd-workflow
description: >
  Use when writing new features, fixing bugs, or refactoring code that needs tests.
  Trigger: "write tests", "test first", "TDD", "red green refactor", "add tests for",
  "test-driven", "failing test", "test coverage", "what should I test".
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-26"
  bucket: build
  auto_invoke:
    - Writing new feature code that needs tests
    - Fixing a bug (write failing test first)
    - Refactoring existing code with test safety net
    - User asks about testing strategy or TDD workflow
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

This skill enforces a Test-Driven Development workflow where tests are written BEFORE
implementation code, following the Red-Green-Refactor cycle. It formalizes WHEN to use
TDD, HOW to write effective tests, and WHERE tests live relative to the code they verify.
TDD is the primary mechanism for reinforcing Layers 1-3 of the AI Validation Pyramid --
if you write the test first, the agent cannot "prove" broken behavior with matching broken tests.

## When to Use

- Writing any new feature or function (test the behavior you want, then build it)
- Fixing a bug (reproduce the bug as a failing test, then fix it)
- Refactoring code (ensure tests exist first so you know nothing breaks)
- Adding validation, business rules, or edge case handling
- Any sdd-apply task that involves production code changes
- When sdd-verify reports missing test coverage

## Critical Patterns

### Pattern 1: The Red-Green-Refactor Cycle

Every code change follows this three-step loop. No shortcuts, no reordering.

```
STEP 1 — RED (Write a failing test)
├── Write ONE test for the next behavior you need
├── Run the test — it MUST fail
├── Verify it fails for the RIGHT reason (missing feature, not typo)
└── If it passes immediately → your test is wrong, delete and rewrite

STEP 2 — GREEN (Make it pass with minimal code)
├── Write the SIMPLEST code that makes the test pass
├── No extra features, no "while I'm here" changes
├── Run ALL tests — the new one passes, existing ones still pass
└── If existing tests break → your change has side effects, investigate

STEP 3 — REFACTOR (Clean up, tests stay green)
├── Remove duplication between production and test code
├── Improve naming, extract helpers, simplify logic
├── Run ALL tests after each refactor step
└── If any test goes red → undo the refactor, try a smaller step
```

### Pattern: Test Pyramid Distribution

Aim for this distribution across your test suite:

| Layer | Percentage | Speed Target | What It Tests |
|---|---|---|---|
| Unit tests | ~80% | < 50ms each | Single function/module in isolation |
| Integration tests | ~15% | < 500ms each | Two modules working together |
| E2E tests | ~5% | < 5s each | Full user workflow end-to-end |

This ratio optimizes for speed (most tests run instantly) while catching real bugs at boundaries.

### Pattern: DAMP Over DRY in Tests

Test code prioritizes readability over reuse (**D**escriptive **A**nd **M**eaningful **P**hrases).

- Each test should tell a complete story without tracing through shared helpers
- Duplicated setup is acceptable if it improves clarity
- Avoid shared `beforeEach` blocks that make individual tests hard to understand
- This is the INVERSE of production code, where DRY is paramount

### Pattern 2: Test-First Bug Fixes

When fixing a bug, the test IS the proof that the bug existed and is now fixed.

```python
# STEP 1: Write a test that reproduces the bug exactly
def test_negative_inventory_rejects_order():
    """
    BUG: Orders were accepted even when inventory was negative.
    This test proves the bug exists (RED) and later proves the fix works (GREEN).
    """
    inventory = create_inventory(item="widget", quantity=-5)
    result = place_order(item="widget", quantity=1)
    assert result.status == "rejected"
    assert "insufficient inventory" in result.reason

# STEP 2: Run test → confirms it fails (bug is real)
# STEP 3: Fix the bug with minimal code
# STEP 4: Run test → confirms it passes (bug is fixed)
# STEP 5: Run ALL tests → confirms nothing else broke
```

### Pattern 3: Test Naming and Mocking Rules

**Naming**: Test names describe WHAT the system does, not HOW the test works.
Good: `test_expired_user_cannot_access_premium_content`. Bad: `test_case_3`.

**Mocking**: Mock external boundaries (APIs, databases, filesystem). Never mock internal logic -- you end up testing your mocks, not your code.

```python
# GOOD — mocking the boundary (external payment API)
def test_order_fails_gracefully_when_payment_provider_is_down():
    with mock_payment_gateway(raises=TimeoutError):
        result = process_order(order)
        assert result.status == "payment_pending"

# BAD — mocking internal implementation (proves nothing)
def test_calculate_total():
    with patch("app.cart.sum") as mock_sum:
        mock_sum.return_value = 100
        assert calculate_total(items) == 100  # Testing the mock, not the code
```

## Decision Trees

### When is TDD Mandatory vs Optional?

| Situation | TDD Required? | Why |
|-----------|--------------|-----|
| New feature (sdd-apply task) | MANDATORY | Tests define the contract before code exists |
| Bug fix | MANDATORY | Failing test proves the bug exists and prevents regression |
| Refactoring existing code | MANDATORY | Tests are the safety net -- no net, no refactor |
| Throwaway prototype / spike | OPTIONAL | Exploring, not building -- but delete the spike after |
| Configuration file changes | OPTIONAL | Config is data, not behavior -- validate with integration tests |
| Documentation-only changes | SKIP | No behavior to test |
| Generated code (migrations, schemas) | OPTIONAL | Test the generator, not the output |

### What Kind of Test Should I Write?

| What You Are Testing | Test Type | Speed | Scope |
|---------------------|-----------|-------|-------|
| A single function's logic | Unit test | < 50ms | One module |
| Two modules working together | Integration test | < 500ms | Two modules |
| A user-facing workflow end-to-end | E2E test | < 5s | Full stack |
| Input combinations and edge cases | Property-based test | < 200ms | One function |
| Data transformations (ETL, parsers) | Snapshot / golden test | < 100ms | One pipeline |

### How Many Tests Per Feature?

| Feature Complexity | Minimum Tests | What to Cover |
|-------------------|---------------|---------------|
| Simple (1 input, 1 output) | 3 | Happy path + 1 edge case + 1 error case |
| Medium (branching logic) | 5-8 | Each branch + boundary values + error paths |
| Complex (state machine, workflows) | 10+ | Each state transition + invalid transitions + concurrency |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| Writing tests AFTER implementation | Tests that match existing code prove nothing -- they just describe what IS, not what SHOULD BE | Write the test first, watch it fail, then implement |
| Test passes immediately on first run | Either the test is wrong or the behavior already exists -- neither teaches you anything | Delete the test, verify the behavior is genuinely new, rewrite |
| Mocking internal functions | You are testing your mocks, not your code -- refactors break tests even when behavior is correct | Mock only at boundaries (APIs, DB, filesystem) |
| Test name says "test_function_works" | Tells you nothing about expected behavior -- useless as documentation | Name describes the behavior: "test_expired_user_gets_renewal_prompt" |
| Multiple assertions testing different behaviors | One failure hides others, makes diagnosis slow | One logical behavior per test -- split if name has "and" |
| Copying test code instead of extracting fixtures | Duplicated setup drifts out of sync, masking false positives | Extract shared setup into fixtures or factory functions |
| Testing implementation details (checking private methods) | Locks you to one implementation -- refactors break tests | Test public behavior and outcomes, not internal structure |
| Skipping the RED step ("I know it will fail") | If you did not SEE it fail, you do not know your test catches the right thing | Always run the test and verify the failure message |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| AI Validation Pyramid (Layers 1-3) | TDD produces the unit tests (Layer 2) and integration tests (Layer 3) that sdd-verify checks. If TDD is followed, Layers 2-3 pass automatically. |
| sdd-verify | Verification reads test coverage and results. TDD ensures tests exist BEFORE verify runs. |
| sdd-apply | Every sdd-apply task that touches production code should follow the Red-Green-Refactor cycle. |
| Scope Rule | Tests live adjacent to the code they test: `features/{feature}/tests/` or co-located `__tests__/` depending on stack convention. |
| Backtrack (sdd-backtrack) | When requirements change, update the TEST first (new RED), then update the implementation (new GREEN). The test change is the proof that requirements changed. |

## Code Examples

```python
# Example: Full TDD cycle — RED → GREEN → REFACTOR

# RED: Write the failing test
def test_first_time_buyer_gets_10_percent_discount():
    """BUSINESS RULE: First purchase gets 10% off."""
    customer = create_customer(purchase_count=0)
    price = calculate_price(item_price=100.00, customer=customer)
    assert price == 90.00
# Run: pytest -x → FAILS (function does not exist) ← Correct

# GREEN: Minimal implementation
def calculate_price(item_price: float, customer: Customer) -> float:
    """Calculate final price applying customer-specific discounts."""
    if customer.purchase_count == 0:
        return item_price * 0.90
    return item_price
# Run: pytest -x → PASSES ← Move to refactor

# REFACTOR: Extract the discount constant
FIRST_PURCHASE_DISCOUNT = 0.10  # BUSINESS RULE: 10% for first-time buyers
def calculate_price(item_price: float, customer: Customer) -> float:
    """Calculate final price applying customer-specific discounts."""
    discount = FIRST_PURCHASE_DISCOUNT if customer.purchase_count == 0 else 0.0
    return item_price * (1 - discount)
# Run: pytest → ALL PASS ← Cycle complete, start next RED
```

```typescript
// Example: Property-based test (any valid input should round-trip)
import { fc, test } from "@fast-check/vitest";
test.prop([fc.integer({ min: 0, max: 999_999 })])(
  "formatCurrency and parseCurrency are inverse operations",
  (amount) => {
    const formatted = formatCurrency(amount);
    expect(parseCurrency(formatted)).toBe(amount);
  }
);
```

## Commands

```bash
# Watch mode (re-run on changes) — fast RED-GREEN feedback
pytest --watch                     # Python (pytest-watch)
npx vitest --watch                 # TypeScript (Vitest)

# Run only changed/failed tests
pytest --lf                        # last-failed only
npx vitest --changed               # changed files only

# Single test during RED-GREEN cycle
pytest tests/test_pricing.py -x    # stop at first failure

# Coverage after GREEN phase
pytest --cov=src --cov-report=term-missing
npx vitest --coverage
```

## Rules

- ALWAYS write the test BEFORE the implementation code. No exceptions unless explicitly listed in the Decision Tree.
- ALWAYS run the test and watch it FAIL before writing implementation. If you skip this, you do not know if your test catches the right behavior.
- NEVER write more than ONE test at a time. Complete the full Red-Green-Refactor cycle before writing the next test.
- NEVER mock internal functions or private methods. Mock only at system boundaries (external APIs, databases, filesystem, network).
- ALWAYS name tests to describe behavior, not mechanics. If you cannot name it clearly, you do not understand the requirement well enough.
- NEVER skip the REFACTOR step. Duplication left after GREEN becomes technical debt that compounds across the codebase.
- When fixing a bug, the FIRST action is writing a failing test that reproduces it. No debugging without a test.
- Tests MUST live near the code they test, following Scope Rule. Never create a root-level `tests/` directory that mirrors the entire source tree.
- If a test passes immediately on first run, DELETE it and investigate why. Either the behavior already exists (your test is redundant) or your test is wrong.
- AFTER three consecutive test failures where you cannot make the test pass, STOP. Re-read the requirement. The test or the requirement may be wrong -- do not brute-force the implementation.

## What This Means (Simply)

> **For non-technical readers**: Test-Driven Development means we write a description
> of what the software SHOULD do before we write the software itself. Think of it
> like writing the exam questions before teaching the class -- it forces clarity about
> what "correct" looks like. The process has three steps repeated in a loop: (1) write
> a check that currently fails because the feature does not exist yet, (2) write the
> smallest amount of code to make that check pass, (3) clean up the code while making
> sure all checks still pass. This approach catches bugs before they reach users,
> creates a permanent safety net for future changes, and ensures every feature is
> tested -- not just the ones someone remembered to check manually.

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Tests slow me down — I'll add them after the feature works" | Tests written AFTER code prove only that the code matches itself, not that it matches the requirement. After-the-fact tests miss bugs the test-first cycle would have surfaced during the RED step. |
| "I'll add tests later" | "Later" never arrives. Code without tests becomes legacy code on day one. The cost of adding tests grows quadratically as the implementation hardens. |
| "This change is too small to need a test" | Small changes to untested code are how regressions ship. The cost of writing one test is < 5 minutes; the cost of debugging a production regression is hours. |
| "I'll mock the internal function — the test runs faster" | Mocking internals tests your mocks, not your code. Refactors break the test even when behavior is correct, training the agent to delete tests. |
| "The bug is obvious — I don't need to write a failing test first" | Without the failing test, you have no proof the bug existed. Future regressions reintroducing the same bug will not be caught. |

## Red Flags

- Writing implementation code before any test exists for the new behavior
- Test passes immediately on first run without ever failing — your test is wrong or testing nothing new
- Test name contains "works", "test_function", "test_case_3" — name describes mechanics not behavior
- Multiple `assert` statements in one test covering different behaviors — split required
- Mocking a function defined in the same module as the code under test — boundary violation
- Skipping REFACTOR step "to save time" — duplication left compounds across the codebase
- Editing a test to make it pass after a code change without questioning whether the requirement changed
- Three consecutive failing implementations on the same test — STOP, the test or requirement is wrong

## Verification Checklist

- [ ] Failing test was written and observed to fail (RED) BEFORE any implementation code
- [ ] Test failure was for the right reason (missing feature), not a typo or import error
- [ ] Implementation is the SIMPLEST code that turns the test green — no extra features
- [ ] All existing tests still pass after the new test (`pytest` or `vitest` exit code 0)
- [ ] Test name describes WHAT the system does (not HOW the test works)
- [ ] Mocking is only at boundaries (external APIs, DB, filesystem) — no internal-function mocks
- [ ] One logical behavior per test — no "and" in the test name
- [ ] REFACTOR step was executed; tests stayed green throughout
- [ ] Test lives next to the code it tests per Scope Rule (no root-level `tests/` mirroring src)
