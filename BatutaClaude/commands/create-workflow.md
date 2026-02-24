---
name: create-workflow
description: >
  Create a new workflow (multi-step automation) for the Batuta ecosystem.
  Generates workflow definition with steps, triggers, and documentation.
argument-hint: "<workflow-name>"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Create Workflow

Invoke the `ecosystem-creator` skill in **workflow creation mode**.

The argument ($ARGUMENTS) is the name for the new workflow.

Read the skill instructions at `~/.claude/skills/ecosystem-creator/SKILL.md` and follow the **workflow creation** section.

If the skill file does not exist, tell the user:
```
El skill ecosystem-creator no esta instalado. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
