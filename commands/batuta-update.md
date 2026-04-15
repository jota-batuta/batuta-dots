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

1. `~/batuta-dots/`
2. `/tmp/batuta-dots/`

If not found in either location, clone it:
```bash
git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-dots
```

Store the path in `$BATUTA_DOTS_PATH`.

### Step 2: Pull latest changes

Tell the user: "Actualizando batuta-dots para obtener los últimos skills y configuración..."

Run `git pull` in `$BATUTA_DOTS_PATH`. If it fails (dirty tree, wrong branch, conflict),
**stop and explain the issue to the user**. Do NOT silently continue with stale files —
the user needs to know they're not getting the latest version.

Common failures and what to tell the user:
- Dirty tree: "batuta-dots tiene cambios sin commit. Haz commit o stash antes de actualizar."
- Wrong branch: "batuta-dots está en la rama X. Cambia a master para actualizar."
- Network error: "No hay conexión. Verifica tu red."

### Step 3: Run full update (internal)

Run internally (the user NEVER sees bash commands):
`bash "$BATUTA_DOTS_PATH/infra/setup.sh" --update "$(pwd)"`

Tell the user: "Actualizando skills, agentes, y configuración..."

This does:
- Syncs skills, agents, commands, output-styles to `~/.claude/`
- Cleans up orphan hooks and skills from `~/.claude/`
- Installs hooks + permissions to `~/.claude/settings.json`
- Copies updated CLAUDE.md to the current project (hub layer only)
- Refreshes `.batuta/ecosystem.json` with version and skill lists

### Step 3.5: Preserve project overrides

If the project has `.claude/CLAUDE.md` (project-specific rules), this file is NEVER touched.
The --update flag only overwrites the root CLAUDE.md (hub-managed layer).

Tell the user: "Tu CLAUDE.md fue actualizado. Tus reglas de proyecto en .claude/CLAUDE.md no fueron tocadas."

### Step 3.6: Check for new skills to provision

After updating, check if any newly available skills should be provisioned for this project:

1. Read updated skill list from `~/.claude/skills/`
2. Compare against `.claude/skills/.provisions.json` (if it exists)
3. Read `tech_detected` from `.provisions.json` to know this project's stack
4. If new skills in global match the project's tech stack:
   → Auto-copy to `.claude/skills/` and update `.provisions.json`
   → Report: "Nuevos skills provisionados: {list}"
5. If no new matches: skip silently

### What gets updated vs what stays

| Scope | Updated? | Location |
|-------|----------|----------|
| Skills, agents, commands | YES | ~/.claude/ |
| Hooks + permissions | YES | ~/.claude/settings.json |
| Orphan hooks/skills | CLEANED UP | ~/.claude/hooks/, ~/.claude/skills/ |
| Project CLAUDE.md (hub layer) | YES | ./CLAUDE.md |
| Project CLAUDE.md (overrides) | **NO — preserved** | .claude/CLAUDE.md |
| Project ecosystem.json | YES | .batuta/ecosystem.json |
| Project session state | **NO — stays local** | .batuta/session.md |
| SDD artifacts | **NO — stays local** | openspec/ |

NEVER overwrite `.claude/CLAUDE.md`, `.batuta/session.md`, or `openspec/` contents.

### Step 4: Report

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
