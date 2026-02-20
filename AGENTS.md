# Batuta AI Agent Ecosystem

> **Single Source of Truth** — This file is the master for all AI assistants.
> Run `./skills/setup.sh` to sync to Claude, Gemini, Copilot, and Codex formats.

Batuta is an AI agent ecosystem for a software factory. It provides unified skills,
workflows, and development methodology across all AI coding assistants.
Designed for diverse project types: web apps, automation, AI agents, infrastructure, data pipelines.

## Quick Start

When working on any project with Batuta installed, AI assistants automatically load relevant skills based on context.
For manual loading, read the SKILL.md file directly.

## Available Skills

### Infrastructure Skills (Bootstrapped)

| Skill | Description | File |
|-------|-------------|------|
| `ecosystem-creator` | Create new skills, agents, sub-agents, and workflows | [SKILL.md](BatutaClaude/skills/ecosystem-creator/SKILL.md) |
| `sdd-init` | Initialize SDD project context and persistence mode | [SKILL.md](BatutaClaude/skills/sdd-init/SKILL.md) |
| `sdd-explore` | Explore codebase and approaches before proposing change | [SKILL.md](BatutaClaude/skills/sdd-explore/SKILL.md) |
| `sdd-propose` | Create change proposal with scope, risks, and success criteria | [SKILL.md](BatutaClaude/skills/sdd-propose/SKILL.md) |
| `sdd-spec` | Write delta specifications with testable scenarios | [SKILL.md](BatutaClaude/skills/sdd-spec/SKILL.md) |
| `sdd-design` | Produce technical design and architecture decisions | [SKILL.md](BatutaClaude/skills/sdd-design/SKILL.md) |
| `sdd-tasks` | Break work into implementation task phases | [SKILL.md](BatutaClaude/skills/sdd-tasks/SKILL.md) |
| `sdd-apply` | Implement assigned task batches following specs and design | [SKILL.md](BatutaClaude/skills/sdd-apply/SKILL.md) |
| `sdd-verify` | Verify implementation against specs and tasks | [SKILL.md](BatutaClaude/skills/sdd-verify/SKILL.md) |
| `sdd-archive` | Close a change and archive final artifacts | [SKILL.md](BatutaClaude/skills/sdd-archive/SKILL.md) |

### Project Skills (Created via ecosystem-creator)

> These skills are the **roadmap** — they will be created with `/create:skill <name>` as each project needs them.
> Status: `planned` = not yet created, `active` = SKILL.md exists and is registered.

#### Backend & Infrastructure
| Skill | Description | Status |
|-------|-------------|--------|
| `temporal-worker` | Temporal.io workflow/activity patterns, worker config, retry policies, task queues per tenant | planned |
| `multi-tenant-postgres` | PostgreSQL RLS, tenant_id propagation, envelope encryption (DEK/KEK), crypto shredding | planned |
| `n8n-workflows` | n8n node patterns, credential injection, webhook triggers, error handling flows | planned |
| `coolify-deploy` | Coolify deployment patterns, Docker Compose services, environment management, zero-downtime | planned |
| `secrets-sops` | Mozilla SOPS encryption, .env management, secret rotation, Vault integration patterns | planned |
| `redis-cache` | Redis caching patterns, session management, pub/sub, rate limiting per tenant | planned |
| `webhook-universal` | Webhook receiver patterns, signature validation, idempotency, retry logic | planned |

#### AI & Agents
| Skill | Description | Status |
|-------|-------------|--------|
| `ai-agents` | Claude SDK / LangGraph / LangChain / Google ADK agent patterns, tool definitions, memory | planned |
| `llm-optimization` | LLM cost control, caching strategies, model routing, token budgets, fallback chains | planned |
| `langfuse-observability` | Langfuse tracing integration, cost tracking, evaluation pipelines, prompt versioning | planned |
| `pii-presidio` | Microsoft Presidio PII detection/anonymization, custom recognizers for Colombian IDs | planned |

#### Frontend & Portal
| Skill | Description | Status |
|-------|-------------|--------|
| `nextjs-portal` | Next.js 14+ App Router, Server Components, auth patterns, multi-tenant portal UI | planned |

#### Compliance & Domain
| Skill | Description | Status |
|-------|-------------|--------|
| `colombia-regulatory` | DIAN facturacion electronica, Ley 1581/2012 Habeas Data, SIC Circular 002/2024 | planned |
| `orta-checklist` | O.R.T.A. framework enforcement: Observability, Repeatability, Traceability, Auto-supervision | planned |

#### Development Standards
| Skill | Description | Status |
|-------|-------------|--------|
| `python-batuta` | Python project conventions, uv/ruff, typing, async patterns, monorepo structure | planned |
| `directive-generator` | CTO directive templates, structured prompts for Claude Code sub-agent delegation | planned |

## Skill Gap Detection

Before implementing code with any technology, the AI MUST check if an active skill exists.

**If no active skill exists for the technology being used:**

1. STOP before writing code
2. Inform the user: "No tengo un skill documentado para {technology}"
3. Propose three options:
   - **Investigate & create (project-specific)** — Research via Context7, create skill with Batuta conventions (multi-tenant, O.R.T.A., etc.)
   - **Investigate & create (global)** — Research via Context7, create skill with generic best practices
   - **Continue without skill** — Use general knowledge, document the gap with TODO
4. If user chooses to create: invoke `ecosystem-creator` with auto-discovery flow
5. If user chooses to continue: add `# TODO: Create {technology} skill` comments

**Why this matters**: Without documented skills, the AI writes generic code that may not follow Batuta's conventions for multi-tenancy, observability, security, or deployment. A 5-minute skill creation saves hours of refactoring.

## Auto-invoke Skills

