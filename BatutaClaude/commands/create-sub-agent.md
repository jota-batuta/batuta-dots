---
name: create-sub-agent
description: >
  Create a new sub-agent for the Batuta ecosystem.
  Generates agent .md file with frontmatter, skills, and memory configuration.
argument-hint: "<agent-name>"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Create Sub-Agent

Invoke the `ecosystem-creator` skill in **sub-agent creation mode**.

The argument ($ARGUMENTS) is the name for the new sub-agent.

Read the skill instructions at `~/.claude/skills/ecosystem-creator/SKILL.md` and follow the **sub-agent creation** section.

If the skill file does not exist, tell the user:
```
El skill ecosystem-creator no esta instalado. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
