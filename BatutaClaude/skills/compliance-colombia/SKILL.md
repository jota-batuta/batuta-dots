---
name: compliance-colombia
description: >
  Use when handling Colombian data protection, tax retention, or AI compliance.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-23"
  source: "CTO Layer skill 06"
  scope: [pipeline]
  auto_invoke: false
allowed-tools: Read, Glob, Grep, WebSearch
platforms: [claude, antigravity]
---

# Compliance Colombia — Regulatory Specialist

## Purpose

Asegurar que cada solucion Batuta cumpla con la regulacion colombiana vigente — proteccion de datos, IA, tributaria — y que el roadmap de certificaciones avance de forma pragmatica sin paralizar la operacion.

**Regla**: Cumple hoy con lo vinculante, preparate para lo que viene.

## When to Invoke

- sdd-design toca datos personales o registros financieros
- Proceso usa IA/LLM sobre datos personales
- Integracion con APIs internacionales (Anthropic, OpenAI, Google)
- Solicitud de eliminacion de datos (habeas data)
- Nuevo tenant onboarding (politica de privacidad)
- Evaluacion de certificacion (SOC 2, ISO 27001, ISO 42001)

## Does NOT Handle

- Implementacion tecnica de seguridad (→ security-audit)
- Diseno de arquitectura (→ sdd-design)
- Interpretacion tributaria especifica (→ domain-experts.md Finance)

## Regulacion Vinculante

### Ley 1581/2012 — Habeas Data

**Aplica cuando**: Cualquier proceso toca datos personales.

**Assessment rapido:**

- [ ] Toca datos personales? Si no, no aplica
- [ ] Hay consentimiento del titular?
- [ ] Finalidad documentada?
- [ ] Canal de rectificacion/eliminacion existe?
- [ ] Transferencia a terceros? Contrato de transmision

### Circular SIC 002/2024 — IA y Datos Personales

**Aplica cuando**: Un proceso usa IA/ML/LLM sobre datos personales.

**Test de Proporcionalidad (4 partes — obligatorio):**

| Parte | Pregunta | Documentar |
|-------|----------|------------|
| 1. Idoneidad | El tratamiento con IA es adecuado para el fin? | Si + evidencia |
| 2. Necesidad | No hay alternativa menos invasiva? | Alternativas evaluadas |
| 3. Proporcionalidad | El beneficio supera el riesgo para el titular? | Analisis riesgo/beneficio |
| 4. Garantias | Que medidas minimizan el impacto? | Presidio, encryption, ZDR |

**Principios**: Precaucion, Privacy by Design, Responsabilidad demostrada.

### Art. 632 Estatuto Tributario

**Obligacion**: Conservar pruebas contables por 5 anos.

### Tombstoning Pattern

Cuando aplica habeas data + conservacion tributaria:
1. **Eliminar**: datos de acceso, marketing, perfilamiento
2. **Retener**: registros transaccionales en almacenamiento frio
3. **Crypto shredding**: destruir KEK para datos eliminados

### Transferencia Internacional

APIs LLM (Anthropic/US, OpenAI/US, Google/US):
- US no es pais adecuado segun SIC → requiere contrato
- APIs LLM = transmision (Batuta controlador, LLM procesador)
- Mitigacion: contrato + PII stripping (Presidio) + ZDR

### Notificacion de Brechas

- Plazo: 15 dias habiles ante SIC
- Contenido: naturaleza, datos afectados, medidas, plan remediacion

## Roadmap de Certificaciones

Fase 1 (Mes 1-6): SOC 2 Type 1
Fase 2 (Mes 6-12): ISO 27001
Fase 3 (Mes 12-18): ISO 42001 (30-40% mas rapido con ISO 27001)

## Output Files

- `compliance-assessment-{nombre}-{fecha}.md`
- `test-proporcionalidad-{nombre}-{fecha}.md`
- `transfer-assessment-{nombre}-{fecha}.md`

## Handoff

- **sdd-design**: Compliance integrado en threat model + data flow
- **sdd-verify**: Checklist de compliance como validacion cruzada
- **security-audit**: Implementacion tecnica de medidas
