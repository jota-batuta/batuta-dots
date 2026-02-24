---
name: sdd-ff
description: >
  Fast-forward through SDD planning phases: propose, spec, design, and tasks.
  Skips explore (assumes already done) and runs 4 phases in sequence.
argument-hint: "[change-name]"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## SDD Fast-Forward

Run the planning phases in sequence: propose -> spec -> design -> tasks.

### Step 1: Find the active change

If $ARGUMENTS is provided, use it as the change name.
If not, look in `openspec/changes/` for the most recently modified change directory.

### Step 2: Verify explore is done

Check that `openspec/changes/{change-name}/explore.md` exists.
If not, tell the user: "Explore no esta completo. Ejecuta /sdd-explore primero."

### Step 3: Run phases in sequence

For each phase that doesn't have its artifact yet, read the skill and execute:

1. **Propose** — `~/.claude/skills/sdd-propose/SKILL.md` -> `proposal.md`
2. **Spec** — `~/.claude/skills/sdd-spec/SKILL.md` -> `spec.md`
3. **Design** — `~/.claude/skills/sdd-design/SKILL.md` -> `design.md`
4. **Tasks** — `~/.claude/skills/sdd-tasks/SKILL.md` -> `tasks.md`

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
