---
name: batuta-init
description: >
  Import the Batuta AI ecosystem into the current project.
  Sets up CLAUDE.md, skills, and git initialization.
  Use this when starting a new project with Batuta conventions.
disable-model-invocation: true
argument-hint: "[project-name]"
allowed-tools: Bash, Read, Write, Glob
---

## Batuta Ecosystem Setup

Initialize this project with the Batuta AI ecosystem. Follow these steps exactly:

### Step 1: Locate batuta-dots

Check if batuta-dots exists locally:

1. First check: `E:/BATUTA PROJECTS/claude/batuta-dots/BatutaClaude/CLAUDE.md`
2. If not found, check: `~/batuta-dots/BatutaClaude/CLAUDE.md`
3. If not found, clone it: `git clone https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-dots`

Store the path you found as `BATUTA_DOTS_PATH`.

If batuta-dots was found locally (not cloned fresh), update it:
```bash
git -C "$BATUTA_DOTS_PATH" pull --ff-only 2>/dev/null || echo "Could not update batuta-dots (offline?)"
```

### Step 2: Copy CLAUDE.md

Copy from `BATUTA_DOTS_PATH`:

1. `BatutaClaude/CLAUDE.md` → `./CLAUDE.md`

Do NOT copy settings.json, mcp-servers.template.json, or other config files — those stay in batuta-dots.

### Step 2.5: Initialize .batuta/ directory

Create the project-local Batuta directory for session continuity and prompt tracking:

```bash
mkdir -p .batuta
```

Copy the session template from batuta-dots:
```bash
cp "$BATUTA_DOTS_PATH/BatutaClaude/skills/prompt-tracker/assets/session-template.md" .batuta/session.md
```

Read the session template and use the Write tool to create `.batuta/session.md`,
replacing `{project-name}` with the actual project name (from argument or directory name).
Do not use sed — use Claude Code's native Write tool for cross-platform compatibility.

Create an empty prompt log:
```bash
touch .batuta/prompt-log.jsonl
```

### Step 3: Sync skills + install hooks

Run the setup script to sync skills and install hooks:

```bash
bash "$BATUTA_DOTS_PATH/infra/setup.sh" --sync
bash "$BATUTA_DOTS_PATH/infra/setup.sh" --hooks
```

The `--hooks` flag installs the 5 native hooks (Execution Gate, session continuity, O.R.T.A.) and permissions to `~/.claude/settings.json`. It backs up existing settings before merging.

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
.batuta/prompt-log.jsonl
.batuta/analysis-report.md
```

### Step 5: Confirm

Report to the user:

```
Ecosistema Batuta instalado en este proyecto.

Archivos creados:
- CLAUDE.md (personalidad + reglas + routing de skills)
- .batuta/session.md (continuidad entre sesiones)
- .batuta/prompt-log.jsonl (tracking de satisfaccion)

Skills sincronizados a ~/.claude/skills/ (X skills)
Hooks instalados en ~/.claude/settings.json (5 hooks + permissions)

Comandos disponibles:
- /sdd-init          — Iniciar proyecto con SDD
- /sdd-explore       — Explorar una idea
- /sdd-new           — Crear propuesta de cambio
- /create-skill      — Crear un skill nuevo

Siguiente paso recomendado: /sdd-init
```

If a project name was provided as argument ($ARGUMENTS), mention it in the confirmation and suggest using it for `/sdd-init`.
