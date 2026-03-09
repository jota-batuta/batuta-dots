# Team Template: Legacy Refactoring

> **Patron**: A (SDD Pipeline) — flujo secuencial de analisis, implementacion por batches, y verificacion.
> **Stack**: Cualquier lenguaje/framework. Este template es agnostico de tecnologia.
> **Nivel recomendado**: 3 (Agent Team) cuando el refactoring toca multiples modulos y requiere garantia de preservacion de comportamiento.

---

## Cuando Usar

- Codigo legacy que necesita modernizacion sin cambiar comportamiento externo.
- El refactoring es lo suficientemente grande para dividirlo en batches independientes (2+ modulos).
- Se necesita analisis previo de dependencias y riesgos antes de tocar codigo.
- La preservacion de comportamiento debe ser verificada formalmente (tests, no "a ojo").

### Cuando NO Usar

- Renombrar una variable o extraer un metodo — usa solo session.
- Refactoring de un solo archivo — usa subagent.
- Rewrite completo (tirar y rehacer) — este template es para refactoring incremental, no para rewrites.

---

## Composicion

| Teammate | Scope Agent | Responsabilidad | Archivos Propios |
|----------|-------------|-----------------|------------------|
| `analyst` | pipeline-agent | Analisis de codigo, mapeo de dependencias, evaluacion de riesgos | `analysis/**` (solo reportes, no modifica codigo de produccion) |
| `implementor-1` | pipeline-agent | Refactoring batch 1 (Modulo A) | Definidos explicitamente por el Lead en el plan de batches |
| `implementor-2` | pipeline-agent | Refactoring batch 2 (Modulo B) | Definidos explicitamente por el Lead en el plan de batches |
| `reviewer` | quality-agent (recomendado) o pipeline-agent | Verificar que el refactoring preserva comportamiento, ejecutar tests | Ninguno (acceso read-only para revision) |

**Lead owns**: Plan de batches, asignacion de archivos, coordinacion entre batches, resolucion de conflictos.

---

## Contratos

### Input Contracts

| Teammate | Recibe | Formato | De quien |
|----------|--------|---------|----------|
| `analyst` | Codebase actual + areas objetivo del refactoring | Acceso lectura al repo + brief del Lead (Markdown) | Lead |
| `implementor-1` | Reporte de analisis + lista explicita de archivos a refactorizar (batch 1) | `analysis/report.md` + file list del Lead | Lead (despues de que `analyst` termine) |
| `implementor-2` | Reporte de analisis + lista explicita de archivos a refactorizar (batch 2) | `analysis/report.md` + file list del Lead | Lead (despues de que `analyst` termine) |
| `reviewer` | Codigo antes y despues del refactoring + suite de tests | Acceso lectura a archivos modificados + `tests/` | Lead (despues de que implementors terminen) |

### Output Contracts

| Teammate | Produce | Formato | Criterio de exito |
|----------|---------|---------|-------------------|
| `analyst` | Reporte de dependencias + mapa de riesgos + recomendacion de batches | Markdown en `analysis/` | Todos los archivos objetivo mapeados; riesgos clasificados (alto/medio/bajo) |
| `implementor-1` | Codigo refactorizado (batch 1) + tests actualizados | Archivos modificados en sus ubicaciones originales | Tests pasan; comportamiento externo preservado |
| `implementor-2` | Codigo refactorizado (batch 2) + tests actualizados | Archivos modificados en sus ubicaciones originales | Tests pasan; comportamiento externo preservado |
| `reviewer` | Reporte de verificacion: tests, cobertura, backward compatibility | Markdown en `analysis/verification-report.md` | Cero regresiones; cobertura >= nivel pre-refactoring |

---

## File Ownership Map

```
analyst OWNS:
  analysis/**           (reportes de analisis — SOLO lectura del resto del repo)

implementor-1 OWNS:
  {archivos del batch 1}  — definidos EXPLICITAMENTE por el Lead
  Ejemplo: features/moduleA/**, tests/moduleA/**

implementor-2 OWNS:
  {archivos del batch 2}  — definidos EXPLICITAMENTE por el Lead
  Ejemplo: features/moduleB/**, tests/moduleB/**

reviewer OWNS:
  NADA — acceso read-only a todo para verificacion
  Escribe SOLO en: analysis/verification-report.md

Lead OWNS:
  Plan de batches (que archivos van en que batch)
  Archivos compartidos que ambos batches necesitan
  Resolucion de conflictos de integracion
```

> Regla critica: Los archivos de cada implementor se definen ANTES del spawn y no se solapan NUNCA. Si dos modulos comparten un archivo, ese archivo pertenece al Lead.

---

## Cross-Review

