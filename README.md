# Batuta.Dots

**AI agent ecosystem for software factories — Claude Code first, replicable to any platform.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## What is Batuta?

Batuta is an AI agent ecosystem that gives Claude Code a complete set of skills, workflows, and development methodology. You write your conventions once in `CLAUDE.md`, and skills are lazy-loaded on demand based on context. When you are ready to extend to other platforms, a replication script generates the equivalent for Gemini, Copilot, Codex, or OpenCode.

Inspired by [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots), adapted for:

- **Multi-project software factory**.
- **CTO/Mentor personality** that educates and documents for non-technical stakeholders.
- **Scope Rule** that organizes files by who uses them, not by type.
- **Skill Gap Detection** with automatic research via Context7.
- **Lazy skill loading** — Claude reads ~186 lines at startup, skills load on demand.
- **Mix-of-Experts routing** — principal agent delegates to specialized scope agents.
- **Execution Gate** — mandatory pre-validation before any code change.
- **Skill-Sync** — routing tables auto-generated from skill frontmatters.
- **O.R.T.A. framework** (Observability, Repeatability, Traceability, Auto-supervision).
- **Agent Teams** — orchestrate multiple Claude sessions in parallel for complex tasks.
- **Contract-First Protocol** — pre-spawn contracts define input/output/file-ownership per teammate.
- **AI-First Security** — dedicated security-audit skill integrated in design and verify phases.
- **Team Templates + Playbook** — pre-built team compositions per stack (Next.js, FastAPI, n8n, AI agent, data pipeline, refactoring).

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/jota-batuta/batuta-dots.git
cd batuta-dots

# 2. Full setup: sync skills + agents + skill-sync + copy CLAUDE.md
./skills/setup.sh --all

# 3. Verify everything is set up correctly
./skills/setup.sh --verify
```

Or run `./skills/setup.sh` with no arguments for an interactive menu.

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
│   │   ├── batuta-analyze-prompts.md  # /batuta:analyze-prompts — satisfaction analysis
│   │   └── batuta-sync-skills.md      # /batuta:sync-skills — regenerate routing tables
│   ├── agents/                        # Scope agents (Mix-of-Experts routing)
│   │   ├── pipeline-agent.md          # SDD Pipeline specialist (9 skills)
│   │   ├── infra-agent.md             # Infrastructure specialist (5 skills)
│   │   └── observability-agent.md     # O.R.T.A. engine (1 skill)
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
│       ├── prompt-tracker/            # Prompt satisfaction tracking (O.R.T.A.)
│       │   ├── SKILL.md
│       │   └── assets/session-template.md
│       ├── team-orchestrator/SKILL.md # Agent Teams orchestration (when to escalate)
│       ├── security-audit/SKILL.md   # AI-first security practices (OWASP + threats)
│       └── skill-sync/               # Automatic routing table generation
│           ├── SKILL.md
│           └── assets/
│               ├── sync.sh
│               └── sync_test.sh
├── docs/                              # All documentation
│   ├── architecture/                  # Architecture and design
│   │   ├── arquitectura-diagrama.md   # Mermaid architecture diagrams (9+ diagrams)
│   │   └── arquitectura-para-no-tecnicos.md  # Non-technical guide (restaurant analogy)
│   ├── guides/                        # Step-by-step execution guides (10 guides, Spanish)
│   │   ├── guia-batuta-app.md         # Dashboard app — full lifecycle guide
│   │   ├── guia-temporal-io-app.md    # Temporal.io workflows — full lifecycle guide
│   │   ├── guia-langchain-gmail-agent.md  # LangChain + Gmail agent guide
│   │   ├── guia-n8n-automation.md     # n8n workflow automation guide
│   │   ├── guia-fastapi-service.md    # FastAPI microservice guide
│   │   ├── guia-nextjs-saas.md        # Next.js SaaS app guide
│   │   ├── guia-cli-python.md         # Python CLI tool guide
│   │   ├── guia-data-pipeline.md      # Data pipeline (ETL) guide
│   │   ├── guia-refactoring-legacy.md # Legacy refactoring guide
│   │   └── guia-ai-agent-adk.md       # AI agent (Google ADK) guide
│   └── qa/                            # Quality assurance reports
│       ├── BatutaTestCalidadV5-V7.md  # Quality test reports (v5-v7)
│       └── LogCorrecciones-V5-V7.md   # Corrections logs (v5-v7)
├── teams/                             # Agent Team assets
│   ├── templates/                     # Pre-built team compositions per stack
│   │   ├── nextjs-saas.md             # Next.js SaaS team template
│   │   ├── fastapi-service.md         # FastAPI microservice team template
│   │   ├── n8n-automation.md          # n8n automation team template
│   │   ├── ai-agent.md               # AI agent team template
│   │   ├── data-pipeline.md          # Data pipeline team template
│   │   └── refactoring.md            # Legacy refactoring team template
│   └── playbook.md                    # Team patterns and best practices
├── CHANGELOG-refactor.md              # Refactoring trace document (v1-v9)
└── skills/                            # Repository-level scripts
    ├── setup.sh                       # Claude Code setup (primary)
    ├── replicate-platform.sh          # Multi-platform replication (future)
    ├── setup_test.sh                  # Verification tests (51 tests)
    └── hooks/                         # O.R.T.A. hooks for Agent Teams
        ├── session-start.sh           # SessionStart — inject session.md as context
        ├── session-save.sh            # Stop — log session end event
        ├── orta-teammate-idle.sh      # TeammateIdle — log teammate completion
        └── orta-task-gate.sh          # TaskCompleted — quality gate
```

