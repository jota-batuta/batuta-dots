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
- **Lazy skill loading** — Claude reads ~220 lines at startup, skills load on demand.
- **Scope agents** — 3 agents with skills auto-discovered by description field.
- **Execution Gate** — mandatory pre-validation before any code change.
- **Skill-Sync** — asset inventory auto-generated from skill frontmatters via sync.sh.
- **Native hooks** — SessionStart, Stop.
- **O.R.T.A. framework** (Observability, Repeatability, Traceability, Auto-supervision).
- **Agent Teams** — orchestrate multiple Claude sessions in parallel for complex tasks.
- **Contract-First Protocol** — pre-spawn contracts define input/output/file-ownership per teammate.
- **AI-First Security** — dedicated security-audit skill integrated in design and verify phases.
- **Team Templates + Playbook** — pre-built team compositions per stack (Next.js, FastAPI, n8n, AI agent, data pipeline, refactoring).
- **CTO Strategy Layer** — 3 strategic gates (G0.5, G1, G2) + 6 specialist skills (process-analyst, compliance, data-pipeline, LLM-pipeline, worker-scaffold, recursion-designer) integrated into the SDD pipeline.
- **Batuta Bootstrap** — "The Rule" enforcement via SessionStart hook: if a skill applies, you MUST use it.
- **MCP Discovery** — active web search for beneficial MCP servers during explore phase.
- **Superpowers-Style Review** — 2-stage review loop (spec + quality) for complex tasks.
- **Trigger-Only Descriptions** — all 22 skill descriptions follow "Use when..." convention for reliable activation.

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

# Antigravity (Gemini CLI) only
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
| **Claude Code** | `~/.claude/` | 22 skills, 3 agents, 11 commands, 2 hooks, settings.json, output-styles |
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
│   ├── agents/                        # Scope agents (skills auto-discovered by description)
│   │   ├── pipeline-agent.md          # SDD Pipeline specialist (9 skills)
│   │   ├── infra-agent.md             # Infrastructure specialist (3 skills)
│   │   └── observability-agent.md     # O.R.T.A. engine (no active skills)
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
├── BatutaAntigravity/                 # Antigravity IDE configuration (Lite)
│   ├── GEMINI.md                      # Full CTO brain adapted for Antigravity
│   ├── setup-antigravity.sh           # Setup script (--global / --workspace / --all)
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
│   ├── guides/                        # Step-by-step execution guides (12 guides, Spanish)
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
│   ├── templates/                     # Pre-built team compositions per stack
│   │   ├── nextjs-saas.md             # Next.js SaaS team template
│   │   ├── fastapi-service.md         # FastAPI microservice team template
│   │   ├── n8n-automation.md          # n8n automation team template
│   │   ├── ai-agent.md               # AI agent team template
│   │   ├── data-pipeline.md          # Data pipeline team template
│   │   └── refactoring.md            # Legacy refactoring team template
│   └── playbook.md                    # Team patterns and best practices
├── CHANGELOG-refactor.md              # Refactoring trace document (v1-v11.0)
├── academia/                          # Training course (8 modules, 53 lessons)
└── infra/                             # Infrastructure & setup scripts
    ├── setup.sh                       # Claude Code setup (primary)
    ├── sync.sh                        # Bidirectional skill sync (hub ↔ projects)
    ├── replicate-platform.sh          # Multi-platform replication
    ├── setup_test.sh                  # Verification tests (51 tests)
    └── hooks/                         # O.R.T.A. hooks (native Claude Code hooks)
        ├── session-start.sh           # SessionStart — inject session.md as context
        └── session-save.sh            # Stop — log session end event
```

---

## How It Works

1. **CLAUDE.md** is the single entry point. It defines personality, rules, Scope Rule, Execution Gate, and SDD commands. Skills are auto-discovered by Claude Code based on their `description` field.
2. **setup.sh --all** syncs skills and agents, installs hooks + permissions to `~/.claude/settings.json`, then copies the updated CLAUDE.md to root.
3. **Claude Code** reads CLAUDE.md at conversation start (~220 lines), then uses 3-level lazy loading: principal agent → scope agent → skill.

```
CLAUDE.md (personality + rules — ~220 lines)
    │
    ├──> Hooks (settings.json)
    │     ├── SessionStart → inject session.md as context
    │     └── Stop → update session.md + log session end
    │
    ├──> Skills (auto-discovered by Claude Code via description)
    │     ├── pipeline: sdd-init...sdd-archive (9 skills)
    │     ├── infra: scope-rule, ecosystem-creator, team-orchestrator, security-audit
    │     └── observability: (no active skills)
    │
    ├──> Scope Agents (skills auto-discovered by description field)
    │     ├── pipeline-agent (dependency graph, orchestrator rules)
    │     ├── infra-agent (Skill Gap Detection, Ecosystem Auto-Update)
    │     └── observability-agent (session lifecycle)
    │
    └──> Agent Team (Level 3) ──> spawn teammates from scope agents
```

### Multi-Platform: Claude Code + Antigravity

Batuta supports parallel execution across platforms — Claude Code (Full) for complex projects and Google Antigravity IDE (Lite) for quick wins:

| Aspect | Claude Code (Full) | Antigravity (Lite) |
|--------|-------------------|-------------------|
| Brain | Full CTO via CLAUDE.md | Full CTO via GEMINI.md |
| Commands | Slash commands (native) | Workflows (saved prompts) |
| Hooks | Native (SessionStart, Stop) | Behavioral rules |
| Skills | `~/.claude/skills/` | `.agent/skills/` or `~/.gemini/antigravity/skills/` |
| Multi-agent | Agent Teams | Manager View |
| Cost | Claude Max x20 ($200/mo) | Free (preview) |

Skills are platform-agnostic (SKILL.md open standard). The `platforms` field in frontmatter controls which platforms receive each skill during sync. See the [Antigravity Guide](docs/guides/guia-batuta-antigravity.md).

```bash
# Setup Antigravity in a project
bash BatutaAntigravity/setup-antigravity.sh --workspace

