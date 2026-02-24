# /sdd-continue

> Continue the SDD pipeline from where it left off. Detects the current phase and runs the next needed phase automatically.

## Instructions

### Step 1: Find the active change

If `{{args}}` is provided, use it as the change name.
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

Read the corresponding skill from `.agent/skills/sdd-{phase}/SKILL.md` or `~/.gemini/antigravity/skills/sdd-{phase}/SKILL.md` and follow it exactly.

If any skill file does not exist, tell the user:

```
Los skills SDD no estan instalados. Ejecuta /batuta-update primero para sincronizar el ecosistema.
```
