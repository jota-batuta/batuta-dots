# Skills — Referencia tecnica

Ficha tecnica de cada uno de los 38 skills del ecosistema Batuta Dots v13.

> **Nota sobre domain agents**: Los skills marcados como pertenecientes a un domain agent se cargan bajo demanda (`defer_loading: true`) cuando ese agente se auto-invoca. No necesitas activarlos manualmente — el router (CLAUDE.md) detecta la tecnologia y delega al agente correcto, que a su vez carga el skill necesario.

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
- **Que hace**: Crea SKILL.md, agent .md, workflow definitions con frontmatter correcto. Para agentes, genera thick persona (80-120 lineas de expertise embebido) y bloque `sdk:` con `defer_loading`. Step 5.5: RED-GREEN-REFACTOR para validar skills empiricamente antes de registrarlos. Despues de crear, invoca ecosystem-lifecycle para clasificar (generico vs proyecto-especifico)

### ecosystem-lifecycle
- **Scope**: infra
- **Trigger**: Despues de crear un skill, cuando se reporta violacion de reglas, cuando falta un skill para una tecnologia
- **Que hace**: Clasifica skills (generico vs proyecto-especifico), verifica y repara violaciones de reglas, auto-provisiona skills desde la libreria global
- **Plataformas**: Claude Code, Antigravity

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

### skill-eval
- **Scope**: infra
- **Auto-invoke**: No (invocado via `/skill:eval nombre`)
- **Tools**: Read, Glob, Grep, Bash, Task
- **Que hace**: Ejecuta tests comportamentales para skills usando SKILL.eval.yaml. Lanza sub-agentes que simulan escenarios reales, evalua quality_criteria y anti_criteria, genera reporte de salud. Modo benchmark para evaluar multiples skills

### claude-agent-sdk
- **Scope**: infra
- **Auto-invoke**: Si (al trabajar con Claude Agent SDK)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Patrones de deployment para Claude Agent SDK: AgentDefinitions, `defer_loading` (carga de skills bajo demanda en domain agents), `setting_sources` (configuracion por proyecto), Tool Search, configuracion de agents como servicios programaticos

---

## Patrones reutilizables

> Estos skills se cargan bajo demanda dentro de **backend-agent** (`defer_loading: true`).

### fastapi-crud
- **Scope**: pipeline
- **Domain agent**: backend-agent
- **Auto-invoke**: Si (al construir APIs FastAPI)
- **Que hace**: Genera CRUD completo: models, schemas, services, routes con SQLAlchemy

### jwt-auth
- **Scope**: pipeline
- **Domain agent**: backend-agent
- **Auto-invoke**: Si (al implementar auth)
- **Que hace**: Register, login, token validation, password hashing con bcrypt

### sqlalchemy-models
- **Scope**: pipeline
- **Domain agent**: backend-agent
- **Auto-invoke**: Si (al crear modelos BD)
- **Que hace**: Patrones one-to-many, many-to-many, database session, migrations

---

## Tecnologias y Metodologias (v13)

### react-nextjs
- **Scope**: pipeline
- **Auto-invoke**: Si (al construir frontend React/Next.js)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Patrones App Router, Server/Client Components, data fetching, server actions, Scope Rule para componentes

### typescript-node
- **Scope**: pipeline
- **Auto-invoke**: Si (al construir backend TypeScript/Node.js)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Configuracion TypeScript estricta, patrones Express/Fastify, manejo de errores tipado, dependency injection

### api-design
- **Scope**: pipeline
- **Auto-invoke**: Si (al disenar APIs REST)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Diseno de endpoints REST, versionado de API, contratos de error, paginacion, OpenAPI/Swagger

### e2e-testing
- **Scope**: pipeline
- **Auto-invoke**: Si (al implementar tests E2E)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Testing end-to-end con Playwright/Cypress, Page Object Model, selectores accesibles, CI integration

### tdd-workflow
- **Scope**: pipeline
- **Auto-invoke**: Si (al usar metodologia TDD)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Ciclos red-green-refactor, test-first approach, cobertura minima, test doubles y mocking

### debugging-systematic
- **Scope**: pipeline
- **Auto-invoke**: Si (al depurar problemas complejos)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Depuracion con busqueda binaria, prueba de hipotesis, aislamiento de variables, reproduccion de bugs

### vector-db-rag
- **Scope**: pipeline
- **Auto-invoke**: Si (al implementar RAG o busqueda semantica)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Pipelines RAG, embeddings, vector stores (Pinecone, Chroma, pgvector), chunking, retrieval strategies

### message-queues
- **Scope**: pipeline
- **Auto-invoke**: Si (al implementar colas de mensajes)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Patrones pub/sub, work queues, dead letter queues con RabbitMQ, Redis Streams, SQS

### ci-cd-pipeline
- **Scope**: infra
- **Auto-invoke**: Si (al configurar CI/CD)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Pipelines GitHub Actions/GitLab CI, stages, caching, deploy strategies, secrets management

### observability
- **Scope**: observability
- **Auto-invoke**: Si (al implementar monitoreo)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Structured logging, distributed tracing (OpenTelemetry), metricas, dashboards, alertas, health checks

### accessibility-audit
- **Scope**: pipeline
- **Auto-invoke**: Si (al verificar accesibilidad)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Auditoria WCAG 2.1/2.2, roles ARIA, contraste de colores, navegacion por teclado, lectores de pantalla, compliance Section 508

### performance-testing
- **Scope**: pipeline
- **Auto-invoke**: Si (al implementar pruebas de rendimiento)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Load testing (k6, Artillery, Locust), benchmarks, metricas de rendimiento (TTFB, P95, P99), profiling, capacity planning

### technical-writer
- **Scope**: pipeline
- **Auto-invoke**: Si (al generar documentacion tecnica)
- **Tools**: Read, Edit, Write, Glob, Grep
- **Que hace**: Generacion de documentacion tecnica profesional: guias de usuario, API docs, changelogs, release notes, documentacion de arquitectura para stakeholders no-tecnicos
