# /sdd-explore

> Explore and investigate an idea before committing to a change. Analyzes the codebase, detects skill gaps, and produces an exploration report.

## Instructions

The argument `{{args}}` is the topic to explore. Pass it to the skill as the exploration subject.

1. Locate and read the `sdd-explore` skill file at `.agent/skills/sdd-explore/SKILL.md` or `~/.gemini/antigravity/skills/sdd-explore/SKILL.md`.
2. Follow the skill instructions exactly, using `{{args}}` as the exploration topic.
3. The skill will analyze the codebase, detect relevant patterns and skill gaps, and produce an exploration report.

If the skill file does not exist, tell the user:

```
El skill sdd-explore no esta instalado. Ejecuta /batuta-update primero para sincronizar el ecosistema.
```
