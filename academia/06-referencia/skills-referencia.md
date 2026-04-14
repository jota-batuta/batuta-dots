# Skills — Referencia tecnica

Ficha tecnica de cada uno de los 43 skills del ecosistema Batuta Dots v15.

> **Nota sobre carga de skills**: Los skills se distribuyen en dos niveles:
> - `~/.claude/skills/` (GLOBAL) = skills universales que aplican a todo proyecto (max 5-8). Se instalan con `setup.sh --sync`.
> - `.claude/skills/` (PROYECTO) = skills que este proyecto necesita. Se provisionan con `/batuta-init` y se amplian con `/batuta-sync`.
>
> El hub (batuta-dots repo) conserva los 43 skills como biblioteca. No se clona dentro de `~/.claude/`.
>
> **Delegacion por contrato (v15)**: El main agent no ejecuta directamente — contrata agentes especializados que cargan los skills relevantes. Los skills pertenecen a los agentes, no al main agent.

---

## Pipeline SDD

### sdd-init
- **Scope**: pipeline
- **Auto-invoke**: Si (al iniciar SDD)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Detecta tipo de proyecto y stack, crea openspec/, genera config.yaml, provisiona skills del hub segun tech stack detectado

### sdd-explore
- **Scope**: pipeline
- **Auto-invoke**: Si (al explorar)
- **Tools**: Read, Glob, Grep, WebFetch, WebSearch
- **Que hace**: Investiga codebase con subagentes en paralelo, compara opciones, detecta skill gaps, aplica Research-First (verificar conocimiento via web antes de asumir)

### sdd-design
- **Scope**: pipeline
- **Auto-invoke**: Si
- **Tools**: Read, Edit, Write, Glob, Grep
- **Que hace**: Disena arquitectura, toma decisiones (ADR), secciones condicionales LLM/Data/Infra, Architecture Validation Checklist, threat model. USER STOP obligatorio al finalizar

### sdd-apply
- **Scope**: pipeline + infra
- **Auto-invoke**: Si (al implementar)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Implementa codigo con Execution Gate, Scope Rule, documentacion obligatoria. El main agent contrata agentes especializados segun tecnologias de cada tarea

### sdd-verify
- **Scope**: pipeline
- **Auto-invoke**: Si (al verificar)
- **Tools**: Read, Glob, Grep, Bash
- **Que hace**: Piramide de Validacion AI (5 capas), testing diferenciado por tipo (pure auto / auto+LLM / agent), verificacion de documentacion

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

### agent-hiring
- **Scope**: infra
- **Auto-invoke**: Si (al delegar tareas)
- **Tools**: Read, Glob, Grep
- **Que hace**: Protocolo de contratacion de agentes: verifica si ya existe un agente en `.claude/agents/` o `~/.claude/agents/`, propone contratacion si no existe (USER STOP obligatorio), crea archivo de agente con contrato formal

### ecosystem-creator
- **Scope**: infra
- **Auto-invoke**: Si (al crear skills/agentes/workflows)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash, WebFetch, WebSearch, Task
- **Que hace**: Crea SKILL.md, agent .md, workflow definitions con frontmatter correcto. RED-GREEN-REFACTOR para validar skills. Despues de crear, invoca ecosystem-lifecycle para clasificar

### ecosystem-lifecycle
- **Scope**: infra
- **Trigger**: Despues de crear un skill, cuando se reporta violacion de reglas, cuando falta un skill para una tecnologia
- **Que hace**: Clasifica skills (generico vs proyecto-especifico), verifica y repara violaciones de reglas, auto-provisiona skills desde la libreria global

### scope-rule
- **Scope**: infra
- **Auto-invoke**: Si (al crear archivos)
- **Tools**: Read, Glob, Grep
- **Que hace**: Arbol de decision: 1 feature -> features/, 2+ -> shared/, toda app -> core/. Anti-patterns

### team-orchestrator
- **Scope**: infra
- **Auto-invoke**: Si (al evaluar complejidad)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash, Task
- **Que hace**: Decision tree (solo/subagente/team), Contract-First Protocol, 4 patrones de composicion, integracion con Execution Gate

### security-audit
- **Scope**: infra
- **Auto-invoke**: Si (en design y verify)
- **Tools**: Read, Glob, Grep, Bash
- **Que hace**: Checklist 10 puntos OWASP, threat model, secrets scan, dependency audit, seccion especial IA (prompt injection, PII, cost control)