# Sync skills filtered by platforms tag
bash infra/sync.sh --to-antigravity

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

Users describe what they need in natural language. The agent classifies intent and routes automatically:

| Intent | Route |
|--------|-------|
| Build / Feature / Problem | SDD Pipeline (auto-advance with checkpoints) |
| Quick fix / Bug | Direct fix (skip SDD, Execution Gate LIGHT) |
| Continue / Resume | Detect phase from artifacts, resume |
| Backtrack / Rethink | Classify target phase, update artifact, re-advance |
| Question / Explain | Answer directly |
| Explicit `/sdd-*` command | Manual override |

### Scope Agents

Three scope agents organize skills by domain. Skills are auto-discovered by Claude Code based on their `description` field:

| Scope Agent | Domain | Skills |
|-------------|--------|--------|
| `pipeline-agent` | Development lifecycle | 9 SDD skills (init through archive) |
| `infra-agent` | File organization, ecosystem, security | scope-rule, ecosystem-creator, team-orchestrator, security-audit |
| `observability-agent` | Session lifecycle | (no active skills) |

This keeps the principal agent lightweight (~220 lines) and each scope agent focused on its domain.

### Execution Gate

Before any code change, a mandatory pre-validation runs. Cannot be skipped.

| Mode | When | What it shows |
|------|------|---------------|
| LIGHT | Single-file edit, simple fix | "Modifying {file} at {location}. Proceed?" |
| FULL | New files, 2+ file changes, architecture | Location plan + impact + SDD/skill compliance |

### Skill-Sync

The asset inventory is auto-generated from SKILL.md frontmatters. Adding a skill = create SKILL.md with proper frontmatter → run sync.sh → inventory validated automatically.

### Skill Gap Detection

Before writing code with any technology, Claude checks if an active skill exists. If not, it stops and offers to research via Context7 and create the skill before proceeding.

### Lazy Loading (3 levels)

| Level | What loads | Lines |
|-------|-----------|-------|
| 1 | CLAUDE.md (router) | ~220 |
| 2 | Scope agent | ~80-120 |
| 3 | Individual skill | ~200-500 |

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

---

## Available Skills (22 + 3 scope agents)

| Skill | Scope | Description |
|-------|-------|-------------|
| `ecosystem-creator` | infra | Create new skills, agents, sub-agents, and workflows |
| `scope-rule` | infra | Enforce scope-based file organization |
| `team-orchestrator` | infra | Evaluate when to escalate to Agent Teams, spawn and coordinate |
| `security-audit` | infra, pipeline | AI-first security: OWASP + prompt injection + secrets scanning + dependency audit |
| `sdd-init` through `sdd-archive` | pipeline | 9-phase SDD pipeline |
| `process-analyst` | pipeline | Complex process analysis with 3+ case variants |
| `recursion-designer` | pipeline | External taxonomies, categories that change, learning systems |
| `compliance-colombia` | pipeline | Colombian data protection, tax retention, AI compliance |
| `data-pipeline-design` | pipeline | ETL, ERP integrations, data quality patterns |
| `llm-pipeline-design` | pipeline | LLM classifiers, prompt engineering, drift detection |
| `worker-scaffold` | pipeline | Temporal workers, Docker, Coolify deploy, monitoring |
| `fastapi-crud` | pipeline | FastAPI CRUD patterns and best practices |
| `jwt-auth` | pipeline | JWT authentication implementation patterns |
| `sqlalchemy-models` | pipeline | SQLAlchemy ORM model patterns |

---

## Commands

| Command | Description |
|---------|-------------|
| `/batuta-init [name]` | Import Batuta ecosystem into a project |
| `/batuta-update` | Update ecosystem from latest batuta-dots |
| `/sdd-init` | Initialize orchestration context |
| `/sdd-explore <topic>` | Explore idea and constraints |
| `/sdd-new <change-name>` | Start change proposal flow |
| `/sdd-continue [change-name]` | Run next dependency-ready phase |
| `/sdd-ff [change-name]` | Fast-forward: propose → spec → design → tasks |
| `/sdd-apply [change-name]` | Implement tasks in batches |
| `/sdd-verify [change-name]` | Validate implementation |
| `/sdd-archive [change-name]` | Close and persist final state |
| `/create <type> <name>` | Create a new skill, sub-agent, or workflow |

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
| `--verify` | Verify setup (51 checks) |

The `--all` flag: syncs skills and agents → installs hooks + permissions → copies updated CLAUDE.md to root.

---

## Guides

Step-by-step execution guides (12 guides) covering the full lifecycle: ecosystem installation → SDD pipeline → build → test → deploy → production → archive.

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

---

## Credits

Inspired by [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) by [Gentleman Programming](https://github.com/Gentleman-Programming). Batuta adapts the dotfiles concept for multi-project software factories with a CTO/Mentor personality, Spec-Driven Development, the Scope Rule, scope agents with auto-discovered skills, skill gap auto-detection, and the O.R.T.A. framework.

---

## License

[MIT](LICENSE)
