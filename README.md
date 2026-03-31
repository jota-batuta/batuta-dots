# Batuta.Dots

**AI agent ecosystem for software factories — Claude Code first, replicable to any platform.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## What is Batuta?

Batuta is an AI agent ecosystem built as a **Mixture of Experts (MoE)** for software development. `CLAUDE.md` acts as the **router** (intent classification + routing), **domain agents** are the **experts** (backend, data, quality — each carrying 80-120 lines of embedded expertise), and **skills** are the **parameters** (loaded on demand based on context). You write your conventions once, and the right expert activates automatically. When you are ready to extend to other platforms, a replication script generates the equivalent for Gemini, Copilot, Codex, or OpenCode.

Inspired by [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots), adapted for:

- **Multi-project software factory**.
- **CTO/Mentor personality** that educates and documents for non-technical stakeholders.
- **Scope Rule** that organizes files by who uses them, not by type.
- **Skill Gap Detection** with automatic research via Context7.
- **Lazy skill loading** — Claude reads ~300 lines at startup, skills load on demand.
- **MoE architecture** — CLAUDE.md routes, domain agents are experts, skills are parameters.
- **6 agents** — 3 scope agents (pipeline, infra, observability) + 3 domain agents (backend, data, quality) with auto-discovered skills.
- **Execution Gate** — mandatory pre-validation before any code change.
- **Native hooks** — SessionStart, Stop.
- **O.R.T.A. framework** (Observability, Repeatability, Traceability, Auto-supervision).
- **Agent Teams** — orchestrate multiple Claude sessions in parallel for complex tasks.
- **Contract-First Protocol** — pre-spawn contracts define input/output/file-ownership per teammate.
- **AI-First Security** — dedicated security-audit skill integrated in design and verify phases.
- **Team Templates + Playbook** — pre-built team compositions per stack (Next.js, FastAPI, n8n, AI agent, data pipeline, refactoring).
- **PRD Generation** — after task plan approval, pipeline-agent generates a consolidated `PRD.md` for clean context reset between planning and execution sessions.
- **Batuta Bootstrap** — "The Rule" enforcement via SessionStart hook: if a skill applies, you MUST use it.
- **MCP Discovery** — active web search for beneficial MCP servers during explore phase.
- **Trigger-Only Descriptions** — all 39 skill descriptions follow "Use when..." convention for reliable activation.
- **Domain Agents** — 3 domain experts (backend, data, quality) with thick persona, auto-invoked as autonomous subprocesses based on technology signals.

---

## Quick Start

### Install (Recommended)

Install Batuta with a single command — no permanent clone needed:

```bash
git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install && bash /tmp/batuta-install/infra/install.sh && rm -rf /tmp/batuta-install
```

This will:
1. Clone the repository to a temporary directory
2. Ask which platform to install (**Claude Code** or **Antigravity**)
3. Install the selected platform files to their global locations
4. Set up your current directory as a Batuta project (Claude Code)
5. Clean up the temporary clone

**Non-interactive install:**

```bash
# Claude Code only
git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install && bash /tmp/batuta-install/infra/install.sh --claude && rm -rf /tmp/batuta-install

# Antigravity only
git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install && bash /tmp/batuta-install/infra/install.sh --antigravity && rm -rf /tmp/batuta-install
```

**Windows:**

> **Important:** Use WSL or Git Bash. PowerShell is not supported (its `curl` is an alias for `Invoke-WebRequest`).

```bash
# WSL (recommended) or Git Bash
git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install && bash /tmp/batuta-install/infra/install.sh && rm -rf /tmp/batuta-install
```

### What Gets Installed

| Platform | Destination | Contents |
|----------|-------------|----------|
| **Claude Code** | `~/.claude/` | 38 skills, 6 agents, 13 commands, 2 hooks, settings.json, output-styles |
| **Claude Code** | Current directory | `CLAUDE.md` + `.batuta/` (session, ecosystem.json) |
| **Antigravity** | `~/.gemini/antigravity/` | Antigravity-compatible skills, workflows, GEMINI.md |

