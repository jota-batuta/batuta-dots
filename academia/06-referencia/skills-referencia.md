# Skills — Referencia tecnica

Ficha tecnica de cada uno de los 23 skills del ecosistema Batuta Dots v12.

---

## Pipeline SDD

### sdd-init
- **Scope**: pipeline
- **Auto-invoke**: Si (al iniciar SDD)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Detecta tipo de proyecto y stack, crea openspec/, genera config.yaml, opcionalmente genera domain-experts.md y hooks de proyecto

### sdd-explore
- **Scope**: pipeline
- **Auto-invoke**: Si (al explorar)
- **Tools**: Read, Glob, Grep, WebFetch, WebSearch
- **Que hace**: Investiga codebase, compara opciones, detecta skill gaps, evalua Discovery Completeness (5 preguntas), detecta complejidad de proceso. Incluye MCP Discovery (local + web) y G0.25 (skill gaps como gate bloqueante)

### sdd-propose
- **Scope**: pipeline
- **Auto-invoke**: Si (al proponer)
- **Tools**: Read, Edit, Write, Glob, Grep
- **Que hace**: Crea propuesta formal con scope, cost-benefit analysis (obligatorio), y Client Communication (lenguaje no-tecnico obligatorio). Cost-benefit analysis obligatorio, Amendment History para seguimiento de cambios

### sdd-spec
- **Scope**: pipeline
- **Auto-invoke**: Si
- **Tools**: Read, Edit, Write, Glob, Grep
- **Que hace**: Escribe requisitos en formato Given/When/Then con RFC 2119 keywords

### sdd-design
- **Scope**: pipeline
- **Auto-invoke**: Si
- **Tools**: Read, Edit, Write, Glob, Grep
- **Que hace**: Disena arquitectura, toma decisiones (ADR), secciones condicionales LLM/Data/Infra, Architecture Validation Checklist (7 items), threat model

### sdd-tasks
- **Scope**: pipeline
- **Auto-invoke**: Si
- **Tools**: Read, Edit, Write, Glob, Grep
- **Que hace**: Divide trabajo en tareas con dependencias, fases, y estimaciones. Fase de documentacion obligatoria en task breakdown

### sdd-apply
- **Scope**: pipeline + infra
- **Auto-invoke**: Si (al implementar)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Implementa codigo con Execution Gate, Scope Rule, documentacion obligatoria (docstrings + WHY comments), evaluacion de complejidad de equipo. MCP Documentation Check antes de implementar

### sdd-verify
- **Scope**: pipeline
- **Auto-invoke**: Si (al verificar)
- **Tools**: Read, Glob, Grep, Bash
- **Que hace**: Piramide de Validacion AI (5 capas), testing diferenciado por tipo (pure auto / auto+LLM / agent), verificacion de documentacion. Flag archive_ready para confirmar preparacion para produccion

### sdd-archive
- **Scope**: pipeline
- **Auto-invoke**: Si (al archivar)
- **Tools**: Read, Edit, Write, Glob, Grep
- **Que hace**: Sincroniza specs, archiva cambio, Learning Loop (6 preguntas). Ecosystem improvement triggers: detecta cuando un cambio sugiere mejoras al ecosistema

---

## Capa CTO (Especialistas)

### process-analyst
- **Scope**: pipeline
- **Auto-invoke**: No (sugerido por sdd-explore)
- **Tools**: Read, Glob, Grep, WebSearch
- **Que hace**: 6 fases: inventario (10 preguntas), arbol variantes, catalogo taxonomias, mapa actores, catalogo excepciones, validacion cierre

### recursion-designer
- **Scope**: pipeline
- **Auto-invoke**: No (sugerido cuando hay taxonomias externas)
- **Tools**: Read, Glob, Grep, WebSearch
- **Que hace**: 4 mecanismos: deteccion desconocidos, aprobacion humana, propagacion controlada, versionado inmutable

