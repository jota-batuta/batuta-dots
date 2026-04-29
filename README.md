# Batuta.Dots

**AI agent ecosystem for software factories — Claude Code first, replicable to any platform.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **Status (2026-04-16): v16 is the final feature release. This repository is now maintenance-only.**
>
> Successor: [`jota-batuta/batuta-agent-skills`](https://github.com/jota-batuta/batuta-agent-skills) — a minimal fork of [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) that layers 4 Batuta skills on top (research-first-dev, notion-kb-workflow, batuta-skill-authoring, batuta-agent-authoring) without custom hooks or persistent state.
>
> The successor was chosen after an end-to-end comparative experiment ([REPORT](../e2e-comparison/REPORT.md) if you have the sibling directory) showed `batuta-dots v16` costing 2–3× more per project than plain `agent-skills` with a broken memory subsystem (`CHECKPOINT.md` and `session.md` never updated). The fork path inherits a battle-tested engineering skill base, eliminates the hook breakage, and adds only the behaviors that actually differentiate Batuta workflows.
>
> **New projects: use the fork.** Existing projects on v16 will continue to work; no active development, only security and critical-bug fixes.

---

## What is Batuta?

Batuta is an AI agent ecosystem built on **contract-based delegation** for software development. The main agent acts as an **orchestrator** — it never writes code itself but contracts specialized agents via the Task tool. Each agent carries embedded domain expertise and loads skills on demand. The PRD is the single planning artifact. You describe your problem, and the right agent activates automatically. When you are ready to extend to other platforms, a replication script generates the equivalent for Gemini, Copilot, Codex, or OpenCode.

Inspired by [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots), adapted for:

- **Multi-project software factory**.
- **Scope Rule** that organizes files by who uses them, not by type.
- **2 modes (SPRINT/COMPLETO)** — fast-track for clear tasks, full pipeline for complex features.
- **5 contract-based agents** — pipeline, infra, backend, data, quality — each with embedded expertise, invoked as autonomous subprocesses via Task tool.
- **Main agent as orchestrator** — the main agent NEVER executes, only contracts agents.
- **PRD as single planning artifact** — one document consolidates all planning context.
- **43 skills (13 global, rest per-project)** — lazy-loaded on demand, provisioned per technology.
- **0-1 gates** — no mandatory gates in SPRINT mode, 1 approval gate in COMPLETO mode.
- **Research-First principle** — non-negotiable in both modes: understand before build.
- **Skill Gap Detection** with automatic research via Context7.
- **Native hooks** — SessionStart, Stop, SubagentStop.
- **Agent Teams** — orchestrate multiple Claude sessions in parallel for complex tasks.
- **Contract-First Protocol** — pre-spawn contracts define input/output/file-ownership per teammate.
- **AI-First Security** — dedicated security-audit skill integrated in design and verify phases.
- **Team Templates + Playbook** — pre-built team compositions per stack (Next.js, FastAPI, n8n, AI agent, data pipeline, refactoring).
- **Trigger-Only Descriptions** — all skill descriptions follow "Use when..." convention for reliable activation.
- **Checkpoint-based continuity** — structured checkpoints (WHERE/WHY/HOW) instead of verbose session files.

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
| **Claude Code** | `~/.claude/` | 43 skills, 5 agents, 13 commands, 3 hooks, settings.json, output-styles |
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
│   ├── CLAUDE.md                      # Orchestrator rules + delegation contracts
│   ├── VERSION                        # Ecosystem version (semver): 15.0.0
│   ├── settings.json                  # Permissions, output style
│   ├── mcp-servers.template.json      # MCP server template
│   ├── output-styles/batuta.md        # Custom output format
│   ├── commands/                      # Global slash commands (13)
│   │   ├── batuta-init.md             # /batuta-init — import ecosystem
│   │   ├── batuta-update.md           # /batuta-update — pull latest
│   ├── agents/                        # 5 contract-based agents
│   │   ├── pipeline-agent.md          # SDD Pipeline specialist (SPRINT/COMPLETO modes)
│   │   ├── infra-agent.md             # Infrastructure, ecosystem, security
│   │   ├── backend-agent.md           # Provisioned when backend frameworks detected
│   │   ├── quality-agent.md           # Always provisioned (AI Validation Pyramid)
│   │   └── data-agent.md              # Provisioned when data/AI frameworks detected
│   └── skills/                        # 43 skills (lazy-loaded, provisioned per-project)
│       ├── ecosystem-creator/         # Bootstrap skill
│       │   ├── SKILL.md
│       │   └── assets/                # Templates for skills, agents, workflows
│       ├── scope-rule/SKILL.md        # File organization rules
│       ├── sdd-init/SKILL.md          # SDD bootstrap
│       ├── sdd-explore/SKILL.md       # Research and investigation
│       ├── sdd-design/SKILL.md        # Architecture decisions
│       ├── sdd-apply/SKILL.md         # Implementation
│       ├── sdd-verify/SKILL.md        # AI Validation Pyramid
│       ├── team-orchestrator/SKILL.md # Agent Teams orchestration (when to escalate)
│       └── security-audit/SKILL.md    # AI-first security practices (OWASP + threats)
├── BatutaAntigravity/                 # Antigravity Lite (brainstorming & prototyping)
│   ├── GEMINI.md                      # Full CTO brain adapted for Antigravity
│   ├── setup-antigravity.sh           # Setup script (--global / --workspace / --all / --update)
│   ├── settings-template.json         # Recommended Antigravity config
│   └── workflows/                     # Saved prompts (SDD + session + sync)
│       ├── sdd-init.md ... sdd-verify.md   # SDD pipeline workflows
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
├── CHANGELOG-refactor.md              # Refactoring trace document (v1-v15)
├── academia/                          # Training course (8 modules, 53 lessons)
└── infra/                             # Infrastructure & setup scripts
    ├── setup.sh                       # Claude Code setup (primary)
    ├── sync.sh                        # Bidirectional skill sync (hub ↔ projects, --push for zero-friction)
    ├── replicate-platform.sh          # Multi-platform replication
    ├── setup_test.sh                  # Verification tests
    └── hooks/                         # Native Claude Code hooks
        ├── session-start.sh           # SessionStart — inject session.md + skill inventory
        ├── session-save.sh            # Stop — write checkpoint + update session.md
        └── subagent-save.sh           # SubagentStop — append sub-agent reports
```

---

## How It Works

Batuta operates as a **contract-based delegation** system:

1. **CLAUDE.md** is the **orchestrator** — the single entry point. It classifies user intent, enforces rules (Scope Rule, Research-First), and delegates to the right agent via Task tool. The main agent NEVER writes code itself.
2. **Agents** are **contracted specialists** — 5 agents (pipeline, infra, backend, data, quality), each carrying embedded domain expertise. They run as autonomous subprocesses via the Task tool.
3. **Skills** are loaded on demand when an agent needs specific patterns (e.g., SQLAlchemy models, React/Next.js conventions).
4. **PRD** is the single planning artifact — one document consolidates all context for execution.
5. **setup.sh --all** syncs skills and agents, installs hooks + permissions to `~/.claude/settings.json`, then copies the updated CLAUDE.md to root.

```
CLAUDE.md — THE ORCHESTRATOR (rules + delegation contracts)
    │
    ├──> Hooks (settings.json)
    │     ├── SessionStart → inject session.md + skill inventory
    │     ├── Stop → write checkpoint + update session.md
    │     └── SubagentStop → append sub-agent reports
    │
    ├──> Skills (43 total — auto-discovered by Claude Code via description)
    │     ├── 13 global skills (always provisioned)
    │     └── 30 per-project skills (provisioned by sdd-init based on tech detection)
    │
    ├──> Contract-Based Agents (invoked via Task tool, never inline)
    │     ├── pipeline-agent — SDD pipeline (SPRINT/COMPLETO modes)
    │     ├── infra-agent — Skill Gap Detection, Ecosystem, Security
    │     ├── backend-agent (fastapi|django|express|nestjs) — API, auth, DB
    │     ├── quality-agent (always provisioned) — testing, security, debugging
    │     └── data-agent (pandas|langchain|anthropic) — ETL, AI/ML, RAG
    │
    └──> Agent Team (Level 3) ──> spawn teammates from agents
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

Two modes that enforce "understand before build":

| Mode | When | Flow |
|------|------|------|
| **SPRINT** | Clear scope, <5 files, no architecture decisions | explore -> design -> apply -> verify |
| **COMPLETO** | Complex feature, 5+ files, architecture decisions | explore -> design -> (PRD approval) -> apply -> verify |

The pipeline-agent orchestrates both modes. The user interacts through **natural conversation** (auto-routing classifies intent), not slash commands. Commands remain as manual overrides. The PRD is the single planning artifact that consolidates all context.

### Auto-Routing (Intent-Driven Pipeline)

**Batuta detects your intent automatically — you don't need to type slash commands.** Just describe your problem or task in natural language. Slash commands exist as manual overrides when you want explicit control over a specific pipeline phase.

| Intent | What you say | Route |
|--------|-------------|-------|
| Build / Feature / Problem | "necesito un dashboard", "build a notification system" | SDD Pipeline (SPRINT or COMPLETO, auto-classified) |
| Quick fix / Bug | "el botón no funciona", "fix the null check" | SPRINT mode (fast-track) |
| Continue / Resume | "donde quedamos?", "continua con inventario" | Detect phase from artifacts, resume |
| Backtrack / Rethink | "esto no funciona como pensé", "cambio el requisito" | Classify target phase, update artifact |
| Question / Explain | "qué es SDD?", "how does auth work?" | Answer directly |
| Explicit `/sdd-*` command | `/sdd-explore`, `/sdd-apply` | Manual override (bypasses auto-routing) |

### SPRINT vs COMPLETO

Batuta automatically selects the right mode for your task:

| Scope | Mode | Steps | Gates |
|-------|------|-------|-------|
| **SPRINT** — clear scope, <5 files, no architecture decisions | SPRINT | explore -> design -> apply -> verify | 0 gates |
| **COMPLETO** — complex feature, 5+ files, architecture decisions | COMPLETO | explore -> design -> PRD -> apply -> verify | 1 gate (PRD approval) |

You don't choose — the agent classifies for you. If a SPRINT grows in scope (5+ files, architectural implications), the agent switches to COMPLETO and tells you why.

### Agents (5 Contract-Based Specialists)

Batuta's 5 agents are contracted specialists invoked by the main agent via the Task tool. The main agent NEVER executes code — it only contracts agents. Each agent carries embedded domain expertise and loads skills on demand.

| Agent | Provisioned When | Expertise |
|-------|-----------------|-----------|
| `pipeline-agent` | Always | SDD pipeline (SPRINT/COMPLETO), orchestration |
| `infra-agent` | Always | File organization, ecosystem, security, Skill Gap Detection |
| `backend-agent` | fastapi, django, express, nestjs detected | API design, auth flows, DB schema, middleware |
| `quality-agent` | Always | AI Validation Pyramid, testing strategy, security audits, debugging |
| `data-agent` | pandas, langchain, anthropic detected | ETL pipelines, AI/ML integration, RAG patterns |

Agents carry embedded expertise + skill pointers and include an `sdk:` block for programmatic deployment via Claude Agent SDK. This keeps the orchestrator lightweight and each agent focused on its domain.

**Agent Lifecycle** — agents follow the same sync model as skills:

1. **Create**: `ecosystem-creator` generates the agent in `BatutaClaude/agents/` (hub)
2. **Classify**: `ecosystem-lifecycle` determines if the agent is generic (hub) or project-specific (local)
3. **Sync to global**: `setup.sh --sync` copies hub agents to `~/.claude/agents/`
4. **Provision to projects**: `sdd-init` copies relevant agents from global to `.claude/agents/` based on detected technologies

### Research-First Principle

Before any code change, the agent MUST understand the problem first. This applies in BOTH SPRINT and COMPLETO modes — it is non-negotiable. The main agent contracts agents to research and design before contracting for implementation.

### Skill Gap Detection

Before writing code with any technology, Claude checks if an active skill exists. If not, it stops and offers to research via Context7 and create the skill before proceeding.

### Lazy Loading (3 levels)

| Level | Role | What loads |
|-------|------|-----------|
| 1 | Orchestrator | CLAUDE.md (rules + delegation contracts) |
| 2 | Agent | Contracted agent (pipeline, infra, backend, data, quality) |
| 3 | Skill | Individual skill loaded by the agent on demand |

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

### Project Skill Provisioning & Agent Provisioning

During `/sdd-init`, only relevant skills and agents are copied from the global library to your project. The agent sees only what it needs, keeping context clean as the ecosystem grows.

The `skill-provisions.yaml` manifest defines:

- **`always`**: skills provisioned to every project (13 global skills)
- **`always_agents`**: agents provisioned to every project (currently: `quality-agent`)
- **`agent_rules`**: conditional provisioning based on detected dependencies (e.g., `backend-agent` when fastapi/django/express detected, `data-agent` when pandas/langchain/anthropic detected)

### Rules & Gates

All mandatory behaviors (scope enforcement, skill invocation, research-first, delegation) are defined as hard Rules with MUST/NEVER/ALWAYS keywords. In SPRINT mode there are 0 mandatory gates. In COMPLETO mode there is 1 gate: PRD approval before implementation begins.

### Session Budget

Session.md is capped at 80 lines as a briefing document answering WHERE/WHY/HOW — not a project README. Checkpoints follow a structured template (what I'm doing, state, attempts, what's left, gotchas).

---

## Available Skills (43 skills + 5 agents)

43 skills organized by scope. 13 global skills are always provisioned; the rest are provisioned per-project by `sdd-init` based on detected technologies.

| Skill | Scope | Description |
|-------|-------|-------------|
| `ecosystem-creator` | infra | Create new skills, agents, sub-agents, and workflows |
| `scope-rule` | infra | Enforce scope-based file organization |
| `team-orchestrator` | infra | Evaluate when to escalate to Agent Teams, spawn and coordinate |
| `ecosystem-lifecycle` | infra | Classify, self-heal, provision skills lifecycle |
| `skill-eval` | infra | Evaluate skill quality: Eval (behavioral test), Improve (propose edits), Benchmark (health report) |
| `claude-agent-sdk` | infra | Claude Agent SDK patterns: setting_sources, defer_loading, hooks mapping, CI/CD deployment |
| `security-audit` | infra, pipeline | AI-first security: OWASP + prompt injection + secrets scanning + dependency audit |
| `sdd-init` | pipeline | Bootstrap SDD in a project |
| `sdd-explore` | pipeline | Research and investigation |
| `sdd-design` | pipeline | Architecture decisions and technical design |
| `sdd-apply` | pipeline | Implementation following specs and design |
| `sdd-verify` | pipeline | AI Validation Pyramid verification |
| `prd-generator` | pipeline | Consolidate planning into PRD artifact |
| `process-analyst` | pipeline | Complex process analysis with 3+ case variants |
| `recursion-designer` | pipeline | External taxonomies, categories that change, learning systems |
| `compliance-colombia` | pipeline | Colombian data protection, tax retention, AI compliance |
| `data-pipeline-design` | pipeline | ETL, ERP integrations, data quality patterns |
| `llm-pipeline-design` | pipeline | LLM classifiers, prompt engineering, drift detection |
| `worker-scaffold` | pipeline | Temporal workers, Docker, Coolify deploy, monitoring |
| `accessibility-audit` | pipeline | Accessibility audit: WCAG compliance, screen reader testing |
| `performance-testing` | pipeline | Performance testing: load testing, profiling, bottleneck analysis |
| `technical-writer` | pipeline | Technical writing: API docs, user guides, architecture decision records |
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
| `observability` | pipeline | Monitoring, logging, tracing, alerting patterns |

---

## Commands

All commands are **manual overrides**. For normal work, just describe your task — auto-routing handles the rest.

| Command | When to use |
|---------|-------------|
| `/batuta-init [name]` | First time: import Batuta into a new project |
| `/batuta-update` | Pull latest skills, agents, and CLAUDE.md from the hub |
| `/sdd-init` | Initialize SDD context (`openspec/`) in a project |
| `/sdd-explore <topic>` | Manually trigger exploration of a specific topic |
| `/sdd-new <change-name>` | Start from scratch: explore + design in one step |
| `/sdd-continue [change-name]` | Resume an in-progress change from where it left off |
| `/sdd-ff [change-name]` | **Fast-Forward**: after exploring, run design in one shot |
| `/sdd-apply [change-name]` | Implement the approved design/PRD |
| `/sdd-verify [change-name]` | Run the AI Validation Pyramid against the implementation |
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
| `--verify` | Verify setup |

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

Inspired by [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) by [Gentleman Programming](https://github.com/Gentleman-Programming). Batuta adapts the dotfiles concept for multi-project software factories with contract-based agent delegation, Spec-Driven Development (SPRINT/COMPLETO modes), the Scope Rule, and skill gap auto-detection.

---

## License

[MIT](LICENSE)
