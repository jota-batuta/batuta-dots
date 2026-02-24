---
name: sdd-continue
description: >
  Continue the SDD pipeline from where it left off. Detects the current phase
  and runs the next needed phase automatically.
argument-hint: "[change-name]"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## SDD Continue

Continue the SDD pipeline for a change. Detect which phase to run next.

### Step 1: Find the active change

If $ARGUMENTS is provided, use it as the change name.
If not, look in `openspec/changes/` for the most recently modified change directory.
If multiple changes exist and none specified, ask the user which one to continue.

### Step 2: Detect current phase

Check which artifacts exist in `openspec/changes/{change-name}/`:

| File exists? | Next phase to run |
|-------------|-------------------|
| No explore.md | Run sdd-explore |
| explore.md but no proposal.md | Run sdd-propose |
| proposal.md but no spec.md | Run sdd-spec |
| spec.md but no design.md | Run sdd-design |
| design.md but no tasks.md | Run sdd-tasks |
| tasks.md but no implementation | Run sdd-apply |
| Implementation exists but no verify.md | Run sdd-verify |
| verify.md exists | Run sdd-archive |

### Step 3: Execute the next phase

Read the corresponding skill from `~/.claude/skills/sdd-{phase}/SKILL.md` and follow it.

If any skill file does not exist, tell the user:
```
Los skills SDD no estan instalados. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
