# Batuta.Dots

**AI agent ecosystem for software factories — Claude Code first, replicable to any platform.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## What is Batuta?

Batuta is an AI agent ecosystem that gives Claude Code a complete set of skills, workflows, and development methodology. You write your conventions once in `AGENTS.md`, and Batuta generates `CLAUDE.md` with personality and auto-loadable skills. When you are ready to extend to other platforms, a replication script generates the equivalent for Gemini, Copilot, Codex, or OpenCode.

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/jota-batuta/batuta-dots.git
cd batuta-dots

# 2. Generate CLAUDE.md and sync skills
./skills/setup.sh --all

# 3. Verify everything is set up correctly
./skills/setup.sh --verify
```

Or run `./skills/setup.sh` with no arguments for an interactive menu.

## Architecture

```
batuta-dots/
├── AGENTS.md                          # Single source of truth
├── BatutaClaude/                      # Claude Code configuration
│   ├── CLAUDE.md                      # Personality + rules (source file)
│   ├── settings.json                  # Permissions, output style
│   ├── mcp-servers.template.json      # MCP server template
│   ├── output-styles/batuta.md        # Custom output format
│   └── skills/                        # Skill definitions
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
│       └── sdd-archive/SKILL.md
├── BatutaOpenCode/                    # OpenCode config (for future replication)
│   ├── opencode.json
│   └── themes/batuta.json
├── guides/                            # Step-by-step guides
│   └── guia-batuta-app.md            # Prompting guide (Spanish)
└── skills/                            # Repository-level scripts
    ├── setup.sh                       # Claude Code setup (primary)
    ├── replicate-platform.sh          # Multi-platform replication (future)
    └── setup_test.sh                  # Verification tests
```

## How It Works

1. **AGENTS.md** contains all skills, workflows, conventions, and the SDD pipeline. This is the master file.
2. **setup.sh** generates `CLAUDE.md` (personality + AGENTS.md) and syncs skills to `~/.claude/skills/`.
3. **Claude Code** auto-loads relevant skills based on context — when you edit PostgreSQL code, the PostgreSQL skill activates; when you start SDD, the pipeline skills chain together.

```
AGENTS.md  (single source of truth)
    │
    ├──> setup.sh --claude  ──> CLAUDE.md (personality + AGENTS.md)
    └──> setup.sh --sync    ──> ~/.claude/skills/ (all SKILL.md files)
```

Need other platforms later?
```bash
./skills/replicate-platform.sh --all   # Generates GEMINI.md, CODEX.md, copilot-instructions.md
```

## Core Concepts

### Scope Rule

Before creating ANY file, the AI asks: "Who will use this?"

| Who uses it? | Where it goes |
|---|---|
| 1 feature | `features/{feature}/{type}/{name}` |
| 2+ features | `features/shared/{type}/{name}` |
| Entire app | `core/{type}/{name}` |

This prevents messy `utils/` and `components/` dump folders. The full rule is in the `scope-rule` skill.

### Spec-Driven Development (SDD)

A 9-phase pipeline that enforces "understand before build":

```
init -> explore -> propose -> spec -> design -> tasks -> apply -> verify -> archive
```

Each phase is a dedicated sub-agent skill. The orchestrator delegates all heavy work and only tracks state and user decisions.

### Skill Gap Detection

Before writing code with any technology, Claude checks if an active skill exists. If not, it stops and offers to research via Context7 and create the skill before proceeding.

### Ecosystem Auto-Update

When new skills are created in a project, Claude proposes propagating them back to batuta-dots so other projects benefit.

## Available Skills (12)

| Skill | Description |
|-------|-------------|
| `ecosystem-creator` | Create new skills, agents, sub-agents, and workflows |
| `scope-rule` | Enforce scope-based file organization |
| `sdd-init` through `sdd-archive` | 9-phase SDD pipeline |

Plus 17 planned project skills. See [AGENTS.md](AGENTS.md) for the full roadmap.

## Commands

| Command | Description |
|---------|-------------|
| `/sdd:init` | Initialize orchestration context |
| `/sdd:explore <topic>` | Explore idea and constraints |
| `/sdd:new <change-name>` | Start change proposal flow |
| `/sdd:continue [change-name]` | Run next dependency-ready phase |
| `/sdd:apply [change-name]` | Implement tasks in batches |
| `/sdd:verify [change-name]` | Validate implementation |
| `/sdd:archive [change-name]` | Close and persist final state |
| `/create:skill <name>` | Create a new skill |
| `/create:sub-agent <name>` | Create a new SDD sub-agent |
| `/create:workflow <name>` | Create a new workflow command |

## setup.sh Reference

| Flag | Action |
|------|--------|
| `--claude` | Generate CLAUDE.md |
| `--sync` | Sync skills to ~/.claude/skills/ |
| `--all` | Generate + sync (recommended) |
| `--verify` | Verify setup |

## Contributing

### Adding a New Skill

1. Run `/create:skill <name>` — the ecosystem-creator guides you
2. Or manually create `BatutaClaude/skills/<name>/SKILL.md`
3. Register in `AGENTS.md` under the appropriate skills table
4. Run `./skills/setup.sh --all`

## Credits

Inspired by [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) by Gentleman Programming. Batuta adapts the dotfiles concept for multi-project software factories with a CTO/Mentor personality, Spec-Driven Development, the Scope Rule, skill gap auto-detection, and the O.R.T.A. framework.

## License

[MIT](LICENSE)