### compliance-colombia
- **Scope**: pipeline
- **Auto-invoke**: No (sugerido cuando hay datos personales)
- **Tools**: Read, Glob, Grep, WebSearch
- **Que hace**: Valida Ley 1581, Circular SIC 002/2024, Art. 632 ET, transferencias internacionales, tombstoning

### data-pipeline-design
- **Scope**: pipeline
- **Auto-invoke**: No (sugerido para ETL/integraciones)
- **Tools**: Read, Glob, Grep, WebSearch
- **Que hace**: Disena ETL, conectores ERP colombianos, reglas calidad datos, schemas PostgreSQL con RLS

### llm-pipeline-design
- **Scope**: pipeline
- **Auto-invoke**: No (sugerido para soluciones con IA)
- **Tools**: Read, Glob, Grep, WebSearch
- **Que hace**: Pipeline 6 fases (ingestion, clasificacion, enrutamiento, procesamiento, validacion, retroalimentacion), model routing, confidence scoring, drift detection

### worker-scaffold
- **Scope**: pipeline
- **Auto-invoke**: No (sugerido para workers/deploy)
- **Tools**: Read, Glob, Grep, WebSearch, Bash
- **Que hace**: Estructura directorios worker, config Temporal, Dockerfile, docker-compose, deploy Coolify, health checks

---

## Infraestructura

### ecosystem-creator
- **Scope**: infra
- **Auto-invoke**: Si (al crear skills/agentes/workflows)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash, WebFetch, WebSearch, Task
- **Que hace**: Crea SKILL.md, agent .md, workflow definitions con frontmatter correcto. Step 5.5: RED-GREEN-REFACTOR para validar skills empiricamente antes de registrarlos. Step 7: Post-Creation Classification (invoca ecosystem-lifecycle para evaluar generico vs proyecto)

### ecosystem-lifecycle
- **Scope**: infra
- **Auto-invoke**: Si (post-creacion, violacion de reglas, tech sin skill)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash, Task
- **Que hace**: 4 comportamientos autonomos:
  1. **Clasificacion post-creacion**: Evalua si un skill es generico o proyecto-especifico. Indicadores: rutas hardcoded, tenant-specific, tech generica
  2. **Auto-propagacion**: Si se clasifica como generico y el usuario aprueba, copia al hub, cross-syncs a Antigravity, commit + push
  3. **Self-heal**: Cuando el usuario reporta violacion de reglas, identifica el problema en CLAUDE.md, propone fix, aplica con autorizacion
  4. **Provisioning continuo**: En cualquier fase SDD, si se detecta tech sin skill, auto-copia desde global o activa Skill Gap Detection

### scope-rule
- **Scope**: infra
- **Auto-invoke**: Si (al crear archivos)
- **Tools**: Read, Glob, Grep
- **Que hace**: Arbol de decision: 1 feature → features/, 2+ → shared/, toda app → core/. Anti-patterns.

### team-orchestrator
- **Scope**: infra
- **Auto-invoke**: Si (al evaluar complejidad)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash, Task
- **Que hace**: Decision tree (solo/subagente/team), Contract-First Protocol, 4 patrones de composicion, integracion con Execution Gate. Pattern E: Superpowers-Style Review (loop spec + calidad por task)

### security-audit
- **Scope**: infra
- **Auto-invoke**: Si (en design y verify)
- **Tools**: Read, Glob, Grep, Bash
- **Que hace**: Checklist 10 puntos OWASP, threat model, secrets scan, dependency audit, seccion especial IA (prompt injection, PII, cost control)

---

## Patrones reutilizables

### fastapi-crud
- **Scope**: pipeline
- **Auto-invoke**: Si (al construir APIs FastAPI)
- **Que hace**: Genera CRUD completo: models, schemas, services, routes con SQLAlchemy

### jwt-auth
- **Scope**: pipeline
- **Auto-invoke**: Si (al implementar auth)
- **Que hace**: Register, login, token validation, password hashing con bcrypt

### sqlalchemy-models
- **Scope**: pipeline
- **Auto-invoke**: Si (al crear modelos BD)
- **Que hace**: Patrones one-to-many, many-to-many, database session, migrations
