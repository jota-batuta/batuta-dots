# Skills que tienes

Batuta Dots tiene 43 skills en el hub — especialistas que los agentes contratados cargan cuando los necesitan. En v15, los skills **pertenecen a los agentes**, no al agente principal.

---

## Que es un skill

Un archivo (`SKILL.md`) que le dice a un agente: que sabe hacer, cuando activarse, como hacerlo, y que herramientas usa. Como un manual de procedimientos para un empleado muy competente.

### Donde viven los skills

En v15, los skills existen en tres niveles:

| Nivel | Ubicacion | Cuantos | Cuando se cargan |
|-------|-----------|---------|-----------------|
| **Hub** | `batuta-dots/BatutaClaude/skills/` | 43 | Biblioteca completa. No se clonan directo. |
| **Global** | `~/.claude/skills/` | 13 | Universales que aplican a TODO proyecto. Se instalan con `setup.sh --sync`. |
| **Proyecto** | `.claude/skills/` | Variable | Solo los que ESTE proyecto necesita. Se provisionan con `/batuta-init`. |

### Los 13 skills globales

Estos se instalan en tu maquina y estan disponibles en todo proyecto:

| Skill | Que hace |
|-------|---------|
| **scope-rule** | Decide donde va cada archivo |
| **ecosystem-creator** | Crea skills, agentes, workflows |
| **security-audit** | OWASP, secrets, amenazas |
| **team-orchestrator** | Solo, subagente, o equipo |
| **ecosystem-lifecycle** | Clasifica, auto-repara, provisiona skills |
| **sdd-explore** | Investiga problemas y opciones |
| **sdd-design** | Arquitectura y decisiones tecnicas |
| **sdd-apply** | Implementa codigo |
| **sdd-verify** | Piramide de Validacion |
| **prd-generator** | Genera PRD consolidado |
| **tdd-workflow** | Metodologia Test-Driven Development |
| **debugging-systematic** | Depuracion sistematica de bugs |
| **sdd-init** | Inicializa SDD en un proyecto |

### Convencion de activacion

Cada skill tiene un campo `description` en su archivo que empieza con "Use when..." — esto le dice al agente **cuando** activar el skill. Las tablas de abajo describen que hace cada skill en lenguaje simple.

---

## Skills por categoria

### Pipeline SDD (5 skills)

| Skill | Que hace | Comando |
|-------|---------|---------|
| **sdd-explore** | Investiga problemas y opciones | `/sdd-explore` |
| **sdd-design** | Arquitectura y decisiones tecnicas | Via `/sdd-new` o `/sdd-ff` |
| **sdd-apply** | Implementa codigo | `/sdd-apply` |
| **sdd-verify** | Piramide de Validacion | `/sdd-verify` |
| **prd-generator** | Genera PRD consolidado | Automatico tras aprobacion de plan |

### Capa CTO — 6 especialistas

| Skill | Que hace | Cuando se activa |
|-------|---------|-----------------|
| **process-analyst** | Mapea variantes de un proceso | 3+ tipos de caso |
| **recursion-designer** | Sistemas que manejan cambio externo | Taxonomias que cambian |
| **compliance-colombia** | Cumplimiento regulatorio colombiano | Datos personales, DIAN |
| **data-pipeline-design** | Pipelines de datos y ETL | ERPs, archivos planos |
| **llm-pipeline-design** | Pipelines de IA | Clasificadores, prompts |
| **worker-scaffold** | Workers y deploy | Temporal, Docker, Coolify |

### Infraestructura (7 skills)

| Skill | Que hace |
|-------|---------|
| **ecosystem-creator** | Crea skills, agentes, workflows |
| **ecosystem-lifecycle** | Clasifica, auto-repara y provisiona skills |
| **scope-rule** | Decide donde va cada archivo |
| **team-orchestrator** | Solo, subagente, o equipo |
| **security-audit** | OWASP, secrets, amenazas |
| **skill-eval** | Tests comportamentales para skills |
| **claude-agent-sdk** | Patrones de deployment via Agent SDK |

### Patrones reutilizables (3 skills)

| Skill | Que hace |
|-------|---------|
| **fastapi-crud** | CRUD con FastAPI + SQLAlchemy |
| **jwt-auth** | Autenticacion JWT con bcrypt |
| **sqlalchemy-models** | Modelos BD con relaciones |

### Tecnologias y Metodologias (17 skills)

