---
name: react-nextjs
description: >
  Use when building frontend with React and Next.js App Router.
  Trigger: "React component", "Next.js page", "server component",
  "client component", "App Router", "server action", "frontend feature".
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-26"
  bucket: build
  auto_invoke:
    - Working with React components or Next.js pages
    - Creating or modifying App Router routes
    - Deciding between Server and Client Components
    - Implementing data fetching or server actions
  platforms: [claude, antigravity]
allowed-tools: Read Edit Write Glob Grep Bash
---

## Purpose

You are a skill for building **React/Next.js App Router** frontends following Batuta
conventions. You enforce Server Component defaults, proper client/server boundaries,
the Scope Rule for component placement, and multi-tenant-aware data fetching patterns.

All generated code follows the Batuta file structure (`features/{feature}/components/`),
documentation standard (module docstrings, JSDoc on exports), and the principle that
Server Components are the default -- Client Components are the exception.

## When to Use

- Creating or modifying React components in a Next.js project
- Building App Router pages, layouts, or route handlers
- Deciding between Server Components and Client Components
- Implementing data fetching (RSC fetch, server actions, React Query)
- Adding state management or interactivity to a feature
- Structuring a multi-tenant frontend with tenant-scoped data

## Critical Patterns

### Pattern 1: Server Components Are the Default

Every component is a Server Component unless it needs interactivity. This is the
single most important rule. Server Components run on the server, have zero JS bundle
cost, and can directly access databases, APIs, and environment variables.

```tsx
// CORRECT: Server Component (default -- no directive needed)
// features/dashboard/components/MetricsPanel.tsx
/**
 * Dashboard metrics panel -- fetches and displays KPIs.
 *
 * Server Component: data is fetched at render time, no client JS shipped.
 * Business context: shows real-time business health to managers.
 */
import { getMetrics } from "../services/metrics-service";

export async function MetricsPanel({ tenantId }: { tenantId: string }) {
  // SECURITY: tenantId comes from authenticated session, never from URL
  const metrics = await getMetrics(tenantId);
  return (
    <section>
      <h2>Key Metrics</h2>
      {metrics.map((m) => (
        <MetricCard key={m.id} label={m.label} value={m.value} />
      ))}
    </section>
  );
}
```

### Pattern 2: Client Components -- Explicit and Minimal

Only add `"use client"` when the component needs: event handlers, useState/useEffect,
browser APIs, or third-party client-only libraries. Keep Client Components as leaf
nodes -- never wrap a Server Component inside a Client Component.

```tsx
// features/dashboard/components/DateRangePicker.tsx
"use client";
/**
 * Interactive date range picker for filtering dashboard data.
 *
 * Client Component: requires useState for selection state and onClick handlers.
 * WORKAROUND: react-datepicker requires browser DOM, cannot run on server.
 */
import { useState } from "react";

export function DateRangePicker({ onRangeChange }: DateRangePickerProps) {
  const [range, setRange] = useState<DateRange>(DEFAULT_RANGE);
  // ... interactivity logic
}
```

### Pattern 3: Scope Rule for Components

Components follow the Batuta Scope Rule -- no root-level `components/` directory.

```
app/
  layout.tsx              # Root layout (core)
  (dashboard)/
    page.tsx              # Route entry -- thin, delegates to feature components
features/
  dashboard/
    components/           # Components used ONLY by dashboard
      MetricsPanel.tsx
      DateRangePicker.tsx
    services/
      metrics-service.ts  # Data fetching logic
  shared/
    components/           # Components used by 2+ features
      DataTable.tsx
      Pagination.tsx
core/
  components/             # App-wide components (used everywhere)
    Header.tsx
    ErrorBoundary.tsx
```

### Pattern 4: Data Fetching Hierarchy

```tsx
// app/(dashboard)/page.tsx
/**
 * Dashboard page -- route entry point.
 *
 * Thin page: delegates data fetching to Server Components,
 * orchestrates layout only. Never contains business logic.
 */
import { MetricsPanel } from "@/features/dashboard/components/MetricsPanel";
import { getSession } from "@/core/auth/session";

export default async function DashboardPage() {
  const session = await getSession();
  // SECURITY: tenant isolation enforced at page level
  return (
    <main>
      <MetricsPanel tenantId={session.tenantId} />
    </main>
  );
}
```

### Pattern 5: Server Actions for Mutations

