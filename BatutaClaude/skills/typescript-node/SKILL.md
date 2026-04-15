---
name: typescript-node
description: >
  Use when building backend services or libraries with TypeScript and Node.js.
  Trigger: "TypeScript project", "Node.js backend", "TypeScript strict mode",
  "error handling pattern", "ES modules", "barrel exports", "Result pattern".
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-26"
  scope: [pipeline]
  auto_invoke:
    - Creating or modifying TypeScript backend code
    - Setting up a new Node.js project with TypeScript
    - Implementing error handling or domain types
    - Structuring a TypeScript codebase with the Scope Rule
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

You are a skill for building **TypeScript/Node.js** backend services following Batuta
conventions. You enforce strict mode, the Result pattern for error handling, proper ES
module structure, and the Scope Rule for file placement in TypeScript projects.

TypeScript's type system is a force multiplier -- it catches bugs before tests run
(AI Validation Pyramid Layer 0). This skill ensures the team extracts maximum value
from the type system by using strict mode, discriminated unions, and explicit error types
instead of thrown exceptions.

## When to Use

- Creating or structuring a TypeScript backend project
- Writing Node.js services, utilities, or libraries
- Implementing error handling, domain types, or validation
- Deciding on project structure, module boundaries, or barrel exports
- Integrating TypeScript backend with FastAPI or Next.js frontend

## Critical Patterns

### Pattern 1: Strict Mode -- Non-Negotiable

Every TypeScript project uses strict mode. This catches null errors, implicit any, and
unused variables at compile time -- before any test runs.

```jsonc
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,                    // Enables ALL strict checks
    "noUncheckedIndexedAccess": true,  // array[i] returns T | undefined
    "noImplicitReturns": true,         // Every code path must return
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true,
    "forceConsistentCasingInFileNames": true,
    "module": "NodeNext",             // ES modules with Node.js resolution
    "moduleResolution": "NodeNext",
    "target": "ES2022",
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "skipLibCheck": true               // Faster compilation, safe for app code
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

### Pattern 2: Result Pattern for Error Handling

Never throw exceptions for expected failures. Use discriminated unions (the Result
pattern) so callers are forced by the type system to handle both success and failure.

```typescript
// core/types/result.ts
/**
 * Result type -- forces callers to handle both success and failure.
 *
 * Why not throw? Thrown errors are invisible to the type system. A function
 * that returns Result<User, NotFoundError | ValidationError> tells callers
 * exactly what can go wrong. A function that throws tells them nothing.
 */

/** Successful result containing a value. */
type Ok<T> = { ok: true; value: T };

/** Failed result containing a typed error. */
type Err<E> = { ok: false; error: E };

/** Discriminated union: success or typed failure. */
export type Result<T, E = Error> = Ok<T> | Err<E>;

/** Helper to create a success result. */
export function ok<T>(value: T): Ok<T> {
  return { ok: true, value };
}

/** Helper to create a failure result. */
export function err<E>(error: E): Err<E> {
  return { ok: false, error };
}
```

```typescript
// features/tasks/services/task-service.ts
/**
 * Task service -- business logic for task operations.
 *
 * Returns Result types instead of throwing. Callers see all possible
 * error cases in the function signature.
 */
import { type Result, ok, err } from "@/core/types/result";

// BUSINESS RULE: domain errors are explicit types, not string messages
type TaskNotFoundError = { code: "TASK_NOT_FOUND"; taskId: string };
type TaskForbiddenError = { code: "TASK_FORBIDDEN"; taskId: string; tenantId: string };
type TaskError = TaskNotFoundError | TaskForbiddenError;

