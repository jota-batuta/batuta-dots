# Batuta.Dots

**Unified AI agent ecosystem for software factories -- one config, every AI coding assistant.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## What is Batuta?

Batuta is an AI agent ecosystem that gives every AI coding assistant the same skills, workflows, and development methodology. You write your conventions once in a single `AGENTS.md` file, and Batuta syncs them to Claude Code, Gemini CLI, GitHub Copilot, OpenAI Codex, and OpenCode. The result: consistent AI behavior across tools, projects, and teams.

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/your-org/batuta-dots.git
cd batuta-dots

# 2. Generate instruction files for all AI tools
./skills/setup.sh --all

# 3. Sync skills to your local AI tool configs
./skills/setup.sh --sync-all

# 4. Verify everything is set up correctly
./skills/setup.sh --verify
```

Or run `./skills/setup.sh` with no arguments for an interactive menu.

### Generate for a single tool

```bash
./skills/setup.sh --claude     # Claude Code
./skills/setup.sh --gemini     # Gemini CLI
./skills/setup.sh --copilot    # GitHub Copilot
./skills/setup.sh --codex      # OpenAI Codex
```

## Architecture

```
batuta-dots/
├── AGENTS.md                          # Single source of truth for all AI tools
├── BatutaClaude/                      # Claude Code configuration
│   ├── CLAUDE.md                      # Personality + rules (prepended to AGENTS.md)
│   ├── settings.json                  # Permissions, output style
│   ├── mcp-servers.template.json      # MCP server template
│   ├── output-styles/batuta.md        # Custom output format
│   └── skills/                        # Skill definitions
│       ├── ecosystem-creator/         # Bootstrap skill for creating all others
│       │   ├── SKILL.md
│       │   └── assets/                # Templates for skills, agents, workflows
│       ├── sdd-init/SKILL.md          # SDD pipeline phases (9 skills)
│       ├── sdd-explore/SKILL.md
│       ├── sdd-propose/SKILL.md
│       ├── sdd-spec/SKILL.md
│       ├── sdd-design/SKILL.md
│       ├── sdd-tasks/SKILL.md
│       ├── sdd-apply/SKILL.md
│       ├── sdd-verify/SKILL.md
│       └── sdd-archive/SKILL.md
├── BatutaOpenCode/                    # OpenCode configuration
│   ├── opencode.json                  # Agents, permissions, MCP servers
│   └── themes/batuta.json             # Custom theme
└── skills/                            # Repository-level scripts
    ├── setup.sh                       # Sync AGENTS.md to all tool formats
    └── setup_test.sh                  # Verification tests
