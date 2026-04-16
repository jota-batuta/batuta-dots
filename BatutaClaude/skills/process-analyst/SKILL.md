---
name: process-analyst
description: >
  Use when a process has 3+ case types requiring different handling.
license: MIT
metadata:
  author: Batuta
  version: "1.1"
  created: "2026-02-23"
  source: "CTO Layer skill 14"
  bucket: define
  auto_invoke: false
  platforms: [claude, antigravity]
allowed-tools: Read Glob Grep WebSearch
---

# Process Analyst — Variant Mapping Specialist

## Purpose

Cerrar el universo completo de variantes de cualquier proceso antes de disenar.
El happy path es el 20% del esfuerzo. El 80% esta en los casos que nadie menciona.

## When to Invoke

- sdd-explore detecta multiples variantes o tipos de caso
- Proceso con excepciones frecuentes
- Taxonomias externas (categorias controladas por terceros)

## Framework: 6 Fases

### Fase 1 — Inventario Inicial

10 preguntas universales:

1. **Universo de entradas**: Que tipos distintos de caso puede recibir?
2. **Comportamiento diferenciado**: Hay casos donde se hace algo diferente?
3. **Casos problematicos**: Cuales toman mas tiempo o generan mas errores?
4. **Excepciones conocidas**: Que casos se manejan diferente a la regla general?
5. **Categorias externas**: Usa clasificaciones de otro sistema/proveedor/regulador?
6. **Actores**: Quien ejecuta? Quien decide? De donde viene cada dato?
7. **Casos sin regla clara**: Hay casos donde hay que "pensar" o "consultar"?
8. **Rechazados/escalados**: Hay casos que el proceso no maneja?
9. **Frecuencia y volumen**: Cuanto representa cada tipo del total?
10. **Cambio historico**: Ha cambiado en los ultimos 12 meses?

Output: Lista bruta sin estructura. Incluir contradicciones.

### Fase 2 — Arbol de Variantes

Estructura cerrada donde cada caso tiene un lugar:

```
PROCESO: [nombre]
CRITERIO PRINCIPAL: [que hace a cada caso diferente]

+-- VARIANTE A: [nombre]
|   +-- Criterio identificacion
|   +-- Origen dato principal
|   +-- Actor(es) involucrado(s)
|   +-- Logica especifica
|   +-- Excepciones: [descripcion + frecuencia + manejo]
|   +-- Output esperado
|
+-- VARIANTE B: [misma estructura]
|
+-- EXCEPCIONES TRANSVERSALES: [afectan multiples tipos]
|
+-- CASO NO CLASIFICABLE:
    +-- Definicion + Frecuencia + Manejo
```

Reglas: cada hoja tiene manejo, cada bifurcacion tiene criterio, "no se" = gap pendiente.

### Fase 3 — Catalogo Taxonomias Externas

Para cada taxonomia: tipo, quien controla, donde se usa, version actual, historial cambios, frecuencia cambio, quien detecta, que pasa cuando cambia.

**Si existen taxonomias → sugerir /recursion-designer.**

| Dominio | Taxonomia | Quien controla |
|---------|-----------|----------------|
| Conciliacion bancaria | Conceptos extracto | El banco |
| Facturas | Cuentas contables | El cliente (ERP) |
| Candidatos | Competencias cargo | Area solicitante |
| Inventario | Codigos producto | El proveedor |
| Nomina | Tablas aportes | Regulador (UGPP) |

### Fase 4 — Mapa de Actores por Variante

Por variante: ejecutor, fuente dato entrada, actor externo (formato, ambiguedades, resolucion), decisor cuando hay duda.

### Fase 5 — Catalogo de Excepciones

Por excepcion: variante, frecuencia, trigger, evidencia, impacto, manejo, tiempo resolucion.

| Nivel | Descripcion | Manejo |
|-------|-------------|--------|
| Simple | Regla clara | Automatico |
| Medio | Ambiguedad | Automatico + log + revision |
| Complejo | Requiere juicio | Cola revision humana |
| Bloqueante | Sin manejo | Escalacion inmediata |