### Developer Setup

If you want to contribute to batuta-dots itself:

```bash
git clone https://github.com/jota-batuta/batuta-dots.git
cd batuta-dots
./infra/setup.sh --all
./infra/setup.sh --verify
```

---

## Architecture

```
batuta-dots/
├── BatutaClaude/                      # Claude Code configuration
│   ├── CLAUDE.md                      # Single entry point (router + rules + scope routing)
│   ├── VERSION                        # Ecosystem version (semver)
│   ├── settings.json                  # Permissions, output style
│   ├── mcp-servers.template.json      # MCP server template
│   ├── output-styles/batuta.md        # Custom output format
│   ├── commands/                      # Global slash commands
│   │   ├── batuta-init.md             # /batuta-init — import ecosystem
│   │   ├── batuta-update.md           # /batuta-update — pull latest
│   ├── agents/                        # Scope + Domain agents
│   │   ├── pipeline-agent.md          # Scope: SDD Pipeline specialist (9 skills)
│   │   ├── infra-agent.md             # Scope: Infrastructure specialist (5 skills)
│   │   ├── observability-agent.md     # Scope: O.R.T.A. engine (no active skills)
│   │   ├── backend-agent.md           # Domain: provisioned when backend frameworks detected
│   │   ├── quality-agent.md           # Domain: always provisioned (AI Validation Pyramid)
│   │   └── data-agent.md              # Domain: provisioned when data/AI frameworks detected
│   └── skills/                        # Skill definitions (lazy-loaded)
│       ├── ecosystem-creator/         # Bootstrap skill
│       │   ├── SKILL.md
│       │   └── assets/                # Templates for skills, agents, workflows
│       ├── scope-rule/SKILL.md        # File organization rules
│       ├── sdd-init/SKILL.md          # SDD pipeline (9 phases)
│       ├── sdd-explore/SKILL.md
│       ├── sdd-propose/SKILL.md
│       ├── sdd-spec/SKILL.md
│       ├── sdd-design/SKILL.md
│       ├── sdd-tasks/SKILL.md
│       ├── sdd-apply/SKILL.md
│       ├── sdd-verify/SKILL.md
│       ├── sdd-archive/SKILL.md
│       ├── team-orchestrator/SKILL.md # Agent Teams orchestration (when to escalate)
│       └── security-audit/SKILL.md   # AI-first security practices (OWASP + threats)
├── BatutaAntigravity/                 # Antigravity Lite (brainstorming & prototyping)
│   ├── GEMINI.md                      # Full CTO brain adapted for Antigravity
│   ├── setup-antigravity.sh           # Setup script (--global / --workspace / --all / --update)
│   ├── settings-template.json         # Recommended Antigravity config
│   └── workflows/                     # Saved prompts (SDD + session + sync)
│       ├── sdd-init.md ... sdd-archive.md  # SDD pipeline (8 workflows)
│       ├── save-session.md            # Save state (replaces Stop hook)
│       ├── push-skill.md             # Propagate local skill to hub
│       └── batuta-update.md          # Update from hub
├── docs/                              # All documentation
│   ├── architecture/                  # Architecture and design
│   │   ├── arquitectura-diagrama.md   # Mermaid architecture diagrams (15+ diagrams)
│   │   └── arquitectura-para-no-tecnicos.md  # Non-technical guide (restaurant analogy, 15+ roles)
│   ├── guides/                        # Step-by-step execution guides (14 guides, Spanish)
│   │   ├── guia-batuta-app.md         # Dashboard app — full lifecycle guide
│   │   ├── guia-temporal-io-app.md    # Temporal.io workflows — full lifecycle guide
│   │   ├── guia-langchain-gmail-agent.md  # LangChain + Gmail agent guide
│   │   ├── guia-n8n-automation.md     # n8n workflow automation guide
│   │   ├── guia-fastapi-service.md    # FastAPI microservice guide
│   │   ├── guia-nextjs-saas.md        # Next.js SaaS app guide
│   │   ├── guia-cli-python.md         # Python CLI tool guide
│   │   ├── guia-data-pipeline.md      # Data pipeline (ETL) guide
│   │   ├── guia-refactoring-legacy.md # Legacy refactoring guide
│   │   ├── guia-ai-agent-adk.md       # AI agent (Google ADK) guide
│   │   ├── guia-auditoria-contable.md # Accounting audit (CTO v11.0) guide
│   │   └── guia-seleccion-personal.md # Personnel selection (CTO v11.0) guide
│   └── qa/                            # Quality assurance reports
│       ├── README.md                  # QA index
│       ├── audits/                    # Quality audit reports (v5-v9)
│       ├── corrections/               # Correction logs (v5-v9.2)
│       ├── integration-tests/         # Integration test reports (12 guides)
│       └── smoke-tests/              # Smoke test reports (5 reports)
├── teams/                             # Agent Team assets
│   ├── templates/                     # Pre-built team compositions per stack (7 templates)
│   │   ├── nextjs-saas.md             # Next.js SaaS team template
│   │   ├── fastapi-service.md         # FastAPI microservice team template
│   │   ├── n8n-automation.md          # n8n automation team template
│   │   ├── ai-agent.md               # AI agent team template
│   │   ├── data-pipeline.md          # Data pipeline team template
│   │   ├── temporal-io-app.md         # Temporal.io workflow team template
│   │   └── refactoring.md            # Legacy refactoring team template
│   └── playbook.md                    # Team patterns and best practices
├── CHANGELOG-refactor.md              # Refactoring trace document (v1-v13.1)
├── academia/                          # Training course (8 modules, 53 lessons)
└── infra/                             # Infrastructure & setup scripts
    ├── setup.sh                       # Claude Code setup (primary)
    ├── sync.sh                        # Bidirectional skill sync (hub ↔ projects, --push for zero-friction)
    ├── replicate-platform.sh          # Multi-platform replication
    ├── setup_test.sh                  # Verification tests (51 tests)
    └── hooks/                         # O.R.T.A. hooks (native Claude Code hooks)
        ├── session-start.sh           # SessionStart — inject session.md as context
        └── session-save.sh            # Stop — log session end event
```

