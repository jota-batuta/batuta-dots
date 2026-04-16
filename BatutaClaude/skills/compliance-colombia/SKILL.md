---
name: compliance-colombia
description: >
  Use when handling Colombian data protection, tax retention, or AI compliance.
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-23"
  source: "CTO Layer skill 06"
  bucket: review
  auto_invoke: false
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep WebSearch
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

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "Compliance comes later, primero el MVP" | Habeas data y consentimiento se disenan en el modelo de datos. Retrofittear compliance cuesta 10x mas y suele requerir re-onboarding de usuarios. Compliance es un requisito de arquitectura, no un wrapper. |
| "Ley 1581 es opcional para empresas pequenas" | Aplica a TODO responsable que trate datos personales en territorio colombiano. La SIC sanciona PYMES — multas hasta 2,000 SMLMV (~COP $2,600M). El tamano de la empresa no exime del cumplimiento. |
| "Usar APIs de USA no es transferencia internacional" | Anthropic, OpenAI, Google estan en US. Cada llamada con datos personales = transferencia internacional. US no es pais adecuado segun SIC. Requiere contrato + mitigacion (PII stripping + ZDR). |
| "Si el dato esta anonimizado no aplica habeas data" | "Anonimizado" en sentido estricto requiere irreversibilidad demostrable. Hashing, pseudonimizacion, y data mascarada NO son anonimizacion — siguen siendo datos personales bajo Ley 1581. |
| "El test de proporcionalidad es opcional" | Circular SIC 002/2024 lo hace obligatorio para todo tratamiento con IA sobre datos personales. Sin documentacion del test, el tratamiento es ilegal aunque tecnicamente funcione. |

## Red Flags

- Procesar datos personales sin politica de privacidad publicada y aceptada por el titular
- Llamadas a APIs LLM (Anthropic/OpenAI/Google) con datos personales sin contrato de transmision firmado
- No tener canal documentado para solicitudes de habeas data (rectificacion, eliminacion, acceso)
- Eliminar registros transaccionales antes de los 5 anos del Art. 632 ET
- Modificar registros transaccionales para "cumplir" habeas data (debe ser tombstoning, no UPDATE)
- Brechas no notificadas a SIC en plazo de 15 dias habiles
- Tratamiento con IA sin test de proporcionalidad documentado (las 4 partes)
- Logs de produccion conteniendo PII sin politica de retencion definida
- Compartir datos con terceros sin contrato de transmision o sin clausula de confidencialidad
- Asumir que ISO 27001 == cumplimiento Ley 1581 (son complementarios, no equivalentes)

## Verification Checklist

- [ ] Existe politica de privacidad publicada, accesible, y aceptada por el titular antes del tratamiento
- [ ] Se documenta finalidad especifica para cada tratamiento de datos personales (no "uso general")
- [ ] Hay canal de habeas data funcional: solicitudes de acceso, rectificacion, eliminacion procesadas
- [ ] Si se usa IA sobre datos personales: test de proporcionalidad completo (4 partes documentadas)
- [ ] Si se transfiere datos a terceros internacionales: contrato firmado + mitigacion (PII stripping, ZDR, encriptacion)
- [ ] Tombstoning implementado: separar datos de acceso/marketing (eliminables) de transaccionales (retenidos 5 anos)
- [ ] Crypto shredding configurado para datos eliminados (KEK destruido)
- [ ] Procedimiento de notificacion de brechas documentado con plazo de 15 dias habiles
- [ ] Roadmap de certificaciones definido (SOC 2 → ISO 27001 → ISO 42001) con responsable y fecha
- [ ] Logs de produccion no contienen PII sin polincia de retencion explicita
- [ ] Compliance Officer (interno o externo) revisa cambios que tocan datos personales
- [ ] Output files generados: compliance-assessment, test-proporcionalidad, transfer-assessment (si aplica)