| Skill | Que hace |
|-------|---------|
| **react-nextjs** | Frontend React/Next.js App Router |
| **typescript-node** | Backend TypeScript/Node.js |
| **api-design** | Diseno de APIs REST y contratos |
| **e2e-testing** | Tests E2E con Playwright/Cypress |
| **tdd-workflow** | Metodologia Test-Driven Development |
| **debugging-systematic** | Depuracion sistematica de bugs |
| **vector-db-rag** | Bases de datos vectoriales y RAG |
| **message-queues** | Colas de mensajes (RabbitMQ, Redis, SQS) |
| **ci-cd-pipeline** | Pipelines CI/CD (GitHub Actions, GitLab) |
| **observability** | Monitoreo, logging, tracing, alertas |
| **accessibility-audit** | Cumplimiento WCAG y accesibilidad web |
| **performance-testing** | Load testing, benchmarks, y metricas |
| **technical-writer** | Documentacion tecnica profesional |
| **sdd-init** | Inicializa SDD en un proyecto |
| **coolify-deploy** | Deploy en Coolify |
| **ai-first** | Decidir IA vs codigo determinista |
| **agent-hiring** | Protocolo de contratacion de agentes |

### Skills de dominio especifico (5 skills)

| Skill | Que hace |
|-------|---------|
| **evolution-api** | Integracion WhatsApp via Evolution API |
| **google-adk** | Agentes con Google ADK |
| **icg-erp** | Schema y gotchas para ICG ERP |
| **pydantic-ai** | Agentes con Pydantic AI |
| **supabase-python** | Supabase con Python |
| **prefect-flows** | Flujos Prefect 3 |
| **user-execution-guide** | Guia de ejecucion para el operador |

---

## Como se cargan en v15: skills pertenecen a agentes

Este es el cambio fundamental. En v14, el agente principal cargaba skills. En v15:

1. **El agente principal NO carga skills** — solo sabe a quien contratar
2. **Cada agente tiene skills asignados** en su contrato (archivo `.md`)
3. **Al contratarse, el agente carga SOLO sus skills** — no los demas

| Agente | Skills asignados | Cuando se cargan |
|--------|-----------------|-----------------|
| **pipeline-agent** | sdd-explore, sdd-design, sdd-apply, sdd-verify, prd-generator | Al contratar para fases SDD |
| **backend-agent** | fastapi-crud, jwt-auth, sqlalchemy-models, api-design, message-queues, typescript-node | Al contratar para trabajo de API/backend |
| **data-agent** | data-pipeline-design, llm-pipeline-design, vector-db-rag, prefect-flows | Al contratar para trabajo de datos/IA |
| **quality-agent** | tdd-workflow, debugging-systematic, security-audit, e2e-testing, accessibility-audit, performance-testing | Al contratar para testing/calidad |
| **infra-agent** | scope-rule, ecosystem-creator, ecosystem-lifecycle, ci-cd-pipeline, coolify-deploy, worker-scaffold | Al contratar para infra/deployment |

**Por que importa**: Un backend-agent no carga skills de testing. Un quality-agent no carga skills de FastAPI. Cada agente ve solo lo que necesita, manteniendo el contexto limpio y el rendimiento alto.

### Descripcion de 1 linea: el budget de metadata

Claude Code carga SOLO las descripciones de 1 linea de los skills al inicio (~450 tokens total). El contenido completo se carga SOLO cuando el agente decide usar uno. Esto es por que las descripciones deben ser cortas (maximo 130 caracteres).

### Skills globales vs proyecto

- **13 skills globales** (`~/.claude/skills/`): universales, aplican a todo proyecto. Se instalan con `setup.sh --sync`.
- **Skills de proyecto** (`.claude/skills/`): solo los que este proyecto necesita. Se provisionan con `/batuta-init` (deteccion automatica del tech stack) o se traen del hub con `/batuta-sync`.

El hub conserva los 43 skills como biblioteca. No se clona completo — se extraen los que cada proyecto necesita.

---

## Si falta un skill

En v15, cuando un agente necesita expertise que no tiene:

1. El agente detecta el gap durante research-first
2. Busca en el hub global (`~/.claude/skills/`)
3. Si existe → propone traerlo al proyecto con `/batuta-sync`
4. Si no existe → declara el gap, busca en web, y puede crear uno nuevo via `ecosystem-creator`

El ecosistema crece contigo. Los skills nuevos pueden propagarse al hub para beneficiar otros proyectos.

---

-> [Agentes y equipos](agentes-y-equipos.md) — Los coordinadores
