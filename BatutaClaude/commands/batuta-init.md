---
name: batuta-init
description: >
  Import the Batuta AI ecosystem into the current project.
  Sets up CLAUDE.md, AGENTS.md, skills, and git initialization.
  Use this when starting a new project with Batuta conventions.
disable-model-invocation: true
argument-hint: "[project-name]"
allowed-tools: Bash, Read, Write, Glob
---

## Batuta Ecosystem Setup

Initialize this project with the Batuta AI ecosystem. Follow these steps exactly:

### Step 1: Locate batuta-dots

Check if batuta-dots exists locally:

1. First check: `E:/BATUTA PROJECTS/claude/batuta-dots/AGENTS.md`
2. If not found, check: `~/batuta-dots/AGENTS.md`
3. If not found, clone it: `git clone https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-dots`

Store the path you found as `BATUTA_DOTS_PATH`.

### Step 2: Copy ecosystem files

Copy these files from `BATUTA_DOTS_PATH` to the current project root:

1. `AGENTS.md` → `./AGENTS.md`
2. `BatutaClaude/CLAUDE.md` → `./CLAUDE.md`

Do NOT copy settings.json, mcp-servers.template.json, or other config files — those stay in batuta-dots.

### Step 3: Sync skills

Run the setup script to sync skills to the user's Claude config:

```bash
bash "$BATUTA_DOTS_PATH/skills/setup.sh" --sync
```

If the script fails, manually copy skills:
```bash
cp -r "$BATUTA_DOTS_PATH/BatutaClaude/skills/"* ~/.claude/skills/
```

### Step 4: Initialize git

If this project doesn't have a `.git` directory:

```bash
git init
```

Create a `.gitignore` if one doesn't exist, with at minimum:
```
.env
.env.*
node_modules/
__pycache__/
.venv/
```

### Step 5: Confirm

Report to the user:

```
Ecosistema Batuta instalado en este proyecto.

Archivos creados:
- CLAUDE.md (personalidad + reglas)
- AGENTS.md (fuente unica de verdad)

Skills sincronizados a ~/.claude/skills/ (X skills)

Comandos disponibles:
- /sdd:init          — Iniciar proyecto con SDD
- /sdd:explore       — Explorar una idea
- /sdd:new           — Crear propuesta de cambio
- /create:skill      — Crear un skill nuevo

Siguiente paso recomendado: /sdd:init
```

If a project name was provided as argument ($ARGUMENTS), mention it in the confirmation and suggest using it for `/sdd:init`.
