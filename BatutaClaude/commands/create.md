---
name: create
description: >
  Create a new ecosystem component (skill, sub-agent, or workflow).
  Delegates to ecosystem-creator skill with the appropriate mode.
argument-hint: "<type> <name>"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Create Ecosystem Component

Parse $ARGUMENTS to extract `<type>` and `<name>`.

Valid types: `skill`, `sub-agent`, `workflow`.

Examples:
- `/create skill fastapi-patterns`
- `/create sub-agent qa-agent`
- `/create workflow deploy-staging`

If type is missing or invalid, show:
```
Uso: /create <type> <name>

Tipos validos:
  skill       — Nuevo skill reutilizable (SKILL.md con frontmatter)
  sub-agent   — Nuevo agente de scope (agent .md con skills y memoria)
  workflow    — Nueva automatizacion multi-paso
```

Invoke the `ecosystem-creator` skill in **{type} creation mode**.

Read the skill instructions at `~/.claude/skills/ecosystem-creator/SKILL.md` and follow the **{type} creation** section.

If the skill file does not exist, tell the user:
```
El skill ecosystem-creator no esta instalado. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
