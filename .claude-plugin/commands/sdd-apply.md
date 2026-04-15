---
name: sdd-apply
description: >
  Implement code for a change following its specs, design, and task breakdown.
  Enforces documentation standard and complexity evaluation.
argument-hint: "[change-name]"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## SDD Apply

Invoke the `sdd-apply` skill to implement the code for a change.

### Step 1: Find the active change

If $ARGUMENTS is provided, use it as the change name.
If not, look in `openspec/changes/` for the most recently modified change directory.

### Step 2: Verify prerequisites

Check that these artifacts exist in `openspec/changes/{change-name}/`:
- `spec.md` (required)
- `design.md` (required)
- `tasks.md` (required)

If any is missing, tell the user which phase to run first.

### Step 3: Execute

Read the skill instructions at `~/.claude/skills/sdd-apply/SKILL.md` and follow them exactly.

If the skill file does not exist, tell the user:
```
El skill sdd-apply no esta instalado. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