---

## How It Works

Batuta operates as a **Mixture of Experts (MoE)** system:

1. **CLAUDE.md** is the **router** — the single entry point (~220 lines). It classifies user intent, enforces rules (Scope Rule, Execution Gate, SDD gates), and routes to the right expert. Skills are auto-discovered by Claude Code based on their `description` field.
2. **Domain agents** are the **experts** — autonomous subprocesses carrying "thick persona" (80-120 lines of embedded domain knowledge). They run via the Task tool, not as inline context, keeping the main agent lightweight.
3. **Skills** are the **parameters** — loaded on demand when an expert needs specific patterns (e.g., FastAPI CRUD, JWT auth, SQLAlchemy models).
4. **setup.sh --all** syncs skills and agents, installs hooks + permissions to `~/.claude/settings.json`, then copies the updated CLAUDE.md to root.

```
CLAUDE.md — THE ROUTER (intent classification + rules — ~220 lines)
    │
    ├──> Hooks (settings.json)
    │     ├── SessionStart → inject session.md as context
    │     └── Stop → update session.md + log session end
    │
    ├──> PARAMETERS — Skills (auto-discovered by Claude Code via description)
    │     ├── pipeline: sdd-init...sdd-archive (9 skills)
    │     ├── infra: scope-rule, ecosystem-creator, ecosystem-lifecycle, team-orchestrator, security-audit
    │     └── observability: (no active skills)
    │
    ├──> Scope Agents (always loaded, skills auto-discovered by description)
    │     ├── pipeline-agent (dependency graph, orchestrator rules)
    │     ├── infra-agent (Skill Gap Detection, Ecosystem Auto-Update)
    │     └── observability-agent (session lifecycle)
    │
    ├──> EXPERTS — Domain Agents (autonomous subprocesses, provisioned by tech detection)
    │     ├── backend-agent (fastapi|django|express|nestjs) — API, auth, DB expertise
    │     ├── quality-agent (always provisioned) — testing, security, debugging
    │     └── data-agent (pandas|langchain|anthropic) — ETL, AI/ML, RAG expertise
    │
    └──> Agent Team (Level 3) ──> spawn teammates from scope + domain agents
```

