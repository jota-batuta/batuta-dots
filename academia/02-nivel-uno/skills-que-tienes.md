# Skills que tienes

Batuta Dots tiene 33 skills — especialistas que se activan cuando los necesitas. El sistema los activa automaticamente, pero conocerlos te da poder para pedir exactamente lo que necesitas.

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

### Infraestructura (5 skills)

| Skill | Que hace | Comando |
|-------|---------|---------|
| **ecosystem-creator** | Crea skills, agentes, workflows | `/create-skill` |
| **ecosystem-lifecycle** | Clasifica, auto-repara y provisiona skills | Automatico |
| **scope-rule** | Decide donde va cada archivo | Automatico |
| **team-orchestrator** | Solo, subagente, o equipo | Automatico |
| **security-audit** | OWASP, secrets, amenazas | En design/verify |

### Patrones reutilizables (3 skills)

| Skill | Que hace |
|-------|---------|
| **fastapi-crud** | CRUD con FastAPI + SQLAlchemy |
| **jwt-auth** | Autenticacion JWT con bcrypt |
| **sqlalchemy-models** | Modelos BD con relaciones |

### Tecnologias y Metodologias (10 skills)

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

---

## Como se activan

**Automatica**: Escribes `/sdd-explore` → pipeline-agent activa sdd-explore.
**Por deteccion**: sdd-explore detecta 3+ variantes → sugiere process-analyst.
**Manual**: "Necesito analizar variantes con process-analyst".

## Si falta un skill

El sistema detecta el gap, ofrece crearlo (local o global), o continuar sin el. El ecosistema crece contigo.

---

→ [Agentes y equipos](agentes-y-equipos.md) — Los coordinadores
