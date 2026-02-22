---
name: scope-rule
description: >
  Enforces the Scope Rule for file and component organization: "Use determines location."
  Every component, service, utility, or module must be placed based on WHO uses it,
  not what it does. Prevents messy utils/ and components/ dump folders.
  Trigger: When creating files, components, services, modules, organizing code,
  "where should this go", "file structure", "folder structure", "component location",
  "shared component", "move to shared", "scope", architecture, refactor structure.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-20"
  scope: [infra]
  auto_invoke: "Creating files, deciding file locations"
allowed-tools: Read, Glob, Grep
---

## Purpose

You are the **Scope Rule enforcer** for the Batuta ecosystem. Before creating ANY file,
component, service, utility, or module, you MUST determine its scope to decide its
physical location in the project.

> **The fundamental principle**: "El uso determina la ubicacion" — Use determines location.

This rule exists because LLMs tend to create dumping-ground folders like `utils/`,
`helpers/`, `components/`, and `shared/` where everything gets thrown together.
The Scope Rule forces a single question before writing any file: **"Who is going to use this?"**

> **What This Means (Simply):** Before putting any file anywhere, ask yourself:
> "Who needs this?" If only one feature needs it, it lives inside that feature's folder.
> If two or more features need it, it goes to a shared folder. If the ENTIRE app needs
> it (like login or the main layout), it goes to a core folder. It's like organizing a
> kitchen: your personal spices go in your cabinet, shared spices go on the common shelf,
> and the stove (used by everyone) is in the center.

---

## The Decision Tree (MANDATORY)

Before creating ANY file, run this decision:

```
Who will use this?
│
├── 1 Feature only ──────── FEATURE SCOPE
│   Location: features/{feature-name}/{type}/
│   Example:  features/products/components/ProductCard.tsx
│   Rule:     NEVER put it in a global/shared folder
│
├── 2+ Features ─────────── SHARED SCOPE
│   Location: features/shared/{type}/
│   Example:  features/shared/components/ActionButton.tsx
│   Rule:     Only PROMOTE here when a second consumer appears
│             NEVER preemptively put things in shared/
│
└── Entire App (singleton) ── CORE SCOPE
    Location: core/{type}/
    Example:  core/guards/auth.ts
    Rule:     Only for true app-wide singletons:
              auth, routing, error boundaries, app layout,
              database connection, logging service
```

### Quick Reference Table

| Who uses it? | Scope | Path pattern | Examples |
|---|---|---|---|
| 1 feature | Feature | `features/{feature}/{type}/{name}` | `features/inventory/components/StockTable.tsx` |
| 2+ features | Shared | `features/shared/{type}/{name}` | `features/shared/hooks/useDebounce.ts` |
| Entire app | Core | `core/{type}/{name}` | `core/services/auth.service.ts` |

### Type Subfolders

| Type | What goes here |
|---|---|
| `components/` | UI components (React, Vue, Svelte, etc.) |
| `hooks/` | Custom hooks (React) or composables (Vue) |
| `services/` | Business logic, API clients, data transformers |
| `utils/` | Pure utility functions (formatDate, parseCSV) |
| `types/` | TypeScript types and interfaces |
| `guards/` | Auth guards, route guards, permission checks |
| `models/` | Data models, schemas, DTOs |
| `stores/` | State management (Zustand, Pinia, Redux slices) |
| `api/` | API route handlers, endpoint definitions |
| `middleware/` | Express/Next.js middleware |
| `workers/` | Background workers (Temporal activities, etc.) |

---

## Critical Patterns

### Pattern 1: Start Feature-Scoped, Promote When Needed

```
WRONG: Creating a component directly in shared/ because "it might be reused"
RIGHT: Create it in the feature that needs it first

Step 1: features/checkout/components/PriceDisplay.tsx  (only checkout uses it)
Step 2: Cart also needs it → MOVE to features/shared/components/PriceDisplay.tsx
Step 3: Update ALL imports that referenced the old path
```

**Rule**: NEVER preemptively promote to shared. Wait for the second consumer.

### Pattern 2: Core is for True Singletons Only

```
WRONG: core/utils/formatDate.ts  (this is NOT a singleton)
RIGHT: features/shared/utils/formatDate.ts  (shared utility, not core)

Core examples (correct):
- core/guards/auth.guard.ts         (one auth system for the entire app)
- core/services/database.service.ts (one DB connection pool)
- core/middleware/error-handler.ts   (one global error handler)
- core/config/app.config.ts         (one configuration source)
```

**Rule**: If you can imagine having TWO of these in the same app, it's NOT core.

