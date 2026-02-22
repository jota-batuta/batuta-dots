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
- **Carga lazy de skills** — Claude lee ~216 lineas al iniciar, el resto se carga bajo demanda.
- **Routing Mix-of-Experts** — agente principal delega a agentes de scope especializados.
- **Execution Gate** — pre-validacion obligatoria antes de cualquier cambio de codigo.
- **Skill-Sync** — tablas de routing auto-generadas desde frontmatters de skills.
- **Framework O.R.T.A.** (Observabilidad, Repetibilidad, Trazabilidad, Auto-supervision).

---

## Inicio Rapido

```bash
# 1. Clonar el repositorio
git clone https://github.com/jota-batuta/batuta-dots.git
cd batuta-dots

# 2. Setup completo: sync skills + agentes + skill-sync + copiar CLAUDE.md
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
│   ├── settings.json                  # Permisos, estilo de salida
│   ├── mcp-servers.template.json      # Plantilla de servidores MCP
│   ├── output-styles/batuta.md        # Estilo de salida personalizado
│   ├── commands/                      # Slash commands globales
│   │   ├── batuta-init.md             # /batuta-init — importar ecosistema
│   │   ├── batuta-update.md           # /batuta-update — actualizar
│   │   ├── batuta-analyze-prompts.md  # /batuta:analyze-prompts — analisis de satisfaccion
│   │   └── batuta-sync-skills.md      # /batuta:sync-skills — regenerar tablas de routing
│   ├── agents/                        # Agentes de scope (routing Mix-of-Experts)
│   │   ├── pipeline-agent.md          # Especialista SDD Pipeline (9 skills)
│   │   ├── infra-agent.md             # Especialista infraestructura (3 skills)
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
│       └── skill-sync/               # Generacion automatica de tablas de routing
│           ├── SKILL.md
│           └── assets/
│               ├── sync.sh
│               └── sync_test.sh
├── about/                             # Documentacion de arquitectura y diseno
│   ├── arquitectura-diagrama.md       # Diagramas Mermaid de arquitectura (9 diagramas)
│   └── arquitectura-para-no-tecnicos.md # Arquitectura sin tecnicismos (analogia restaurante)
├── guides/                            # Guias de ejecucion paso a paso (Espanol)
│   ├── guia-batuta-app.md             # Dashboard app — guia ciclo completo
│   ├── guia-temporal-io-app.md        # Temporal.io workflows — guia ciclo completo
│   └── guia-langchain-gmail-agent.md  # Agente LangChain + Gmail — guia ciclo completo
├── qa/                                # Reportes de control de calidad
│   ├── BatutaTestCalidadV5.md         # Reporte de test de calidad v5
│   └── LogCorrecciones-V5.md         # Log de correcciones v5
├── CHANGELOG-refactor.md              # Documento de traza de refactorizaciones (v1-v5)
└── skills/                            # Scripts del repositorio
    ├── setup.sh                       # Script principal (Claude Code)
    ├── replicate-platform.sh          # Replicacion a otras plataformas (futuro)
    └── setup_test.sh                  # Tests de verificacion (23 tests)
```

---

## Como funciona

1. **CLAUDE.md** es el unico punto de entrada. Actua como un router puro usando Mix-of-Experts: clasifica el scope de cada solicitud y delega a agentes de scope especializados.
2. **setup.sh --all** sincroniza skills y agentes, ejecuta skill-sync para regenerar tablas de routing, y luego copia el CLAUDE.md actualizado a la raiz.
3. **Claude Code** lee CLAUDE.md al iniciar (~216 lineas), luego usa carga lazy de 3 niveles: agente principal → agente de scope → skill.