### skill-eval
- **Scope**: infra
- **Auto-invoke**: No (invocado via `/skill:eval nombre`)
- **Tools**: Read, Glob, Grep, Bash, Task
- **Que hace**: Ejecuta tests comportamentales para skills usando SKILL.eval.yaml. Modo benchmark para evaluar multiples skills

### claude-agent-sdk
- **Scope**: infra
- **Auto-invoke**: Si (al trabajar con Claude Agent SDK)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Patrones de deployment para Claude Agent SDK: AgentDefinitions, `defer_loading`, `setting_sources`, Tool Search, configuracion de agents como servicios programaticos

### prd-generator
- **Scope**: infra
- **Auto-invoke**: Si (despues de aprobacion de plan)
- **Tools**: Read, Edit, Write, Glob, Grep
- **Que hace**: Consolida artefactos de planificacion SDD en un brief de ejecucion limpio (PRD). Invocado automaticamente por pipeline-agent

### user-execution-guide
- **Scope**: infra
- **Auto-invoke**: Si (despues de plan con multiples slices/agentes)
- **Tools**: Read, Edit, Write, Glob, Grep
- **Que hace**: Genera guia de ejecucion (SPO) para el operador: prerequisitos, comandos, que monitorear, criterios de exito

### ai-first
- **Scope**: infra
- **Auto-invoke**: Si (al decidir entre IA y codigo determinista)
- **Tools**: Read, Glob, Grep
- **Que hace**: Framework de decision para cuando usar IA/LLM vs codigo determinista. Evalua costo, precision, mantenibilidad

---

## Tecnologias y Metodologias

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

### sqlalchemy-models
- **Scope**: pipeline
- **Auto-invoke**: Si (al crear modelos BD)
- **Que hace**: Patrones one-to-many, many-to-many, database session, migrations

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
- **Que hace**: Auditoria WCAG 2.1/2.2, roles ARIA, contraste de colores, navegacion por teclado, lectores de pantalla

### performance-testing
- **Scope**: pipeline
- **Auto-invoke**: Si (al implementar pruebas de rendimiento)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Load testing (k6, Artillery, Locust), benchmarks, metricas de rendimiento (TTFB, P95, P99), profiling

### technical-writer
- **Scope**: pipeline
- **Auto-invoke**: Si (al generar documentacion tecnica)
- **Tools**: Read, Edit, Write, Glob, Grep
- **Que hace**: Documentacion tecnica profesional: guias de usuario, API docs, changelogs, release notes, documentacion de arquitectura

---

## Integraciones y Plataformas

### coolify-deploy
- **Scope**: infra
- **Auto-invoke**: Si (al deployar en Coolify)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Patrones de deploy para Coolify (self-hosted PaaS): servicios, Docker Compose, networking, environment variables

### evolution-api
- **Scope**: pipeline
- **Auto-invoke**: Si (al integrar WhatsApp)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Integracion WhatsApp via Evolution API (Baileys): webhooks, envio de mensajes, grupos

### google-adk
- **Scope**: pipeline
- **Auto-invoke**: Si (al construir agentes con Google ADK)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Patrones para Google Agent Development Kit: LlmAgent, FunctionTool, session management

### icg-erp
- **Scope**: pipeline
- **Auto-invoke**: Si (al trabajar con ICG ERP)
- **Tools**: Read, Glob, Grep
- **Que hace**: Schema y gotchas para ICG ERP (restaurantes) en SQL Server 2017: MOVIMENTS, STOCKS, TRASPASOSCAB

### prefect-flows
- **Scope**: pipeline
- **Auto-invoke**: Si (al usar Prefect)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Patrones para Prefect 3 self-hosted: flows, tasks, scheduling, Docker setup, work pools

### pydantic-ai
- **Scope**: pipeline
- **Auto-invoke**: Si (al construir agentes con Pydantic AI)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Framework de agentes Python con typed dependencies, function tools, dynamic instructions

### supabase-python
- **Scope**: pipeline
- **Auto-invoke**: Si (al usar Supabase con Python)
- **Tools**: Read, Edit, Write, Glob, Grep, Bash
- **Que hace**: Patrones supabase-py: insert, select, RLS, service_role key, pgvector
