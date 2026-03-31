# Skills que tienes

Batuta Dots tiene 39 skills — especialistas que se activan cuando los necesitas. El sistema los activa automaticamente, pero conocerlos te da poder para pedir exactamente lo que necesitas.

---

## Que es un skill

Un archivo (`SKILL.md`) que le dice a Claude: que sabe hacer, cuando activarse, como hacerlo, y que herramientas usa. Como un manual de procedimientos para un empleado muy competente.

### Convencion de activacion (v11.0)

Cada skill tiene un campo `description` en su archivo que empieza con "Use when..." — esto le dice a Claude **cuando** activar el skill, no **que** hace. Es como un cartel en la puerta: "Entrar cuando llueva" vs "Este es el departamento de paraguas". Las tablas de abajo describen que hace cada skill en lenguaje simple.

---

## Skills por categoria

### Pipeline SDD (9 skills)

| Skill | Que hace | Comando |
|-------|---------|---------|
| **sdd-init** | Prepara un proyecto para SDD | `/sdd-init` |
| **sdd-explore** | Investiga problemas y opciones | `/sdd-explore` |
| **sdd-propose** | Propuestas con costos y beneficios | Via `/sdd-new` |
| **sdd-spec** | Requisitos exactos (Given/When/Then) | Via `/sdd-ff` |
| **sdd-design** | Arquitectura y decisiones tecnicas | Via `/sdd-ff` |
| **sdd-tasks** | Divide trabajo en tareas | Via `/sdd-ff` |
| **sdd-apply** | Implementa codigo | `/sdd-apply` |
| **sdd-verify** | Piramide de Validacion | `/sdd-verify` |
| **sdd-archive** | Archiva y documenta | `/sdd-archive` |

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

| Skill | Que hace | Comando |
|-------|---------|---------|
| **ecosystem-creator** | Crea skills, agentes, workflows | `/create-skill` |
| **ecosystem-lifecycle** | Clasifica, auto-repara y provisiona skills | Automatico |
| **scope-rule** | Decide donde va cada archivo | Automatico |
| **team-orchestrator** | Solo, subagente, o equipo | Automatico |
| **security-audit** | OWASP, secrets, amenazas | En design/verify |
| **skill-eval** | Tests comportamentales para skills (SKILL.eval.yaml) | `/skill:eval nombre` |
| **claude-agent-sdk** | Patrones de deployment via Claude Agent SDK | Automatico |

### Patrones reutilizables (3 skills)

| Skill | Que hace |
|-------|---------|
| **fastapi-crud** | CRUD con FastAPI + SQLAlchemy |
| **jwt-auth** | Autenticacion JWT con bcrypt |
| **sqlalchemy-models** | Modelos BD con relaciones |

### Tecnologias y Metodologias (13 skills)

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
| **performance-testing** | Load testing, benchmarks, y metricas de rendimiento |
| **technical-writer** | Generacion de documentacion tecnica profesional |

---

## Como se activan

Los skills se activan de tres formas:

**Automatica**: Escribes `/sdd-explore` → pipeline-agent activa sdd-explore.
**Por deteccion**: sdd-explore detecta 3+ variantes → sugiere process-analyst.
**Manual**: "Necesito analizar variantes con process-analyst".

### Skills dentro de domain agents (carga bajo demanda)

Los domain agents (backend, quality, data) tienen un mecanismo especial: sus skills se cargan **bajo demanda** (`defer_loading: true`). Esto significa que el agente no carga todos sus skills al arrancar — los busca y activa cuando los necesita.

Por ejemplo, cuando backend-agent recibe una tarea sobre autenticacion, busca y activa jwt-auth en ese momento. Si la tarea fuera sobre modelos de base de datos, activaria sqlalchemy-models en su lugar. Esto ahorra tokens y mantiene al agente enfocado.

| Domain Agent | Skills disponibles | Cuando se cargan |
|-------------|-------------------|-----------------|
| backend-agent | fastapi-crud, jwt-auth, sqlalchemy-models, api-design, message-queues, typescript-node | Al detectar la tecnologia en la tarea |
| quality-agent | tdd-workflow, debugging-systematic, security-audit, e2e-testing, accessibility-audit, performance-testing | Siempre disponibles (no usa defer_loading) |
| data-agent | data-pipeline-design, llm-pipeline-design, vector-db-rag | Al detectar la tecnologia en la tarea |

Nota que quality-agent es la excepcion: sus skills estan disponibles inmediatamente porque las verificaciones de calidad deben poder ejecutarse en cualquier momento, sin espera.

## Si falta un skill

El sistema detecta el gap, ofrece crearlo (local o global), o continuar sin el. El ecosistema crece contigo.

---

→ [Agentes y equipos](agentes-y-equipos.md) — Los coordinadores
