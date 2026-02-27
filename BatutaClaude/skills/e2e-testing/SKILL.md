---
name: e2e-testing
description: >
  Use when writing end-to-end tests with Playwright.
  Trigger: "E2E test", "Playwright", "end-to-end", "integration test",
  "page object", "test automation", "browser test", "sdd-verify layer 3".
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-26"
  scope: [pipeline]
  auto_invoke:
    - Writing or modifying Playwright E2E tests
    - Implementing AI Validation Pyramid Layer 3
    - Running sdd-verify on features with UI
    - Setting up test infrastructure for browser testing
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

You are a skill for writing **Playwright end-to-end tests** following Batuta conventions.
You enforce the AI Validation Pyramid Layer 3 (E2E tests), proper page object patterns,
resilient selectors, and test data isolation for multi-tenant applications.

E2E tests are the top automated layer of the AI Validation Pyramid. They validate that
the entire stack works together from the user's perspective -- but they are expensive to
run, so each test must justify its existence by covering a critical user journey.

## When to Use

- Writing Playwright tests for new or existing features
- Running sdd-verify on features that include UI interaction
- Setting up E2E test infrastructure in a project
- Deciding whether a scenario needs E2E vs unit vs integration testing
- Configuring CI pipeline for browser-based testing

## Critical Patterns

### Pattern 1: Test Structure -- Feature-Aligned

Tests live alongside the features they validate, not in a root-level `tests/` dump.

```
e2e/                              # E2E test root (configured in playwright.config.ts)
  fixtures/                       # Shared test fixtures and setup
    auth.fixture.ts               # Authentication helpers
    tenant.fixture.ts             # Multi-tenant test data
  features/
    dashboard/
      dashboard.spec.ts           # Test file for dashboard feature
      dashboard.page.ts           # Page Object for dashboard
    tasks/
      task-crud.spec.ts
      tasks.page.ts
  shared/
    pages/                        # Page Objects used by 2+ feature tests
      navigation.page.ts
      login.page.ts
```

### Pattern 2: Page Object Pattern

Page Objects encapsulate selectors and interactions. Tests read like user stories.

```typescript
// e2e/features/tasks/tasks.page.ts
/**
 * Page Object for the Tasks feature.
 *
 * Encapsulates all selectors and user interactions for the task list.
 * Tests use this class instead of raw selectors -- if the UI changes,
 * only this file needs updating.
 */
import { type Page, type Locator } from "@playwright/test";

export class TasksPage {
  readonly page: Page;
  readonly newTaskButton: Locator;
  readonly taskTitleInput: Locator;
  readonly taskList: Locator;

  constructor(page: Page) {
    this.page = page;
    // BUSINESS RULE: use data-testid for stability, role-based for accessibility
    this.newTaskButton = page.getByRole("button", { name: "New Task" });
    this.taskTitleInput = page.getByLabel("Task title");
    this.taskList = page.getByTestId("task-list");
  }

  async goto() {
    await this.page.goto("/tasks");
  }

  async createTask(title: string) {
    await this.newTaskButton.click();
    await this.taskTitleInput.fill(title);
    await this.page.getByRole("button", { name: "Save" }).click();
    // Wait for optimistic update or server response
    await this.page.getByText(title).waitFor();
  }

  async getTaskCount(): Promise<number> {
    return this.taskList.getByRole("listitem").count();
  }
}
```

### Pattern 3: Test Files -- User Journey Focus

Each test validates a complete user journey, not a UI detail.

