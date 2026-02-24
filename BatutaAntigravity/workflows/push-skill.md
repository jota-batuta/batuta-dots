# /push-skill

> Propagate a local skill to the batuta-dots hub repository so it becomes available across all Batuta-powered projects.

## Instructions

The argument `{{args}}` is the skill name to push. If not provided, ask the user which skill to propagate.

### Step 1: Locate the local skill

Check for the skill in these locations (in order):
1. `.agent/skills/{{args}}/SKILL.md` (project-local)
2. `~/.gemini/antigravity/skills/{{args}}/SKILL.md` (user-global)

If not found, tell the user: "Skill '{{args}}' no encontrado localmente."

### Step 2: Locate batuta-dots

Check these locations in order:
1. `~/batuta-dots/`
2. `/tmp/batuta-dots/`

If not found, tell the user: "batuta-dots no encontrado. Clona el repo primero: git clone https://github.com/jota-batuta/batuta-dots.git ~/batuta-dots"

### Step 3: Evaluate portability

Before copying, check:
- Does the skill contain project-specific paths or hardcoded values?
- Is the skill general enough to be useful across projects?

If the skill has project-specific content, warn the user and suggest generalizing it first.

### Step 4: Copy skill to hub

Copy the skill directory to `{batuta-dots}/skills/{{args}}/SKILL.md`.

If the skill already exists in batuta-dots, show a diff and ask the user whether to overwrite.

### Step 5: Confirm

Tell the user:

```
Skill '{{args}}' copiado a batuta-dots.
Recuerda hacer commit y push en batuta-dots para que otros proyectos puedan recibirlo con /batuta-update.
```