export async function getTask(
  taskId: string,
  tenantId: string,
): Promise<Result<Task, TaskError>> {
  const task = await db.tasks.findUnique({ where: { id: taskId } });

  if (!task) {
    return err({ code: "TASK_NOT_FOUND", taskId });
  }
  // SECURITY: verify tenant ownership before returning data
  if (task.tenantId !== tenantId) {
    return err({ code: "TASK_FORBIDDEN", taskId, tenantId });
  }
  return ok(task);
}
```

```typescript
// Caller is FORCED to handle both cases -- type system enforces this
const result = await getTask(taskId, session.tenantId);
if (!result.ok) {
  switch (result.error.code) {
    case "TASK_NOT_FOUND":
      return res.status(404).json({ error: "Task not found" });
    case "TASK_FORBIDDEN":
      return res.status(403).json({ error: "Access denied" });
  }
}
// TypeScript narrows: result.value is Task here
const task = result.value;
```

### Pattern 3: Project Structure with Scope Rule

```
src/
  core/                          # Used by the entire application
    types/
      result.ts                  # Result type, shared primitives
    config/
      env.ts                     # Environment variable parsing (Zod)
    database/
      client.ts                  # Database client singleton
  features/
    tasks/
      models/
        task.model.ts            # Task entity / DB schema
      services/
        task-service.ts          # Business logic (returns Result)
      routes/
        task-routes.ts           # HTTP handlers (thin, delegates to service)
      types/
        task.types.ts            # Types used ONLY by tasks feature
    shared/
      services/
        pagination.ts            # Used by 2+ features
      types/
        tenant.types.ts          # Multi-tenant types shared across features
  index.ts                       # Entry point (thin: starts server)
```

### Pattern 4: Environment Variable Validation

Never access `process.env` directly. Parse and validate at startup using Zod.

```typescript
// core/config/env.ts
/**
 * Environment variable validation -- fail fast at startup.
 *
 * Why Zod? It validates at runtime AND generates TypeScript types.
 * If a required env var is missing, the app crashes immediately with
 * a clear error instead of failing mysteriously later.
 */
import { z } from "zod";

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "production", "test"]),
  DATABASE_URL: z.string().url(),
  PORT: z.coerce.number().int().positive().default(3000),
  // SECURITY: JWT secret must be at least 32 characters
  JWT_SECRET: z.string().min(32),
  COOLIFY_WEBHOOK_URL: z.string().url().optional(),
});

// Parse once at startup -- crash immediately if invalid
export const env = envSchema.parse(process.env);

// Type is inferred: { NODE_ENV: "development" | "production" | "test", ... }
export type Env = z.infer<typeof envSchema>;
```

### Pattern 5: Barrel Exports -- Deliberate Public API

Each feature exposes a deliberate public API via `index.ts`. Internal modules are
implementation details, not importable by other features.

```typescript
// features/tasks/index.ts
/**
 * Tasks feature public API.
 *
 * Only types and functions exported here may be imported by other features.
 * Internal services, models, and utilities are implementation details.
 */
export { taskRouter } from "./routes/task-routes";
export type { Task, CreateTaskInput } from "./types/task.types";
// BUSINESS RULE: service is NOT exported -- route layer is the public interface
```

## Decision Trees

| Scenario | Approach | Why |
|----------|----------|-----|
| Expected failure (not found, validation) | Return `Result<T, E>` | Caller forced to handle, type-safe |
| Unexpected failure (DB down, OOM) | Let it throw (unhandled -> crash) | App should restart, not hide crashes |
| Configuration value | Zod schema in `core/config/env.ts` | Fail fast at startup, typed access |
| Type used by 1 feature | `features/{feature}/types/` | Scope Rule: feature-local |
| Type used by 2+ features | `features/shared/types/` | Scope Rule: shared |
| Type used app-wide (Result, Env) | `core/types/` | Scope Rule: core |
| JSON API response | Zod schema + inferred type | Single source of truth for validation + types |
| Database query | Return `Promise<Result<T, E>>` | Async + typed errors |
| HTTP handler | Thin function, delegates to service | Separation of concerns, testable |
| Utility function | Place by Scope Rule, never `utils/` | No root-level dumps |

| Module System | When | Why |
|---------------|------|-----|
| `"module": "NodeNext"` | Node.js backend projects | Native ESM with `.js` extension resolution |
| `"module": "ESNext"` | Libraries or frontend code | Bundler handles resolution |
| `"module": "CommonJS"` | Legacy projects only | Avoid for new projects |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| `strict: false` in tsconfig | Defeats the purpose of TypeScript | Always `strict: true` |
| `any` type annotation | Turns off type checking for that value | Use `unknown`, then narrow |
| `as` type assertion (except tests) | Lies to compiler, hides bugs | Narrow with type guards |
| Thrown exceptions for expected errors | Invisible to type system, unhandled crashes | Return `Result<T, E>` |
| `process.env.X` directly in code | No validation, `string \| undefined` | Zod schema at startup (`core/config/env.ts`) |
| Root-level `utils/` or `helpers/` | Becomes dumping ground, violates Scope Rule | Place by who uses it |
| `export *` in barrel files | Leaks internals, circular dependencies | Explicit named exports only |
| Mutable global state | Unpredictable, hard to test, race conditions | Dependency injection, function params |
| `console.log` for production logging | No structure, no levels, no context | Use structured logger (pino, winston) |
| `.ts` extensions in import paths | Does not work with `NodeNext` resolution | Use `.js` extension in imports |

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| FastAPI (Python backend) | TypeScript backend serves as BFF (Backend for Frontend) or standalone microservice alongside FastAPI |
| Next.js (Frontend) | Shares types via `features/shared/types/`. API contracts defined with Zod, exported for both |
| PostgreSQL | Access via Prisma or Drizzle ORM. Multi-tenant queries filter by `tenantId` column |
| Docker/Coolify | `npm run build` produces `dist/`. Dockerfile uses `node dist/index.js` |
| CI/CD | `tsc --noEmit` is Layer 1 in CI pipeline. Must pass before tests run |
| Testing | Vitest for unit tests, Playwright for E2E. Result pattern makes service tests straightforward |

## Code Examples

```typescript
// Example: Multi-tenant service with Result pattern
// features/invoices/services/invoice-service.ts
/**
 * Invoice service -- business logic for invoice operations.
 *
 * All queries are tenant-scoped. Returns Result types for
 * predictable error handling at the route layer.
 */