```tsx
// features/tasks/actions/task-actions.ts
"use server";
/**
 * Task server actions -- mutation handlers for task CRUD.
 *
 * Server actions run on the server, validate input, and revalidate caches.
 * They replace API routes for simple mutations in the App Router model.
 */
import { revalidatePath } from "next/cache";
import { z } from "zod";

const CreateTaskSchema = z.object({
  title: z.string().min(1).max(200),
  dueDate: z.string().datetime().optional(),
});

export async function createTask(formData: FormData) {
  const parsed = CreateTaskSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) {
    return { error: "Invalid input", details: parsed.error.flatten() };
  }
  // SECURITY: get tenantId from session, never from form data
  const session = await getSession();
  await taskService.create({ ...parsed.data, tenantId: session.tenantId });
  revalidatePath("/tasks");
}
```

## Decision Trees

| Situation | Approach | Why |
|-----------|----------|-----|
| Displays data, no interactivity | Server Component (default) | Zero JS bundle, direct data access |
| Needs onClick, onChange, useState | Client Component (`"use client"`) | Browser APIs require client runtime |
| Form submission / data mutation | Server Action (`"use server"`) | Validated on server, no API route needed |
| Complex client state (cart, filters) | Client Component + Zustand/Jotai | Lightweight, avoids Redux complexity |
| Real-time updates (chat, notifications) | Client Component + WebSocket/SSE | Persistent connection requires browser |
| Data used by multiple components | Fetch in parent Server Component, pass as props | Avoids waterfalls, single request |
| Shared between 2+ features | `features/shared/components/` | Scope Rule: shared > feature-local |
| Used app-wide (header, error boundary) | `core/components/` | Scope Rule: core for universal use |

## Anti-Patterns (Never Do This)

| Anti-Pattern | Why It Is Wrong | Do This Instead |
|--------------|-----------------|-----------------|
| `"use client"` on every component | Destroys Server Component benefits, bloats JS bundle | Only add when interactivity is required |
| Root-level `components/` directory | Violates Scope Rule, creates dumping ground | Use `features/{name}/components/` or `core/components/` |
| Fetching data in Client Components for initial load | Causes loading spinners, poor SEO, extra round trips | Fetch in Server Component, pass as props |
| `useEffect` for data fetching on mount | Waterfall requests, no server-side rendering | Use Server Components or React Query |
| Passing `tenantId` from URL params | Security: users can modify URLs | Extract `tenantId` from authenticated session |
| Business logic in `page.tsx` files | Pages should be thin route entries | Delegate to feature services and components |
| Wrapping Server Components inside Client Components | Server Component becomes client-rendered | Use composition: pass Server Components as `children` |

### Anti-Pattern: "AI Aesthetic" Detection

LLMs tend to generate UI with recognizable patterns. Watch for and correct:
- **Purple/indigo everything**: Default AI color palette. Use the project's actual design system colors.
- **Excessive gradients**: Gradient backgrounds on every section. Use solid colors unless the design system specifies gradients.
- **Rounded-full on everything**: `rounded-full` on buttons, cards, containers. Use the design system's border radius scale.
- **Generic hero sections**: Large centered text with gradient background. Match the project's actual layout patterns.

### Rule: Component Size Limit

Components exceeding **200 lines** are candidates for splitting. If a component cannot fit on screen with reasonable scrolling, it is doing too much. Extract child components, separate data fetching logic, or pull out custom hooks.

## Stack Integration

| Layer | Integration Point |
|-------|-------------------|
| Backend (FastAPI) | Server Components call FastAPI endpoints via `fetch()` with service-to-service auth tokens |
| Database (PostgreSQL) | Server Components can query DB directly via Prisma/Drizzle with tenant-scoped queries |
| Auth | `getSession()` in Server Components/Actions extracts tenant context from cookies/JWT |
| Deployment (Coolify) | Next.js deployed as Docker container; `output: "standalone"` in `next.config.js` reduces image size |
| Testing (Playwright) | E2E tests validate rendered output; use `data-testid` attributes on interactive elements |

## Code Examples

```tsx
// Example: Composition pattern -- Server Component children inside Client Component
// features/dashboard/components/DashboardLayout.tsx
"use client";
/**
 * Dashboard layout with collapsible sidebar.
 * Client Component for sidebar toggle state.
 * Children remain Server Components (not re-rendered on client).
 */
import { useState, type ReactNode } from "react";

export function DashboardLayout({ children }: { children: ReactNode }) {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  return (
    <div className={sidebarOpen ? "with-sidebar" : "no-sidebar"}>
      <button onClick={() => setSidebarOpen(!sidebarOpen)}>Toggle</button>
      {/* children are Server Components -- they stay server-rendered */}
      <main>{children}</main>
    </div>
  );
}
```

