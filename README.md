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
- **Lazy skill loading** — Claude reads ~195 lines at startup, skills load on demand.
- **Mix-of-Experts routing** — principal agent delegates to specialized scope agents.
- **Execution Gate** — mandatory pre-validation before any code change.
- **Skill-Sync** — routing tables auto-generated from skill frontmatters.
- **O.R.T.A. framework** (Observability, Repeatability, Traceability, Auto-supervision).

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
│   │   ├── infra-agent.md             # Infrastructure specialist (3 skills)
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
│       └── skill-sync/               # Automatic routing table generation
│           ├── SKILL.md
│           └── assets/sync.sh
├── guides/                            # Step-by-step guides (Spanish)
│   ├── guia-batuta-app.md             # Dashboard app — full lifecycle guide
│   ├── guia-temporal-io-app.md        # Temporal.io workflows — full lifecycle guide
│   ├── guia-langchain-gmail-agent.md  # LangChain + Gmail agent — full lifecycle guide
│   ├── arquitectura-diagrama.md       # Mermaid architecture diagrams (9 diagrams)
│   └── arquitectura-para-no-tecnicos.md  # Non-technical architecture guide (restaurant analogy)
├── CHANGELOG-refactor.md              # Refactoring trace document (v1-v5)
└── skills/                            # Repository-level scripts
    ├── setup.sh                       # Claude Code setup (primary)
    ├── replicate-platform.sh          # Multi-platform replication (future)
    └── setup_test.sh                  # Verification tests (23 tests)
```

---

## How It Works

1. **CLAUDE.md** is the single entry point. It acts as a pure router using Mix-of-Experts: it classifies each request's scope and delegates to specialized scope agents.
2. **setup.sh --all** syncs skills and agents, runs skill-sync to regenerate routing tables, then copies the updated CLAUDE.md to root.
3. **Claude Code** reads CLAUDE.md at conversation start (~195 lines), then uses 3-level lazy loading: principal agent → scope agent → skill.

```
CLAUDE.md (router — ~195 lines)
    │
    ├──> Execution Gate (validate → classify → route → log)
    │
    ├──> pipeline-agent ──> sdd-init...sdd-archive (9 skills)
    ├──> infra-agent ──────> scope-rule, ecosystem-creator, skill-sync
    └──> observability-agent ──> prompt-tracker
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
| `infra-agent` | File organization, ecosystem | scope-rule, ecosystem-creator, skill-sync |
| `observability-agent` | Quality tracking | prompt-tracker |

This keeps the principal agent lightweight (~195 lines) and each scope agent focused on its domain.

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
| 1 | CLAUDE.md (router) | ~195 |
| 2 | Scope agent | ~80-120 |
| 3 | Individual skill | ~200-500 |

Only the needed level loads. A simple question never reaches level 3.

### Prompt Satisfaction Tracking (O.R.T.A.)

Every significant interaction is logged in `.batuta/prompt-log.jsonl`. Five event types: `prompt`, `gate`, `correction`, `follow-up`, `closed`. Over time, `/batuta:analyze-prompts` computes metrics and generates actionable recommendations.

### Session Continuity

At conversation start, Claude reads `.batuta/session.md` to restore context. At the end of significant work, it updates the file so the next conversation picks up where this one left off.

### Ecosystem Auto-Update

When new skills are created in a project, Claude proposes propagating them back to batuta-dots so other projects benefit.

---

## Available Skills (13 + 3 scope agents)

| Skill | Scope | Description |
|-------|-------|-------------|
| `ecosystem-creator` | infra | Create new skills, agents, sub-agents, and workflows |
| `scope-rule` | infra | Enforce scope-based file organization |
| `skill-sync` | infra | Auto-generate routing tables from SKILL.md frontmatters |
| `sdd-init` through `sdd-archive` | pipeline | 9-phase SDD pipeline |
| `prompt-tracker` | observability | Track prompt satisfaction, gate compliance, and analyze patterns |

Plus 17 planned project skills. See CLAUDE.md for the full roadmap.

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
| `--verify` | Verify setup (23 checks) |

The `--all` flag: syncs skills and agents → runs skill-sync to regenerate routing tables → copies updated CLAUDE.md to root.

---

## Guides

All guides use a sequential step-by-step format covering the full lifecycle: ecosystem installation → SDD pipeline → build → test → deploy → production → archive.

| Guide | Description |
|-------|-------------|
| [Dashboard App](guides/guia-batuta-app.md) | Build a monitoring dashboard (n8n + Google AI tokens) — 15 steps |
| [Temporal.io Workers](guides/guia-temporal-io-app.md) | Build workflow orchestration with Temporal.io — 14 steps |
| [LangChain + Gmail Agent](guides/guia-langchain-gmail-agent.md) | Build an AI email classifier agent — 15 steps |
| [Architecture Diagrams](guides/arquitectura-diagrama.md) | 9 Mermaid diagrams (MoE routing, SDD, lazy loading, etc.) |
| [Non-Technical Architecture](guides/arquitectura-para-no-tecnicos.md) | Restaurant analogy for non-developers |

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
