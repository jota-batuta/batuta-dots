# /sdd-ff

> Fast-forward through SDD planning: explore then design (2 steps). Use when you want to go from idea to actionable design quickly.

## Instructions

### Step 1: Find the active change

If `{{args}}` is provided, use it as the change name.
If not, look in `openspec/changes/` for the most recently modified change directory.

### Step 2: Run phases in sequence

For each phase that doesn't have its artifact yet, read the skill and execute:

1. **Explore** -- `.agent/skills/sdd-explore/SKILL.md` or `~/.gemini/antigravity/skills/sdd-explore/SKILL.md` -> `explore.md`
2. **Design** -- `.agent/skills/sdd-design/SKILL.md` or `~/.gemini/antigravity/skills/sdd-design/SKILL.md` -> `design.md`

Skip any phase whose artifact already exists.

### Step 3: User approval gate

After design is generated, STOP and present it to the user for approval.
Do NOT auto-advance to apply.

After completion, tell the user:
```
Fast-forward completo. Artefactos generados:
- explore.md
- design.md

Siguiente paso: /sdd-apply {change-name}
```