```

## How It Works

Batuta follows a single-source-of-truth model:

1. **AGENTS.md** contains all skills, workflows, conventions, and the SDD pipeline definition. This is the master file.
2. **setup.sh** reads AGENTS.md and generates tool-specific instruction files:
   - `CLAUDE.md` -- Claude Code (personality header + AGENTS.md content)
   - `GEMINI.md` -- Gemini CLI
   - `CODEX.md` -- OpenAI Codex
   - `.github/copilot-instructions.md` -- GitHub Copilot
3. **Skills** are synced to each tool's config directory (e.g., `~/.claude/skills/` for Claude Code, `~/.config/opencode/skill/` for OpenCode).
4. AI tools auto-load relevant skills based on context detection -- when you edit PostgreSQL code, the PostgreSQL skill activates; when you start an SDD workflow, the SDD skills chain together.

Generated files (CLAUDE.md, GEMINI.md, etc.) are gitignored. Only the source files are tracked.

## Spec-Driven Development (SDD)

SDD is a 9-phase pipeline that enforces "understand before build" -- no code gets written until the change is explored, proposed, specified, and designed.

```
init -> explore -> propose -> spec -> design -> tasks -> apply -> verify -> archive
```

| Phase | What Happens |
|-------|-------------|
| **init** | Set up project context and persistence mode |
| **explore** | Investigate the codebase and possible approaches |
| **propose** | Write a change proposal with scope, risks, and success criteria |
| **spec** | Define delta specifications with testable scenarios |
| **design** | Produce technical design and architecture decisions |
| **tasks** | Break work into implementation task batches |
| **apply** | Implement the tasks following specs and design |
| **verify** | Validate the implementation against specs |
| **archive** | Close the change and persist final artifacts |

Each phase is a dedicated sub-agent skill. The orchestrator delegates all heavy work to sub-agents and only tracks state and user decisions. The dependency graph allows specs and design to run in parallel:

```
proposal -> [specs || design] -> tasks -> apply -> verify -> archive
```

## Skill Gap Detection

Before writing code with any technology, the AI checks whether an active skill exists for it. If no skill is found, the AI stops and offers three options:

1. **Investigate and create (project-specific)** -- Research via Context7, create a skill with Batuta conventions (multi-tenancy, O.R.T.A., observability)
2. **Investigate and create (global)** -- Research via Context7, create a skill with generic best practices
3. **Continue without a skill** -- Use general knowledge and document the gap with a TODO

This prevents the AI from writing generic code that ignores project conventions. A 5-minute skill creation can save hours of refactoring.

## Available Skills

### Infrastructure Skills (10)

| Skill | Description |
|-------|-------------|
| `ecosystem-creator` | Create new skills, agents, sub-agents, and workflows |
| `sdd-init` | Initialize SDD project context and persistence mode |
| `sdd-explore` | Explore codebase and approaches before proposing a change |
| `sdd-propose` | Create change proposal with scope, risks, and success criteria |
| `sdd-spec` | Write delta specifications with testable scenarios |
| `sdd-design` | Produce technical design and architecture decisions |
| `sdd-tasks` | Break work into implementation task phases |
| `sdd-apply` | Implement assigned task batches following specs and design |
| `sdd-verify` | Verify implementation against specs and tasks |
| `sdd-archive` | Close a change and archive final artifacts |

### Project Skills (Roadmap)

Project-specific skills (e.g., `temporal-worker`, `multi-tenant-postgres`, `nextjs-portal`, `colombia-regulatory`) are created on demand using the `ecosystem-creator` skill and the `/create:skill` command. See the full roadmap in [AGENTS.md](AGENTS.md).

## Commands

### SDD Pipeline

| Command | Description |
|---------|-------------|
| `/sdd:init` | Initialize orchestration context |
| `/sdd:explore <topic>` | Explore idea and constraints |
| `/sdd:new <change-name>` | Start change proposal flow |
| `/sdd:continue [change-name]` | Run next dependency-ready phase |
| `/sdd:ff [change-name]` | Fast-forward all planning artifacts |
| `/sdd:apply [change-name]` | Implement tasks in batches |
| `/sdd:verify [change-name]` | Validate implementation |
| `/sdd:archive [change-name]` | Close and persist final state |

### Ecosystem Management

| Command | Description |
|---------|-------------|
| `/create:skill <name>` | Create a new skill (technology, workflow, or project-type) |
| `/create:agent <name>` | Create a new agent definition for OpenCode |
| `/create:sub-agent <name>` | Create a new SDD-style sub-agent skill |
| `/create:workflow <name>` | Create a new workflow command with skill mapping |

## Supported AI Tools

| Tool | Instruction File | Skill Sync Location |
|------|-----------------|---------------------|
| Claude Code | `CLAUDE.md` (personality + AGENTS.md) | `~/.claude/skills/` |
| Gemini CLI | `GEMINI.md` | -- |
| GitHub Copilot | `.github/copilot-instructions.md` | -- |
| OpenAI Codex | `CODEX.md` | -- |
| OpenCode | `opencode.json` (agents + skills) | `~/.config/opencode/skill/` |

### setup.sh Flags

| Flag | Action |
|------|--------|
| `--claude` | Generate CLAUDE.md |
| `--gemini` | Generate GEMINI.md |
| `--copilot` | Generate .github/copilot-instructions.md |
| `--codex` | Generate CODEX.md |
| `--all` | Generate all instruction files |
| `--sync-claude` | Sync skills to ~/.claude/skills/ |
| `--sync-opencode` | Sync skills to OpenCode config |
| `--sync-all` | Sync to all user configs |
| `--verify` | Verify generated files contain AGENTS.md content |

## Contributing

### Adding a New Skill

1. Run `/create:skill <name>` -- the ecosystem-creator skill guides you through it
2. Or manually create `BatutaClaude/skills/<name>/SKILL.md` using the template in `BatutaClaude/skills/ecosystem-creator/assets/skill-template.md`
3. Register the skill in `AGENTS.md` under the appropriate skills table
4. Run `./skills/setup.sh --all && ./skills/setup.sh --sync-all`

### Adding a New Agent

1. Run `/create:agent <name>` -- adds the agent definition to `opencode.json`
2. Register in `AGENTS.md` if it references skills

### Adding a New Workflow

1. Run `/create:workflow <name>` -- creates a command-to-skill mapping
2. Add the command to the "Command -> Skill Mapping" section in `AGENTS.md`

### Platform Support

setup.sh works on Windows (Git Bash / MSYS2 / MINGW64) and native Unix. Path normalization is handled automatically.

## Credits

Inspired by [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) by Gentleman Programming. Batuta adapts the dotfiles concept for multi-project software factories with a CTO/Mentor personality, Spec-Driven Development, skill gap auto-detection, and the O.R.T.A. framework (Observability, Repeatability, Traceability, Auto-supervision).

## License

[MIT](LICENSE)
