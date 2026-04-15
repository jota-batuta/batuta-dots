---
name: sdd-init
description: >
  Bootstrap SDD in this project. Detects project type (webapp, automation, ai-agent,
  infrastructure, data-pipeline, library) and creates the openspec/ directory structure.
argument-hint: ""
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## SDD Init

Invoke the `sdd-init` skill to bootstrap Spec-Driven Development in this project.

Read the skill instructions at `~/.claude/skills/sdd-init/SKILL.md` and follow them exactly.

If the skill file does not exist, tell the user:
```
El skill sdd-init no esta instalado. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