```typescript
// e2e/features/tasks/task-crud.spec.ts
/**
 * E2E tests for task CRUD operations.
 *
 * AI Validation Pyramid Layer 3: validates full stack from browser
 * through API to database. Each test represents a critical user journey.
 */
import { test, expect } from "@playwright/test";
import { TasksPage } from "./tasks.page";

test.describe("Task Management", () => {
  let tasksPage: TasksPage;

  test.beforeEach(async ({ page }) => {
    // SECURITY: authenticate as test tenant, isolated data
    await page.goto("/api/test/login?tenant=test-tenant-1");
    tasksPage = new TasksPage(page);
    await tasksPage.goto();
  });

  test("user can create and see a new task", async () => {
    const initialCount = await tasksPage.getTaskCount();
    await tasksPage.createTask("Buy groceries");
    await expect(tasksPage.taskList).toContainText("Buy groceries");
    expect(await tasksPage.getTaskCount()).toBe(initialCount + 1);
  });

  test("user cannot see another tenant's tasks", async ({ page }) => {
    // SECURITY: verify tenant isolation in UI
    await tasksPage.createTask("Secret task");
    // Switch to different tenant
    await page.goto("/api/test/login?tenant=test-tenant-2");
    await tasksPage.goto();
    await expect(tasksPage.taskList).not.toContainText("Secret task");
  });
});
```

### Pattern 4: Selector Strategy -- Resilience Hierarchy

```typescript
// PREFERRED: Role-based (accessible, semantic)
page.getByRole("button", { name: "Submit" });
page.getByLabel("Email address");
page.getByRole("heading", { name: "Dashboard" });

// GOOD: Test ID (stable, decoupled from UI text)
page.getByTestId("metrics-panel");

// ACCEPTABLE: Text content (for static, unique text)
page.getByText("No tasks found");

// NEVER: CSS selectors or XPath (brittle, couples to implementation)
// page.locator(".btn-primary");           // WRONG
// page.locator("#submit-button");          // WRONG
// page.locator("div > span.task-title");   // WRONG
```

## Decision Trees

| Scenario | Test Type | Why |
|----------|-----------|-----|
| Pure function, utility, calculation | Unit test (Layer 1) | Fast, isolated, high coverage |
| API endpoint response/validation | Integration test (Layer 2) | Tests API contract without browser |
| Critical user journey (login, checkout, CRUD) | E2E test (Layer 3) | Validates full stack end-to-end |
| Visual appearance, layout | Visual regression (Playwright screenshots) | Catches CSS regressions |
| Edge case in business logic | Unit test (Layer 1) | E2E is too slow for edge cases |
| Multi-step workflow (wizard, onboarding) | E2E test (Layer 3) | Steps depend on previous state |
| Tenant data isolation | E2E test (Layer 3) | Must verify through full auth stack |
| Performance under load | Dedicated load test (k6, Artillery) | Playwright is not a load testing tool |

| Selector Approach | When | Why |
|-------------------|------|-----|
| `getByRole()` | Interactive elements (buttons, inputs, links) | Accessible, semantic, resilient |
| `getByLabel()` | Form inputs | Matches user mental model |
| `getByTestId()` | Dynamic containers, lists, panels | Stable when text/role is ambiguous |
| `getByText()` | Static display text, headings | Simple, readable assertions |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| CSS/XPath selectors (`locator(".btn")`) | Breaks on any styling or DOM change | Use `getByRole()`, `getByTestId()` |
| Testing implementation details (state, props) | Couples test to code, not behavior | Test what the user sees and does |
| Shared mutable test data | Tests interfere with each other, flaky | Isolate data per test, use fresh tenant |
| `page.waitForTimeout(3000)` | Arbitrary waits are flaky and slow | Use `waitFor()`, `expect().toBeVisible()` |
| One huge spec file for all features | Slow, hard to debug, merge conflicts | One spec per feature, per user journey |
| Root-level `tests/` dump | Violates Scope Rule, hard to find tests | `e2e/features/{feature}/` structure |
| E2E test for every edge case | Slow CI, diminishing returns | Unit test edge cases, E2E for journeys |
| Skipping test cleanup | Stale data causes flaky failures | Use `beforeEach` cleanup or transaction rollback |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| AI Validation Pyramid | Layer 3 (top automated layer). Runs AFTER unit (L1) and integration (L2) pass |
| sdd-verify | E2E tests are mandatory for features with UI. sdd-verify checks they exist and pass |
| CI/CD (GitHub Actions) | Run in headless mode, parallel shards, after unit/integration gates pass |
| Backend (FastAPI) | Tests hit the real API. Use test database seeded per tenant for isolation |
| Auth | Use test-only login endpoint (`/api/test/login`) or fixture-based auth state |
| Coolify/Docker | Tests run against `docker compose up` preview environment in CI |

