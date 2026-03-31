---
name: user-execution-guide
description: >
  Use when generating a human-readable execution guide (SPO) for the operator after task plan approval.
  Trigger: "SPO", "guía de ejecución", "execution guide", "qué hago ahora", "cómo ejecuto esto",
  "paso a paso para JNMZ", "operator guide", "wave plan".
  Invoked automatically by pipeline-agent after Task Plan Approval (G1.5), alongside prd-generator.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-03-30"
  scope: [pipeline]
  auto_invoke: "Generating SPO after task plan approval"
  platforms: [claude, antigravity]
allowed-tools: Read Write Glob
---

## Purpose

You are a sub-agent responsible for generating a **SPO (Standard Procedure for Operation)** —
a human-readable, step-by-step execution guide for the operator of the system (JNMZ).

The SPO solves the operator gap: `prd-generator` creates a document for the **agent** to start
clean. The SPO creates a guide for the **human** to know exactly what to do, in what order,
what to expect at each gate, and when to open a new Claude Code session.

Without SPO: JNMZ receives SDD artifacts and Claude Code directives but must reconstruct
the execution sequence himself. With SPO: he has a checklist with exact commands to paste,
gates to approve, and verification steps after each session.

**When invoked**: After Task Plan Approval, alongside prd-generator (G1.5).
**Output**: `openspec/changes/{change-name}/SPO.md`
**Audience**: JNMZ as human operator — NOT the Claude Code agent.

---

## Step 1 — Read planning artifacts

Read from `openspec/changes/{change-name}/`:
- `tasks.md` — task breakdown, phases, exit criteria
- `PRD.md` — if already generated (read for summary context)
- `design.md` — for architecture context and technology decisions

If `tasks.md` is missing: report "SPO generation blocked — tasks.md not found. Run sdd-tasks first."

---

## Step 2 — Identify waves

A **wave** is a group of tasks that must execute in the same session or can be batched together.
Group tasks into waves based on dependencies and session budget:

**Wave rules**:
- Tasks with dependencies (Task 2 needs Task 1's output) → same wave, sequential
- Tasks that touch different files and can reset → separate waves (different sessions)
- Rule of thumb: each wave = 1 Claude Code session with fresh context
- If all tasks are simple and sequential → single wave is fine

For each wave, determine:
1. What session it opens in (new session vs continuing)
2. The exact command to paste to start it
3. The gates the operator will encounter
4. What to verify when it's done

---

## Step 3 — Write SPO.md

Write to `openspec/changes/{change-name}/SPO.md`:

```markdown
# SPO — {change-name}
*Guía de ejecución para el operador — generada el {ISO date}*
*Este documento es para TI, no para el agente. El agente lee PRD.md + tasks.md.*

---

## Resumen ejecutivo

**Qué se construye**: {1 oración: el resultado visible}
**Waves**: {N waves} — {breve descripción de qué hace cada una}
**Tiempo estimado**: {estimado realista por wave}
**Repo / Proyecto**: {nombre del proyecto}

---

## Preparación (antes de empezar)

- [ ] Repo clonado y actualizado (`git pull`)
- [ ] Branch de trabajo creado: `git checkout -b {branch-name}`
- [ ] Variables de entorno configuradas: {lista si aplica, o "N/A"}

---

## Wave 1: {nombre descriptivo}

### Sesión {1} — {qué logra esta sesión}

**Abre Claude Code en**: `{ruta del proyecto}`

**Pega este comando para iniciar**:
```
Lee PRD.md y tasks.md de {change-name}, implementa {Task N} hasta {Task M}
```

**Lo que verás primero**: {descripción de la primera respuesta del agente}

**Gates que encontrarás**:

| Gate | Qué te presenta el agente | Cómo aprobar |
|------|--------------------------|--------------|
| Execution Gate | Plan de archivos a modificar | Responde "dale" si el scope es correcto |
| {otro gate si aplica} | {qué muestra} | {cómo responder} |

**Al terminar esta sesión, verifica**:
- [ ] {condición verificable 1 — algo visible en el proyecto}
- [ ] {condición verificable 2}

---

## Wave 2: {nombre descriptivo} *(si aplica)*

{repetir estructura de Wave 1}

---

## Gates humanos (resumen)

| Gate | Wave | Qué aprobar | Señal de OK |
|------|------|-------------|-------------|
| Proposal | 1 | Scope y approach | "dale" o "proceed" |
| Task Plan | 1 | Lista de tareas | "dale" o "apruebo" |
| {gate específico} | {N} | {qué decisión} | {cómo aprobar} |

---

## Si algo falla

| Síntoma | Causa probable | Qué hacer |
|---------|----------------|-----------|
| El agente pide clarificación sobre {tema} | {causa} | {acción concreta} |
| Error en {paso} | {causa probable} | {resolver con este comando o acción} |
| El agente parece perdido / repite lo mismo | Contexto saturado | Abre sesión nueva: `lee CHECKPOINT.md de {change-name} y continúa` |

---

## Después de completar

- [ ] Correr verificación: {comando si aplica}
- [ ] Actualizar estado en Notion si aplica
- [ ] Abrir PR: `gh pr create`
```

Keep the SPO under 100 lines per wave. Focus on what the operator DOES, not on technical implementation detail.

---

## Step 4 — Report

Return to pipeline-agent with:

```
STATUS: success
ARTIFACT: openspec/changes/{change-name}/SPO.md
WAVES: {N}
READY_MESSAGE: "SPO listo. Sigue la Wave 1 en SPO.md para iniciar la implementación."
```
