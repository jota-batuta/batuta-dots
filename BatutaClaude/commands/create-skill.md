---
name: create-skill
description: >
  Create a new reusable skill for the Batuta ecosystem.
  Generates SKILL.md with frontmatter, purpose, and execution steps.
argument-hint: "<skill-name>"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Create Skill

Invoke the `ecosystem-creator` skill in **skill creation mode**.

The argument ($ARGUMENTS) is the name for the new skill.

Read the skill instructions at `~/.claude/skills/ecosystem-creator/SKILL.md` and follow the **skill creation** section.

If the skill file does not exist, tell the user:
```
El skill ecosystem-creator no esta instalado. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