### Pattern 3: Backend Scope (Python / Node)

The same rule applies to backend code:

```
backend/
├── core/                        # App-wide singletons
│   ├── config.py
│   ├── database.py
│   ├── auth/
│   │   ├── service.py
│   │   └── middleware.py
│   └── logging.py
├── features/                    # Feature modules
│   ├── workflows/               # n8n workflow monitoring
│   │   ├── routes.py
│   │   ├── service.py
│   │   ├── models.py
│   │   └── schemas.py
│   ├── tokens/                  # Google token tracking
│   │   ├── routes.py
│   │   ├── service.py
│   │   └── schemas.py
│   └── shared/                  # Shared across 2+ features
│       ├── pagination.py
│       └── date_utils.py
```

### Pattern 4: Scope Promotion Checklist

When moving a component from feature-scoped to shared:

1. Move the file to `features/shared/{type}/`
2. Update ALL import paths across the codebase
3. Review if the component needs to become more generic (remove feature-specific props)
4. Add a brief comment: `// Promoted from features/{origin-feature}/ — used by {feature-1}, {feature-2}`
5. Run tests to verify nothing breaks

---

## Anti-Patterns (NEVER Do This)

| Anti-Pattern | Why it's wrong | Correct approach |
|---|---|---|
| `src/utils/` dump folder | Everything gets thrown here, no one knows what belongs where | Split into `features/{name}/utils/` per consumer |
| `src/components/` global folder | 50 components, no organization by feature | `features/{name}/components/` per feature |
| `src/helpers/` | Vague category, same as utils dump | Use `utils/` within the correct scope |
| Preemptive `shared/` | "It might be reused someday" | Start feature-scoped, promote when needed |
| `core/` for utilities | formatDate is NOT a singleton | `features/shared/utils/` |
| `src/lib/` catch-all | Same as utils dump with a fancier name | Apply scope rule normally |
| Circular imports | Feature A imports from Feature B directly | Promote shared code to `features/shared/` |

---

## Batuta Stack Integration

| Stack Component | Scope Rule Application |
|---|---|
| **Temporal.io** | Workflow definitions → `features/{name}/workers/`, shared activities → `features/shared/workers/` |
| **n8n** | Webhook handlers → `features/{name}/webhooks/`, shared webhook utils → `features/shared/webhooks/` |
| **PostgreSQL (multi-tenant)** | Tenant-aware models → `core/database/` (singleton), feature models → `features/{name}/models/` |
| **Redis** | Cache service → `core/services/cache.ts` (singleton), feature-specific cache keys → `features/{name}/cache/` |
| **Next.js** | Pages → `app/{route}/`, feature components → `features/{name}/components/`, shared UI → `features/shared/components/` |
| **Auth** | Always `core/auth/` — authentication is a true app-wide singleton |
| **Langfuse** | Tracing service → `core/services/observability.ts` (singleton) |
| **Presidio** | PII service → `core/services/pii.ts` (singleton), custom recognizers → `features/{name}/pii/` |

---

## Rules

1. **ALWAYS ask "Who uses this?" before creating any file**
2. **NEVER create `utils/`, `helpers/`, `lib/`, or `components/` at the project root** — these are scope-less dumping grounds
3. **Start feature-scoped** — only promote to shared when a second consumer appears
4. **Core is for singletons only** — auth, database, logging, app config
5. **When promoting to shared**, update ALL imports and consider making the component more generic
6. **No circular imports** — if Feature A needs something from Feature B, that thing belongs in `features/shared/`
7. **Backend follows the same rules** — Python, Node, Go — scope is universal
8. **Document promotions** — when moving to shared, add a comment noting where it came from and why

---

## Commands

| Scenario | What to do |
|---|---|
| User asks "where should I put this component?" | Run the Decision Tree |
| User says "create a utils folder" | STOP — ask what utilities, determine scope for each |
| Refactoring messy structure | Map each file to its consumers, move to correct scope |
| New feature module | Create `features/{name}/` with only the subfolders needed |

---

## What This Means (Simply)

Think of your project like a building:
- **Feature folders** are apartments — each one has its own kitchen, bathroom, and living room.
  You don't share your toothbrush with the neighbor.
- **Shared folder** is the building's common area — the laundry room, the gym.
  Multiple apartments use it, so it lives in a shared space.
- **Core folder** is the building's infrastructure — one elevator, one electrical system, one water main.
  There's exactly ONE of these for the whole building.

The Scope Rule simply asks: "Is this a personal item (feature), a shared amenity (shared),
or building infrastructure (core)?" That answer determines exactly where the file goes.
