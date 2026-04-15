---
name: sdd-verify
description: >
  Verify implementation using the AI Validation Pyramid: linting, tests,
  documentation checks, and cross-layer security validation.
argument-hint: "[change-name]"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## SDD Verify

Invoke the `sdd-verify` skill to validate the implementation.

### Step 1: Find the active change

If $ARGUMENTS is provided, use it as the change name.
If not, look in `openspec/changes/` for the most recently modified change directory.

### Step 2: Verify prerequisites

Check that implementation exists (source code files created by sdd-apply).

### Step 3: Execute

Read the skill instructions at `~/.claude/skills/sdd-verify/SKILL.md` and follow them exactly.

The verification report will be saved to `openspec/changes/{change-name}/verify.md`.

If the skill file does not exist, tell the user:
```
El skill sdd-verify no esta instalado. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