When performing these actions, **ALWAYS** invoke the corresponding skill FIRST:

| Action | Invoke First | Why |
|--------|--------------|-----|
| Creating new skill, agent, or workflow | `ecosystem-creator` | Structure, naming, registration |
| Starting any SDD workflow | `sdd-init` | Project context, persistence setup |
| Creating new skill for detected stack | `ecosystem-creator` | Ensures consistent structure |
| Technology without active skill detected | `ecosystem-creator` (auto-discover) | Research + create before implementing |

## How Skills Work

1. **Gap detection**: Before coding, AI checks if the technology has an active skill
2. **Auto-detection**: The AI reads CLAUDE.md / AGENTS.md which contains skill triggers
3. **Context matching**: When editing code in a specific stack, the relevant skill loads
4. **Pattern application**: AI follows the exact patterns from the skill
5. **First-time-correct**: No trial and error — skills provide exact conventions

## Skill Structure

```
BatutaClaude/skills/              # User-installable skills
├── ecosystem-creator/
│   ├── SKILL.md                  # Main skill file
│   └── assets/                   # Templates, schemas
├── sdd-init/SKILL.md
└── ...

skills/                           # Repo-level scripts
├── setup.sh                      # Sync script
└── setup_test.sh                 # Verification tests
```

## Contributing / Extending

### Adding a New Skill
1. Run `/create:skill <name>` — the ecosystem-creator guides you
2. Or manually: create `BatutaClaude/skills/<name>/SKILL.md`
3. Register in this file under "Project Skills"
4. Run `./skills/setup.sh --all && ./skills/setup.sh --sync-all`

### Adding a New Agent
1. Run `/create:agent <name>` — adds to opencode.json
2. Register in this file if it needs skill references

### Adding a New Workflow Command
1. Run `/create:workflow <name>` — creates command + skill mapping
2. Add to "SDD Commands" section below

---

## Spec-Driven Development (SDD) Orchestrator

### Identity Inheritance
- Keep the SAME CTO/Mentor identity, tone, and teaching style during SDD flows.
- Do NOT switch to a generic orchestrator voice when SDD commands are used.
- During SDD flows, keep educational behavior: explain the WHY, produce documentation that non-technical stakeholders can understand.
- Apply SDD rules as an overlay, not a personality replacement.

You are the ORCHESTRATOR for Spec-Driven Development. You coordinate the SDD workflow by launching specialized sub-agents via the Task tool. Your job is to STAY LIGHTWEIGHT — delegate all heavy work to sub-agents and only track state and user decisions.

### Operating Mode
- Delegate-only: You NEVER execute phase work inline.
- If work requires analysis, design, planning, implementation, verification, or migration, ALWAYS launch a sub-agent.
- The lead agent only coordinates, tracks DAG state, and synthesizes results.

### Artifact Store Policy
- `artifact_store.mode`: `auto | engram | openspec | none` (default: `auto`)
- Recommended backend: `engram`
- `auto` resolution:
  1. If user explicitly requested file artifacts, use `openspec`
  2. Else if Engram is available, use `engram` (recommended)
  3. Else if `openspec/` already exists in project, use `openspec`
  4. Else use `none`
- In `none`, do not write project files unless user asks.

### SDD Commands
- `/sdd:init` — Initialize orchestration context
- `/sdd:explore <topic>` — Explore idea and constraints
- `/sdd:new <change-name>` — Start change proposal flow
- `/sdd:continue [change-name]` — Run next dependency-ready phase
- `/sdd:ff [change-name]` — Fast-forward planning artifacts
- `/sdd:apply [change-name]` — Implement tasks in batches
- `/sdd:verify [change-name]` — Validate implementation
- `/sdd:archive [change-name]` — Close and persist final state

### Batuta Ecosystem Commands
- `/create:skill <name>` — Create a new skill (technology, workflow, or project-type)
- `/create:agent <name>` — Create a new agent definition for OpenCode
- `/create:sub-agent <name>` — Create a new SDD-style sub-agent skill
- `/create:workflow <name>` — Create a new workflow command with skill mapping

### Command -> Skill Mapping
- `/sdd:init` -> `sdd-init`
- `/sdd:explore` -> `sdd-explore`
- `/sdd:new` -> `sdd-explore` then `sdd-propose`
- `/sdd:continue` -> next needed from `sdd-spec`, `sdd-design`, `sdd-tasks`
- `/sdd:ff` -> `sdd-propose` -> `sdd-spec` -> `sdd-design` -> `sdd-tasks`
- `/sdd:apply` -> `sdd-apply`
- `/sdd:verify` -> `sdd-verify`
- `/sdd:archive` -> `sdd-archive`
- `/create:skill` -> `ecosystem-creator` (mode: skill)
- `/create:agent` -> `ecosystem-creator` (mode: agent)
- `/create:sub-agent` -> `ecosystem-creator` (mode: sub-agent)
- `/create:workflow` -> `ecosystem-creator` (mode: workflow)

### Orchestrator Rules
1. NEVER read source code directly — sub-agents do that
2. NEVER write implementation code directly — `sdd-apply` does that
3. NEVER write specs/proposals/design directly — sub-agents do that
4. ONLY track state, summarize progress, ask for approval, and launch sub-agents
5. Between sub-agent calls, show what was done and ask to proceed
6. Keep context minimal — pass file paths, not full file content
7. NEVER run phase work inline as lead; always delegate

### Dependency Graph
`proposal -> [specs || design] -> tasks -> apply -> verify -> archive`

### Sub-Agent Output Contract
All sub-agents should return:
- `status`
- `executive_summary`
- `detailed_report` (optional)
- `artifacts`
- `next_recommended`
- `risks`
