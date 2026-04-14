# /sdd-continue

> Continue the SDD pipeline from where it left off. Detects SPRINT vs COMPLETO mode and resumes from session.md state.

## Instructions

### Step 1: Read session.md

Read `session.md` (or `.batuta/session.md`) to determine:
- Current mode: SPRINT or COMPLETO
- Current phase
- Active change name

If session.md does not exist or has no SDD state, fall back to artifact detection (Step 3).

### Step 2: Find the active change

If `{{args}}` is provided, use it as the change name.
If session.md names a change, use that.
If neither, look in `openspec/changes/` for the most recently modified change directory.
If multiple changes exist and none specified, ask the user which one to continue.

### Step 3: Detect next phase by mode

**SPRINT mode** (default -- no gates):

| State | Next action |
|-------|-------------|
| No implementation yet | Run sdd-apply |
| Implementation exists but no verify | Run sdd-verify |
| Verify done | Done -- report to user |

**COMPLETO mode** (PRD-driven):

| Artifact exists? | Next action |
|------------------|-------------|
| No explore.md | Run sdd-explore |
| explore.md but no design.md | Run sdd-design, then STOP for approval |
| design.md but no implementation | Run sdd-apply |
| Implementation but no verify | Run sdd-verify |
| Verify done | Done -- report to user |

### Step 4: Execute the next phase

Read the corresponding skill from `.agent/skills/sdd-{phase}/SKILL.md` or `~/.gemini/antigravity/skills/sdd-{phase}/SKILL.md` and follow it.

If any skill file does not exist, tell the user:
```
Los skills SDD no estan instalados. Ejecuta /batuta-update primero para sincronizar el ecosistema.
```