### Multi-Platform: Claude Code + Antigravity Lite

Batuta supports two platforms with distinct roles — Claude Code for serious production work (full SDD pipeline) and Antigravity Lite as a brainstorming & quick prototyping companion:

| Aspect | Claude Code (Full) | Antigravity Lite |
|--------|-------------------|-------------------|
| Role | Production — full SDD pipeline, architecture, complex features | Exploration — brainstorming, quick prototyping, scripts, docs |
| Brain | Full CTO via CLAUDE.md | Full CTO via GEMINI.md |
| Commands | Slash commands (native) | Workflows (saved prompts) |
| Hooks | Native (SessionStart, Stop) | No hooks — behavioral rules only |
| Skills | `~/.claude/skills/` | `.agent/skills/` or `~/.gemini/antigravity/skills/` |
| Multi-agent | Agent Teams | Manager View |
| Cost | Claude Max x20 ($200/mo) | Free (preview) |

Skills are platform-agnostic (SKILL.md open standard). The `platforms` field in frontmatter controls which platforms receive each skill during sync. See the [Antigravity Lite Guide](docs/guides/guia-batuta-antigravity.md).

```bash
# Setup Antigravity in a project
bash BatutaAntigravity/setup-antigravity.sh --workspace

# Sync skills filtered by platforms tag
bash infra/sync.sh --to-antigravity

# Push local skills to hub (import + cross-sync + commit + push)
bash infra/sync.sh --push

# Other platforms (Gemini CLI, Codex, Copilot)
./infra/replicate-platform.sh --all
```

---

## Core Concepts

### Scope Rule

Before creating ANY file, the AI asks: "Who will use this?"

| Who uses it? | Where it goes |
|---|---|
| 1 feature | `features/{feature}/{type}/{name}` |
| 2+ features | `features/shared/{type}/{name}` |
| Entire app | `core/{type}/{name}` |

NEVER create root `utils/`, `helpers/`, `lib/`, or `components/` folders. Full details in the `scope-rule` skill.

### Spec-Driven Development (SDD)

A 9-phase state machine that enforces "understand before build":

```
init -> explore -> propose -> spec -> design -> tasks -> apply -> verify -> archive
                                                          ↑ backtracks ↑
```

Each phase is a dedicated sub-agent skill. The pipeline-agent orchestrates as a **state machine** — phases can move forward (happy path) or backward (backtracks) when implementation reveals issues. The user interacts through **natural conversation** (auto-routing classifies intent), not slash commands. Commands remain as manual overrides.

### Auto-Routing (Intent-Driven Pipeline)

**Batuta detects your intent automatically — you don't need to type slash commands.** Just describe your problem or task in natural language. Slash commands exist as manual overrides when you want explicit control over a specific pipeline phase.

| Intent | What you say | Route |
|--------|-------------|-------|
| Build / Feature / Problem | "necesito un dashboard", "build a notification system" | SDD Pipeline (auto-advance with checkpoints) |
| Quick fix / Bug | "el botón no funciona", "fix the null check" | Direct fix (skip SDD, Execution Gate LIGHT) |
| Continue / Resume | "donde quedamos?", "continua con inventario" | Detect phase from artifacts, resume |
| Backtrack / Rethink | "esto no funciona como pensé", "cambio el requisito" | Classify target phase, update artifact |
| Question / Explain | "qué es SDD?", "how does auth work?" | Answer directly |
| Explicit `/sdd-*` command | `/sdd-explore`, `/sdd-apply` | Manual override (bypasses auto-routing) |

