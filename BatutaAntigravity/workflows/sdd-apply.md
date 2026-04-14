# /sdd-apply

> Implement code for a change. Receives a PRD, design, or task description and implements it.

## Instructions

### Step 1: Find the active change

If `{{args}}` is provided, use it as the change name.
If not, look in `openspec/changes/` for the most recently modified change directory.

### Step 2: Verify prerequisites

Check for implementation context. At least one of these should exist:
- A PRD in Notion (search via MCP by project name)
- A design or task description in `openspec/changes/{change-name}/`
- Direct user instructions describing what to implement

If no context is found, tell the user to describe what to implement or run `/sdd-explore` first.

### Step 3: Execute

Locate and read the `sdd-apply` skill at `.agent/skills/sdd-apply/SKILL.md` or `~/.gemini/antigravity/skills/sdd-apply/SKILL.md` and follow it exactly.

Research is mandatory before implementation (Research-First rule). Verify skills and framework docs are current before writing code.

If the skill file does not exist, tell the user:

```
El skill sdd-apply no esta instalado. Ejecuta /batuta-update primero para sincronizar el ecosistema.
```
