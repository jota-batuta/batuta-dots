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

### Step 2: Re-sync skills

```bash
bash "$BATUTA_DOTS_PATH/skills/setup.sh" --sync
```

### Step 3: Update project CLAUDE.md

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
CLAUDE.md: [actualizado | sin cambios | omitido]

Nuevos skills disponibles desde la ultima actualizacion:
- [lista de skills nuevos si los hay, comparando con la version anterior]
```
