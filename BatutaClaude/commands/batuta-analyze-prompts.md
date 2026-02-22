---
name: batuta-analyze-prompts
description: >
  Analyze the prompt satisfaction log and generate improvement recommendations.
  Reads .batuta/prompt-log.jsonl, computes metrics, and suggests updates to
  CLAUDE.md behavior rules, user prompting habits, and sub-agent patterns.
  Part of the O.R.T.A. framework (Auto-supervision layer).
allowed-tools: Read, Glob, Grep, Write
---

## Analyze Prompt Satisfaction

Load the `prompt-tracker` skill in analysis mode and run the full analysis pipeline.

### Step 1: Verify log exists

Check if `.batuta/prompt-log.jsonl` exists in the current project root.

If it does NOT exist:
```
No se encontro el log de prompts en .batuta/prompt-log.jsonl

Para empezar a registrar interacciones, ejecuta /batuta-init en tu proyecto
o crea el archivo manualmente: touch .batuta/prompt-log.jsonl
```

If it exists but has fewer than 5 closed prompts:
```
El log tiene {N} interacciones cerradas. Se necesitan al menos 5 para generar
metricas significativas. Sigue trabajando y ejecuta este analisis mas adelante.
```

### Step 2: Load prompt-tracker skill

Read `~/.claude/skills/prompt-tracker/SKILL.md` and follow its Analysis Mode (Steps 1-6).

### Step 3: Present results

After generating `.batuta/analysis-report.md`, show the user:

```
Analisis de Satisfaccion de Prompts

Periodo: {first date} — {last date}
Prompts analizados: {count}

Metricas clave:
- Tasa de satisfaccion: {X}%
- Tipo de correccion mas comun: {type} ({Y}%)
- Contexto con mas correcciones: {context}
- Tasa de compliance del gate: {X}%
- Distribucion de scopes: pipeline {X}%, infra {Y}%, observability {Z}%

Top 3 recomendaciones:
1. [Usuario] {recommendation}
2. [CLAUDE.md] {recommendation}
3. [Sub-agente] {recommendation}

Reporte completo: .batuta/analysis-report.md

Quieres que aplique alguna de estas recomendaciones?
```

### Step 4: Apply recommendations (if user approves)

If the user wants to apply recommendations:

**For CLAUDE.md behavior updates:**
- Edit `BatutaClaude/CLAUDE.md` in the batuta-dots repo
- Show the diff before applying
- After applying, suggest running `./skills/setup.sh --claude` to propagate

**For sub-agent rule updates:**
- Edit the specific `SKILL.md` in `BatutaClaude/skills/{skill}/`
- Show the diff before applying
- After applying, suggest running `./skills/setup.sh --sync` to propagate

**For user prompting guide:**
- Generate or update `.batuta/prompting-guide.md` in the current project
- This is a local file — not propagated to batuta-dots

Always ask before applying each change. Never batch-apply without confirmation.
