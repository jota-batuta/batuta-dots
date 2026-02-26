---
name: batuta-update
description: >
  Update the Batuta ecosystem in the current project from the latest batuta-dots.
  Single command: syncs global ~/.claude/, updates project CLAUDE.md, refreshes ecosystem.
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Glob
---

## Update Batuta Ecosystem

Pull latest batuta-dots and update everything (global + project) in one shot.

### Step 1: Locate batuta-dots

Check these locations in order:

1. `E:/BATUTA PROJECTS/batuta-dots/`
2. `~/batuta-dots/`
3. `/tmp/batuta-dots/`

If found, do a `git pull` in that directory to get latest changes.
If not found, clone: `git clone https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-dots`

Store the path in `$BATUTA_DOTS_PATH`.

### Step 2: Run full update (one command)

```bash
bash "$BATUTA_DOTS_PATH/infra/setup.sh" --update "$(pwd)"
```

This single command does everything:
- Syncs skills, agents, commands, output-styles to `~/.claude/`
- Cleans up orphan hooks and skills from `~/.claude/`
- Installs hooks + permissions to `~/.claude/settings.json`
- Copies updated CLAUDE.md to the current project
- Refreshes `.batuta/ecosystem.json` with version and skill lists

### What gets updated vs what stays

| Scope | Updated? | Location |
|-------|----------|----------|
| Skills, agents, commands | YES | ~/.claude/ |
| Hooks + permissions | YES | ~/.claude/settings.json |
| Orphan hooks/skills | CLEANED UP | ~/.claude/hooks/, ~/.claude/skills/ |
| Project CLAUDE.md | YES | ./CLAUDE.md |
| Project ecosystem.json | YES | .batuta/ecosystem.json |
| Project session state | **NO — stays local** | .batuta/session.md |
| SDD artifacts | **NO — stays local** | openspec/ |

NEVER overwrite `.batuta/session.md` or `openspec/` contents. Project context is sacred.

### Step 3: Report

```
Ecosistema Batuta actualizado.

Global:
  Skills sincronizados: X skills en ~/.claude/skills/
  Agentes sincronizados: X agentes en ~/.claude/agents/
  Hooks + permissions: instalados

Proyecto:
  CLAUDE.md: actualizado a vX.Y.Z
  ecosystem.json: version y skills actualizados

Nuevos skills desde la ultima actualizacion:
- [lista si los hay]
```