## Code Examples

```typescript
// Example: Auth fixture for multi-tenant test isolation
// e2e/fixtures/auth.fixture.ts
/**
 * Authentication fixture for Playwright tests.
 *
 * Creates authenticated browser contexts per tenant.
 * Stores auth state to avoid re-login on every test.
 */
import { test as base } from "@playwright/test";

type AuthFixtures = {
  authenticatedPage: Page;
  tenantId: string;
};

export const test = base.extend<AuthFixtures>({
  tenantId: ["test-tenant-default", { option: true }],
  authenticatedPage: async ({ page, tenantId }, use) => {
    // SECURITY: test-only auth endpoint, disabled in production
    await page.goto(`/api/test/login?tenant=${tenantId}`);
    await use(page);
  },
});
```

```typescript
// Example: Playwright config for CI
// playwright.config.ts
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,        // Fail if .only() left in CI
  retries: process.env.CI ? 2 : 0,     // Retry flaky tests in CI only
  workers: process.env.CI ? 4 : undefined,
  reporter: process.env.CI ? "github" : "html",
  use: {
    baseURL: process.env.BASE_URL || "http://localhost:3000",
    trace: "on-first-retry",           // Capture trace for debugging
    screenshot: "only-on-failure",
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    // BUSINESS RULE: only test multiple browsers in CI, not locally
    ...(process.env.CI
      ? [{ name: "firefox", use: { ...devices["Desktop Firefox"] } }]
      : []),
  ],
  webServer: {
    command: "npm run dev",
    port: 3000,
    reuseExistingServer: !process.env.CI,
  },
});
```

## Commands

```bash
# Run all E2E tests
npx playwright test

# Run tests for a specific feature
npx playwright test e2e/features/tasks/

# Run in headed mode (visible browser) for debugging
npx playwright test --headed

# Run with Playwright UI mode (interactive debugging)
npx playwright test --ui

# Generate test code by recording browser actions
npx playwright codegen http://localhost:3000

# Show HTML report of last test run
npx playwright show-report

# Update Playwright browsers
npx playwright install --with-deps
```

## Rules

- ALWAYS use Page Objects to encapsulate selectors and interactions.
- ALWAYS prefer `getByRole()` and `getByLabel()` over CSS selectors or XPath.
- ALWAYS isolate test data per tenant -- tests must not share mutable state.
- ALWAYS add `data-testid` attributes to dynamic containers and complex components.
- ALWAYS run E2E tests in CI with `forbidOnly: true` to catch stray `.only()` calls.
- ALWAYS place test files in `e2e/features/{feature}/`, never in a root `tests/` dump.
- NEVER use `waitForTimeout()` -- use explicit waits (`waitFor()`, `toBeVisible()`).
- NEVER use CSS selectors (`.class`, `#id`) or XPath in Playwright tests.
- NEVER write E2E tests for pure logic -- use unit tests (Pyramid Layer 1) for that.
- NEVER skip E2E tests for features with UI during sdd-verify.

## What This Means (Simply)

> **For non-technical readers**: This skill ensures we test our application the way a
> real person uses it -- by opening a browser and clicking through the actual screens.
> Think of it as a robot that follows a checklist: "log in, create a task, verify it
> appears, check that another customer cannot see it." These tests catch problems that
> simpler tests miss, like a button that does not work or data leaking between customers.
> We run them automatically every time code changes, but only for the most important
> user journeys because they take longer than other types of tests.
