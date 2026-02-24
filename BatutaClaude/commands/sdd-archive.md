---
name: sdd-archive
description: >
  Archive a completed change: sync specs to main, capture lessons learned,
  and move change artifacts to the archive directory.
argument-hint: "[change-name]"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## SDD Archive

Invoke the `sdd-archive` skill to archive a completed change.

### Step 1: Find the active change

If $ARGUMENTS is provided, use it as the change name.
If not, look in `openspec/changes/` for the most recently modified change directory.

### Step 2: Verify prerequisites

Check that `openspec/changes/{change-name}/verify.md` exists and shows a passing result.

### Step 3: Execute

Read the skill instructions at `~/.claude/skills/sdd-archive/SKILL.md` and follow them exactly.

If the skill file does not exist, tell the user:
```
El skill sdd-archive no esta instalado. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