| Reviewer | Revisa | Pregunta clave |
|----------|--------|----------------|
| `reviewer` | Cambios de `implementor-1` | "El comportamiento externo se preserva? Los tests cubren los paths criticos?" |
| `reviewer` | Cambios de `implementor-2` | "El comportamiento externo se preserva? Hay regresiones en la integracion?" |
| `implementor-1` | Reporte de `analyst` | "El analisis de dependencias del modulo A es correcto? Falta algun riesgo?" |
| `implementor-2` | Reporte de `analyst` | "El analisis de dependencias del modulo B es correcto? Falta algun riesgo?" |
| `analyst` | Cambios de ambos implementors | "Los cambios respetan las dependencias mapeadas? Se introdujeron nuevos acoplamientos?" |

---

## Flujo de Ejecucion (Secuencial con Paralelismo Interno)

```
FASE 1 — Analisis (secuencial, antes de tocar codigo)
  1. analyst: Mapea dependencias del codebase objetivo
  2. analyst: Evalua riesgos y clasifica (alto/medio/bajo)
  3. analyst: Recomienda division en batches
  4. Lead: Revisa reporte y define plan de batches con file ownership

FASE 2 — Implementacion (PARALELO entre batches)
  5. implementor-1: Refactoriza batch 1 (Modulo A)
  6. implementor-2: Refactoriza batch 2 (Modulo B)
     (en paralelo — sin archivos compartidos)

FASE 3 — Verificacion (secuencial, despues de implementacion)
  7. reviewer: Ejecuta tests sobre batch 1
  8. reviewer: Ejecuta tests sobre batch 2
  9. reviewer: Verifica integracion entre batches
  10. reviewer: Genera reporte de verificacion

FASE 4 — Consolidacion
  11. Lead: Integra hallazgos, resuelve conflictos
  12. Cross-review final entre todos los teammates
  13. Lead: Presenta resultado al usuario
```

---

## Enfoque en Preservacion de Comportamiento

El principio fundamental de este template: **el codigo nuevo debe hacer EXACTAMENTE lo mismo que el codigo viejo desde la perspectiva externa**.

### Estrategias de Verificacion

| Estrategia | Cuando usar | Como |
|-----------|-------------|------|
| Tests existentes | Hay buena cobertura de tests | Ejecutar suite completa antes y despues — cero diferencias |
| Tests nuevos | Cobertura insuficiente | `analyst` identifica paths sin cobertura; implementors escriben tests ANTES de refactorizar |
| Snapshot testing | Outputs complejos (JSON, HTML, reports) | Capturar outputs pre-refactoring; comparar post-refactoring |
| Backward compatibility | APIs publicas o interfaces compartidas | Verificar que signatures, return types, y side effects no cambian |

### Regla de Oro

> Si no hay tests que demuestren que el comportamiento se preserva, el refactoring NO esta completo — sin importar que tan limpio quede el codigo.

---

## Lecciones Aprendidas

- **Analisis primero, siempre** — tocar codigo legacy sin entender dependencias es la receta para romper cosas inesperadas.
- **Batches independientes** — si dos batches comparten archivos, el plan de batches esta mal diseynado. Redisenyar antes de implementar.
- **Tests antes del refactoring** — si la cobertura es baja, el primer paso es escribir tests que capturen el comportamiento actual. Despues refactorizar.
- **Commits atomicos** — cada cambio de refactoring debe poder revertirse independientemente. Commits grandes = rollback imposible.
- **No mejorar y refactorizar al mismo tiempo** — si el refactoring introduce nuevos features o "mejoras", la verificacion de preservacion de comportamiento se vuelve imposible.
- **El reviewer es sagrado** — nunca asignar tareas de implementacion al reviewer. Su independencia garantiza objetividad.

---

## Checklist Pre-Spawn

Antes de crear el equipo, el Lead verifica:

- [ ] Modulos objetivo del refactoring identificados
- [ ] Cobertura de tests actual evaluada (suficiente para verificar preservacion?)
- [ ] Division en batches definida (sin archivos compartidos entre batches)
- [ ] Archivos de cada batch listados explicitamente (file ownership claro)
- [ ] Criterio de exito definido (que significa "refactoring exitoso"?)
- [ ] Estrategia de rollback definida (como revertir si algo sale mal?)
- [ ] Backward compatibility requirements documentados (APIs publicas, interfaces externas)

---

**Nota v13**: Los domain agents (backend-agent, quality-agent, data-agent) aportan expertise embebida de dominio. quality-agent es el agente recomendado para `reviewer` porque trae expertise en TDD, debugging sistematico, y seguridad. quality-agent esta disponible en todo proyecto.
