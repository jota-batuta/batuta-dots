# Batuta.Dots

**Ecosistema de agentes IA para fabricas de software — Claude Code primero, replicable a cualquier plataforma.**

[![Licencia: MIT](https://img.shields.io/badge/Licencia-MIT-blue.svg)](LICENSE)

---

## Que es Batuta?

Batuta es un ecosistema de agentes IA que le da a Claude Code un conjunto completo de skills, workflows y metodologia de desarrollo. Escribes tus convenciones una vez en `CLAUDE.md`, y los skills se cargan bajo demanda segun el contexto. Cuando estes listo para extender a otras plataformas, un script de replicacion genera el equivalente para Gemini, Copilot, Codex u OpenCode.

Inspirado en [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots), adaptado para:

- **Fabrica de software multi-proyecto**.
- **Personalidad CTO/Mentor** que educa y documenta para personas no tecnicas.
- **Regla de Alcance (Scope Rule)** que organiza archivos por quien los usa, no por tipo.
- **Auto-deteccion de gaps en skills** con investigacion automatica via Context7.
- **Carga lazy de skills** — Claude lee ~186 lineas al iniciar, el resto se carga bajo demanda.
- **Routing nativo** — skills se auto-invocan por su campo `description`, agentes de scope con frontmatter nativo.
- **Execution Gate** — pre-validacion obligatoria via hook `PreToolUse` (enforcement determinístico).
- **Hooks nativos** — SessionStart, PreToolUse, Stop, TeammateIdle, TaskCompleted.
- **Skill-Sync** — inventario de assets auto-generado desde frontmatters de skills.
- **Framework O.R.T.A.** (Observabilidad, Repetibilidad, Trazabilidad, Auto-supervision).
- **Agent Teams** — orquestacion de multiples sesiones Claude en paralelo para tareas complejas.
- **Contract-First Protocol** — contratos pre-spawn definen input/output/file-ownership por teammate.
- **Seguridad AI-First** — skill security-audit dedicado, integrado en fases de diseno y verificacion.
- **Team Templates + Playbook** — composiciones pre-armadas por stack (Next.js, FastAPI, n8n, agente IA, data pipeline, refactoring).

---

## Inicio Rapido

```bash
# 1. Clonar el repositorio
git clone https://github.com/jota-batuta/batuta-dots.git
cd batuta-dots

# 2. Setup completo: sync skills + agentes + skill-sync + hooks + copiar CLAUDE.md
./skills/setup.sh --all

# 3. Verificar
./skills/setup.sh --verify
```

O ejecuta `./skills/setup.sh` sin argumentos para un menu interactivo.

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
│   │   ├── batuta-analyze-prompts.md  # /batuta:analyze-prompts — analisis de satisfaccion
│   │   └── batuta-sync-skills.md      # /batuta:sync-skills — regenerar tablas de routing
│   ├── agents/                        # Agentes de scope (frontmatter nativo + dominio)
│   │   ├── pipeline-agent.md          # Especialista SDD Pipeline (9 skills)
│   │   ├── infra-agent.md             # Especialista infraestructura (5 skills)
│   │   └── observability-agent.md     # Motor O.R.T.A. (1 skill)
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
│       ├── prompt-tracker/            # Tracking de satisfaccion (O.R.T.A.)
│       │   ├── SKILL.md
│       │   └── assets/session-template.md
│       ├── team-orchestrator/SKILL.md # Orquestacion Agent Teams (cuando escalar)
│       ├── security-audit/SKILL.md   # Seguridad AI-first (OWASP + amenazas + escaneo de secretos)
│       └── skill-sync/               # Generacion automatica de tablas de routing
│           ├── SKILL.md
│           └── assets/
│               ├── sync.sh
│               └── sync_test.sh
├── docs/                              # Toda la documentacion
│   ├── architecture/                  # Arquitectura y diseno
│   │   ├── arquitectura-diagrama.md   # Diagramas Mermaid de arquitectura (15+ diagramas)
│   │   └── arquitectura-para-no-tecnicos.md  # Guia sin tecnicismos (analogia restaurante, 15+ roles)
│   ├── guides/                        # Guias de ejecucion paso a paso (10 guias, Espanol)
│   │   ├── guia-batuta-app.md         # Dashboard app — guia ciclo completo
│   │   ├── guia-temporal-io-app.md    # Temporal.io workflows — guia ciclo completo
│   │   ├── guia-langchain-gmail-agent.md  # Agente LangChain + Gmail — guia ciclo completo
│   │   ├── guia-n8n-automation.md     # Automatizacion con n8n
│   │   ├── guia-fastapi-service.md    # Microservicio FastAPI
│   │   ├── guia-nextjs-saas.md        # App SaaS con Next.js
│   │   ├── guia-cli-python.md         # Herramienta CLI en Python
│   │   ├── guia-data-pipeline.md      # Pipeline de datos (ETL)
│   │   ├── guia-refactoring-legacy.md # Refactoring de codigo legacy
│   │   └── guia-ai-agent-adk.md       # Agente IA con Google ADK
│   └── qa/                            # Reportes de control de calidad
│       ├── BatutaTestCalidadV5.md     # Reporte de calidad v5
│       ├── BatutaTestCalidadV6.md     # Reporte de calidad v6
│       ├── BatutaTestCalidadV7.md     # Reporte de calidad v7
│       ├── BatutaTestCalidadV9.md     # Reporte de calidad v9
│       ├── LogCorrecciones-V5.md      # Log de correcciones v5
│       ├── LogCorrecciones-V6.md      # Log de correcciones v6
│       ├── LogCorrecciones-V7.md      # Log de correcciones v7
│       └── LogCorrecciones-V9.md      # Log de correcciones v9
├── teams/                             # Assets de Agent Teams
│   ├── templates/                     # Composiciones pre-armadas por stack
│   │   ├── nextjs-saas.md             # Template equipo Next.js SaaS
│   │   ├── fastapi-service.md         # Template equipo microservicio FastAPI
│   │   ├── n8n-automation.md          # Template equipo automatizacion n8n
│   │   ├── ai-agent.md               # Template equipo agente IA
│   │   ├── data-pipeline.md          # Template equipo pipeline de datos
│   │   └── refactoring.md            # Template equipo refactoring legacy
│   └── playbook.md                    # Patrones y mejores practicas de equipos
├── CHANGELOG-refactor.md              # Documento de traza de refactorizaciones (v1-v9)
└── skills/                            # Scripts del repositorio
    ├── setup.sh                       # Script principal (Claude Code)
    ├── replicate-platform.sh          # Replicacion a otras plataformas (futuro)
    ├── setup_test.sh                  # Tests de verificacion (51 tests)
    └── hooks/                         # Hooks O.R.T.A. (nativos de Claude Code)
        ├── session-start.sh           # SessionStart — inyectar session.md como contexto
        ├── session-save.sh            # Stop — logear fin de sesion
        ├── orta-teammate-idle.sh      # TeammateIdle — registrar fin de teammate
        └── orta-task-gate.sh          # TaskCompleted — puerta de calidad
```

---

## Como funciona

1. **CLAUDE.md** es el punto de entrada (~186 lineas). Define personalidad, reglas, Scope Rule, Execution Gate, y SDD commands.
2. **Skills se auto-invocan** por Claude Code basandose en su campo `description`. No hay routing manual.
3. **Hooks nativos** enfuerzan comportamientos criticos de forma deterministica (Execution Gate, session continuity).
4. **setup.sh --all** sincroniza skills y agentes, ejecuta skill-sync para validar inventario, y copia CLAUDE.md a la raiz.

```
CLAUDE.md (personalidad + reglas — ~186 lineas)
    │
    ├──> Hooks nativos (settings.json)
    │     ├── SessionStart → inyecta session.md como contexto
    │     ├── PreToolUse → Execution Gate (valida antes de Write/Edit)
    │     ├── Stop → actualiza session.md + logea fin de sesion
    │     ├── TeammateIdle → logging centralizado
    │     └── TaskCompleted → puerta de calidad
    │
    ├──> Skills (auto-invocados por Claude Code via description)
    │     ├── pipeline: sdd-init...sdd-archive (9 skills)
    │     ├── infra: scope-rule, ecosystem-creator, skill-sync, team-orchestrator, security-audit
    │     └── observability: prompt-tracker
    │
    ├──> Scope Agents (frontmatter nativo + dominio)
    │     ├── pipeline-agent (dependency graph, orchestrator rules)
    │     ├── infra-agent (Skill Gap Detection, Ecosystem Auto-Update)
    │     └── observability-agent (session lifecycle, analysis pipeline)
    │
    └──> Agent Team (Nivel 3) ──> spawn desde scope agents
```

### Otras plataformas (futuro)

```bash
./skills/replicate-platform.sh --all    # Genera GEMINI.md, CODEX.md, copilot-instructions.md
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

Pipeline de 9 fases que fuerza "entender antes de construir":

```
init -> explore -> propose -> spec -> design -> tasks -> apply -> verify -> archive
```

Cada fase es un sub-agente especializado. El pipeline-agent orquesta, delega todo el trabajo pesado y solo rastrea estado y decisiones del usuario.

### Mix-of-Experts

El agente principal actua como un router puro. Clasifica el scope de cada solicitud y delega a agentes de scope especializados:

| Agente de Scope | Dominio | Skills |
|-----------------|---------|--------|
| `pipeline-agent` | Ciclo de desarrollo | 9 skills SDD (init a archive) |
| `infra-agent` | Organizacion, ecosistema, seguridad | scope-rule, ecosystem-creator, skill-sync, team-orchestrator, security-audit |
| `observability-agent` | Tracking de calidad | prompt-tracker |

Esto mantiene al agente principal liviano (~186 lineas) y a cada agente de scope enfocado en su dominio. Los scope agents usan frontmatter nativo de Claude Code (`skills`, `memory: project`).

### Execution Gate (Puerta de Ejecucion)

Antes de cualquier cambio de codigo, una pre-validacion obligatoria se ejecuta. No se puede omitir. Enforzado determinísticamente via hook `PreToolUse` sobre `Write|Edit`.

| Modo | Cuando | Que muestra |
|------|--------|-------------|
| LIGHT | Edicion de un solo archivo, fix simple | "Modifico {archivo} en {ubicacion}. Procedo?" |
| FULL | Archivos nuevos, 2+ archivos, arquitectura | Plan de ubicacion + impacto + cumplimiento SDD/skills |

### Hooks Nativos (v8)

Batuta usa hooks nativos de Claude Code para enforcement determinístico:

| Hook | Tipo | Proposito |
|------|------|-----------|
| SessionStart | command | Inyecta `.batuta/session.md` como contexto automaticamente |
| PreToolUse | prompt | Execution Gate: valida cambios antes de Write/Edit |
| Stop | prompt + command | Actualiza session.md + logea fin de sesion |
| TeammateIdle | command | Logging centralizado de teammates |
| TaskCompleted | command | Puerta de calidad para tareas |

### Skill-Sync

El inventario de skills se gestiona desde los frontmatters de SKILL.md. Agregar un skill = crear SKILL.md con frontmatter → ejecutar sync.sh → inventario validado automaticamente.

### Deteccion de Skills Faltantes

Antes de escribir codigo con una tecnologia, Claude verifica si existe un skill activo en `~/.claude/skills/` (global) o `.claude/skills/` (local del proyecto). Si no existe en ninguna ubicacion, se detiene y ofrece investigar via Context7 y crear el skill antes de continuar.

### Carga Lazy (3 niveles)

| Nivel | Que se carga | Lineas |
|-------|-------------|--------|
| 1 | CLAUDE.md (personalidad + reglas) | ~186 |
| 2 | Agente de scope | ~80-120 |
| 3 | Skill individual | ~200-500 |

Solo se carga el nivel necesario. Una pregunta simple nunca llega al nivel 3.

### Tracking de Satisfaccion de Prompts (O.R.T.A.)

Cada interaccion significativa se registra en `.batuta/prompt-log.jsonl`. Seis tipos de evento: `prompt`, `gate`, `correction`, `follow-up`, `closed`, `team`. Con el tiempo, `/batuta:analyze-prompts` computa metricas y genera recomendaciones accionables.

### Continuidad de Sesion

Enforzada determinísticamente via hooks nativos. Al inicio de cada conversacion, el hook `SessionStart` inyecta `.batuta/session.md` automaticamente. Al final, el hook `Stop` evalua si se necesita actualizar el archivo.

### Agent Teams (Ejecucion de 3 Niveles)

Batuta soporta tres niveles de ejecucion. El sistema evalua automaticamente cual usar:

| Nivel | Mecanismo | Cuando |
|-------|-----------|--------|
| Sesion solo | Ejecucion directa | Edicion 1 archivo, bug fix, pregunta simple |
| Subagente (Task tool) | Delegacion fire-and-forget | Investigacion, verificacion, fase SDD individual |
| Agent Team | Multiples sesiones Claude independientes | Feature multi-modulo, pipeline SDD completo, hipotesis competitivas |

Los Agent Teams crean sesiones reales de Claude Code que trabajan en paralelo con una lista de tareas compartida y mensajeria bidireccional. Hooks O.R.T.A. (`TeammateIdle`, `TaskCompleted`) aseguran logging centralizado y puertas de calidad.

### Auto-actualizacion del Ecosistema

Cuando se crean skills nuevos en un proyecto, Claude propone propagarlos de vuelta a batuta-dots para que otros proyectos se beneficien.

---

## Skills Disponibles (15 + 3 agentes de scope)

| Skill | Scope | Descripcion |
|-------|-------|-------------|
| `ecosystem-creator` | infra | Crea nuevos skills, agentes, sub-agentes y workflows |
| `scope-rule` | infra | Organiza archivos por alcance (feature / shared / core) |
| `skill-sync` | infra | Genera tablas de routing automaticamente desde frontmatters |
| `team-orchestrator` | infra | Evalua cuando escalar a Agent Teams, spawn y coordinacion |
| `security-audit` | infra, pipeline | Seguridad AI-first: OWASP + inyeccion de prompts + escaneo de secretos + auditoria de dependencias |
| `sdd-init` a `sdd-archive` | pipeline | Pipeline SDD de 9 fases |
| `prompt-tracker` | observability | Tracking de satisfaccion, compliance de gate, y analisis de patrones |

---

## Comandos

| Comando | Agente de Scope | Descripcion |
|---------|-----------------|-------------|
| `/batuta-init [nombre]` | — | Importar ecosistema Batuta a un proyecto |
| `/batuta-update` | — | Actualizar ecosistema desde batuta-dots |
| `/sdd:init` | pipeline | Inicializar contexto de orquestacion |
| `/sdd:explore <tema>` | pipeline | Explorar idea y restricciones |
| `/sdd:new <nombre>` | pipeline | Iniciar flujo de propuesta |
| `/sdd:continue [nombre]` | pipeline | Ejecutar siguiente fase |
| `/sdd:apply [nombre]` | pipeline + infra | Implementar en lotes |
| `/sdd:verify [nombre]` | pipeline | Validar implementacion |
| `/sdd:archive [nombre]` | pipeline | Cerrar y persistir estado final |
| `/create:skill <nombre>` | infra | Crear un nuevo skill |
| `/create:sub-agent <nombre>` | infra | Crear un nuevo sub-agente |
| `/create:workflow <nombre>` | infra | Crear un nuevo workflow |
| `/batuta:analyze-prompts` | observability | Analizar log de satisfaccion y generar recomendaciones |
| `/batuta:sync-skills` | infra | Regenerar tablas de routing desde frontmatters |

---

## Opciones de setup.sh

| Flag | Accion |
|------|--------|
| `--claude` | Copia CLAUDE.md a la raiz del proyecto |
| `--sync` | Sincroniza skills + agentes + commands a ~/.claude/ |
| `--all` | Setup completo: sync + skill-sync + hooks + copy (recomendado) |
| `--hooks` | Instala hooks + permisos en ~/.claude/settings.json |
| `--project <path>` | Setup de un proyecto destino (CLAUDE.md + .batuta/ + git + hooks) |
| `--verify` | Verificacion completa (51 checks) |

El flag `--all`: sincroniza skills y agentes → ejecuta skill-sync → instala hooks + permisos → copia CLAUDE.md actualizado a la raiz.

---

## Guias

Guias de ejecucion paso a paso cubriendo el ciclo completo: instalacion del ecosistema → pipeline SDD → construccion → pruebas → deploy → produccion → archive.

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

## Arquitectura y Diseno

| Documento | Descripcion |
|-----------|-------------|
| [Diagramas de Arquitectura](docs/architecture/arquitectura-diagrama.md) | 15+ diagramas Mermaid (MoE, SDD, hooks, piramide, contratos, seguridad, etc.) |
| [Arquitectura para No-Tecnicos](docs/architecture/arquitectura-para-no-tecnicos.md) | Analogia del restaurante para no-desarrolladores |

---

## Contribuir

### Agregar un Skill Nuevo

1. Ejecutar `/create:skill <nombre>` — el ecosystem-creator guia el proceso (frontmatter: scope, auto_invoke, allowed-tools)
2. O manualmente: crear `BatutaClaude/skills/<nombre>/SKILL.md` con frontmatter completo
3. Ejecutar `bash BatutaClaude/skills/skill-sync/assets/sync.sh` para actualizar tablas de routing
4. Ejecutar `./skills/setup.sh --all`

### Agregar un Agente de Scope Nuevo

1. Crear `BatutaClaude/agents/<scope>-agent.md` con frontmatter nativo (`name`, `description`, `skills`, `memory`)
2. Actualizar frontmatters de SKILL.md para referenciar el nuevo scope
3. Ejecutar skill-sync para validar el inventario

---

## Creditos

Inspirado en [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) de [Gentleman Programming](https://github.com/Gentleman-Programming). Batuta adapta el concepto de dotfiles para fabricas de software multi-proyecto con personalidad CTO/Mentor, Spec-Driven Development, Regla de Alcance, routing Mix-of-Experts, auto-deteccion de skills, y el framework O.R.T.A.

---

## Licencia

[MIT](LICENSE)
