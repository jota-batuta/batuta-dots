# /batuta-update

> Update the Batuta ecosystem in the current project from the latest batuta-dots hub. Pulls latest changes, re-syncs skills, and updates GEMINI.md.

## Instructions

### Step 1: Locate batuta-dots

Check these locations in order:
1. `~/batuta-dots/`
2. `/tmp/batuta-dots/`

If not found, clone it: `git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-dots`

If found, try `git pull` to get the latest changes. **This is best-effort** — if it fails
(dirty tree, wrong branch, user rejects), continue with the local version. Say:
"No pude hacer pull. Continúo con la versión local de batuta-dots."

Do NOT stop the flow if git pull fails. The local version is good enough.

### Important: What gets updated vs what stays

| Scope | Updates from batuta-dots? | Location |
|-------|--------------------------|----------|
| Agent behavior (rules, personality) | YES | GEMINI.md |
| Skills (coding standards) | YES | .agent/skills/ or ~/.gemini/antigravity/skills/ |
| Workflows (slash commands) | YES | .agent/workflows/ or ~/.gemini/antigravity/workflows/ |
| Project context (session state) | **NO -- stays local** | .batuta/session.md |
| SDD artifacts (specs, designs) | **NO -- stays local** | openspec/ |

NEVER overwrite `.batuta/` contents during update. Project context is sacred.

### Step 2: Re-sync skills and workflows

Copy skills from `{batuta-dots}/BatutaClaude/skills/` to the appropriate skills directory.
Only copy skills whose SKILL.md frontmatter contains `platforms:.*antigravity`.

Copy workflows from `{batuta-dots}/BatutaAntigravity/workflows/` to the project workflows directory.

### Step 3: Confirm GEMINI.md update

If `./GEMINI.md` exists in the current project, ask the user:

> "GEMINI.md ya existe en este proyecto. Quieres actualizarlo con la version mas reciente de batuta-dots?
> Esto sobreescribira cualquier cambio local que hayas hecho a GEMINI.md.
> Si prefieres, puedo hacer un diff primero para que veas las diferencias."

Options:
1. Overwrite -- Copy latest BatutaAntigravity/GEMINI.md
2. Show diff -- Run diff and let the user decide
3. Skip -- Keep current GEMINI.md

### Step 4: Report

```
Ecosistema Batuta actualizado.

Skills sincronizados: X skills
Workflows sincronizados: X workflows
GEMINI.md: [actualizado | sin cambios | omitido]

Nuevos skills disponibles desde la ultima actualizacion:
- [lista de skills nuevos si los hay]
```