### Quick Mode vs Full SDD Pipeline

Batuta automatically selects the right depth for your task:

| Scope | Route | Steps |
|-------|-------|-------|
| **Quick Mode** — bug fix, 1-2 file change, clear scope | Direct fix | Execution Gate LIGHT → implement |
| **Full SDD** — new feature, 3+ files, architecture decision | SDD Pipeline | explore → propose → spec → design → tasks → apply → verify → archive |

You don't choose — the agent classifies for you. If a quick fix grows in scope (3+ files, architectural implications), the agent switches to SDD and tells you why.

### Agents (Scope + Domain) — The MoE Experts

Batuta's 6 agents form the "experts" layer of the MoE architecture. **3 Scope Agents** (always loaded) organize the SDD pipeline machinery, and **3 Domain Agents** (provisioned by tech detection) carry "thick persona" — 80-120 lines of embedded domain expertise that run as autonomous subprocesses, not inline context.

**Scope Agents** — always loaded, skills auto-discovered by `description` field:

| Scope Agent | Domain | Skills |
|-------------|--------|--------|
| `pipeline-agent` | Development lifecycle | 9 SDD skills (init through archive) |
| `infra-agent` | File organization, ecosystem, security | scope-rule, ecosystem-creator, ecosystem-lifecycle, team-orchestrator, security-audit |
| `observability-agent` | Session lifecycle | (no active skills) |

**Domain Agents** — auto-invoked based on technology signals, run as subprocesses via Task tool:

| Domain Agent | Provisioned When | Expertise |
|--------------|-----------------|-----------|
| `backend-agent` | fastapi, django, express, nestjs detected | API design, auth flows, DB schema, middleware |
| `quality-agent` | Always provisioned | AI Validation Pyramid, testing strategy, security audits, debugging |
| `data-agent` | pandas, langchain, anthropic detected | ETL pipelines, AI/ML integration, RAG patterns |

Domain agents carry personality + patterns + skill pointers and include an `sdk:` block for programmatic deployment via Claude Agent SDK. This keeps the principal agent lightweight (~220 lines) and each agent focused on its domain.

**Agent Lifecycle** — agents follow the same sync model as skills:

1. **Create**: `ecosystem-creator` generates the agent in `BatutaClaude/agents/` (hub)
2. **Classify**: `ecosystem-lifecycle` determines if the agent is generic (hub) or project-specific (local)
3. **Sync to global**: `setup.sh --sync` copies hub agents to `~/.claude/agents/`
4. **Provision to projects**: `sdd-init` copies relevant agents from global to `.claude/agents/` based on detected technologies

### Execution Gate

Before any code change, a mandatory pre-validation runs. Cannot be skipped.

| Mode | When | What it shows |
|------|------|---------------|
| LIGHT | Single-file edit, simple fix | "Modifying {file} at {location}. Proceed?" |
| FULL | New files, 2+ file changes, architecture | Location plan + impact + SDD/skill compliance |

### Skill Gap Detection

Before writing code with any technology, Claude checks if an active skill exists. If not, it stops and offers to research via Context7 and create the skill before proceeding.

### Lazy Loading (3 levels — MoE in action)

| Level | MoE Role | What loads | Lines |
|-------|----------|-----------|-------|
| 1 | Router | CLAUDE.md (intent classification + rules) | ~220 |
| 2 | Expert | Scope or domain agent | ~80-120 |
| 3 | Parameters | Individual skill | ~200-500 |

Only the needed level loads. A simple question never reaches level 3.

### Session Continuity

At conversation start, Claude reads `.batuta/session.md` to restore context. At the end of significant work, it updates the file so the next conversation picks up where this one left off.

### Agent Teams (3-Level Execution)

Batuta supports three execution levels. The system automatically evaluates which level to use:

