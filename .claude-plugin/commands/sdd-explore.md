---
name: sdd-explore
description: >
  Explore and investigate an idea before committing to a change.
  Analyzes the codebase, detects skill gaps, and produces an exploration report.
argument-hint: "<topic>"
allowed-tools: Read, Glob, Grep, Bash, WebSearch, WebFetch, Edit, Write
---

## SDD Explore

Invoke the `sdd-explore` skill to investigate a topic or feature idea.

The argument ($ARGUMENTS) is the topic to explore. Pass it to the skill as the exploration subject.

Read the skill instructions at `~/.claude/skills/sdd-explore/SKILL.md` and follow them exactly.

If the skill file does not exist, tell the user:
```
El skill sdd-explore no esta instalado. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
