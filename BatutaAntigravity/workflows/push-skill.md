# /push-skill

> Propagate local skills to the batuta-dots hub repository so they become available across all Batuta-powered projects.

## Instructions

### Option A: Push all new skills (recommended)

Run the sync script with `--push`. This scans both `.agent/skills/` and `.claude/skills/`,
imports new skills to the hub, cross-syncs to Antigravity, and commits + pushes automatically.

```bash
# From your project directory:
/path/to/batuta-dots/infra/sync.sh --push

# Or with an explicit project path:
/path/to/batuta-dots/infra/sync.sh --push /path/to/project
```

### Option B: Push a specific skill manually

The argument `{{args}}` is the skill name to push. If not provided, ask the user which skill to propagate.

#### Step 1: Locate the local skill

Check for the skill in these locations (in order):
1. `.agent/skills/{{args}}/SKILL.md` (project-local)
2. `~/.gemini/antigravity/skills/{{args}}/SKILL.md` (user-global)

If not found, tell the user: "Skill '{{args}}' no encontrado localmente."

#### Step 2: Locate batuta-dots

Check these locations in order:
1. `~/batuta-dots/`
2. `/tmp/batuta-dots/`

If not found, tell the user: "batuta-dots no encontrado. Clona el repo primero: git clone https://github.com/jota-batuta/batuta-dots.git ~/batuta-dots"

#### Step 3: Evaluate portability

Before copying, check:
- Does the skill contain project-specific paths or hardcoded values?
- Is the skill general enough to be useful across projects?

If the skill has project-specific content, warn the user and suggest generalizing it first.

#### Step 4: Copy skill to hub

Copy the skill directory to `{batuta-dots}/BatutaClaude/skills/{{args}}/SKILL.md`.

If the skill already exists in batuta-dots, show a diff and ask the user whether to overwrite.

#### Step 5: Cross-sync to Antigravity

If the skill has `platforms: [claude, antigravity]` in its frontmatter, also copy it to
`{batuta-dots}/BatutaAntigravity/skills/{{args}}/SKILL.md`.

#### Step 6: Confirm

Tell the user:

```
Skill '{{args}}' sincronizado al hub.
Recuerda hacer commit y push en batuta-dots para que otros proyectos lo reciban con /batuta-update.
```