---

## How It Works

1. **CLAUDE.md** is the single entry point. It acts as a pure router using Mix-of-Experts: it classifies each request's scope and delegates to specialized scope agents.
2. **setup.sh --all** syncs skills and agents, runs skill-sync to regenerate routing tables, then copies the updated CLAUDE.md to root.
3. **Claude Code** reads CLAUDE.md at conversation start (~186 lines), then uses 3-level lazy loading: principal agent → scope agent → skill.

```
CLAUDE.md (router — ~186 lines)
    │
    ├──> Execution Gate (validate → classify → route → log)
    │
    ├──> pipeline-agent ──> sdd-init...sdd-archive (9 skills)
    ├──> infra-agent ──────> scope-rule, ecosystem-creator, skill-sync, team-orchestrator, security-audit
    ├──> observability-agent ──> prompt-tracker
    │
    └──> Agent Team (Level 3) ──> spawn teammates from scope agents
              │                     with shared task list + O.R.T.A. hooks
              ├── TeammateIdle hook → centralized logging
              └── TaskCompleted hook → quality gate
```

Need other platforms later?
```bash
./skills/replicate-platform.sh --all   # Generates GEMINI.md, CODEX.md, copilot-instructions.md
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

A 9-phase pipeline that enforces "understand before build":

```
init -> explore -> propose -> spec -> design -> tasks -> apply -> verify -> archive
```

Each phase is a dedicated sub-agent skill. The pipeline-agent orchestrates, delegates all heavy work, and only tracks state and user decisions.

### Mix-of-Experts

The principal agent acts as a pure router. It classifies the scope of each request and delegates to specialized scope agents:

| Scope Agent | Domain | Skills |
|-------------|--------|--------|
| `pipeline-agent` | Development lifecycle | 9 SDD skills (init through archive) |
| `infra-agent` | File organization, ecosystem, security | scope-rule, ecosystem-creator, skill-sync, team-orchestrator, security-audit |
| `observability-agent` | Quality tracking | prompt-tracker |

This keeps the principal agent lightweight (~186 lines) and each scope agent focused on its domain.

### Execution Gate

Before any code change, a mandatory pre-validation runs. Cannot be skipped.

| Mode | When | What it shows |
|------|------|---------------|
| LIGHT | Single-file edit, simple fix | "Modifying {file} at {location}. Proceed?" |
| FULL | New files, 2+ file changes, architecture | Location plan + impact + SDD/skill compliance |

### Skill-Sync

Routing tables in CLAUDE.md and scope agent files are auto-generated from SKILL.md frontmatters. Adding a skill = create SKILL.md with proper frontmatter → run sync.sh → routing tables update automatically. No manual table editing.

### Skill Gap Detection

Before writing code with any technology, Claude checks if an active skill exists. If not, it stops and offers to research via Context7 and create the skill before proceeding.

### Lazy Loading (3 levels)

| Level | What loads | Lines |
|-------|-----------|-------|
| 1 | CLAUDE.md (router) | ~186 |
| 2 | Scope agent | ~80-120 |
| 3 | Individual skill | ~200-500 |

Only the needed level loads. A simple question never reaches level 3.

### Prompt Satisfaction Tracking (O.R.T.A.)

Every significant interaction is logged in `.batuta/prompt-log.jsonl`. Six event types: `prompt`, `gate`, `correction`, `follow-up`, `closed`, `team`. Over time, `/batuta:analyze-prompts` computes metrics and generates actionable recommendations.

### Session Continuity

At conversation start, Claude reads `.batuta/session.md` to restore context. At the end of significant work, it updates the file so the next conversation picks up where this one left off.

### Agent Teams (3-Level Execution)

Batuta supports three execution levels. The system automatically evaluates which level to use:

| Level | Mechanism | When |
|-------|-----------|------|
| Solo session | Direct execution | 1-file edit, bug fix, simple question |
| Subagent (Task tool) | Fire-and-forget delegation | Research, verify, single SDD phase |
| Agent Team | Multiple independent Claude sessions | Multi-module feature, full SDD pipeline, competing hypotheses |

Agent Teams spawn real Claude Code sessions that work in parallel with a shared task list and bidirectional messaging. O.R.T.A. hooks (`TeammateIdle`, `TaskCompleted`) ensure centralized logging and quality gates.

### Ecosystem Auto-Update

When new skills are created in a project, Claude proposes propagating them back to batuta-dots so other projects benefit.

---

## Available Skills (15 + 3 scope agents)

| Skill | Scope | Description |
|-------|-------|-------------|
| `ecosystem-creator` | infra | Create new skills, agents, sub-agents, and workflows |
| `scope-rule` | infra | Enforce scope-based file organization |
| `skill-sync` | infra | Auto-generate routing tables from SKILL.md frontmatters |
| `team-orchestrator` | infra | Evaluate when to escalate to Agent Teams, spawn and coordinate |
| `security-audit` | infra, pipeline | AI-first security: OWASP + prompt injection + secrets scanning + dependency audit |
| `sdd-init` through `sdd-archive` | pipeline | 9-phase SDD pipeline |
| `prompt-tracker` | observability | Track prompt satisfaction, gate compliance, and analyze patterns |

---

## Commands

| Command | Scope Agent | Description |
|---------|-------------|-------------|
| `/batuta-init [name]` | — | Import Batuta ecosystem into a project |
| `/batuta-update` | — | Update ecosystem from latest batuta-dots |
| `/sdd:init` | pipeline | Initialize orchestration context |
| `/sdd:explore <topic>` | pipeline | Explore idea and constraints |
| `/sdd:new <change-name>` | pipeline | Start change proposal flow |
| `/sdd:continue [change-name]` | pipeline | Run next dependency-ready phase |
| `/sdd:apply [change-name]` | pipeline + infra | Implement tasks in batches |
| `/sdd:verify [change-name]` | pipeline | Validate implementation |
| `/sdd:archive [change-name]` | pipeline | Close and persist final state |
| `/create:skill <name>` | infra | Create a new skill |
| `/create:sub-agent <name>` | infra | Create a new sub-agent |
| `/create:workflow <name>` | infra | Create a new workflow command |
| `/batuta:analyze-prompts` | observability | Analyze satisfaction log and generate recommendations |
| `/batuta:sync-skills` | infra | Regenerate routing tables from skill frontmatters |

---

## setup.sh Reference

| Flag | Action |
|------|--------|
| `--claude` | Copy CLAUDE.md to project root |
| `--sync` | Sync skills + agents + commands to ~/.claude/ |
| `--all` | Full setup: sync + skill-sync + copy (recommended) |
| `--verify` | Verify setup (51 checks) |

The `--all` flag: syncs skills and agents → runs skill-sync to regenerate routing tables → copies updated CLAUDE.md to root.

---

## Guides

Step-by-step execution guides covering the full lifecycle: ecosystem installation → SDD pipeline → build → test → deploy → production → archive.

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

## Architecture & Design

| Document | Description |
|----------|-------------|
| [Architecture Diagrams](docs/architecture/arquitectura-diagrama.md) | 15+ Mermaid diagrams (MoE, SDD, hooks, pyramid, contracts, security, etc.) |
| [Non-Technical Architecture](docs/architecture/arquitectura-para-no-tecnicos.md) | Restaurant analogy for non-developers |

---

## Contributing

### Adding a New Skill

1. Run `/create:skill <name>` — the ecosystem-creator guides you through frontmatter (scope, auto_invoke, allowed-tools)
2. Or manually create `BatutaClaude/skills/<name>/SKILL.md` with complete frontmatter
3. Run `bash BatutaClaude/skills/skill-sync/assets/sync.sh` to update routing tables
4. Run `./skills/setup.sh --all`

### Adding a New Scope Agent

1. Create `BatutaClaude/agents/<scope>-agent.md` with `<!-- AUTO-GENERATED by skill-sync -->` delimiters
2. Update SKILL.md frontmatters to reference the new scope
3. Run skill-sync to populate the agent's skill table

---

## Credits

Inspired by [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) by [Gentleman Programming](https://github.com/Gentleman-Programming). Batuta adapts the dotfiles concept for multi-project software factories with a CTO/Mentor personality, Spec-Driven Development, the Scope Rule, Mix-of-Experts routing, skill gap auto-detection, and the O.R.T.A. framework.

---

## License

[MIT](LICENSE)