| Level | Mechanism | When |
|-------|-----------|------|
| Solo session | Direct execution | 1-file edit, bug fix, simple question |
| Subagent (Task tool) | Fire-and-forget delegation | Research, verify, single SDD phase |
| Agent Team | Multiple independent Claude sessions | Multi-module feature, full SDD pipeline, competing hypotheses |

Agent Teams spawn real Claude Code sessions that work in parallel with a shared task list and bidirectional messaging.

### Ecosystem Auto-Update

When new skills are created in a project, Claude proposes propagating them back to batuta-dots so other projects benefit.

### Project Skill Provisioning (v11.3) & Agent Provisioning (v13.0)

During `/sdd-init`, only relevant skills are copied from the global library to your project. The agent sees only what it needs, keeping context clean as the ecosystem grows to 100+ skills.

Agent provisioning follows the same principle. The `skill-provisions.yaml` manifest defines:

- **`always_agents`**: agents provisioned to every project (currently: `quality-agent`)
- **`agent_rules`**: conditional provisioning based on detected dependencies (e.g., `backend-agent` when fastapi/django/express detected, `data-agent` when pandas/langchain/anthropic detected)

### Deterministic Rules & Mandatory Gates

All mandatory behaviors (scope enforcement, skill invocation, pipeline gates, ecosystem lifecycle) are defined as hard Rules with MUST/NEVER/ALWAYS keywords — deterministic and compaction-resistant. Seven mandatory gates (Execution Gate, G0.25, G0.5, G1, Proposal Approval, Task Plan Approval, G2) are consolidated as explicit STOP points.

### Proportional Output & Session Budget

Output scales to task complexity via three tiers (MICRO/STANDARD/COMPLEX). Session.md is capped at 80 lines as a briefing document answering WHERE/WHY/HOW — not a project README.

---

## Available Skills (38 skills + 6 agents)

| Skill | Scope | Description |
|-------|-------|-------------|
| `ecosystem-creator` | infra | Create new skills, agents, sub-agents, and workflows |
| `scope-rule` | infra | Enforce scope-based file organization |
| `team-orchestrator` | infra | Evaluate when to escalate to Agent Teams, spawn and coordinate |
| `ecosystem-lifecycle` | infra | Classify, self-heal, provision skills lifecycle |
| `skill-eval` | infra | Evaluate skill quality: Eval (behavioral test), Improve (propose edits), Benchmark (health report) |
| `claude-agent-sdk` | infra | Claude Agent SDK patterns: setting_sources, defer_loading, hooks mapping, CI/CD deployment |
| `security-audit` | infra, pipeline | AI-first security: OWASP + prompt injection + secrets scanning + dependency audit |
| `sdd-init` through `sdd-archive` | pipeline | 9-phase SDD pipeline |
| `process-analyst` | pipeline | Complex process analysis with 3+ case variants |
| `recursion-designer` | pipeline | External taxonomies, categories that change, learning systems |
| `compliance-colombia` | pipeline | Colombian data protection, tax retention, AI compliance |
| `data-pipeline-design` | pipeline | ETL, ERP integrations, data quality patterns |
| `llm-pipeline-design` | pipeline | LLM classifiers, prompt engineering, drift detection |
| `worker-scaffold` | pipeline | Temporal workers, Docker, Coolify deploy, monitoring |
| `accessibility-audit` | pipeline | Accessibility audit: WCAG compliance, screen reader testing, keyboard navigation |
| `performance-testing` | pipeline | Performance testing: load testing, profiling, bottleneck analysis |
| `technical-writer` | pipeline | Technical writing: API docs, user guides, architecture decision records |
| `fastapi-crud` | infra | FastAPI CRUD patterns and best practices |
| `jwt-auth` | infra | JWT authentication implementation patterns |
| `sqlalchemy-models` | infra | SQLAlchemy ORM model patterns |
| `react-nextjs` | pipeline | React/Next.js App Router patterns and conventions |
| `typescript-node` | pipeline | TypeScript/Node.js backend patterns |
| `api-design` | pipeline | REST API design, versioning, error handling |
| `e2e-testing` | pipeline | End-to-end testing with Playwright/Cypress |
| `tdd-workflow` | pipeline | Test-Driven Development methodology |
| `debugging-systematic` | pipeline | Systematic debugging with binary search, hypothesis testing |
| `vector-db-rag` | pipeline | Vector databases and RAG pipeline patterns |
| `message-queues` | pipeline | Message queue patterns (RabbitMQ, Redis, SQS) |
| `ci-cd-pipeline` | infra | CI/CD pipeline design and automation |
| `observability` | observability | Monitoring, logging, tracing, alerting patterns |