import { type Result, ok, err } from "@/core/types/result";
import { db } from "@/core/database/client";
import { env } from "@/core/config/env";

type InvoiceError =
  | { code: "NOT_FOUND"; invoiceId: string }
  | { code: "ALREADY_PAID"; invoiceId: string };

export async function markInvoicePaid(
  invoiceId: string,
  tenantId: string,
): Promise<Result<Invoice, InvoiceError>> {
  // SECURITY: WHERE includes tenantId -- impossible to access other tenant's data
  const invoice = await db.invoice.findFirst({
    where: { id: invoiceId, tenantId },
  });

  if (!invoice) {
    return err({ code: "NOT_FOUND", invoiceId });
  }
  // BUSINESS RULE: prevent double payment
  if (invoice.status === "paid") {
    return err({ code: "ALREADY_PAID", invoiceId });
  }

  const updated = await db.invoice.update({
    where: { id: invoiceId },
    data: { status: "paid", paidAt: new Date() },
  });

  return ok(updated);
}
```

```typescript
// Example: Thin HTTP handler that delegates to service
// features/invoices/routes/invoice-routes.ts
/**
 * Invoice API routes -- thin HTTP handlers.
 *
 * Handlers parse request, call service, map Result to HTTP response.
 * No business logic lives here.
 */
import { Router } from "express";
import { markInvoicePaid } from "../services/invoice-service";

const router = Router();

router.post("/:id/pay", async (req, res) => {
  const result = await markInvoicePaid(req.params.id, req.tenantId);

  if (!result.ok) {
    const statusMap = { NOT_FOUND: 404, ALREADY_PAID: 409 } as const;
    return res.status(statusMap[result.error.code]).json({ error: result.error });
  }

  return res.json(result.value);
});

export { router as invoiceRouter };
```

## Commands

```bash
# Initialize TypeScript project with strict config
npx tsc --init --strict --module NodeNext --moduleResolution NodeNext --target ES2022

# Type-check without emitting (CI Layer 1)
npx tsc --noEmit

# Build to dist/
npx tsc

# Run with tsx (development -- no build step)
npx tsx src/index.ts

# Run with tsx in watch mode
npx tsx watch src/index.ts

# Lint with ESLint (flat config)
npx eslint .

# Run tests with Vitest
npx vitest run

