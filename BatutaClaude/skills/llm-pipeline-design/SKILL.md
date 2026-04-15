---
name: llm-pipeline-design
description: >
  Use when designing LLM classification, prompts, confidence, or drift detection.
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-23"
  source: "CTO Layer skill 03"
  scope: [pipeline]
  auto_invoke: false
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep WebSearch
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

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "LLMs are always better than ML — skip the baseline" | If a logistic regression hits F1 >0.85, it costs 1000x less per inference, has predictable latency, and never hallucinates. Skipping the baseline means paying LLM costs for problems that don't need an LLM. |
| "Confidence scoring is extra complexity — we'll add it later" | Without confidence, you cannot route low-confidence cases to human review, cannot detect drift, and cannot prove the system works. "Later" usually means "after a production incident embarrassed us." |
| "One prompt version is enough for now" | Prompts drift as data drifts. Without versioning (`PROMPT_ID + version`), you cannot A/B test, cannot roll back, and cannot tie quality regressions to a specific prompt change. |

## Red Flags

- LLM call without a corresponding ML baseline measurement — no proof the LLM is needed.
- No confidence score on output — downstream consumers cannot distinguish high-trust from speculation.
- Prompts hardcoded in code with no version field, no metadata, no provenance.
- Single model used for all tasks (no routing by complexity) — paying Sonnet/Opus prices for Haiku-class work.
- No Langfuse traces (or equivalent) — cannot measure cost per tenant, cannot audit decisions.
- PII leaked into prompts or traces — compliance violation.
- No drift detection — model performance silently degrades.
- Self-consistency or LLM-as-judge skipped on critical decisions.

## Verification Checklist

- [ ] Phase 2 statistical analysis run BEFORE Phase 4 LLM (patterns identified deterministically)
- [ ] Phase 3 ML baseline measured; LLM justified only if baseline F1 < 0.85
- [ ] Model routing table defined: Haiku/mini for clear cases, Sonnet/4o for ambiguous, Opus for complex judgment
- [ ] Every prompt has `PROMPT_ID: {domain}-{function}-{task}` and version `vX.Y.Z`
- [ ] Confidence scoring implemented at appropriate level (structural validation minimum, LLM-judge for 10-20% of traces)
- [ ] Self-consistency (3x sampling) on critical decisions
- [ ] Drift detection configured: data drift, concept drift, model drift, prompt drift
- [ ] Langfuse (or equivalent) traces every call with tenant_id, model, prompt_version, confidence, cost
- [ ] PII redacted before prompt construction (Presidio or equivalent)
- [ ] Golden dataset exists with confidence thresholds defined per output type