---

## Commands

All commands are **manual overrides**. For normal work, just describe your task — auto-routing handles the rest.

| Command | When to use |
|---------|-------------|
| `/batuta-init [name]` | First time: import Batuta into a new project |
| `/batuta-update` | Pull latest skills, agents, and CLAUDE.md from the hub |
| `/sdd-init` | Initialize SDD context (`openspec/`) in a project |
| `/sdd-explore <topic>` | Manually trigger exploration of a specific topic |
| `/sdd-new <change-name>` | Start from scratch: explore + propose in one step |
| `/sdd-continue [change-name]` | Resume an in-progress change from where it left off |
| `/sdd-ff [change-name]` | **Fast-Forward**: after exploring, skip to propose → spec → design → tasks in one shot |
| `/sdd-apply [change-name]` | Implement the approved task plan |
| `/sdd-verify [change-name]` | Run the AI Validation Pyramid against the implementation |
| `/sdd-archive [change-name]` | Close the change: persist specs, lessons learned, update Notion |
| `/create <type> <name>` | Create a new skill, sub-agent, or workflow (type: `skill` \| `sub-agent` \| `workflow`) |

---

## setup.sh Reference

| Flag | Action |
|------|--------|
| `--claude` | Copy CLAUDE.md to project root |
| `--sync` | Sync skills + agents + commands to ~/.claude/ |
| `--all` | Full setup: sync + hooks + copy + antigravity (recommended) |
| `--hooks` | Install hooks + permissions to ~/.claude/settings.json |
| `--antigravity` | Sync Antigravity-compatible skills to BatutaAntigravity/skills/ |
| `--project <path>` | Setup a target project (CLAUDE.md + .batuta/ + git + hooks) |
| `--update <path>` | Update an existing project (re-sync global + refresh project CLAUDE.md + ecosystem.json) |
| `--verify` | Verify setup (51 checks) |

The `--all` flag: syncs skills and agents → installs hooks + permissions → copies updated CLAUDE.md to root.

---

## Guides

Step-by-step execution guides (14 guides) covering the full lifecycle: ecosystem installation → SDD pipeline → build → test → deploy → production → archive.

| Guide | Description |
|-------|-------------|
| [Dashboard App](docs/guides/guia-batuta-app.md) | Build a monitoring dashboard (n8n + Google AI tokens) — 15 steps |
| [Temporal.io Workers](docs/guides/guia-temporal-io-app.md) | Build workflow orchestration with Temporal.io — 14 steps |
| [LangChain + Gmail Agent](docs/guides/guia-langchain-gmail-agent.md) | Build an AI email classifier agent — 15 steps |
| [n8n Automation](docs/guides/guia-n8n-automation.md) | Automate business processes with n8n workflows |
| [FastAPI Service](docs/guides/guia-fastapi-service.md) | Build a REST API microservice with FastAPI |
| [Next.js SaaS](docs/guides/guia-nextjs-saas.md) | Build a multi-tenant SaaS app with Next.js |
| [Python CLI Tool](docs/guides/guia-cli-python.md) | Build a command-line tool with Python (Click/Typer) |
| [Data Pipeline](docs/guides/guia-data-pipeline.md) | Build an ETL data pipeline with validation |
| [Legacy Refactoring](docs/guides/guia-refactoring-legacy.md) | Modernize legacy code without breaking functionality |
| [AI Agent (Google ADK)](docs/guides/guia-ai-agent-adk.md) | Build a conversational AI agent with Google ADK |
| [Accounting Audit](docs/guides/guia-auditoria-contable.md) | Bank reconciliation — CTO v11.0 flow |
| [Personnel Selection](docs/guides/guia-seleccion-personal.md) | Resume screening with LLM + compliance |
| [Antigravity Lite](docs/guides/guia-batuta-antigravity.md) | Antigravity setup and workflow guide |
| [SDK Deployment](docs/guides/guia-sdk-deployment.md) | Deploy agents via Claude Agent SDK (Python + TypeScript) |

