---
name: batuta-update
description: >
  Update the Batuta ecosystem in the current project from the latest batuta-dots.
  Pulls latest changes, re-syncs skills, and regenerates CLAUDE.md.
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

### Step 2: Re-sync skills

```bash
bash "$BATUTA_DOTS_PATH/skills/setup.sh" --sync
```

### Step 3: Update project files

If `./AGENTS.md` exists in the current project, ask the user:

> "AGENTS.md ya existe en este proyecto. Quieres actualizarlo con la version mas reciente de batuta-dots?
> Esto sobreescribira cualquier cambio local que hayas hecho a AGENTS.md.
> Si prefieres, puedo hacer un diff primero para que veas las diferencias."

Options:
1. Overwrite — Copy latest AGENTS.md
2. Show diff — Run `diff ./AGENTS.md $BATUTA_DOTS_PATH/AGENTS.md` and let user decide
3. Skip — Keep current AGENTS.md

Same for CLAUDE.md.

### Step 4: Report

```
Ecosistema Batuta actualizado.

Skills sincronizados: X skills en ~/.claude/skills/
AGENTS.md: [actualizado | sin cambios | omitido]
CLAUDE.md: [actualizado | sin cambios | omitido]

Nuevos skills disponibles desde la ultima actualizacion:
- [lista de skills nuevos si los hay, comparando con la version anterior]
```