### Fase 6 — Validacion de Cierre

Checklist antes de handoff:
- [ ] Cada variante tiene criterio de identificacion
- [ ] Cada variante tiene logica de manejo
- [ ] Cada bifurcacion tiene criterio de decision
- [ ] Hay rama para caso no clasificable
- [ ] Taxonomias externas catalogadas
- [ ] Actores identificados por variante
- [ ] Excepciones tienen logica de manejo
- [ ] Volumen estimado por variante
- [ ] Equipo del proceso reviso el arbol

## Output Files

- `process-inventory-{nombre}-{fecha}.md`
- `variant-tree-{nombre}-{fecha}.md`
- `taxonomy-catalog-{nombre}-{fecha}.md`
- `actor-map-{nombre}-{fecha}.md`
- `exception-catalog-{nombre}-{fecha}.md`
- `process-closure-{nombre}-{fecha}.md`

## Handoff

- **sdd-design**: Arbol cerrado + taxonomias + actores + excepciones
- **recursion-designer**: Catalogo taxonomias externas con volatilidad
- **sdd-design (LLM)**: Arbol como contexto prompt + excepciones como golden set

## Common Rationalizations

| Rationalization | Reality |
|-----------------|---------|
| "3 case types = simple process — we don't need full variant mapping" | 3 visible case types is the warning sign, not the simplification. Each "simple" case has 2-5 hidden sub-variants (excepciones, casos sin regla, escalados). The happy path is 20% of the work; the other 80% lives in unmentioned variants. Skipping the full inventory means rebuilding mid-implementation. |
| "Variants will be discovered during implementation" | Discovering variants during implementation = rework. Each new variant invalidates: data model, prompts, golden dataset, validation logic, UI flows. Variant inventory is the cheapest phase; deferring it makes every later phase more expensive. |
| "Excepciones are edge cases — we'll handle them in v2" | Excepciones are the process. In Colombian operations (banking, ERP, payroll), excepciones are 30-60% of real volume. A system that handles only "normal" cases will route majority of work to humans, defeating the purpose of automation. |

## Red Flags

- Variant tree has fewer than 4 leaves — almost certainly missing variants.
- No "CASO NO CLASIFICABLE" branch in the tree — system has nowhere to route unknowns.
- Excepciones catalog has fewer entries than variants — under-specified failure modes.
- Taxonomías externas listed without a "quien controla" column — no plan for when they change.
- Variants without volumen estimado — cannot prioritize implementation order.
- Process owner (cliente, equipo del proceso) has NOT reviewed the variant tree.
- Tree leaves marked "TBD" or "no se" — gaps that will surface as production bugs.
- No actor map per variant — unclear who decides when ambiguity arises.
- Excepciones without manejo defined — silent drop or escalation chaos.
- Single decision criterion at every bifurcación — usually means real criteria are hidden.

## Verification Checklist

- [ ] Fase 1 inventory ran all 10 universal questions, captured contradictions
- [ ] Variant tree has ≥4 leaves AND every leaf has manejo defined
- [ ] Every bifurcación in the tree has an explicit criterio de decisión
- [ ] "CASO NO CLASIFICABLE" branch exists with definición + frecuencia + manejo
- [ ] Taxonomías externas catalog complete: tipo, quien controla, version, frecuencia cambio, quien detecta
- [ ] Recursion-designer invoked if any external taxonomy exists
- [ ] Actor map exists for every variant: ejecutor, fuente dato, decisor
- [ ] Excepciones catalog includes: variante afectada, frecuencia, trigger, evidencia, manejo, tiempo resolución
- [ ] Excepciones classified by nivel: simple / medio / complejo / bloqueante
- [ ] Volumen estimado per variant (% of total) — drives implementation priority
- [ ] Equipo del proceso (cliente operations team) reviewed and signed off on the tree
- [ ] No "TBD" or "pendiente" leaves remain — gaps explicitly documented as risks
- [ ] Output handoff to sdd-design includes tree + taxonomías + actores + excepciones