## Academia (Training Manual)

Complete training course for Batuta Dots — from zero to autonomous usage. 53 lessons across 8 modules, 21 real-world use cases across 10 industries.

| Module | Content | Lessons |
|--------|---------|---------|
| [00 — Welcome](academia/00-bienvenida/) | What is Batuta, setup, course map | 3 |
| [01 — Level Zero](academia/01-nivel-cero/) | First project, commands, SDD pipeline, gates | 4 |
| [02 — Level One](academia/02-nivel-uno/) | Skills catalog, agents, CTO layer, Scope Rule | 5 |
| [03 — Level Two](academia/03-nivel-dos/) | Debugging, validation, teams, compliance, hooks | 5 |
| [04 — Level Three](academia/04-nivel-tres/) | Extending ecosystem, templates, infra, recursion, multi-platform | 5 |
| [05 — Use Cases](academia/05-casos-de-uso/) | Real-world cases by industry | 21 |
| [06 — Reference](academia/06-referencia/) | Commands, skills, glossary, troubleshooting | 5 |
| [07 — Verification](academia/07-verificacion/) | Quizzes per level + graduation checklist | 5 |

**Industries covered**: Web development, Operations, Maintenance, Production, Supply chain, Logistics, Marketing, Finance, HR, Students.

→ [Start the course](academia/README.md)

---

## Architecture & Design

| Document | Description |
|----------|-------------|
| [Architecture Diagrams](docs/architecture/arquitectura-diagrama.md) | 15+ Mermaid diagrams (SDD, hooks, pyramid, contracts, security, etc.) |
| [Non-Technical Architecture](docs/architecture/arquitectura-para-no-tecnicos.md) | Restaurant analogy for non-developers |

---

## Contributing

### Adding a New Skill

1. Run `/create skill <name>` — the ecosystem-creator guides you through frontmatter (scope, auto_invoke, allowed-tools)
2. Or manually create `BatutaClaude/skills/<name>/SKILL.md` with complete frontmatter
3. Run `./infra/setup.sh --all`

### Adding a New Scope Agent

1. Create `BatutaClaude/agents/<scope>-agent.md` with native frontmatter (`name`, `description`, `skills`, `memory`)
2. Update SKILL.md frontmatters to reference the new scope
3. Run `./infra/setup.sh --all`

### Adding a New Domain Agent

1. Create `BatutaClaude/agents/<domain>-agent.md` with frontmatter including `sdk:` block (model, max_tokens, allowed_tools, setting_sources, defer_loading)
2. Add provisioning rule to `BatutaClaude/skills/sdd-init/assets/skill-provisions.yaml` under `agent_rules` (detection patterns + target agent)
3. If the agent should be provisioned to all projects, add it to `always_agents` instead
4. Run `./infra/setup.sh --all`

---

## Credits

Inspired by [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) by [Gentleman Programming](https://github.com/Gentleman-Programming). Batuta adapts the dotfiles concept for multi-project software factories with a CTO/Mentor personality, Spec-Driven Development, the Scope Rule, scope agents with auto-discovered skills, skill gap auto-detection, and the O.R.T.A. framework.

---

## License

[MIT](LICENSE)
