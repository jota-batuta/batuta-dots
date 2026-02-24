# /sdd-archive

> Archive a completed change: sync specs to main, capture lessons learned, and move change artifacts to the archive directory.

## Instructions

### Step 1: Find the active change

If `{{args}}` is provided, use it as the change name.
If not, look in `openspec/changes/` for the most recently modified change directory.

### Step 2: Verify prerequisites

Check that `openspec/changes/{change-name}/verify.md` exists and shows a passing result.

If verification is missing or failing, tell the user to run `/sdd-verify` first.

### Step 3: Execute

Locate and read the `sdd-archive` skill at `.agent/skills/sdd-archive/SKILL.md` or `~/.gemini/antigravity/skills/sdd-archive/SKILL.md` and follow it exactly.

If the skill file does not exist, tell the user:

```
El skill sdd-archive no esta instalado. Ejecuta /batuta-update primero para sincronizar el ecosistema.
```