## Commands

```bash
# Create new Next.js project with App Router
npx create-next-app@latest --typescript --app --tailwind --src-dir

# Run development server
npm run dev

# Build for production (use standalone output for Docker)
npm run build

# Type-check without building
npx tsc --noEmit
```

## Rules

- ALWAYS default to Server Components. Add `"use client"` only when proven necessary.
- ALWAYS follow Scope Rule: `features/{feature}/components/`, `features/shared/components/`, or `core/components/`.
- ALWAYS extract `tenantId` from server-side session, NEVER from URL parameters or client state.
- ALWAYS use `output: "standalone"` in `next.config.js` for Docker deployments.
- ALWAYS validate server action input with Zod schemas before processing.
- NEVER create a root-level `components/`, `utils/`, `hooks/`, or `lib/` directory.
- NEVER put business logic in `page.tsx` files -- keep them as thin route entries.
- NEVER use `useEffect` for initial data fetching -- use Server Components or server actions.
- NEVER import server-only code (DB clients, env secrets) in Client Components.

## What This Means (Simply)

> **For non-technical readers**: This skill ensures our frontend code is fast and secure
> by default. Most of the page is assembled on our servers (like preparing a meal in the
> kitchen) and sent ready to display -- only interactive parts like buttons and forms run
> in the user's browser. It also enforces that every component file lives in a predictable
> place based on who uses it, and that each customer's data stays isolated from others.
> Think of it as the blueprint for building consistent, secure web pages across the team.

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "I'll just put `'use client'` everywhere -- the App Router is too complex otherwise" | Marking everything as client throws away the entire benefit of the App Router: zero JS for static UI, direct database access from components, automatic streaming. You end up shipping a Pages Router app with extra ceremony and a bloated bundle |
| "useEffect for the initial fetch is the standard React pattern -- I learned it that way" | That pattern predates Server Components by a decade. In the App Router, `useEffect` for initial data means a loading spinner, a waterfall request, no SSR, and worse SEO. Fetch in a Server Component and pass as props |
| "The form submission needs an API route, server actions are too magical" | Server actions ARE the API route -- typed, validated, with automatic cache revalidation. Writing a separate route handler duplicates the work and bypasses the integration with `revalidatePath`/`revalidateTag` |
| "Putting tenant_id in the URL is fine -- the user is already authenticated" | Authentication does not equal authorization. A logged-in user can edit the URL to access another tenant's data. Tenant context belongs in the verified session, never in URL params |
| "Shared component? I'll drop it in `/components` at the root for now" | "For now" becomes "forever," and the root `/components` directory becomes a dumping ground that nobody can navigate. Apply Scope Rule once at creation; refactoring a 200-component dump later is a multi-day project |

## Red Flags

- Top-level `'use client'` directive on layouts, pages, or components that only render data
- `useEffect` + `fetch` for initial data loading on mount
- `useState` for data that is fetched once and never mutated locally
- Reading `tenantId`, `userId`, or `orgId` from `useParams()` or URL search params
- Root-level `components/`, `hooks/`, `utils/`, or `lib/` directory
- Business logic (DB calls, validation chains) inside `page.tsx`
- Importing server-only modules (DB client, env secrets) into a Client Component
- API route that wraps a single database query when a Server Action would suffice
- Server Component that calls a Client Component which then re-fetches data the parent already has
- Form without Zod validation in the server action

## Verification Checklist

- [ ] All components default to Server Components; `'use client'` appears only on leaves that need interactivity
- [ ] Initial data fetching happens in Server Components (`async` function components), never in `useEffect`
- [ ] Tenant/org/user context is read from server-side session (`getSession()`), never from URL params or client state
- [ ] All form submissions and mutations use Server Actions with Zod validation, not API routes wrapping a single query
- [ ] File placement follows Scope Rule: `features/{name}/components/`, `features/shared/components/`, or `core/components/`
- [ ] No root-level `components/`, `hooks/`, `utils/`, or `lib/` directories exist
- [ ] `page.tsx` files contain only routing + composition; business logic lives in feature services
- [ ] Server-only modules are not imported into Client Components (verified by `next build` warnings)
- [ ] `next.config.js` has `output: 'standalone'` for Docker deployments
- [ ] Composition pattern is used when interactivity wraps content (Server Component passed as `children` to Client Component)
