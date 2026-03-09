# Batuta.Dots

**Ecosistema de agentes IA para fabricas de software — Claude Code primero, replicable a cualquier plataforma.**

[![Licencia: MIT](https://img.shields.io/badge/Licencia-MIT-blue.svg)](LICENSE)

---

## Que es Batuta?

Batuta es un ecosistema de agentes IA construido como un sistema **Mixture of Experts (MoE)** para desarrollo de software. `CLAUDE.md` actua como el **router** (clasificacion de intent + enrutamiento), los **agentes de dominio** son los **expertos** (backend, data, quality — cada uno con 80-120 lineas de expertise embebido), y los **skills** son los **parametros** (cargados bajo demanda segun el contexto). Escribes tus convenciones una vez, y el experto correcto se activa automaticamente. Cuando estes listo para extender a otras plataformas, un script de replicacion genera el equivalente para Gemini, Copilot, Codex u OpenCode.

Inspirado en [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots), adaptado para:

- **Fabrica de software multi-proyecto**.
- **Personalidad CTO/Mentor** que educa y documenta para personas no tecnicas.
- **Regla de Alcance (Scope Rule)** que organiza archivos por quien los usa, no por tipo.
- **Auto-deteccion de gaps en skills** con investigacion automatica via Context7.
- **Carga lazy de skills** — Claude lee ~220 lineas al iniciar, el resto se carga bajo demanda.
- **Arquitectura MoE** — CLAUDE.md enruta, los agentes de dominio son expertos, los skills son parametros.
- **6 agentes** — 3 agentes de scope (pipeline, infra, observability) + 3 agentes de dominio (backend, data, quality) con skills auto-descubiertos.
- **Execution Gate** — pre-validacion obligatoria antes de cualquier cambio de codigo.
- **Hooks nativos** — SessionStart, Stop.
- **Framework O.R.T.A.** (Observabilidad, Repetibilidad, Trazabilidad, Auto-supervision).
- **Agent Teams** — orquestacion de multiples sesiones Claude en paralelo para tareas complejas.
- **Contract-First Protocol** — contratos pre-spawn definen input/output/file-ownership por teammate.
- **Seguridad AI-First** — skill security-audit dedicado, integrado en fases de diseno y verificacion.
- **Team Templates + Playbook** — composiciones pre-armadas por stack (Next.js, FastAPI, n8n, agente IA, data pipeline, refactoring).
- **CTO Strategy Layer (v11.0)** — 3 gates + 6 skills especialistas en el pipeline SDD.
- **Batuta Bootstrap** — "La Regla" via hook SessionStart: si un skill aplica, DEBES usarlo.
- **MCP Discovery** — busqueda activa de servidores MCP durante la fase explore.
- **Review Superpowers** — loop de revision en 2 etapas (spec + calidad) para tareas complejas.
- **Descripciones Trigger-Only** — las 38 descripciones de skills siguen la convencion "Use when..." para activacion confiable.
- **Agentes de Dominio** — 3 expertos de dominio (backend, data, quality) con persona gruesa, auto-invocados como subprocesos autonomos segun senales de tecnologia.

---

## Inicio Rapido

### Instalacion (Recomendado)

Instala Batuta con un solo comando — sin clon permanente:

```bash
git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install && bash /tmp/batuta-install/infra/install.sh && rm -rf /tmp/batuta-install
```

Esto hace:
1. Clona el repositorio en un directorio temporal
2. Pregunta que plataforma instalar (**Claude Code** o **Antigravity**)
3. Instala los archivos de la plataforma seleccionada
4. Configura tu directorio actual como proyecto Batuta (Claude Code)
5. Limpia el clon temporal automaticamente

**Instalacion no interactiva:**

```bash
# Solo Claude Code
git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install && bash /tmp/batuta-install/infra/install.sh --claude && rm -rf /tmp/batuta-install

# Solo Antigravity
git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install && bash /tmp/batuta-install/infra/install.sh --antigravity && rm -rf /tmp/batuta-install
```

**Windows:**

> **Importante:** Usa WSL o Git Bash. PowerShell no es compatible (su `curl` es un alias de `Invoke-WebRequest`).

```bash
# WSL (recomendado) o Git Bash
git clone --depth 1 https://github.com/jota-batuta/batuta-dots.git /tmp/batuta-install && bash /tmp/batuta-install/infra/install.sh && rm -rf /tmp/batuta-install
```

### Que se instala

| Plataforma | Destino | Contenido |
|------------|---------|-----------|
| **Claude Code** | `~/.claude/` | 38 skills, 6 agentes, 13 comandos, 2 hooks, settings.json, output-styles |
| **Claude Code** | Directorio actual | `CLAUDE.md` + `.batuta/` (session, ecosystem.json) |
| **Antigravity** | `~/.gemini/antigravity/` | Skills compatibles, workflows, GEMINI.md |

### Setup para desarrolladores

Si quieres contribuir a batuta-dots:

```bash
git clone https://github.com/jota-batuta/batuta-dots.git
cd batuta-dots
./infra/setup.sh --all
./infra/setup.sh --verify
```

---

## Arquitectura

```
batuta-dots/
├── BatutaClaude/                      # Configuracion de Claude Code
│   ├── CLAUDE.md                      # Punto de entrada unico (router + reglas + routing)
│   ├── VERSION                        # Version del ecosistema (semver)
│   ├── settings.json                  # Permisos, hooks nativos, estilo de salida
│   ├── mcp-servers.template.json      # Plantilla de servidores MCP
│   ├── output-styles/batuta.md        # Estilo de salida personalizado
│   ├── commands/                      # Slash commands globales
│   │   ├── batuta-init.md             # /batuta-init — importar ecosistema
│   │   ├── batuta-update.md           # /batuta-update — actualizar
│   ├── agents/                        # Agentes de Scope + Dominio
│   │   ├── pipeline-agent.md          # Scope: Especialista SDD Pipeline (9 skills)
│   │   ├── infra-agent.md             # Scope: Especialista infraestructura (5 skills)
│   │   ├── observability-agent.md     # Scope: Motor O.R.T.A. (sin skills activos)
│   │   ├── backend-agent.md           # Dominio: provisionado cuando se detectan frameworks backend
│   │   ├── quality-agent.md           # Dominio: siempre provisionado (AI Validation Pyramid)
│   │   └── data-agent.md              # Dominio: provisionado cuando se detectan frameworks data/IA
│   └── skills/                        # Skills instalables (carga lazy)
│       ├── ecosystem-creator/         # Skill bootstrap
│       │   ├── SKILL.md
│       │   └── assets/                # Plantillas para skills, agentes, workflows
│       ├── scope-rule/SKILL.md        # Regla de Alcance
│       ├── sdd-init/SKILL.md          # Pipeline SDD (9 fases)
│       ├── sdd-explore/SKILL.md
│       ├── sdd-propose/SKILL.md
│       ├── sdd-spec/SKILL.md
│       ├── sdd-design/SKILL.md
│       ├── sdd-tasks/SKILL.md
│       ├── sdd-apply/SKILL.md
│       ├── sdd-verify/SKILL.md
│       ├── sdd-archive/SKILL.md
│       ├── team-orchestrator/SKILL.md # Orquestacion Agent Teams (cuando escalar)
│       └── security-audit/SKILL.md   # Seguridad AI-first (OWASP + amenazas + escaneo de secretos)
├── BatutaAntigravity/                 # Antigravity Lite (brainstorming y prototipado)
│   ├── GEMINI.md                      # Cerebro CTO completo adaptado para Antigravity
│   ├── setup-antigravity.sh           # Script de setup (--global / --workspace / --all / --update)
│   ├── settings-template.json         # Config recomendada para Antigravity
│   └── workflows/                     # Prompts guardados (SDD + session + sync)
│       ├── sdd-init.md ... sdd-archive.md  # Pipeline SDD (8 workflows)
│       ├── save-session.md            # Guardar estado (reemplaza hook Stop)
│       ├── push-skill.md             # Propagar skill local al hub
│       └── batuta-update.md          # Actualizar desde hub
├── docs/                              # Toda la documentacion
│   ├── architecture/                  # Arquitectura y diseno
│   │   ├── arquitectura-diagrama.md   # Diagramas Mermaid de arquitectura (15+ diagramas)
│   │   └── arquitectura-para-no-tecnicos.md  # Guia sin tecnicismos (analogia restaurante, 15+ roles)
│   ├── guides/                        # Guias de ejecucion paso a paso (14 guias, Espanol)
│   │   ├── guia-batuta-app.md         # Dashboard app — guia ciclo completo
│   │   ├── guia-temporal-io-app.md    # Temporal.io workflows — guia ciclo completo
│   │   ├── guia-langchain-gmail-agent.md  # Agente LangChain + Gmail — guia ciclo completo
│   │   ├── guia-n8n-automation.md     # Automatizacion con n8n
│   │   ├── guia-fastapi-service.md    # Microservicio FastAPI
│   │   ├── guia-nextjs-saas.md        # App SaaS con Next.js
│   │   ├── guia-cli-python.md         # Herramienta CLI en Python
│   │   ├── guia-data-pipeline.md      # Pipeline de datos (ETL)
│   │   ├── guia-refactoring-legacy.md # Refactoring de codigo legacy
│   │   ├── guia-ai-agent-adk.md       # Agente IA con Google ADK
│   │   ├── guia-auditoria-contable.md # Auditoria contable (CTO v11.0)
│   │   └── guia-seleccion-personal.md # Seleccion de personal (CTO v11.0)
│   └── qa/                            # Reportes de control de calidad
│       ├── README.md                  # Indice de QA
│       ├── audits/                    # Reportes de auditoria de calidad (v5-v9)
│       ├── corrections/               # Logs de correcciones (v5-v9.2)
│       ├── integration-tests/         # Reportes de tests de integracion (12 guias)
│       └── smoke-tests/              # Reportes de smoke tests (5 reportes)
├── teams/                             # Assets de Agent Teams
│   ├── templates/                     # Composiciones pre-armadas por stack (7 templates)
│   │   ├── nextjs-saas.md             # Template equipo Next.js SaaS
│   │   ├── fastapi-service.md         # Template equipo microservicio FastAPI
│   │   ├── n8n-automation.md          # Template equipo automatizacion n8n
│   │   ├── ai-agent.md               # Template equipo agente IA
│   │   ├── data-pipeline.md          # Template equipo pipeline de datos
│   │   ├── temporal-io-app.md         # Template equipo workflows Temporal.io
│   │   └── refactoring.md            # Template equipo refactoring legacy
│   └── playbook.md                    # Patrones y mejores practicas de equipos
├── CHANGELOG-refactor.md              # Documento de traza de refactorizaciones (v1-v13.1)
├── academia/                          # Curso de capacitacion (8 modulos, 53 lecciones)
└── infra/                             # Infraestructura y scripts de setup
    ├── setup.sh                       # Script principal (Claude Code)
    ├── sync.sh                        # Sync bidireccional de skills (hub ↔ proyectos, --push para zero-friction)
    ├── replicate-platform.sh          # Replicacion a otras plataformas
    ├── setup_test.sh                  # Tests de verificacion (51 tests)
    └── hooks/                         # Hooks O.R.T.A. (nativos de Claude Code)
        ├── session-start.sh           # SessionStart — inyectar session.md como contexto
        └── session-save.sh            # Stop — logear fin de sesion
```

---

## Como funciona

Batuta opera como un sistema **Mixture of Experts (MoE)**:

1. **CLAUDE.md** es el **router** — punto de entrada unico (~220 lineas). Clasifica el intent del usuario, enforza reglas (Scope Rule, Execution Gate, gates SDD), y enruta al experto correcto. Los skills se auto-descubren por Claude Code via su campo `description`.
2. **Agentes de dominio** son los **expertos** — subprocesos autonomos con "persona gruesa" (80-120 lineas de conocimiento de dominio embebido). Se ejecutan via Task tool, no como contexto inline, manteniendo al agente principal liviano.
3. **Skills** son los **parametros** — cargados bajo demanda cuando un experto necesita patrones especificos (e.g., FastAPI CRUD, JWT auth, modelos SQLAlchemy).
4. **setup.sh --all** sincroniza skills y agentes, instala hooks + permisos, y copia CLAUDE.md a la raiz.

```
CLAUDE.md — EL ROUTER (clasificacion de intent + reglas — ~220 lineas)
    │
    ├──> Hooks (settings.json)
    │     ├── SessionStart → inyecta session.md como contexto
    │     └── Stop → actualiza session.md + logea fin de sesion
    │
    ├──> PARAMETROS — Skills (auto-descubiertos por Claude Code via description)
    │     ├── pipeline: sdd-init...sdd-archive (9 skills)
    │     ├── infra: scope-rule, ecosystem-creator, ecosystem-lifecycle, team-orchestrator, security-audit
    │     └── observability: (sin skills activos)
    │
    ├──> Scope Agents (siempre cargados, skills auto-descubiertos por description)
    │     ├── pipeline-agent (dependency graph, orchestrator rules)
    │     ├── infra-agent (Skill Gap Detection, Ecosystem Auto-Update)
    │     └── observability-agent (session lifecycle)
    │
    ├──> EXPERTOS — Domain Agents (subprocesos autonomos, provisionados por deteccion de tecnologia)
    │     ├── backend-agent (fastapi|django|express|nestjs) — API, auth, BD expertise
    │     ├── quality-agent (siempre provisionado) — testing, seguridad, debugging
    │     └── data-agent (pandas|langchain|anthropic) — ETL, AI/ML, RAG expertise
    │
    └──> Agent Team (Nivel 3) ──> spawn desde scope + domain agents
```

### Multi-Plataforma: Claude Code + Antigravity Lite

Batuta soporta dos plataformas con roles distintos — Claude Code para produccion seria (pipeline SDD completo) y Antigravity Lite como companion de brainstorming y prototipado rapido:

| Aspecto | Claude Code (Full) | Antigravity Lite |
|---------|-------------------|-------------------|
| Rol | Produccion — pipeline SDD completo, arquitectura, features complejas | Exploracion — brainstorming, prototipado rapido, scripts, docs |
| Cerebro | CTO completo via CLAUDE.md | CTO completo via GEMINI.md |
| Comandos | Slash commands (nativos) | Workflows (prompts guardados) |
| Hooks | Nativos (SessionStart, Stop) | Sin hooks — solo reglas de comportamiento |
| Skills | `~/.claude/skills/` | `.agent/skills/` o `~/.gemini/antigravity/skills/` |
| Multi-agente | Agent Teams | Manager View |
| Costo | Claude Max x20 ($200/mes) | Gratis (preview) |

Los skills son agnosticos de plataforma (estandar abierto SKILL.md). El campo `platforms` en el frontmatter controla que plataformas reciben cada skill durante el sync. Ver [Guia de Antigravity Lite](docs/guides/guia-batuta-antigravity.md).

```bash
# Setup Antigravity en un proyecto
bash BatutaAntigravity/setup-antigravity.sh --workspace

# Sincronizar skills filtrados por tag platforms
bash infra/sync.sh --to-antigravity

# Propagar skills locales al hub (import + cross-sync + commit + push)
bash infra/sync.sh --push

# Otras plataformas (Gemini CLI, Codex, Copilot)
./infra/replicate-platform.sh --all
```

---

## Conceptos Clave

### Regla de Alcance (Scope Rule)

Antes de crear CUALQUIER archivo, el agente pregunta: "Quien va a usar esto?"

| Quien lo usa? | Donde va |
|---|---|
| 1 feature | `features/{feature}/{tipo}/{nombre}` |
| 2+ features | `features/shared/{tipo}/{nombre}` |
| Toda la app | `core/{tipo}/{nombre}` |

NUNCA se crean carpetas `utils/`, `helpers/`, `lib/` o `components/` en la raiz. Detalles completos en el skill `scope-rule`.

### Spec-Driven Development (SDD)

Maquina de estados de 9 fases que fuerza "entender antes de construir":

```
init -> explore -> propose -> spec -> design -> tasks -> apply -> verify -> archive
                                                          ↑ backtracks ↑
```

Cada fase es un sub-agente especializado. El pipeline-agent orquesta como **maquina de estados** — las fases avanzan (happy path) o retroceden (backtracks) cuando la implementacion revela problemas. El usuario interactua con **conversacion natural** (auto-routing clasifica intent), no con slash commands. Los comandos permanecen como override manual.

### Auto-Routing (Pipeline Dirigido por Intent)

El usuario describe lo que necesita en lenguaje natural. El agente clasifica el intent y enruta automaticamente:

| Intent | Ruta |
|--------|------|
| Construir / Feature / Problema | Pipeline SDD (auto-avance con checkpoints) |
| Fix rapido / Bug | Fix directo (sin SDD, Execution Gate LIGHT) |
| Continuar / Retomar | Detecta fase desde artefactos, retoma |
| Backtrack / Repensar | Clasifica fase destino, actualiza artefacto, re-avanza |
| Pregunta / Explicar | Responde directamente |
| Comando `/sdd-*` explicito | Override manual |

### Agentes (Scope + Dominio) — Los Expertos del MoE

Los 6 agentes de Batuta forman la capa de "expertos" de la arquitectura MoE. **3 Agentes de Scope** (siempre cargados) organizan la maquinaria del pipeline SDD, y **3 Agentes de Dominio** (provisionados por deteccion de tecnologia) llevan "persona gruesa" — 80-120 lineas de expertise de dominio embebido que se ejecutan como subprocesos autonomos, no como contexto inline.

**Agentes de Scope** — siempre cargados, skills auto-descubiertos por campo `description`:

| Agente de Scope | Dominio | Skills |
|-----------------|---------|--------|
| `pipeline-agent` | Ciclo de desarrollo | 9 skills SDD (init a archive) |
| `infra-agent` | Organizacion, ecosistema, seguridad | scope-rule, ecosystem-creator, ecosystem-lifecycle, team-orchestrator, security-audit |
| `observability-agent` | Ciclo de sesion | (sin skills activos) |

**Agentes de Dominio** — auto-invocados segun senales de tecnologia, ejecutados como subprocesos via Task tool:

| Agente de Dominio | Provisionado Cuando | Expertise |
|-------------------|---------------------|-----------|
| `backend-agent` | fastapi, django, express, nestjs detectado | Diseno de API, flujos de auth, schema BD, middleware |
| `quality-agent` | Siempre provisionado | AI Validation Pyramid, estrategia de testing, auditorias de seguridad, debugging |
| `data-agent` | pandas, langchain, anthropic detectado | Pipelines ETL, integracion AI/ML, patrones RAG |

Los agentes de dominio llevan personalidad + patrones + punteros a skills e incluyen un bloque `sdk:` para deployment programatico via Claude Agent SDK. Esto mantiene al agente principal liviano (~220 lineas) y a cada agente enfocado en su dominio.

**Ciclo de Vida de Agentes** — los agentes siguen el mismo modelo de sync que los skills:

1. **Crear**: `ecosystem-creator` genera el agente en `BatutaClaude/agents/` (hub)
2. **Clasificar**: `ecosystem-lifecycle` determina si el agente es generico (hub) o especifico del proyecto (local)
3. **Sync a global**: `setup.sh --sync` copia agentes del hub a `~/.claude/agents/`
4. **Provisionar a proyectos**: `sdd-init` copia agentes relevantes de global a `.claude/agents/` segun tecnologias detectadas

### Execution Gate (Puerta de Ejecucion)

Antes de cualquier cambio de codigo, una pre-validacion obligatoria se ejecuta. No se puede omitir.

| Modo | Cuando | Que muestra |
|------|--------|-------------|
| LIGHT | Edicion de un solo archivo, fix simple | "Modifico {archivo} en {ubicacion}. Procedo?" |
| FULL | Archivos nuevos, 2+ archivos, arquitectura | Plan de ubicacion + impacto + cumplimiento SDD/skills |

### Hooks Nativos

Batuta usa hooks nativos de Claude Code para enforcement determinístico:

| Hook | Tipo | Proposito |
|------|------|-----------|
| SessionStart | command | Inyecta `.batuta/session.md` como contexto automaticamente |
| Stop | prompt + command | Actualiza session.md + logea fin de sesion |

### Deteccion de Skills Faltantes

Antes de escribir codigo con una tecnologia, Claude verifica si existe un skill activo en `~/.claude/skills/` (global) o `.claude/skills/` (local del proyecto). Si no existe en ninguna ubicacion, se detiene y ofrece investigar via Context7 y crear el skill antes de continuar.

### Carga Lazy (3 niveles — MoE en accion)

| Nivel | Rol MoE | Que se carga | Lineas |
|-------|---------|-------------|--------|
| 1 | Router | CLAUDE.md (clasificacion de intent + reglas) | ~220 |
| 2 | Experto | Agente de scope o dominio | ~80-120 |
| 3 | Parametros | Skill individual | ~200-500 |

Solo se carga el nivel necesario. Una pregunta simple nunca llega al nivel 3.

### Continuidad de Sesion

Al inicio de cada conversacion, Claude lee `.batuta/session.md` para restaurar contexto. Al final de trabajo significativo, actualiza el archivo para que la proxima conversacion retome donde quedo.

### Agent Teams (Ejecucion de 3 Niveles)

Batuta soporta tres niveles de ejecucion. El sistema evalua automaticamente cual usar:

| Nivel | Mecanismo | Cuando |
|-------|-----------|--------|
| Sesion solo | Ejecucion directa | Edicion 1 archivo, bug fix, pregunta simple |
| Subagente (Task tool) | Delegacion fire-and-forget | Investigacion, verificacion, fase SDD individual |
| Agent Team | Multiples sesiones Claude independientes | Feature multi-modulo, pipeline SDD completo, hipotesis competitivas |

Los Agent Teams crean sesiones reales de Claude Code que trabajan en paralelo con una lista de tareas compartida y mensajeria bidireccional.

### Auto-actualizacion del Ecosistema

Cuando se crean skills nuevos en un proyecto, Claude propone propagarlos de vuelta a batuta-dots para que otros proyectos se beneficien.

### Provisioning de Skills por Proyecto (v11.3) y Agentes (v13.0)

Durante `/sdd-init`, solo los skills relevantes se copian de la libreria global al proyecto. El agente solo ve lo que necesita, manteniendo el contexto limpio mientras el ecosistema crece a 100+ skills.

El provisioning de agentes sigue el mismo principio. El manifiesto `skill-provisions.yaml` define:

- **`always_agents`**: agentes provisionados a todo proyecto (actualmente: `quality-agent`)
- **`agent_rules`**: provisioning condicional basado en dependencias detectadas (e.g., `backend-agent` cuando se detecta fastapi/django/express, `data-agent` cuando se detecta pandas/langchain/anthropic)

### Reglas Deterministicas y Gates Mandatorios

Todos los comportamientos mandatorios (enforcement de scope, invocacion de skills, gates del pipeline, ciclo de vida del ecosistema) estan definidos como Rules con palabras clave MUST/NEVER/ALWAYS — deterministicos y resistentes a compaction. Siete gates mandatorios (Execution Gate, G0.25, G0.5, G1, Aprobacion de Propuesta, Aprobacion de Plan de Tareas, G2) estan consolidados como puntos de STOP explicitos.

### Output Proporcional y Budget de Sesion

El output escala con la complejidad de la tarea via tres tiers (MICRO/STANDARD/COMPLEX). Session.md tiene un limite de 80 lineas como documento de briefing que responde DONDE/POR QUE/COMO — no es un README del proyecto.

---

## Skills Disponibles (38 skills + 6 agentes)

| Skill | Scope | Descripcion |
|-------|-------|-------------|
| `ecosystem-creator` | infra | Crea nuevos skills, agentes, sub-agentes y workflows |
| `scope-rule` | infra | Organiza archivos por alcance (feature / shared / core) |
| `team-orchestrator` | infra | Evalua cuando escalar a Agent Teams, spawn y coordinacion |
| `ecosystem-lifecycle` | infra | Clasifica, auto-repara y provisiona el ciclo de vida de skills |
| `skill-eval` | infra | Evalua calidad de skills: Eval (test conductual), Improve (proponer ediciones), Benchmark (reporte de salud) |
| `claude-agent-sdk` | infra | Patrones Claude Agent SDK: setting_sources, defer_loading, hooks mapping, CI/CD deployment |
| `security-audit` | infra, pipeline | Seguridad AI-first: OWASP + inyeccion de prompts + escaneo de secretos + auditoria de dependencias |
| `sdd-init` a `sdd-archive` | pipeline | Pipeline SDD de 9 fases |
| `process-analyst` | pipeline | Analisis de procesos complejos con 3+ variantes de caso |
| `recursion-designer` | pipeline | Taxonomias externas, categorias que cambian, sistemas de aprendizaje |
| `compliance-colombia` | pipeline | Proteccion de datos colombiana, retencion fiscal, compliance IA |
| `data-pipeline-design` | pipeline | ETL, integraciones ERP, patrones de calidad de datos |
| `llm-pipeline-design` | pipeline | Clasificadores LLM, prompt engineering, deteccion de drift |
| `worker-scaffold` | pipeline | Workers Temporal, Docker, Coolify deploy, monitoreo |
| `accessibility-audit` | pipeline | Auditoria de accesibilidad: WCAG, lectores de pantalla, navegacion por teclado |
| `performance-testing` | pipeline | Testing de rendimiento: pruebas de carga, profiling, analisis de cuellos de botella |
| `technical-writer` | pipeline | Escritura tecnica: docs de API, guias de usuario, registros de decisiones arquitecturales |
| `fastapi-crud` | infra | Patrones CRUD para FastAPI |
| `jwt-auth` | infra | Patrones de autenticacion JWT |
| `sqlalchemy-models` | infra | Patrones de modelos SQLAlchemy ORM |
| `react-nextjs` | pipeline | Patrones React/Next.js App Router |
| `typescript-node` | pipeline | Patrones TypeScript/Node.js backend |
| `api-design` | pipeline | Diseno de APIs REST, versionado, manejo de errores |
| `e2e-testing` | pipeline | Testing end-to-end con Playwright/Cypress |
| `tdd-workflow` | pipeline | Metodologia Test-Driven Development |
| `debugging-systematic` | pipeline | Depuracion sistematica con busqueda binaria y prueba de hipotesis |
| `vector-db-rag` | pipeline | Bases de datos vectoriales y pipelines RAG |
| `message-queues` | pipeline | Patrones de colas de mensajes (RabbitMQ, Redis, SQS) |
| `ci-cd-pipeline` | infra | Diseno y automatizacion de pipelines CI/CD |
| `observability` | observability | Monitoreo, logging, tracing, alertas |

---

## Comandos

| Comando | Descripcion |
|---------|-------------|
| `/batuta-init [nombre]` | Importar ecosistema Batuta a un proyecto |
| `/batuta-update` | Actualizar ecosistema desde batuta-dots |
| `/sdd-init` | Inicializar contexto de orquestacion |
| `/sdd-explore <tema>` | Explorar idea y restricciones |
| `/sdd-new <nombre>` | Iniciar flujo de propuesta |
| `/sdd-continue [nombre]` | Ejecutar siguiente fase |
| `/sdd-ff [nombre]` | Fast-forward: propose → spec → design → tasks |
| `/sdd-apply [nombre]` | Implementar en lotes |
| `/sdd-verify [nombre]` | Validar implementacion |
| `/sdd-archive [nombre]` | Cerrar y persistir estado final |
| `/create <tipo> <nombre>` | Crear un nuevo skill, sub-agente o workflow |

---

## Opciones de setup.sh

| Flag | Accion |
|------|--------|
| `--claude` | Copia CLAUDE.md a la raiz del proyecto |
| `--sync` | Sincroniza skills + agentes + commands a ~/.claude/ |
| `--all` | Setup completo: sync + hooks + copy + antigravity (recomendado) |
| `--hooks` | Instala hooks + permisos en ~/.claude/settings.json |
| `--antigravity` | Sincroniza skills compatibles con Antigravity a BatutaAntigravity/skills/ |
| `--project <path>` | Setup de un proyecto destino (CLAUDE.md + .batuta/ + git + hooks) |
| `--update <path>` | Actualizar un proyecto existente (re-sync global + refrescar CLAUDE.md + ecosystem.json del proyecto) |
| `--verify` | Verificacion completa (51 checks) |

El flag `--all`: sincroniza skills y agentes → instala hooks + permisos → copia CLAUDE.md actualizado a la raiz.

---

## Guias

Guias de ejecucion paso a paso (14 guias) cubriendo el ciclo completo: instalacion del ecosistema → pipeline SDD → construccion → pruebas → deploy → produccion → archive.

| Guia | Descripcion |
|------|-------------|
| [Dashboard App](docs/guides/guia-batuta-app.md) | Construir dashboard de monitoreo (n8n + tokens Google AI) — 15 pasos |
| [Temporal.io Workers](docs/guides/guia-temporal-io-app.md) | Construir orquestacion de workflows con Temporal.io — 14 pasos |
| [Agente LangChain + Gmail](docs/guides/guia-langchain-gmail-agent.md) | Construir agente IA clasificador de emails — 15 pasos |
| [Automatizacion n8n](docs/guides/guia-n8n-automation.md) | Automatizar procesos de negocio con n8n |
| [Microservicio FastAPI](docs/guides/guia-fastapi-service.md) | Construir API REST con FastAPI |
| [SaaS Next.js](docs/guides/guia-nextjs-saas.md) | Construir app SaaS multi-tenant con Next.js |
| [CLI Python](docs/guides/guia-cli-python.md) | Construir herramienta de linea de comandos con Python |
| [Pipeline de Datos](docs/guides/guia-data-pipeline.md) | Construir pipeline ETL con validacion |
| [Refactoring Legacy](docs/guides/guia-refactoring-legacy.md) | Modernizar codigo legacy sin romper funcionalidad |
| [Agente IA (Google ADK)](docs/guides/guia-ai-agent-adk.md) | Construir agente conversacional con Google ADK |
| [Auditoria Contable](docs/guides/guia-auditoria-contable.md) | Conciliacion bancaria — flujo CTO v11.0 completo |
| [Seleccion de Personal](docs/guides/guia-seleccion-personal.md) | Evaluacion de CVs con LLM + compliance |
| [Antigravity Lite](docs/guides/guia-batuta-antigravity.md) | Guia de setup y workflows de Antigravity |
| [SDK Deployment](docs/guides/guia-sdk-deployment.md) | Deploy de agentes via Claude Agent SDK (Python + TypeScript) |

## Academia (Manual de Capacitacion)

Curso completo de Batuta Dots — desde cero hasta uso autonomo. 53 lecciones en 8 modulos, 21 casos de uso reales en 10 industrias.

| Modulo | Contenido | Lecciones |
|--------|-----------|-----------|
| [00 — Bienvenida](academia/00-bienvenida/) | Que es Batuta, setup, mapa del curso | 3 |
| [01 — Nivel Cero](academia/01-nivel-cero/) | Primer proyecto, comandos, pipeline SDD, gates | 4 |
| [02 — Nivel Uno](academia/02-nivel-uno/) | Catalogo de skills, agentes, capa CTO, Scope Rule | 5 |
| [03 — Nivel Dos](academia/03-nivel-dos/) | Depuracion, validacion, equipos, compliance, hooks | 5 |
| [04 — Nivel Tres](academia/04-nivel-tres/) | Extender ecosistema, templates, infra, recursion, multi-plataforma | 5 |
| [05 — Casos de Uso](academia/05-casos-de-uso/) | Casos reales por industria | 21 |
| [06 — Referencia](academia/06-referencia/) | Comandos, skills, glosario, troubleshooting | 5 |
| [07 — Verificacion](academia/07-verificacion/) | Quizzes por nivel + checklist de graduacion | 5 |

**Industrias cubiertas**: Desarrollo web, Operaciones, Mantenimiento, Produccion, Supply chain, Logistica, Marketing, Finanzas, RRHH, Estudiantes.

→ [Empezar el curso](academia/README.md)

---

## Arquitectura y Diseno

| Documento | Descripcion |
|-----------|-------------|
| [Diagramas de Arquitectura](docs/architecture/arquitectura-diagrama.md) | 15+ diagramas Mermaid (SDD, hooks, piramide, contratos, seguridad, etc.) |
| [Arquitectura para No-Tecnicos](docs/architecture/arquitectura-para-no-tecnicos.md) | Analogia del restaurante para no-desarrolladores |

---

## Contribuir

### Agregar un Skill Nuevo

1. Ejecutar `/create skill <nombre>` — el ecosystem-creator guia el proceso (frontmatter: scope, auto_invoke, allowed-tools)
2. O manualmente: crear `BatutaClaude/skills/<nombre>/SKILL.md` con frontmatter completo
3. Ejecutar `./infra/setup.sh --all`

### Agregar un Agente de Scope Nuevo

1. Crear `BatutaClaude/agents/<scope>-agent.md` con frontmatter nativo (`name`, `description`, `skills`, `memory`)
2. Actualizar frontmatters de SKILL.md para referenciar el nuevo scope
3. Ejecutar `./infra/setup.sh --all`

### Agregar un Agente de Dominio Nuevo

1. Crear `BatutaClaude/agents/<dominio>-agent.md` con frontmatter incluyendo bloque `sdk:` (model, max_tokens, allowed_tools, setting_sources, defer_loading)
2. Agregar regla de provisioning en `BatutaClaude/skills/sdd-init/assets/skill-provisions.yaml` bajo `agent_rules` (patrones de deteccion + agente destino)
3. Si el agente debe provisionarse a todos los proyectos, agregarlo a `always_agents` en lugar de `agent_rules`
4. Ejecutar `./infra/setup.sh --all`

---

## Creditos

Inspirado en [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) de [Gentleman Programming](https://github.com/Gentleman-Programming). Batuta adapta el concepto de dotfiles para fabricas de software multi-proyecto con personalidad CTO/Mentor, Spec-Driven Development, Regla de Alcance, scope agents con skills auto-descubiertos, auto-deteccion de skills, y el framework O.R.T.A.

---

## Licencia

[MIT](LICENSE)
