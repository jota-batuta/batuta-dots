# /batuta-update

> Update the Batuta Antigravity ecosystem in the current project from the latest batuta-dots hub.

## Instructions

### Step 1: Locate batuta-dots

Check these locations in order:
1. `~/batuta-dots/`
2. `/tmp/batuta-dots/`

If not found, clone it: `git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-dots`

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

### Step 3: Run Antigravity update (one command)

```bash
bash "$BATUTA_DOTS_PATH/BatutaAntigravity/setup-antigravity.sh" --update "$(pwd)"
```

This single command does everything for the Antigravity ecosystem:
- Copies GEMINI.md to `~/.gemini/GEMINI.md` (global)
- Syncs antigravity-compatible skills to `~/.gemini/antigravity/skills/` (global)
- Copies GEMINI.md to project root (project-level)
- Syncs skills to `.agent/skills/` (project-level)
- Ensures `.batuta/` exists

**IMPORTANT**: This uses `setup-antigravity.sh`, NOT `setup.sh`.
Each ecosystem has its own setup script. They are independent.

### What gets updated vs what stays

| Scope | Updates from batuta-dots? | Location |
|-------|--------------------------|----------|
| Agent behavior (rules, personality) | YES | GEMINI.md (global + project) |
| Skills (coding standards) | YES | ~/.gemini/antigravity/skills/ + .agent/skills/ |
| Project context (session state) | **NO -- stays local** | .batuta/session.md |
| SDD artifacts (specs, designs) | **NO -- stays local** | openspec/ |

NEVER overwrite `.batuta/` contents during update. Project context is sacred.

### Step 4: Report

```
Ecosistema Batuta (Antigravity) actualizado.

Global:
  GEMINI.md: actualizado en ~/.gemini/GEMINI.md
  Skills sincronizados: X skills en ~/.gemini/antigravity/skills/

Proyecto:
  GEMINI.md: actualizado en ./GEMINI.md
  Skills sincronizados: X skills en .agent/skills/

Nuevos skills disponibles desde la ultima actualizacion:
- [lista de skills nuevos si los hay]
```