```
CLAUDE.md (router — ~216 lineas)
    │
    ├──> Execution Gate (validar → clasificar → rutear → logear)
    │
    ├──> pipeline-agent ──> sdd-init...sdd-archive (9 skills)
    ├──> infra-agent ──────> scope-rule, ecosystem-creator, skill-sync
    └──> observability-agent ──> prompt-tracker
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
| `infra-agent` | Organizacion de archivos, ecosistema | scope-rule, ecosystem-creator, skill-sync |
| `observability-agent` | Tracking de calidad | prompt-tracker |

Esto mantiene al agente principal liviano (~216 lineas) y a cada agente de scope enfocado en su dominio.

### Execution Gate (Puerta de Ejecucion)

Antes de cualquier cambio de codigo, una pre-validacion obligatoria se ejecuta. No se puede omitir.

| Modo | Cuando | Que muestra |
|------|--------|-------------|
| LIGHT | Edicion de un solo archivo, fix simple | "Modifico {archivo} en {ubicacion}. Procedo?" |
| FULL | Archivos nuevos, 2+ archivos, arquitectura | Plan de ubicacion + impacto + cumplimiento SDD/skills |

### Skill-Sync

Las tablas de routing en CLAUDE.md y archivos de agentes de scope se auto-generan desde los frontmatters de SKILL.md. Agregar un skill = crear SKILL.md con frontmatter → ejecutar sync.sh → tablas actualizadas automaticamente. Sin edicion manual.

### Deteccion de Skills Faltantes

Antes de escribir codigo con una tecnologia, Claude verifica si existe un skill activo. Si no existe, se detiene y ofrece investigar via Context7 y crear el skill antes de continuar.

### Carga Lazy (3 niveles)

| Nivel | Que se carga | Lineas |
|-------|-------------|--------|
| 1 | CLAUDE.md (router) | ~216 |
| 2 | Agente de scope | ~80-120 |
| 3 | Skill individual | ~200-500 |

Solo se carga el nivel necesario. Una pregunta simple nunca llega al nivel 3.

### Tracking de Satisfaccion de Prompts (O.R.T.A.)

Cada interaccion significativa se registra en `.batuta/prompt-log.jsonl`. Cinco tipos de evento: `prompt`, `gate`, `correction`, `follow-up`, `closed`. Con el tiempo, `/batuta:analyze-prompts` computa metricas y genera recomendaciones accionables.

### Continuidad de Sesion

Al inicio de cada conversacion, Claude lee `.batuta/session.md` para restaurar el contexto. Al final de trabajo significativo, actualiza el archivo para que la proxima conversacion continue donde esta termino.

### Auto-actualizacion del Ecosistema

Cuando se crean skills nuevos en un proyecto, Claude propone propagarlos de vuelta a batuta-dots para que otros proyectos se beneficien.

---

## Skills Disponibles (13 + 3 agentes de scope)

| Skill | Scope | Descripcion |
|-------|-------|-------------|
| `ecosystem-creator` | infra | Crea nuevos skills, agentes, sub-agentes y workflows |
| `scope-rule` | infra | Organiza archivos por alcance (feature / shared / core) |
| `skill-sync` | infra | Genera tablas de routing automaticamente desde frontmatters |
| `sdd-init` a `sdd-archive` | pipeline | Pipeline SDD de 9 fases |
| `prompt-tracker` | observability | Tracking de satisfaccion, compliance de gate, y analisis de patrones |

Mas 16 skills de proyecto planificados. Ver CLAUDE.md para la hoja de ruta completa.

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
| `--all` | Setup completo: sync + skill-sync + copy (recomendado) |
| `--verify` | Verificacion completa (23 checks) |

El flag `--all`: sincroniza skills y agentes → ejecuta skill-sync → copia CLAUDE.md actualizado a la raiz.

---

## Guias

Guias de ejecucion paso a paso cubriendo el ciclo completo: instalacion del ecosistema → pipeline SDD → construccion → pruebas → deploy → produccion → archive.

| Guia | Descripcion |
|------|-------------|
| [Dashboard App](guides/guia-batuta-app.md) | Construir dashboard de monitoreo (n8n + tokens Google AI) — 15 pasos |
| [Temporal.io Workers](guides/guia-temporal-io-app.md) | Construir orquestacion de workflows con Temporal.io — 14 pasos |
| [Agente LangChain + Gmail](guides/guia-langchain-gmail-agent.md) | Construir agente IA clasificador de emails — 15 pasos |

## About (Arquitectura y Diseno)

| Documento | Descripcion |
|-----------|-------------|
| [Diagramas de Arquitectura](about/arquitectura-diagrama.md) | 9 diagramas Mermaid (routing MoE, SDD, carga lazy, etc.) |
| [Arquitectura para No-Tecnicos](about/arquitectura-para-no-tecnicos.md) | Analogia del restaurante para no-desarrolladores |

---

## Contribuir

### Agregar un Skill Nuevo

1. Ejecutar `/create:skill <nombre>` — el ecosystem-creator guia el proceso (frontmatter: scope, auto_invoke, allowed-tools)
2. O manualmente: crear `BatutaClaude/skills/<nombre>/SKILL.md` con frontmatter completo
3. Ejecutar `bash BatutaClaude/skills/skill-sync/assets/sync.sh` para actualizar tablas de routing
4. Ejecutar `./skills/setup.sh --all`

### Agregar un Agente de Scope Nuevo

1. Crear `BatutaClaude/agents/<scope>-agent.md` con delimitadores `<!-- AUTO-GENERATED by skill-sync -->`
2. Actualizar frontmatters de SKILL.md para referenciar el nuevo scope
3. Ejecutar skill-sync para poblar la tabla de skills del agente

---

## Creditos

Inspirado en [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) de [Gentleman Programming](https://github.com/Gentleman-Programming). Batuta adapta el concepto de dotfiles para fabricas de software multi-proyecto con personalidad CTO/Mentor, Spec-Driven Development, Regla de Alcance, routing Mix-of-Experts, auto-deteccion de skills, y el framework O.R.T.A.

---

## Licencia

[MIT](LICENSE)
