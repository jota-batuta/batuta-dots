---
name: prd-generator
description: >
  Use when creating or reading a PRD — the single planning artifact for any change.
  CTO Desktop writes PRDs to Notion. Claude Code reads them via MCP and executes.
  Trigger: "PRD", "generate PRD", "write PRD", "crear PRD", "directiva".
license: MIT
metadata:
  author: Batuta
  version: "2.0"
  created: "2026-03-30"
  updated: "2026-04-13"
  scope: [pipeline]
  platforms: [claude, antigravity]
allowed-tools: Read Write Glob
---

## Purpose

The PRD is the **single planning artifact** in batuta-dots v15. It replaces the 5-artifact
chain (explore + propose + spec + design + tasks) with ONE document that contains everything
an implementation agent needs.

| Mode | Who | Where | When |
|------|-----|-------|------|
| **Write** | CTO (Desktop) | Notion — child page of project | Before implementation |
| **Read** | Claude Code | Notion MCP or local openspec/ | At implementation start |

---

## PRD Template

```markdown
# PRD — {nombre del cambio}

## Problema
{1 parrafo: que esta roto, para quien, por que importa}

## Solucion
{1-2 parrafos: que se va a construir, como funciona a alto nivel.
 Decisiones de tecnologia y arquitectura SI. Codigo NO.}

## Criterio de exito
- {condicion verificable 1}
- {condicion verificable 2}
- {condicion verificable 3}

## Datos disponibles
- {fuente 1}: {que es, donde esta, que contiene}
- {fuente 2}: {que es, donde esta, que contiene}

## Constraints
- {restriccion critica 1}
- {restriccion critica 2}

## Fuera de alcance
- {que NO se hace en este cambio}
- {que se difiere para despues}
```

**Reglas:**
- Maximo 1-2 paginas. Si crece mas, dividir en cambios separados
- NO incluir: queries SQL, firmas de funciones, pseudocodigo, rutas de archivos
- SI incluir: decisiones de tecnologia, conocimiento de dominio, reglas de negocio
- Criterio de exito debe ser verificable por un agente (no subjetivo)

---

## SPRINT mode (tarea clara, <3 archivos)

No necesita PRD formal. Directiva corta en Notion o mensaje directo:

```markdown
DIRECTIVA: {nombre}
PROBLEMA: {2-3 oraciones}
QUE NECESITO: {resultado en terminos de capacidad}
CRITERIO DE SALIDA: {condicion verificable}
```

---

## For Claude Code: executing from a PRD

### Step 1 — Locate PRD

1. Notion MCP: search project child pages for "PRD" or "directiva"
2. Local fallback: `openspec/changes/{change-name}/PRD.md`
3. If neither: ask user

### Step 2 — Validate

- [ ] Has problem statement
- [ ] Has verifiable success criteria
- [ ] Has "fuera de alcance"
- [ ] Does NOT contain code or SQL

If PRD contains implementation detail → flag: "PRD contiene implementacion.
El CTO decide QUE, el agente decide COMO."

### Step 3 — Execute

Implement using subagents with relevant skills.
Update session.md each interaction. Write discoveries to Notion KB constantly.

### Step 4 — Verify against PRD

Check each "Criterio de exito":
- All met → report success
- Any not met → report what's missing with evidence

---

## What the CTO decides vs what the agent decides

| CTO (in the PRD) | Agent (during implementation) |
|-------------------|------------------------------|
| What technology (embeddings, LLM, OCR) | What functions to create |
| What architectural approach | How to implement it |
| What data exists and what it means | What queries to write |
| What business rules apply | How to code the rules |
| What pattern (CQRS, event sourcing) | How to structure files |

---

## PRD Lifecycle

```
CTO writes PRD in Notion → Code reads via MCP → Implements
    ↕ (discoveries go back to Notion KB constantly)
If pivot: archive PRD as SUPERSEDED → CTO writes new PRD
```
