---
name: recursion-designer
description: >
  Designs mechanisms for automated systems to handle external change without breaking.
  Unknown detection, human approval of new knowledge, controlled propagation, and
  rule versioning. Use whenever a process uses categories controlled by someone outside
  the system.
  Trigger: cambio externo, categorias que cambian, diccionario dinamico, sistema que
  aprende, versionado de reglas, aprobacion humana, propagacion retroactiva.
license: MIT
metadata:
  author: Batuta
  version: "1.0"
  created: "2026-02-23"
  source: "CTO Layer skill 15"
  scope: [pipeline]
  auto_invoke: false
allowed-tools: Read, Glob, Grep, WebSearch
---

# Recursion Designer — Learning Systems

## Purpose

Disenar mecanismos para que sistemas automatizados detecten cambio externo,
lo procesen controladamente, y se actualicen sin romper resultados historicos.

**Regla**: Un sistema que no sabe que no sabe es mas peligroso que uno que sabe que no sabe.

## When to Invoke

- process-analyst detecta taxonomias externas
- Proceso usa categorias controladas por terceros
- Se necesita que el sistema aprenda sin romper lo existente

## 4 Mecanismos

### 1 — Deteccion de Desconocidos

Si valor NO esta en diccionario → NO clasificar → registrar DESCONOCIDO con contexto → escalar.

Comportamiento configurable por proceso:
- **BLOQUEAR**: resultado para cliente, regulatorio/legal
- **CONTINUAR CON MARCA**: procesamiento interno, alta frecuencia/bajo impacto
- **ESCALAR INMEDIATO**: regulatorio + urgente

### 2 — Aprobacion Humana

Sistema propone, humano decide: MAPEAR A EXISTENTE / CREAR NUEVO / CREAR ALIAS / DESCARTAR.

Aprobadores por dominio:
| Dominio | Aprobador | Backup |
|---------|-----------|--------|
| Conceptos bancarios | Tesorero | Dir. financiero |
| Cuentas contables | Contador | Dir. financiero |
| Competencias cargo | Hiring manager | RRHH |
| Categorias gasto | Aprobador presupuesto | Gerente |
| Codigos producto | Resp. inventario | Jefe compras |
| Tasas regulatorias | Contador/tributario | Esperar |

### 3 — Propagacion Controlada

- **FORWARD** (default): desde fecha aprobacion, nuevos casos usan nuevo mapeo
- **BACKWARD** (requiere autorizacion): calcular impacto primero
  - SOLO PENDING: reclasificar pendientes (recomendado)
  - TODOS HISTORICOS: incluir entregados (notificar receptores)
  - NO RECLASIFICAR: solo adelante

**Regla de oro**: Nunca modificar silenciosamente resultado ya entregado.

### 4 — Versionado Inmutable

Cada version del diccionario es inmutable. Solo una activa a la vez. Anteriores para audit.
Toda clasificacion registra version del diccionario usada.

Queries de auditoria:
- Con que logica se clasifico este registro en fecha X?
- Que habria pasado con diccionario vN desde el inicio?

## Output: 7 Decisiones de Diseno

1. Que diccionarios existen en el proceso?
2. Comportamiento ante desconocido (por diccionario)?
3. Quien aprueba nuevo conocimiento?
4. Se requiere doble aprobacion?
5. Politica de retroactividad?
6. Que necesita ver el aprobador para decidir?
7. Como se notifica cuando algo cambia externamente?

## Output Files

- `learning-design-{nombre}-{fecha}.md`
- `dictionary-schema-{nombre}-{fecha}.md`
- `approval-flow-{nombre}-{fecha}.md`
- `propagation-policy-{nombre}-{fecha}.md`

## Handoff

- **sdd-design**: 4 mecanismos con parametros especificos
- **sdd-design (LLM)**: Diccionario activo como contexto prompt
- **sdd-verify**: Test unknown detection + versioning reproducibility
