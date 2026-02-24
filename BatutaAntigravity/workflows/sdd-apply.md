# /sdd-apply

> Implement code for a change following its specs, design, and task breakdown. Enforces documentation standard and complexity evaluation.

## Instructions

### Step 1: Find the active change

If `{{args}}` is provided, use it as the change name.
If not, look in `openspec/changes/` for the most recently modified change directory.

### Step 2: Verify prerequisites

Check that these artifacts exist in `openspec/changes/{change-name}/`:
- `spec.md` (required)
- `design.md` (required)
- `tasks.md` (required)

If any is missing, tell the user which phase to run first.

### Step 3: Execute

Locate and read the `sdd-apply` skill at `.agent/skills/sdd-apply/SKILL.md` or `~/.gemini/antigravity/skills/sdd-apply/SKILL.md` and follow it exactly.

Before writing code, enforce the Execution Gate as defined in GEMINI.md. For multi-file changes, use FULL mode and show the location plan, scope, and impact before proceeding.

If the skill file does not exist, tell the user:

```
El skill sdd-apply no esta instalado. Ejecuta /batuta-update primero para sincronizar el ecosistema.
```
