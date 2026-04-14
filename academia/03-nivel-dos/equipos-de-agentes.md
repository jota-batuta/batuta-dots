# Equipos de agentes

Ya conoces los 3 niveles: Solo, Subagentes, y Agent Team. Con 5 agentes en el hub y la capacidad de crear agentes nuevos via agent-hiring, aqui aprendes cuando y como usar cada nivel para maximizar resultados.

Recuerda: en v15, el agente principal NUNCA ejecuta — siempre contrata. La diferencia entre niveles es cuantos agentes se contratan y como se coordinan.

---

## El arbol de decision completo

```
Nueva tarea llega
  |
  Q1: Cuantos archivos?
  |
  +-- 1 archivo
  |     -> NIVEL 1 (contratar 1 agente)
  |     Ejemplo: arreglar bug, editar config
  |
  +-- 2-3 archivos, mismo dominio
  |     -> NIVEL 2 (contratar agentes en secuencia)
  |     Ejemplo: agregar endpoint + test + docs
  |
  +-- 4+ archivos O multi-dominio
        |
        Q2: Necesitan comunicarse?
        |
        +-- No (tareas independientes)
        |     -> NIVEL 2 (agentes en paralelo)
        |     Ejemplo: 3 endpoints independientes
        |
        +-- Si (decisiones compartidas)
              |
              Q3: Hay riesgo de conflicto de archivos?
              |
              +-- No (archivos diferentes)
              |     -> NIVEL 3 (Agent Team)
              |     Ejemplo: frontend + backend + BD
              |
              +-- Si (mismos archivos)
                    -> NIVEL 2 (agentes secuenciales)
                    Ejemplo: refactoring en cascada
```

---

## Los 4 patrones de equipo

### Patron A: SDD Pipeline Team

Para implementar una feature completa:

| Teammate | Fase | Agente contratado | Archivos |
|----------|------|-------------------|----------|
| researcher | explore | pipeline-agent | openspec/ |
| architect | design | pipeline-agent + backend-agent | openspec/ |
| implementor-api | apply | backend-agent | src/api/**, src/services/** |
| implementor-data | apply | data-agent | src/pipelines/** |
| reviewer | verify | quality-agent | tests/** |

Cada teammate se contrata con el protocolo de agent-hiring. Cada uno tiene file ownership exclusivo.

### Patron B: Revision Paralela (Piramide)

Para verificar codigo exhaustivamente:

| Teammate | Capa | Agente contratado |
|----------|------|-------------------|
| static-reviewer | L1 | quality-agent (tdd-workflow) |
| test-reviewer | L2-L3 | quality-agent (e2e-testing) |
| security-reviewer | Transversal | quality-agent (security-audit) |
| perf-reviewer | Transversal | quality-agent (performance-testing) |

### Patron C: Investigacion

Para debugging complejo o research en paralelo:

| Teammate | Hipotesis | Agente contratado |
|----------|----------|-------------------|
| hypothesis-1 | Problema de API | backend-agent |
| hypothesis-2 | Problema de datos | data-agent |
| hypothesis-3 | Problema de infra | infra-agent |

5 agentes investigando en paralelo = discovery en minutos.

### Patron D: Cross-Layer

Para cambios que cruzan capas:

| Teammate | Capa | Agente contratado | Archivos |
|----------|------|-------------------|----------|
| backend-dev | API | backend-agent | src/api/** |
| frontend-dev | UI | agente ad-hoc (react-nextjs) | src/app/** |
| infra-dev | Deploy | infra-agent | Dockerfile, .github/** |
| quality-dev | Tests | quality-agent | tests/** |

---

## Contract-First en la practica

En v15, el contrato se define antes de crear el equipo. Cada teammate tiene:

```
CONTRATO teammate: backend-dev
  Agente: backend-agent
  Recibe: design.md + PRD
  Produce: routes/, services/
  Archivos: SOLO toca src/api/**
  NO toca: src/app/**, tests/**, core/**
  Skills: fastapi-crud, jwt-auth, api-design
```

Si un teammate intenta tocar archivos que no le pertenecen, el sistema lo detecta. Esto previene conflictos entre agentes que trabajan en paralelo.

---

## Creando agentes nuevos para el equipo

Si el equipo necesita un agente que no existe, el protocolo de agent-hiring se aplica:

1. El agente principal detecta la necesidad ("necesito expertise en React para el frontend")
2. Busca en `.claude/agents/` y `~/.claude/agents/` — no encuentra match
3. Propone contratacion al usuario:

```
PROPUESTA DE CONTRATACION:

Agente: react-frontend
Rol: Implementar componentes React/Next.js
Skills: react-nextjs
Modelo: sonnet
Max turns: 20
Entregable: Componentes + paginas en src/app/**

Apruebas esta contratacion?
```

4. Con aprobacion, crea `.claude/agents/react-frontend.md`
5. Lo integra al equipo con su contrato de file ownership

El agente queda disponible para futuros equipos — no se pierde.

---

## Costos y cuando vale la pena

| Nivel | Costo tokens | Vale la pena cuando |
|-------|-------------|---------------------|
| 1 | 1x | Siempre para tareas simples |
| 2 | 1.2-1.5x | Tareas medianas, ganas velocidad |
| 3 | 3-5x | Tareas complejas, ganas calidad y paralelismo |

**Regla**: Si la tarea te tomaria mas de 2 horas en Nivel 1, probablemente vale Nivel 3.

**Research en paralelo**: Uno de los mayores beneficios de v15. 5 agentes investigando simultaneamente resuelven en minutos lo que un solo agente tardaria mucho mas. El costo en tokens es mayor, pero el tiempo se reduce drasticamente.

---

-> [Compliance y datos](compliance-y-datos.md) — Regulacion y pipelines
