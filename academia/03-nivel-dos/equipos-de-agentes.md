# Equipos de agentes

Ya conoces los 3 niveles: Solo, Subagente, y Agent Team. Con 6 agentes disponibles (3 scope + 3 domain), aqui aprendes cuando y como usar cada uno para maximizar resultados.

---

## El arbol de decision completo

```
Nueva tarea llega
  |
  Q1: Cuantos archivos?
  |
  +-- 1 archivo
  |     -> NIVEL 1 (solo session)
  |     Ejemplo: arreglar bug, editar config
  |
  +-- 2-3 archivos, mismo scope
  |     -> NIVEL 2 (subagente)
  |     Ejemplo: agregar endpoint + test + docs
  |
  +-- 4+ archivos O multi-scope
        |
        Q2: Necesitan comunicarse?
        |
        +-- No (tareas independientes)
        |     -> NIVEL 2 (subagentes en paralelo)
        |     Ejemplo: 3 endpoints independientes
        |
        +-- Si (decisiones compartidas)
              |
              Q3: Hay riesgo de conflicto de archivos?
              |
              +-- No (archivos diferentes)
              |     -> NIVEL 3 (Agent Team)
              |     Ejemplo: frontend + backend + BD
              |     Domain agents como teammates especializados
              |
              +-- Si (mismos archivos)
                    -> NIVEL 2 (subagentes secuenciales)
                    Ejemplo: refactoring en cascada
```

---

## Los 4 patrones de equipo

### Patron A: SDD Pipeline Team

Para implementar una feature completa:

| Teammate | Fase | Tarea | Domain Agent opcional |
|----------|------|-------|---------------------|
| researcher | explore + propose | Investigar y proponer | — |
| architect | spec + design | Especificar y disenar | backend-agent o data-agent |
| implementor-1 | apply batch 1 | Implementar backend | backend-agent |
| implementor-2 | apply batch 2 | Implementar frontend | — |
| reviewer | verify | Verificar todo | quality-agent |

### Patron B: Revision Paralela (Piramide)

Para revisar codigo exhaustivamente:

| Teammate | Capa | Que revisa |
|----------|------|-----------|
| static-reviewer | L1 | Lint, tipos, formateo |
| test-reviewer | L2-L3 | Tests unitarios y E2E |
| security-reviewer | Transversal | OWASP, secrets, auth |
| perf-reviewer | Transversal | N+1 queries, memoria |

### Patron C: Investigacion

Para debugging complejo:

| Teammate | Hipotesis | Enfoque |
|----------|----------|---------|
| hypothesis-1 | Problema de red | Trazar API calls |
| hypothesis-2 | Bug de estado | Trazar mutaciones |
| hypothesis-3 | Error de config | Revisar env vars |

### Patron D: Cross-Layer

Para cambios que cruzan capas:

| Teammate | Capa | Archivos | Domain Agent |
|----------|------|----------|-------------|
| backend-dev | API | Routes, services | backend-agent |
| frontend-dev | UI | Components, pages | — |
| infra-dev | Deploy | Docker, CI/CD | — |
| quality-dev | Tests | E2E, integration | quality-agent |

Los domain agents aportan expertise de dominio al equipo — en vez de un agente generico, el equipo tiene un especialista. Por ejemplo, backend-agent sabe de patrones FastAPI y JWT, mientras que data-agent conoce ETL y pipelines de datos.

---

## Contract-First en la practica

Antes de crear un equipo, el lead define para cada teammate:

```
CONTRATO teammate: backend-dev
  Recibe: spec.md + design.md
  Produce: routes/, services/, tests/
  Archivos: SOLO toca features/api/**
  NO toca: features/ui/**, core/**
```

Si un teammate intenta tocar archivos que no le pertenecen, el sistema lo detecta.

---

## Costos y cuando vale la pena

| Nivel | Costo tokens | Vale la pena cuando |
|-------|-------------|---------------------|
| 1 | 1x | Siempre para tareas simples |
| 2 | 1.2-1.5x | Tareas medianas, ganas velocidad |
| 3 | 3-5x | Tareas complejas, ganas calidad y paralelismo |

**Regla**: Si la tarea te tomaria mas de 2 horas en Nivel 1, probablemente vale Nivel 3. Los domain agents no agregan costo extra — son expertise embebido, no agentes adicionales.

---

-> [Compliance y datos](compliance-y-datos.md) — Regulacion y pipelines
