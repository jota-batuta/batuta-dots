# /sdd-ff

> Fast-forward through SDD planning phases: propose, spec, design, and tasks. Skips explore (assumes already done) and runs 4 phases in sequence.

## Instructions

### Step 1: Find the active change

If `{{args}}` is provided, use it as the change name.
If not, look in `openspec/changes/` for the most recently modified change directory.

### Step 2: Verify explore is done

Check that `openspec/changes/{change-name}/explore.md` exists.
If not, tell the user: "Explore no esta completo. Ejecuta /sdd-explore primero."

### Step 3: Run phases in sequence

For each phase that does not have its artifact yet, read the skill and execute:

1. **Propose** -- `.agent/skills/sdd-propose/SKILL.md` or `~/.gemini/antigravity/skills/sdd-propose/SKILL.md` -> save to `proposal.md`
2. **Spec** -- `.agent/skills/sdd-spec/SKILL.md` or `~/.gemini/antigravity/skills/sdd-spec/SKILL.md` -> save to `spec.md`
3. **Design** -- `.agent/skills/sdd-design/SKILL.md` or `~/.gemini/antigravity/skills/sdd-design/SKILL.md` -> save to `design.md`
4. **Tasks** -- `.agent/skills/sdd-tasks/SKILL.md` or `~/.gemini/antigravity/skills/sdd-tasks/SKILL.md` -> save to `tasks.md`

Skip any phase whose artifact already exists.

After completion, tell the user:

```
Fast-forward completo. Artefactos generados:
- proposal.md
- spec.md
- design.md
- tasks.md

Siguiente paso: /sdd-apply {change-name}
```
