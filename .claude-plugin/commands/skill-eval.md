---
name: skill-eval
description: >
  Evaluate or benchmark skills to verify they change agent behavior as intended.
  Routes to skill-eval skill in the appropriate mode.
argument-hint: "<skill-name> [--improve] | --benchmark [--all | skill-names...]"
allowed-tools: Read, Glob, Grep, Bash, Task
---

## Skill Eval

Evaluate a skill's behavioral impact or benchmark multiple skills.

### Step 1: Parse the command

Parse $ARGUMENTS to determine the mode:

- `/skill:eval <skill-name>` --> Eval mode on a specific skill
- `/skill:eval <skill-name> --improve` --> Improve mode (fix failures)
- `/skill:benchmark --all` --> Benchmark all skills with eval files
- `/skill:benchmark <skill-name-1> <skill-name-2>` --> Benchmark named skills

If no arguments provided, show:
```
Uso: /skill:eval <nombre-del-skill> [--improve]
      /skill:benchmark [--all | skill-1 skill-2 ...]

Modos:
  eval        — Ejecuta los casos de SKILL.eval.yaml contra un skill especifico
  improve     — Analiza fallos del eval y propone ediciones al SKILL.md
  benchmark   — Evalua multiples skills y genera reporte de salud del ecosistema

Ejemplos:
  /skill:eval scope-rule
  /skill:eval ecosystem-creator --improve
  /skill:benchmark --all
```

### Step 2: Locate the skill

Find the skill in this order:
1. `BatutaClaude/skills/{skill-name}/SKILL.md`
2. `~/.claude/skills/{skill-name}/SKILL.md`
3. `.claude/skills/{skill-name}/SKILL.md`

If not found, tell the user:
```
No encuentro el skill "{skill-name}". Verifica el nombre o ejecuta /batuta-sync para sincronizar.
```

### Step 3: Execute

Read the skill-eval instructions at `~/.claude/skills/skill-eval/SKILL.md` (or `BatutaClaude/skills/skill-eval/SKILL.md` in the hub) and follow the appropriate mode.

If the skill-eval file does not exist, tell the user:
```
El skill skill-eval no esta instalado. Ejecuta /batuta-init primero para sincronizar el ecosistema.
```