# Run tests in watch mode
npx vitest
```

## Rules

- ALWAYS enable `strict: true` in tsconfig. No exceptions, no per-file overrides.
- ALWAYS use the Result pattern (`Result<T, E>`) for expected failures. Reserve `throw` for unexpected crashes.
- ALWAYS validate environment variables with Zod at startup in `core/config/env.ts`.
- ALWAYS use explicit barrel exports (`export { name }`) -- never `export *`.
- ALWAYS follow the Scope Rule for file placement: `features/{feature}/`, `features/shared/`, or `core/`.
- ALWAYS include `tenantId` in database queries for multi-tenant applications.
- ALWAYS use `.js` extension in import paths when using `NodeNext` module resolution.
- NEVER use `any` -- use `unknown` and narrow with type guards.
- NEVER use `as` type assertions in production code (acceptable in test setup).
- NEVER create root-level `utils/`, `helpers/`, or `lib/` directories.
- NEVER access `process.env` directly -- always go through the validated `env` object.
- NEVER use `console.log` in production code -- use a structured logger.

## What This Means (Simply)

> **For non-technical readers**: This skill ensures our TypeScript backend code is
> reliable and predictable. TypeScript adds "type safety" to JavaScript -- think of it
> as a spell-checker for code that catches mistakes before anyone runs the program.
> The key patterns here are: (1) strict checking catches more mistakes automatically,
> (2) when something goes wrong (like "user not found"), the code explicitly says so
> instead of crashing unexpectedly, and (3) every file has a designated place based on
> who uses it, like an organized filing cabinet where everyone knows where to find things.
> Together, these patterns mean fewer bugs, faster debugging, and code that new team
> members can navigate confidently.

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Strict mode is pedantic and slows me down -- I'll just disable `noUncheckedIndexedAccess`" | The flags you disable are exactly the ones that catch the bugs you cannot detect by reading code. `array[0]` returning `T \| undefined` is not pedantry; it is the truth. Disabling it means production crashes in the cases your tests did not happen to cover |
| "I'll use `any` just temporarily until I figure out the right type" | "Temporary" `any`s become permanent the moment the code passes review. Each one is a hole in the type system that lets bugs propagate silently. Use `unknown` and narrow -- it costs five minutes and protects callers forever |
| "The Result pattern is overkill -- exceptions are simpler" | Exceptions are simpler to write and harder to debug. A `throw` is invisible in the function signature; a `Result<T, E>` is part of the contract. The next developer who calls your function should not have to read its source to know what can go wrong |
| "I'll skip env validation -- it's just `process.env.DATABASE_URL`, what could go wrong" | Without Zod, missing env vars surface as `undefined` deep in the call stack at 3 AM. Validating at startup means the app crashes loudly with a clear message instead of failing mysteriously after running for a week |
| "Barrel files with `export *` save me typing" | They also leak internals, create circular dependency loops, and make refactoring a minefield because every name is implicitly part of your public API. Explicit named exports document intent and make breakage visible |

## Red Flags

- `strict: false` or any per-file `// @ts-strict-ignore` directive
- Use of `any` outside generated code or third-party shim files
- `as` type assertions in production code (test setup is acceptable)
- `throw` for expected failures (not found, validation error, conflict)
- Direct `process.env.X` access outside `core/config/env.ts`
- Root-level `utils/`, `helpers/`, `lib/`, or `common/` directory
- `export *` in barrel files
- `console.log` for production logging instead of structured logger
- `.ts` extension in import paths when using `NodeNext` resolution
- Multi-tenant query without `tenantId` in the WHERE clause
- Service that returns `void` or `T` for an operation that can fail (no `Result<T, E>`)

## Verification Checklist

- [ ] `tsconfig.json` has `strict: true`, `noUncheckedIndexedAccess: true`, `noImplicitReturns: true`
- [ ] No occurrences of `: any` or `as ` in `src/` (excluding tests and generated code)
- [ ] All service-layer functions that can fail return `Promise<Result<T, E>>` with named error variants
- [ ] Environment variables are parsed and typed in `core/config/env.ts` via Zod schema; `process.env` is not accessed elsewhere
- [ ] All barrel files (`index.ts`) use explicit named exports, never `export *`
- [ ] File placement matches Scope Rule: `features/{name}/`, `features/shared/`, or `core/`
- [ ] Multi-tenant queries include `tenantId` in WHERE clauses
- [ ] Imports use `.js` extension under `NodeNext` module resolution
- [ ] Production code uses a structured logger (pino, winston) instead of `console.log`
- [ ] `npx tsc --noEmit` passes with zero errors before any test runs
