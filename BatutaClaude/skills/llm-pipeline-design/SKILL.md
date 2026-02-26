---
name: llm-pipeline-design
description: >
  Use when designing LLM classification, prompts, confidence, or drift detection.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-23"
  source: "CTO Layer skill 03"
  scope: [pipeline]
  auto_invoke: false
allowed-tools: Read, Glob, Grep, WebSearch
platforms: [claude, antigravity]
---

# LLM Pipeline Design — Intelligence Specialist

## Purpose

Disenar pipelines de inteligencia calibrados con data real del cliente, auto-supervisados, y con observabilidad total via Langfuse.

**Regla**: Si no puedes medir la confianza, no lo pongas en produccion.

## When to Invoke

- sdd-design incluye seccion LLM Pipeline Design
- Nuevo clasificador o evaluador con IA
- Prompt engineering con data del cliente
- Confidence scoring o drift detection

## Pipeline de 6 Fases

### Fase 1: Extraccion
Validar data suficiente: minimo 100 registros por categoria, labels, edge cases.

### Fase 2: Analisis Estadistico
Patrones ANTES de LLM: distribuciones, correlaciones, anomalias, clusters.

### Fase 3: ML Clasico (Baseline)
Si F1 >0.85 → NO usar LLM. Split 70/15/15.

### Fase 4: Capa LLM

**Model Routing:**

| Tarea | Modelo | Razon |
|-------|--------|-------|
| Clasificacion clara | Haiku / gpt-4o-mini | Patrones en prompt |
| Clasificacion ambigua | Sonnet / gpt-4o | Edge cases |
| Evaluacion compleja | Sonnet / Opus | Juicio fino |
| Formateo/extraccion | Haiku / gpt-4o-mini | Alto volumen |

Prompt versionado: `PROMPT_ID: {domain}-{function}-{task}, VERSION: v{X}.{Y}.{Z}`

### Fase 5: Auto-supervision

**Confidence Scoring (4 niveles):**
1. Structural Validation (determinista)
2. LLM-as-Judge (10-20% traces)
3. Self-Consistency (decisiones criticas, 3x)
4. Self-Report (triage, 1-10)

**Drift Detection:**

| Tipo | Senal | Accion |
|------|-------|--------|
| Data Drift | Inputs cambian | Re-calibrar Fase 2 |
| Concept Drift | Input→output cambia | Re-entrenar + re-calibrar |
| Model Drift | Performance baja | Evaluar nuevo modelo |
| Prompt Drift | Efectividad baja | Re-generar con data fresca |

### Fase 6: Trazabilidad
Langfuse obligatorio: tenant_id, model, prompt_version, confidence, cost, PII-redacted.

## Output Files

- `pipeline-design-{nombre}-{fecha}.md`
- `data-patterns-{nombre}-{fecha}.md`
- `prompt-{domain}-{function}-{task}-v{X}.md`
- `model-evaluation-{nombre}-{fecha}.md`

## Handoff

- **sdd-design**: Pipeline como seccion condicional LLM
- **sdd-verify**: Golden datasets + confidence thresholds (Type B/C)
- **data-pipeline-design**: Datos de entrada
- **compliance-colombia**: Test proporcionalidad SIC 002/2024
