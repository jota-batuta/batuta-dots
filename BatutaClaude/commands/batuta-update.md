---
name: batuta-update
description: >
  Update the Batuta ecosystem in the current project from the latest batuta-dots.
  Pulls latest changes, re-syncs skills, and updates CLAUDE.md.
  Use after batuta-dots has been updated with new skills.
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Glob
---

## Update Batuta Ecosystem

Pull the latest changes from batuta-dots and update this project. Follow these steps:

### Step 1: Locate batuta-dots

Check these locations in order:

1. `E:/BATUTA PROJECTS/claude/batuta-dots/`
2. `~/batuta-dots/`
3. `/tmp/batuta-dots/`

If found, do a `git pull` in that directory to get latest changes.
If not found, clone: `git clone https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-dots`

### Important: What gets updated vs what stays

| Scope | Updates from batuta-dots? | Location |
|-------|--------------------------|----------|
| Agent behavior (rules, personality) | YES | CLAUDE.md |
| Skills (coding standards) | YES | ~/.claude/skills/ |
| Scope agents (routing docs) | YES | ~/.claude/agents/ |
| Commands (slash commands) | YES | ~/.claude/commands/ |
| Routing tables (auto-generated) | YES | BatutaClaude/CLAUDE.md + agents/ |
| Hooks + permissions | YES | ~/.claude/settings.json |
| Project context (session state) | **NO — stays local** | .batuta/session.md |
| Prompt logs (satisfaction data) | **NO — stays local** | .batuta/prompt-log.jsonl |
| SDD artifacts (specs, designs) | **NO — stays local** | openspec/ |

NEVER overwrite `.batuta/` contents during update. Project context is sacred.

### Step 2: Re-sync skills, agents, and routing tables

```bash
bash "$BATUTA_DOTS_PATH/skills/setup.sh" --all
```

This syncs skills + scope agents + commands to `~/.claude/`, runs skill-sync to regenerate routing tables, installs hooks + permissions to `~/.claude/settings.json`, and copies the updated CLAUDE.md to the project root.

### Step 3: Confirm CLAUDE.md update

If `./CLAUDE.md` exists in the current project, ask the user:

> "CLAUDE.md ya existe en este proyecto. Quieres actualizarlo con la version mas reciente de batuta-dots?
> Esto sobreescribira cualquier cambio local que hayas hecho a CLAUDE.md.
> Si prefieres, puedo hacer un diff primero para que veas las diferencias."

Options:
1. Overwrite — Copy latest BatutaClaude/CLAUDE.md
2. Show diff — Run `diff ./CLAUDE.md $BATUTA_DOTS_PATH/BatutaClaude/CLAUDE.md` and let user decide
3. Skip — Keep current CLAUDE.md

### Step 4: Report

```
Ecosistema Batuta actualizado.

Skills sincronizados: X skills en ~/.claude/skills/
Agentes sincronizados: X agentes en ~/.claude/agents/
Hooks + permissions: instalados en ~/.claude/settings.json
Tablas de routing: regeneradas por skill-sync
CLAUDE.md: [actualizado | sin cambios | omitido]

Nuevos skills disponibles desde la ultima actualizacion:
- [lista de skills nuevos si los hay, comparando con la version anterior]
```
